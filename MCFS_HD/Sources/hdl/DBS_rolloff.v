`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module for a 2nd order differential filter with a high-frequency roll-down and adjustable damping, identical to DBS.v, but with a resolution of 2^(N/2) for the high-frequency roll-down and 2^N for gamma, which increases timing margin. 
// With reduced resolution on the frequency terms, it allows timing margin at 100 MS/s. Used for cavity servos in CavPID.
//
// H_DIFF(s) = (2 PI f0)^2 D s/((2 PI f0)^2 + s(gamma + s))
//
// The differential gain is D = (1+ND[1:0]/4)*2^(ND[9:2])*T/NF, [1, 1.25, 1.5, 1.75]*2^N, where N is an integer.
// The fractions are represented by the 2 LSB's of the input bit shifts, i.e., ND = {N(8 bits), Fractional Bits (2 bits)}.
//
// The high-frequency gain roll-down is f0 = SQRT[(2^(NF[9:2]))]/(2 pi T)/SQRT[1-(2^(NG[9:2]))/2-(2^(NF[9:2]))/4]
// and the damping is gamma = (2^(NG[9:2]))/T/(1-(2^(NG[9:2]))/2-(2^(NF[9:2]))/4).
//
// NF and NG give a precision is 2^N, where N is an integer.
// Normally dy will only decay to zero if dy < 0 because the minimum value of dy >>> bitshift is -1. 
// If dy > 0, dy >>> bitshift truncates to 0, and then dy never reaches zero so the output will continue to increase to the rail or limit. 
// A conditional assignment when dy >>> bitshift is less than 1 LSB make the filter stable. 
// The result is that when dy is small, it decays faster than a linear filter.
//
// The filter has overflow protection, and will hold at LL or UL if the filter exceeds those limits.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module DBS_rolloff#(parameter SIGNAL_SIZE = 25, FB = 32, OVB = 1)(
    // Clock and control signals
    input  wire clk, on, hold, is_neg,
    // Gains
    input  wire signed [9:0] ND, NF, NG,
    // Lower and upper limits
    input  wire signed [SIGNAL_SIZE-1:0] LL, UL,
    // Input and output
    input  wire signed [SIGNAL_SIZE-1:0] s_in,
    output wire signed [SIGNAL_SIZE-1:0] s_out
);

// Function to interpret 2 lsb's as fractional bits representing 0.5 and 0.25.
// Gives [1, 1.25, 1.5, 1.75]*2^N gain precision without using DSP multipliers.
function signed [SIGNAL_SIZE+FB+OVB-1:0] bs;
    input        [1:0]                    fb;
    input signed [SIGNAL_SIZE+FB+OVB-1:0] in;
    begin
        case (fb)
            2'b00:   bs = in                         ;
            2'b11:   bs = in - (in >>> {fb[0],fb[1]});
            default: bs = in + (in >>> {fb[0],fb[1]});           
        endcase
    end
endfunction

// Function to assign new output with limits; if out of range, assign upper/lower limit.
function  signed [SIGNAL_SIZE+FB+OVB-1:0] newOut;
    input signed [SIGNAL_SIZE+FB+OVB-1:0] in0;
    input signed [SIGNAL_SIZE-1:0] upperLimit, lowerLimit;
    reg   signed [SIGNAL_SIZE+FB+OVB-1:0] UL1, LL1;
    begin
        UL1 = upperLimit <<< FB;
        LL1 = lowerLimit <<< FB;
        if      (in0 > UL1) newOut = UL1[SIGNAL_SIZE+FB+OVB-1:0];
        else if (in0 < LL1) newOut = LL1[SIGNAL_SIZE+FB+OVB-1:0]; 
        else                 newOut = in0[SIGNAL_SIZE+FB+OVB-1:0];
    end
endfunction

// Function force dy to zero when dyH is less than 1 LSB so dy doesn't accumulate.
function signed [SIGNAL_SIZE+FB+OVB-1:0] Ddy;
    input signed [SIGNAL_SIZE+FB+OVB-1:0] dy_in, Ddy_in;
        
    begin
        if (dy_in[SIGNAL_SIZE+FB+OVB-1]) begin
            if (Ddy_in == 0) Ddy = 'd1;
            else             Ddy = Ddy_in;
        end
        else if (dy_in > 0) begin
            if (Ddy_in == 0) Ddy = -'d1;
            else             Ddy = Ddy_in;
        end
        else Ddy = 'd0;
    end
endfunction

// Assign fractional bits and the integer bit shift gain.
reg [1:0] bD;
reg signed [9:0] gF, gG, gD;
always @(posedge clk) begin
    // Fractional bits
    bD <= ND[1:0];
    // 2^g part of gain and cutoff frequency and damping
    gF <= (NF + 10'sb1) >>> 2;
    gG <= (NG + 10'sb1) >>> 2;
    gD <= (ND + 10'sb1) >>> 2; // This gives the integer bit shift, rounding up for the case of 1.75.
end

// Combine on and hold into one 2-bit control signal for the enable logic. 
wire [1:0] ONHOLD;
assign ONHOLD = {on, hold};
// Declaration of integer bit shifts
reg signed [9:0] sD, sF, sG;
// Input.
reg signed [SIGNAL_SIZE-1:0] x0;

reg  signed [SIGNAL_SIZE+FB+OVB-1:0] y0, y1; // Current output of filter, output from one cycle ago
// dy is the difference of subsequent outputs, and yNew is y0 with the overflow function applied.
wire signed [SIGNAL_SIZE+FB+OVB-1:0] dy, yNew;
assign dy = yNew-y1;

// Limit the filter output.
assign yNew = newOut(y0, UL, LL);
assign s_out = yNew[SIGNAL_SIZE+FB-1:FB];

// Calculate IIR terms
wire signed [SIGNAL_SIZE+FB+OVB-1:0] 
    y0F, y0G, dyG, x0D,
    dyG_int0, x0D_int0;
reg signed [SIGNAL_SIZE+FB+OVB-1:0] y1G, x1D, x2D;
// Frequency term, with rounding.
reg signed [SIGNAL_SIZE+FB-1:0] mRnd0 = 0, mRnd = 0, Rnd0 = 0, Rnd = 0;
assign y0F = (yNew<0)?((-yNew+mRnd)>>>sF):(-((yNew+Rnd)>>>sF)); // This is a right bit shift, negative sF (positive NF) results in 0 for this term.
// Linewidth term with rounding.
reg signed [SIGNAL_SIZE+FB-1:0] gRnd0 = 0, gRnd = 0;
assign y0G      = -((yNew+gRnd)>>>sG);
assign dyG_int0 = y0G+y1G;
// This conditional assignment makes dy decay to zero when the bit shifted dy is small, otherwise the output keeps accumulating.
assign dyG      = Ddy(dy, dyG_int0);
// If sD < 0, the term below is zero.
assign x0D_int0 = x0<<<sD;
assign x0D      = bs(bD, x0D_int0); // Fractional bits

always @(posedge clk) begin
    // Calculate the total bit shifts
    // Flip sign on right bit shifts; a more negative NF gives a smaller cut-off frequency, and a more negative NG gives smaller damping.
    sF <= -gF; 
    sG <= -gG; 
    sD <=  gD;
    // Pipeline rounding
    mRnd0 <= -1<<<(sF-1);
    mRnd <= mRnd0;
    Rnd0 <= 1<<<(sF-1);
    Rnd <= Rnd0;
    gRnd0 <= 1<<<(sG-1);
    gRnd <= gRnd0;
    // Bit-shift-add to get next filter output from new input and previous inputs and outputs
    case(ONHOLD)
        // If filter is on and not holding:
        2'b10: begin
            // Retain input and output values. IF for filter sign.
            if (is_neg) x0 <= -s_in;
            else        x0 <=  s_in;
            x1D <= x0D;
            x2D <= -x1D;
            y1G <= -y0G;
            ////// GENERATE NEXT OUTPUT \\\\\\
            // a0 = 2-sF-sG, a2 = -1+sG, 
            // b0 = sD*sF/2, b1 = 0, b2 = -sD*sF/2
            y0 <= yNew + yNew + y0F - y1 + dyG + x0D + x2D;
            // Retain old output
            y1 <= yNew;
        end
        // If filter is on and holding:
        2'b11: begin
            // Retain input and output values. if for filter sign.
            if (is_neg) x0 <= -s_in;
            else        x0 <=  s_in;
            x1D <= x1D;
            x2D <= x2D;
            y1G <= y1G;
            y0  <= y0; 
            y1  <= y1;
        end
        // If not on, output zeros
        default: begin
            x0  <= 'd0;
            x1D <= 'd0;
            x2D <= 'd0;
            y1G <= 'd0;
            y0  <= 'd0;
            y1  <= 'd0;
        end
    endcase
end
    
endmodule