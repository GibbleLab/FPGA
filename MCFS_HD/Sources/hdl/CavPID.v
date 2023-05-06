`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module for fast PID servo, used for cavity locks. 
// To help the PID's meet timing at 100 MS/s in the full design,
// it uses I1BS_rolloff.v and DBS_rolloff.v, which have 2^N frequency shifts, and P1BS_nornd.v, which has 1.25 resolution for the frequency shift, but no rounding on the frequency term.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module CavPID#(
    parameter [31:0] 
        FILTER_IO_SIZE = 25, // Filter input/output word length.
        ISCALING       = 32, // Number of fractional bits for each filter I, P, D.
        PSCALING       = 32, 
        DSCALING       = 26
)(
    input wire 
        clk, on, hld, is_neg,  // clk, PID on, hold, and filter sign signals
    input wire signed [9:0]    // PID gain bitshifts
        NFI, NI, NFP, NP, ND, NFD, NGD,
    input wire signed [FILTER_IO_SIZE-1:0] 
        LL, UL, // PID limits
        s_in,   // input to filter
    output wire signed [FILTER_IO_SIZE-1:0] s_out, // PID output           
                                            s_out_Int // Integrator output (for slow integrator when using low range DAC output for PID output) 
);

// PID filter outputs.
reg  signed [FILTER_IO_SIZE + 1:0] s_out0, s_out0_0, s_out0_1; // The current s_out; there are multiple s_out0's for pipelined addition to have timing margin with a 100 MHz clock.
wire signed [FILTER_IO_SIZE - 1:0] s_out_I, s_out_P, s_out_D; // Output for each filter.
// Integrator (with limit from P filter to prevent integrator wind-up).
I1BS#(FILTER_IO_SIZE, ISCALING, 1)
I1BS_INST(clk, on, hld, is_neg, NFI, NI,     LL, UL, s_out_P, s_in, s_out_I);
// Proportional
P1BS#(FILTER_IO_SIZE, PSCALING, 1)
P1BS_INST(clk, on, hld, is_neg, NFP, NP,     LL, UL,          s_in, s_out_P);
// Differentiator
DBS_rolloff#(FILTER_IO_SIZE,  DSCALING, 1)
DBS_INST(clk, on, hld, is_neg, ND, NFD, NGD, LL, UL,          s_in, s_out_D);

always @(posedge clk) begin
    // Pipelining the sum for timing margin at 100 MHz.
    // I and P are lower bandwidth than D so delay P & I. 
    s_out0_0 <= s_out_I;
    s_out0_1 <= s_out0_0 + s_out_P;
    s_out0   <= s_out0_1 + s_out_D;
end

// Function to assign output, if out of range, assign upper/lower limit.
function  signed [FILTER_IO_SIZE  -1:0] newOut;
    input signed [FILTER_IO_SIZE+2-1:0] in0;
    input signed [FILTER_IO_SIZE  -1:0] upperLimit, lowerLimit;
    reg   signed [FILTER_IO_SIZE+2-1:0] UL1, LL1;
    begin
        UL1 = upperLimit;
        LL1 = lowerLimit;
        if      (in0 >= UL1) newOut = UL1[FILTER_IO_SIZE-1:0];
        else if (in0 <= LL1) newOut = LL1[FILTER_IO_SIZE-1:0]; 
        else                 newOut = in0[FILTER_IO_SIZE-1:0];
    end
endfunction

assign s_out = newOut(s_out0, UL, LL);

assign s_out_Int = s_out_I;

endmodule