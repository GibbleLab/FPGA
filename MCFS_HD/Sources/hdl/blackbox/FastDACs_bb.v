`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Blackbox for FastDACs for OOC synthesis and implementation.
//////////////////////////////////////////////////////////////////////////////////
module FastDACs(
    input wire clk_in, clk_out_in, 
    input wire signed [15:0] 
        s_in0, s_in1, s_in2, s_in3, s_in4, s_in5,
        s_in6, s_in7, s_in8, s_in9, s_in10, s_in11, s_in12, s_in13,
    output wire fDACclkB_out, fDACclkC_out,
    output wire 
        fDAC0_sel, fDAC1_sel, fDAC2_sel,
        fDAC3_sel, fDAC4_sel, fDAC5_sel, fDAC6_sel,
    output wire signed [15:0] 
    fDAC0_out, fDAC1_out, fDAC2_out,
    fDAC3_out, fDAC4_out, fDAC5_out, fDAC6_out
);  

endmodule