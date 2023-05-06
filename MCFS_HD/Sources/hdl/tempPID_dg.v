`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module to implement PID's for variable duty cycle temperature servos with filter outputs for ILA debugging.
// An overall multiplicative gain allows adjustment when PID gains (and frequencies) are fixed, e.g., to use fewer resources.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module tempPID_dg#(
    parameter [31:0] 
        FILTER_IO_SIZE = 18, // I/O length for PID filters
        ISCALING       = 28, // Internal scaling for PID filters
        PSCALING       = 12, 
        DSCALING       = 22,
        multBits       = 7 // Number of bits for multiplier coefficient
)(
    input wire 
        clk,        // 125 kHz clock
        on, is_neg, // PID on/negative gain signals
    input wire signed [9:0] // PID gain bitshifts
        NFI, NI, NFP, NP, ND, NFD, NGD,
    input wire signed [multBits-1:0] errmult, // Multiplier coefficient
    input wire signed [FILTER_IO_SIZE-1:0] 
        LL, UL, // PID limits, with prst, determine the range of duty-cycles
        s_in, // Input to PID
    output reg  signed [FILTER_IO_SIZE  -1:0] NH,  // PID output, with overflow protection 
    output wire signed [15:0] NHpre_dg, NHi_dg, NHp_dg, NHd_dg, NHpost_dg // Outputs for debug
);

// The filter outputs (I, P, D) are summed, multiplied by errmult, and then limited.
// The post-PID multiplier has a range of 1/4 to 2 with a resolution of 1/16 (2 fractional bits) so errmult = 16 yields a multipler gain of 1.
// The sum of the PID filter outputs, before the multiplier, is limited to 4*[LL, UL]. 
// The multiplier output after multiplication, NH, is limited to 0 to 100,000.
localparam ovr = 2, fb = 2; // ovr is the number of MSB overflow bits. 2 bits allow filter outputs to go to 400,000. fb is the number of fractional bits retained to round the sum of the filter outputs before truncating.
localparam lenIO = ovr + FILTER_IO_SIZE + fb;
// PID filter that outputs NH, the number of 100 MHz cycles that the VDC output should be high. 
// The output of the PID could also be connected to a DAC output.
reg  signed [2+lenIO            -1:0] NH0; // Sum with overflow bits
reg  signed [2+lenIO         -fb-1:0] NH1; // Truncated sum after rounding, retaining overflow bits
reg  signed [2+lenIO+multBits-fb-1:0] NH2; // Multiplied, truncated sum
wire signed [lenIO  -1:0] NHp, NHi, NHd; // Output for each filter.
// Scale to account for the 2 extra filter IO bits.
wire signed [lenIO-1:0] LLin, ULin;
wire signed [lenIO-1:0] sig_in;
assign LLin = LL <<< (ovr+fb);
assign ULin = UL <<< (ovr+fb);
assign sig_in = s_in <<< fb; 
// Integral
I1BS#(lenIO,  ISCALING, 1)
I1BS_INST(clk, on, 1'b0, is_neg, NFI, NI,       LLin, ULin, NHp, sig_in, NHi);
// Proportional
P1BS#(lenIO,  PSCALING, 1)
P1BS_INST(clk, on, 1'b0, is_neg, NFP, NP,       LLin, ULin,      sig_in, NHp);
// Differential
DBS#(lenIO, DSCALING, 1)
DBS_INST(clk, on, 1'b0, is_neg, ND, NFD, NGD, LLin, ULin,      sig_in, NHd);

// Function to assign a new output; if the input is out-of-range, assign the upper/lower limit to newOut.
function  signed [FILTER_IO_SIZE-1:0] newOut;
    input signed [2+lenIO+multBits-fb-1:0] in0;
    input signed [FILTER_IO_SIZE-1:0] upperLimit, lowerLimit;
    reg   signed [2+lenIO+multBits-fb-1:0] UL1, LL1;
    begin
        UL1 = upperLimit;
        LL1 = lowerLimit;
        if      ((in0>>>4) >= UL1) newOut = UL1;
        else if ((in0>>>4) <= LL1) newOut = LL1; 
        else                       newOut = in0>>>4;
    end
endfunction

always @(posedge clk) begin
    if (on) begin
        NH0 <= NHi + NHp + NHd + 2'sb10; // Add all 3 filter outputs, 2 "fractional LSB's and 2'b10 gives correct rounding for the following truncation.
        NH1 <= NH0>>>fb;                 // Truncate fractional bits after rounding.
        NH2 <= NH1*errmult;              // Overall gain multiplier 
        NH <= newOut(NH2, UL, LL);       // Apply limits and output a word with length FILTER_IO_SIZE.
    end
    else begin
        NH0 <= 0;
        NH1 <= 0;
        NH2 <= 0;
        NH  <= 0;
    end
end

assign NHpre_dg  = NH0[16+fb-1:fb];
assign NHi_dg    = NHi[16+fb-1:fb];
assign NHp_dg    = NHp[16+fb-1:fb];
assign NHd_dg    = NHd[16+fb-1:fb];
assign NHpost_dg = NH[15:0];

endmodule