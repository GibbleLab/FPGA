`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Blackbox module for OOC synthesis and implementation
//////////////////////////////////////////////////////////////////////////////////

module SlowADCs#(parameter [6:0] N = 100, N_CNV = 5, N_CH=24)(// N = Number of clock cycles between conversions (1 us minimum)
    // Clocks and reset                                       // N_CNV = number of clock cycles to hold CNV high (40-60 ns), and number of channels in conversion sequence
    input wire clk,
               data_in_clk, 
               rst, 
    // SPI wires
    input  wire sADC_SCKO0_in,
                sADC_SCKO1_in,
                sADC_SDO0_in,
                sADC_SDO1_in,
                sADC_BUSY0_in, 
                sADC_BUSY1_in, 
    output wire sADC_CNV_out,
                sADC_SCKI_out, 
                sADC_SDI_out, 
                sADC_CS0_out, 
                sADC_CS1_out, 
    // Channel sequence
    input  wire [2:0] SEQ [0:N_CH-1],
    output wire signed [15:0] s_in_0, s_in_1, s_in_2,  s_in_3,  s_in_4,  s_in_5,  s_in_6,  s_in_7, 
                              s_in_8, s_in_9, s_in_10, s_in_11, s_in_12, s_in_13, s_in_14, s_in_15
);

endmodule