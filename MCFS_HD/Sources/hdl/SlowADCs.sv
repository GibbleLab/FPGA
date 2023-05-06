`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module to read both LTC2335-16 8-channel 1MSPS ADC's, transferring 2 channels of data per conversion cycle.
// 
// Daniel Schussheim
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

// Signal declarations
     // INPUTS
wire sADC_SDO0, sADC_SDO1, sADC_BUSY0, sADC_BUSY1,
     // OUTPUTS + DUMMY VARIABLES
     sADC_SCKI, sADC_CNV, sADC_SDI, sADC_CS0, sADC_CS1,
     sADC_SCKI_dum, sADC_CNV_dum, sADC_SDI_dum, 
     sADC_SCKI_in;

// Input and output buffers

//*********** INPUTS ***********\\
// IBUF: Single-ended Input Buffer
(* DONT_TOUCH = "TRUE" *)IBUF#(.IBUF_LOW_PWR("FALSE"), .IOSTANDARD("LVCMOS33"))IBUF_BUSY0(sADC_BUSY0, sADC_BUSY0_in);
(* DONT_TOUCH = "TRUE" *)IBUF#(.IBUF_LOW_PWR("FALSE"), .IOSTANDARD("LVCMOS33"))IBUF_BUSY1(sADC_BUSY1, sADC_BUSY1_in);
wire sADC_SDO0_int, sADC_SDO1_int;
(* DONT_TOUCH = "TRUE" *)IBUF#(.IBUF_LOW_PWR("FALSE"), .IOSTANDARD("LVCMOS33"))IBUF_SDO0 (sADC_SDO0, sADC_SDO0_in);
(* DONT_TOUCH = "TRUE" *)IBUF#(.IBUF_LOW_PWR("FALSE"), .IOSTANDARD("LVCMOS33"))IBUF_SDO1 (sADC_SDO1, sADC_SDO1_in);

//*********** OUTPUTS ***********\\
wire sADC_SCKI_int;
// OBUF: Single-ended Output Buffer
(* DONT_TOUCH = "TRUE" *)OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW"))OBUF_CNV (sADC_CNV_out , sADC_CNV);
(* DONT_TOUCH = "TRUE" *)OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW"))OBUF_SDI (sADC_SDI_out , sADC_SDI);
(* DONT_TOUCH = "TRUE" *)OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW"))OBUF_CS0 (sADC_CS0_out , sADC_CS0);
(* DONT_TOUCH = "TRUE" *)OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW"))OBUF_CS1 (sADC_CS1_out , sADC_CS1);
(* DONT_TOUCH = "TRUE" *)OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW"))OBUF_SCKI (sADC_SCKI_out , sADC_SCKI_int);
// Output clock
wire SCK_en;
(* DONT_TOUCH = "TRUE" *)
ODDR #("OPPOSITE_EDGE", 1'b0, "SYNC") 
ODDR_sADC_SCKI (sADC_SCKI_int, clk, SCK_en, 1'b1, 1'b0, 1'b0, 1'b0);

// Module declarations
// Combined BUSY for both chips - must be LOW to transfer SPI data.
wire sADC_BUSY;
assign sADC_BUSY = sADC_BUSY0 | sADC_BUSY1;

wire [23:0] data_out0, 
            data_out1; 
wire        ready_out,
            CNVtog_out;
wire [2:0]  state_out;

LTC2335_16 #(N, N_CNV, N_CH)
slow_ADC_inst(clk, data_in_clk, rst, 
    sADC_SDO0, sADC_SDO1, sADC_BUSY, sADC_SCKO0, sADC_SCKO1, 
    sADC_CNV, sADC_CS0, sADC_CS1, sADC_SCKI_in, sADC_SDI, SEQ,
    s_in_0, s_in_1, s_in_2,  s_in_3,  s_in_4,  s_in_5,  s_in_6,  s_in_7,
    s_in_8, s_in_9, s_in_10, s_in_11, s_in_12, s_in_13, s_in_14, s_in_15,
    SCK_en, data_out0, data_out1,
    ready_out, CNVtog_out, state_out
);

endmodule