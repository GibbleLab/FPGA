`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Variant of P1BS.v module for a 1st order proportional filter with a high frequency cutoff.
// It has more timing margin than P1BS.v, by omitting the LSB rounding of the rolloff frequency contribution to the filter output while retaining 25% resolution of the rolloff frequency.
//
// H_PROP(s) = P/(1 + s/wH).
//
// This filter has proportional gain, P = (1+NP[1:0]/4)*2^(NP[9:2])/((1+NF[1:0]/4)*2^(NF[9:2])), [1, 1.25, 1.5, 1.75]*2^N, where N is an integer.
// The fractions are represented by the 2 LSB's of the input bit shifts, i.e., NF = {N(8 bits), Fractional Bits (2 bits)}.
// 
// The high-frequency gain cutoff is wF = 2 ((1+NF[1:0]/4)*2^(NF[9:2]))/(T*(2-((1+NF[1:0]/4)*2^(NF[9:2]))))
//
// If -4(SIGNAL_SIZE + FB) < NF <= 0, the filter has a low-frequency cutoff, otherwise the filter is purely integral gain. 
//
// The filter has overflow protection, and will hold at LL or UL if the filter exceeds those limits.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module P1BS_nornd#(parameter SIGNAL_SIZE = 25, FB = 32, OVB = 2)(
    // Clock and control signals
    input  wire clk, on, hold, is_neg,
    // Gains
    input  wire signed [9:0] NF, NP,
    // Lower and upper limits
    input  wire signed [SIGNAL_SIZE-1:0] LL, UL,
    // Input and output
    input  wire signed [SIGNAL_SIZE-1:0] s_in,
    output wire signed [SIGNAL_SIZE-1:0] s_out
);

// Function to interpret 2 lsb's as fractional bits representing 0.5 and 0.25.
// Gives [1, 1.25, 1.5, 1.75]*2^N gain precision without using DSP multipliers.
function signed [SIGNAL_SIZE+FB-1:0] bs;
    input        [1:0]                     fb;
    input signed [SIGNAL_SIZE+FB-1:0] in;
        
    begin
        case (fb)
            2'b00:   bs = in                         ;
            2'b11:   bs = in - (in >>> {fb[0],fb[1]});
            default: bs = in + (in >>> {fb[0],fb[1]});           
        endcase
    end
endfunction

// Function to assign new output with limits; if out of range, assign upper/lower limit.
function signed [SIGNAL_SIZE+FB-1:0] newOut;
    input signed [SIGNAL_SIZE+FB+OVB-1:0] in0;
    input signed [SIGNAL_SIZE-1:0] upperLimit, lowerLimit;
    reg   signed [SIGNAL_SIZE+FB+OVB-1:0] UL1, LL1;
    begin
        UL1 = upperLimit <<< FB;
        LL1 = lowerLimit <<< FB;
        if      (in0 > UL1) newOut = UL1[SIGNAL_SIZE+FB-1:0];
        else if (in0 < LL1) newOut = LL1[SIGNAL_SIZE+FB-1:0]; 
        else                 newOut = in0[SIGNAL_SIZE+FB-1:0];
    end
endfunction

// Assign fractional bits and the integer bit shift gain.
reg [1:0] bF, bP;
reg signed [9:0] gF, gP;
always @(posedge clk) begin
    // Fractional bits
    bF <= NF[1:0];
    bP <= NP[1:0]; 
    // 2^g part of gain and cutoff frequency
    gF <= (NF + 10'sb1) >>> 2;
    gP <= (NP + 10'sb1) >>> 2;
end

// Combine on and hold into one 2-bit control signal for the enable logic. 
wire [1:0] ONHOLD;
assign ONHOLD = {on, hold};
// Declaration of integer bit shifts
reg signed [9:0] sF, sP;
// Inputs and sum of subsequent inputs.
reg signed [SIGNAL_SIZE-1:0] x0, x1;
wire signed [SIGNAL_SIZE:0] sx;
assign sx = x0 + x1;

// Filter output from one cycle ago
reg  signed [SIGNAL_SIZE+FB-1:0] y1;
// Current filter output.
reg  signed [SIGNAL_SIZE+FB+OVB-1:0] y0; 
// Newest output after the overflow condition is applied.
wire signed [SIGNAL_SIZE+FB-1:0] yNew;

// Limit filter output.
assign yNew = newOut(y0, UL, LL);
assign s_out = yNew[SIGNAL_SIZE+FB-1:FB];

// Calculate IIR terms
wire signed [SIGNAL_SIZE+FB-1:0] 
    y0F, sxP,
    y0F_int0, sxP_int0;
// Frequency term, with rounding.
// assign y0F_int0 = (yNew<0)?((-yNew-(1<<<(sF-1)))>>>sF):(-((yNew+(1<<<(sF-1)))>>>sF)); // This is a right bit shift, negative sF (positive NF) results in 0 for this term.
// Frequency term, without rounding.
assign y0F_int0 = (yNew<0)?((-yNew)>>>sF):(-((yNew)>>>sF)); // This is a right bit shift, negative sF (positive NF) results in 0 for this term.
assign y0F = bs(bF, y0F_int0); // Fractional bits
// Sum of inputs term for P gain.
assign sxP_int0 = sx<<<sP; 
assign sxP      = bs(bP, sxP_int0); // Fractional bits

always @(posedge clk) begin
    // Calculate the total bit shift 
    // Flip sign of NF; a more negative NF gives a smaller cut-off frequency.
    sF <= -gF; 
    sP <=  gP;
    // Bit-shift-add to get next filter output from new input and previous inputs and outputs
    case(ONHOLD)
        // If filter is on and not holding:
        2'b10: begin
            // Retain input values. IF for filter sign.
            if (is_neg) x0 <= -s_in;
            else        x0 <=  s_in;
            x1 <= x0;
            ////// GENERATE NEXT OUTPUT \\\\\\
            // a1 = 1-wH*T, 
            // b0 = b1 = P*wH*T/2
            if (NF > 0) y0 <= -yNew       + sxP; // If NF > 0, go to the wH = infinity case i.e. H_PROP(s) = P.
            else        y0 <=  yNew + y0F + sxP; // Otherwise keep the low-frequency cutoff term.
            // Retain old output
            y1 <= yNew;
        end
        // If filter is on and holding:
        2'b11: begin
            // Retain input values. IF for filter sign.
            if (is_neg) x0 <= -s_in;
            else        x0 <=  s_in;
            x1 <= x0;
            y0 <= y0; 
            y1 <= y1;
        end
        // If not on, output zeros
        (2'b00): begin
            x0  <= 'd0;
            x1  <= 'd0;
            y0  <= 'd0;
            y1  <= 'd0;
        end
        (2'b01): begin
            x0  <= 'd0;
            x1  <= 'd0;
            y0  <= 'd0;
            y1  <= 'd0;
        end
    endcase
end
    
endmodule