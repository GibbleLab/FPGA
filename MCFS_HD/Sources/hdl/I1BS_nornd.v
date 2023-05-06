`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Variant of I1BS.v module for 1st order integral filter with low frequency gain cutoff.
// It has more timing margin than I1BS.v, by omitting the LSB rounding of the cutoff frequency contribution to the filter output while retaining 25% resolution of the low frequency gain cutoff frequency.
//
// H_INT(s) = I/(wL + s).
//
// This filter has integral gain I = (1+NI[1:0]/4)*2^(NI[9:2])/T, [1, 1.25, 1.5, 1.75]*2^N, where N is an integer.
// The fractions are represented by the 2 LSB's of the input bit shifts, i.e., NF = {N(8 bits), Fractional Bits (2 bits)}.
// 
// The low-frequency gain cutoff wL = 2 ((1+NF[1:0]/4)*2^(NF[9:2]))/(T*(2-((1+NF[1:0]/4)*2^(NF[9:2])))).
//
// If -4(SIGNAL_SIZE + FB) < NF <= 0, the filter has a low-frequency cutoff, otherwise the filter is purely integral gain. 
// 
// The filter has overflow protection and will hold at LL or UL if the filter exceeds those limits.
//
// The limits can include the output of the P filter s_P, to prevent integrator wind-up for large error signals.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module I1BS_nornd#(parameter SIGNAL_SIZE = 25, FB = 32, OVB = 2)(
    // Clock and control signals
    input  wire clk, on, hold, is_neg,
    // Gains
    input  wire signed [9:0] NF, NI,
    // Lower and upper limits and input from the P filter
    input  wire signed [SIGNAL_SIZE-1:0] LL, UL, s_P,
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
    input signed [SIGNAL_SIZE+FB+OVB-1:0]  in0;
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
reg [1:0] bF, bI;
reg signed [9:0] gF, gI;
always @(posedge clk) begin
    // Fractional bits
    bF <= NF[1:0];
    bI <= NI[1:0]; 
    // 2^g part of gain and cutoff frequency
    gF <= (NF + 10'sb1) >>> 2;
    gI <= (NI + 10'sb1) >>> 2;
end

// Combine on and hold into one 2-bit control signal for the enable logic. 
wire [1:0] ONHOLD;
assign ONHOLD = {on, hold};
// Declaration of integer bit shifts
reg signed [9:0] sF, sI;
// Inputs and sum of subsequent inputs.
reg signed [SIGNAL_SIZE-1:0] x0, x1;
wire signed [SIGNAL_SIZE:0] sx;
assign sx = x0 + x1;

// Filter output from one cycle ago
reg  signed [SIGNAL_SIZE+FB-1:0] y1;
// Current filter output.
reg  signed [SIGNAL_SIZE+FB+OVB-1:0] y0; 
// Current output after the overflow condition is applied.
wire signed [SIGNAL_SIZE+FB-1:0] yNew;

// Limit the sum of P & I to the upper and lower limits. 
reg signed [SIGNAL_SIZE-1:0] UL0, LL0;
assign yNew = newOut(y0, UL0, LL0);
assign s_out = yNew[SIGNAL_SIZE+FB-1:FB];

// Calculate IIR terms
wire signed [SIGNAL_SIZE+FB-1:0] 
    y0F, sxI,
    y0F_int0, sxI_int0;
// Frequency term, with rounding.
// assign y0F_int0 = (yNew<0)?((-yNew-(1<<<(sF-1)))>>>sF):(-((yNew+(1<<<(sF-1)))>>>sF)); // This is a right bit shift so negative sF (positive NF) gives y0F_int0 = 0.
// Frequency term, without rounding.
assign y0F_int0 = (yNew<0)?((-yNew)>>>sF):(-(yNew>>>sF)); // This is a right bit shift, negative sF (positive NF) gives y0F_int0 = 0.
assign y0F = bs(bF, y0F_int0); // Fractional bits
// Sum of inputs term for I gain.
assign sxI_int0 = sx<<<sI;
assign sxI      = bs(bI, sxI_int0); // Fractional bits

// Save old values of s_P to help meet timing. s_P changes slowly in the regime where the integrator hits a rail.
reg signed [SIGNAL_SIZE-1:0] s_P0, s_P1;

always @(posedge clk) begin
    // Pipeline to help meet timing
    s_P0 <= s_P;
    s_P1 <= s_P0;
    // Limit the sum of P & I to the upper and lower limits.
    if (s_P1<0) begin
        UL0 <= UL;
        LL0 <= LL - s_P1;
    end
    else begin
        UL0 <= UL - s_P1;   
        LL0 <= LL;
    end       
    // Calculate the total bit shifts 
    // Flip sign of NF; a more negative NF gives a smaller cut-off frequency.
    sF <= -gF; 
    sI <=  gI;
    // Bit-shift-add to get next filter output from new input and previous inputs and outputs
    case(ONHOLD)
        // If filter is on and not holding:
        2'b10: begin
            // Retain input values. IF for filter sign.
            if (is_neg) x0 <= -s_in;
            else        x0 <=  s_in;
            x1 <= x0;
            ////// GENERATE NEXT OUTPUT \\\\\\
            // a1 = 1-wL*T, 
            // b0 = b1 = I*T/2
            y0 <= yNew + y0F + sxI;
            // Retain old output
            y1 <= y0;
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