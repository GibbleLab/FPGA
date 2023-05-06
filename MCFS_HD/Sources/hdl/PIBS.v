`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module for a 2nd order proportional and integral filter with a low-frequency 
// integral cap, and a high-frequency roll-down. 
// H_PI(s) = (I + Ps)/(s^2/(2 PI fH) + s + (2 PI fL))
//
// This filter has gains/frequencies of [1, 1.25, 1.5, 1.75]*2^N, where N is an integer.
// The fractions are represented by the 2 LSBs of the input bit shifts, i.e.
// NH = {N(8 bits), Fractional Bits (2 bits)}.
// It has timing margin at 100 MS/s.  
// 
// The proportional gain is P = (1+NP[1:0]/4)*2^(NP[9:2])/((1+NH[1:0]/4)*2^(NH[9:2])), 
// The integral gain is I = (1+NI[1:0]/4)*2^(NI[9:2])/(T*(1+NH[1:0]/4)*2^(NH[9:2])),
// The low-frequency gain cutoff is wL = ((1+NL[1:0]/4)*2^(NL[9:2]))/T,
// and the high-frequency cufoff is 
// 4*((1+NH[1:0]/4)*2^(NH[9:2]))/(T(2*((1+NH[1:0]/4)*2^(NH[9:2]))+((1+NH[1:0]/4)*2^(NH[9:2]))*((1+NL[1:0]/4)*2^(NL[9:2]))-4))
//
// If -4(SIGNAL_SIZE + FB) < NL the filter has a low frequency gain cutoff.
// If NH <= 0 the filter has a high-frequency roll off. 
// 
// Normally dy will only decay to zero if dy < 0 because the minimum value of dy >>> bitshift is -1. 
// If dy > 0, dy >>> bitshift truncates to 0, and then dy never reaches zero so the output will continue to increase to the rail or limit. 
// A conditional assignment when dy >>> bitshift is less than 1 LSB make the filter stable. 
// The result is that when dy is small, it decays faster than a linear filter.
//
// The filter has overflow protection, and will hold at LL or UL if the filter exceeds those limits.
// Note: Adding the outputs of P1BS and I1BS used fewer resources and had more timing margin.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////
module PIBS#(parameter SIGNAL_SIZE = 25, FB = 32, OVB = 1)(
    // Clock and control signals
    input  wire clk, on, hold, is_neg,
    // Gains
    input  wire signed [9:0] NH, NL, NP, NI,
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
        if      (in0 >= UL1) newOut = UL1[SIGNAL_SIZE+FB+OVB-1:0];
        else if (in0 <= LL1) newOut = LL1[SIGNAL_SIZE+FB+OVB-1:0]; 
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
reg [1:0] bH, bL, bP, bI;
reg signed [9:0] gH, gL, gP, gI;
always @(posedge clk) begin
    // Fractional bits
    bH <= NH[1:0];
    bL <= NL[1:0];
    bP <= NP[1:0];
    bI <= NI[1:0];
    // 2^g part of gain and frequency
    gH <= (NH + 10'sb1) >>> 2;
    gL <= (NL + 10'sb1) >>> 2;
    gP <= (NP + 10'sb1) >>> 2;
    gI <= (NI + 10'sb1) >>> 2; 
end

// Combine on and hold into one 2-bit control signal for the enable logic. 
wire [1:0] ONHOLD;
assign ONHOLD = {on, hold};
// Declaration of integer bit shifts
reg signed [9:0] sH, sL, sP, sI;
// Input.
reg signed [SIGNAL_SIZE-1:0] x0;

reg  signed [SIGNAL_SIZE+FB+OVB-1:0] y0, y1; // Current output of filter, output from one cycle ago
wire signed [SIGNAL_SIZE+FB+OVB-1:0] dy, yNew; // dy is the difference of subsequent outputs, and yNew is y0 with the overflow function applied.
assign dy = yNew-y1;

// Limit the filter output.
assign yNew = newOut(y0, UL, LL);
assign s_out = yNew[SIGNAL_SIZE+FB-1:FB];

// Calculate IIR terms
wire signed [SIGNAL_SIZE+FB+OVB-1:0] 
    y0L_int0, y0L, 
    y0H_int0, y0H, dyH_int0, dyH, 
    x0P_int0, x0P, x0I_int0, x0I;
reg signed [SIGNAL_SIZE+FB+OVB-1:0] 
    y1H, 
    x1P, x2P, 
    x1I, x2I;
// Integral gain cap, with rounding.
assign y0L_int0 = (yNew<0)?((-yNew-(1<<<(sL-1)))>>>sL):(-((yNew+(1<<<(sL-1)))>>>sL));
assign y0L = bs(bL, y0L_int0); // Fractional bits.
// High-frequency roll down term, with rounding.
assign y0H_int0 = -((yNew+(1<<<(sH-1)))>>>sH);
assign y0H = bs(bH, y0H_int0); // Fractional bits.
assign dyH_int0 = y0H + y1H;
// This conditional assignment makes dy decay to zero when the bit shifted dy is small, otherwise the output keeps accumulating.
assign dyH = Ddy(dy, dyH_int0); 
// If (sP-2) or sI < 0, these terms are zero.
assign x0P_int0 = (x0<<<(sP-2));    // Proportional gain
assign x0P      = bs(bP, x0P_int0); // Fractional bits.
assign x0I_int0 = (x0<<<sI);        // Integral gain
assign x0I      = bs(bI, x0I_int0); // Fractional bits

always @(posedge clk) begin
    // Calculate the total bit shifts
    // Flip sign on right bit shifts; a more negative sH or sL gives a smaller integral gain cap or cutoff frequency.
    sH <= -gH;
    sL <= -gL;
    sP <= FB+gP;
    sI <= FB+gI;
    // Bit-shift-add to get next filter output from new input and previous inputs and outputs
    case(ONHOLD)
        // If filter is on and not holding:
        2'b10: begin
            // Retain input values. if for filter sign.
            if (is_neg) x0 <= -s_in;
            else        x0 <=  s_in;
            ////// GENERATE NEXT OUTPUT \\\\\\
            // a0 = 2 - sH - sL, a2 = -1 + sH, 
            // b0 = (sP x sH)/2 + sI/4, b1 = sI/2, b2 = -(sP x sH)/2 + sI/4
            y0  <= yNew + y0L + (yNew - y1) + dyH + (x0P - x2P) + (x0I>>>1 + x2I) + x0I;
            // Retain bit shifted inputs and outputs.
            x1P <= x0P;
            x2P <= x1P;
            x1I <= x0I >>> 1; // Bit shift now, instead of doing above sum.
            x2I <= x1I;
            y1H <= -y0H;
            // Retain old output
            y1  <= yNew;
        end
        // If filter is on and holding:
        2'b11: begin
            // Retain input and output values. if for filter sign.
            if (is_neg) x0 <= -s_in;
            else        x0 <=  s_in;
            y0  <= yNew;
            x1P <= x1P;
            x2P <= x2P;
            x1I <= x1I;
            x2I <= x2I;
            y1H <= y1H;
            y1  <= y1;
        end
        // If not on, output zeros
        default: begin
            x0  <= 'd0;
            x1P <= 'd0;
            x2P <= 'd0;
            x1I <= 'd0;
            x2I <= 'd0;
            y0  <= 'd0;
            y1H <= 'd0;
            y1  <= 'd0;
        end
    endcase
end
endmodule