`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Blackbox module for OOC synthesis and implementation
//////////////////////////////////////////////////////////////////////////////////

module SlowDACs#(parameter N0 = 24, N1 = 24)(
    // Clock and reset
    input wire clk, 
    input wire rst, 
    // SPI wires
    input  wire sDAC_SDO_in,
    output wire sDAC_SCK_out,  
                sDAC0_CS_out, 
                sDAC1_CS_out, 
                sDAC_SDI_out,
    // Channel sequences for chip 0 and chip 1
    input  wire [2:0] CH0 [0:N0-1],
    input  wire [2:0] CH1 [0:N1-1],
    // Currently unused adjustable offsets for a sign-dependent, sample-rate dependent offset when overclocking the DAC's
    // input  wire signed [15:0] n0 [0:7], 
    // input  wire signed [15:0] n1 [0:7], 
    // Output signals
    input wire signed [15:0] sout0, sout1, sout2, sout3, sout4, sout5, sout6, sout7, 
                             sout8, sout9, sout10, sout11, sout12, sout13, sout14, sout15
);

endmodule