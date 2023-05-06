`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module to drive both slow LTC2666-16 DAC’s with an arbitrary channel order.
// Includes code for adjustable offsets of each channel for a sign-dependent,
// sample-rate dependent offset when overclocking (currently commented out).
// 
// Daniel Schussheim and Kurt Gibble
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

////////// Signal declarations \\\\\\\\\\
wire sDAC_SDO, sDAC0_CS, sDAC1_CS, sDAC_SCK, sDAC_SCK_int, sDAC_SDI;
wire sDAC_SDO_dum, sDAC_SCK_dum, sDAC_SDI_dum;

////////// Input and output buffers \\\\\\\\\\

//*********** INPUTS ***********\\
// IBUF: Single-ended Input Buffer
(* DONT_TOUCH = "TRUE" *)
IBUF#(.IBUF_LOW_PWR("FALSE"), .IOSTANDARD("LVCMOS33"))IBUF_SDO(sDAC_SDO, sDAC_SDO_in);

//*********** OUTPUTS ***********\\
// OBUF: Single-ended Output Buffer
(* DONT_TOUCH = "TRUE" *)OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW"))OBUF_CS0(sDAC0_CS_out, sDAC0_CS);
(* DONT_TOUCH = "TRUE" *)OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW"))OBUF_CS1(sDAC1_CS_out, sDAC1_CS);
(* DONT_TOUCH = "TRUE" *)OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW"))OBUF_SDI(sDAC_SDI_out, sDAC_SDI);
// Enable clock output sDAC_SCK when one of the CS's is low.
// Outputting sDAC_SCK directly causes a critical error.
wire SCKen;
assign SCKen = !(sDAC0_CS && sDAC1_CS); 
(* DONT_TOUCH = "TRUE" *)ODDR #("OPPOSITE_EDGE", 1'b0, "SYNC")ODDR_SCK(sDAC_SCK_int, clk, SCKen, 1'b1, 1'b0, 1'b0, 1'b0);
(* DONT_TOUCH = "TRUE" *)OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW"))OBUF_SCK(sDAC_SCK_out , sDAC_SCK_int);

////////// Module declarations \\\\\\\\\\
wire [23:0] data_out;
LTC2666x2#(N0, N1)
LTC2666x2_inst(
    clk, rst, 
    sout0, sout1, sout2,  sout3,  sout4,  sout5,  sout6,  sout7,
    sout8, sout9, sout10, sout11, sout12, sout13, sout14, sout15, 
    CH0, CH1, /*n0, n1,*/ data_out, sDAC_SDO, sDAC0_CS, sDAC1_CS, sDAC_SCK, sDAC_SDI
);
          
endmodule