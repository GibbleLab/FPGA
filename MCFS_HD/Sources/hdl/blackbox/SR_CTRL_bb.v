`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Blackbox module for OOC synthesis and implementation
//////////////////////////////////////////////////////////////////////////////////


module SR_CTRL(
    // Clocks, as for display module
input  wire RST,
    input  wire CLK_IN,
    output wire CLK_SR,
    // Controls for display module
    output reg [5:0] cnt_rst,
    output reg [4:0] bitcount,
    // active/data_active are inputs from the display that indicate if the display is initializing, 
    // or operating normally.     
    // Below only (active OR data_active) is used, which seems to always be TRUE, so these inputs can probably be eliminated without loss.   
    input  wire active,
    input  wire data_active,
    // OUTPUTS FOR EACH SHIFT-REGISTER BIT
    input  wire out0,  out1,  out2,  out3,  out4,  out5,  out6,  out7, 
                out8,  out9,  out10, out11, out12, out13, out14, out15,
                out16, out17, out18, out19, out20, out21, out22, out23,
    // INPUTS FROM SHIFT-REGISTER BITS
    output reg in0,  in1,  in2,  in3,  in4,  in5,  in6,  in7, 
               in8,  in9,  in10, in11, in12, in13, in14, in15,
               in16, in17, in18, in19, in20, in21, in22, in23,
    // SERIAL OUTPUT TO SHIFT-REGISTER
    output wire SR_OUT,
    output wire STROBE_OUT,
    // SERIAL INPUT FROM SHIFT-REGISTER
    input  wire SR_IN_INT
);

endmodule