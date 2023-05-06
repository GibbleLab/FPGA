`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Top-level module to test fast ADC clock phases, fine delays, and bit-slips.
// It is adapted from top.sv, retaining the logic necessary for the fast ADC's, 
// fast DAC's, and shift-register B outputs.
//
// Daniel Schussheim
//////////////////////////////////////////////////////////////////////////////////

module top_fADC(
    input wire clk, // 100 MHz clock
    output wire [3:0] led_out, // LEDs
    //// Fast ADC IO \\\\
    // ADC SPI IOs
    output wire fADC_SCK,
                fADC_SDI,
                fADC_CS0, 
                fADC_CS1, 
                fADC_CS2, 
                fADC_CS3,
                fADC_CS4,
    input  wire fADC_SDO,
    // Encode (clock) input for ADC's
    (* IOSTANDARD = "LVDS_25" *) // Needed for top-level implementation if FastADCsDDR is OOC - it is currently not OOC.
    output wire ENC_p,
                ENC_n,
    // Data streams
    (* IOSTANDARD = "LVDS_25" *) // Needed for top-level implementation if FastADCsDDR is OOC - it is currently not OOC.
    input wire [1:0]
        D00_p, D00_n, D01_p, D01_n,
        D10_p, D10_n, D11_p, D11_n,
        D20_p, D20_n, D21_p, D21_n,
        D30_p, D30_n, D31_p, D31_n, 
        D40_p, D40_n, D41_p, D41_n,
    // Frame "enclosing" different sets of data
    (* IOSTANDARD = "LVDS_25" *) // Needed for top-level implementation if FastADCsDDR is OOC - it is currently not OOC.
    input wire FR0_p, FR0_n,
               FR1_p, FR1_n,
               FR2_p, FR2_n,
               FR3_p, FR3_n,
               FR4_p, FR4_n,    
    //// Slow ADC IO \\\\
    output wire sADC_CNV,
    input  wire sADC_SDO0, sADC_SDO1,
    output wire sADC_SCKI, 
                sADC_SDI,
    input  wire sADC_BUSY0, sADC_BUSY1, 
    output wire sADC_CS0, sADC_CS1, 
    //// Fast DAC IO \\\\
    output wire fDACclkB, fDACclkC,
    output wire fDAC0_sel, 
    output wire signed [15:0] fDAC0_out,
    output wire fDAC1_sel, 
    output wire signed [15:0] fDAC1_out,
    output wire fDAC2_sel, 
    output wire signed [15:0] fDAC2_out,
    output wire fDAC3_sel, 
    output wire signed [15:0] fDAC3_out,
    output wire fDAC4_sel, 
    output wire signed [15:0] fDAC4_out,
    output wire fDAC5_sel, 
    output wire signed [15:0] fDAC5_out,
    output wire fDAC6_sel, 
    output wire signed [15:0] fDAC6_out,
    //// Slow DAC IO \\\\
    input  wire sDAC_SDO,
    output wire sDAC_SCK,
                sDAC_SDI,
                sDAC0_CS, sDAC1_CS,
    //// Shift register 1-bit lines \\\\
    output wire SR_STROBE, 
                SR_SCLK, 
                SR_IN,
    input  wire SR_OUT,
    // Shift register B 1-bit lines for chip Power Down's and additional digital outputs
    output wire SR_B_STROBE, 
                SR_B_SCLK, 
                SR_B_IN,
    // Connector B digital inputs or outputs.
    input  wire C12,
    input  wire A14, 
    output wire B14,
    output wire A15,
    output wire B15,
    output wire A19, 
    // Connector C digital inputs or outputs
    output wire U16,
    output wire M22,
    output wire R26,
    output wire P26,
    output wire N26,
    output wire M25,
    output wire L25, 
    output wire M26
);

////**** SIGNAL DECLARATIONS ****\\\\

//// CLOCK AND RESET DECLARATIONS \\\\  
wire clkg; // 100 MHz clock from global clock tree
wire rst;  // Signal to reset after the FPGA is reprogrammed, high for 100-200 mu s after the clock starts
wire rst0; // Optional separate MMCM reset of clock managers
// Clock dividers, phases, MMCM locations, and names.
parameter real 
    div0 = 8,    div1 = 8, div2 = 4, div3 = 2,   div4 = 2,  div5 = 4, div6 = 4,
    phs0 = 22.5, phs1 = 0, phs2 = 0, phs3 = 315, phs4 = 90, phs5 = 0, phs6 = 123.75;
parameter mmcm0loc = "MMCME2_ADV_X1Y2";
wire clk100_out, clk100, clk200, clk400, clk400B, fDAC_clk, fDAC_clk_out; // Output from BUFG's.
wire clk100_out_int, clk100_int, clk200_int, clk400_int, clk400B_int; // Pre-buffered clock signals.

//// FAST ADC'S \\\\
(* keep = "true" *)wire signed [15:0] f_in_0, f_in_1, f_in_2, f_in_3, f_in_4, f_in_5, f_in_6, f_in_7, f_in_8, f_in_9; // 16-bit data
(* keep = "true" *)wire [7:0] fr0_out, fr1_out, fr2_out, fr3_out, fr4_out; // Deserialized FRAME for each fast ADC, nominally 8'b11110000
wire ADCOFF; // Signal to trigger SPI programming to put all fast ADC's in sleep mode.

//// FAST DAC'S \\\\
// Inputs to DAC's
(* keep = "true" *)wire signed [15:0]
    f_out_0, f_out_1, f_out_2, f_out_3, f_out_4, f_out_5, 
    f_out_6, f_out_7, f_out_8, f_out_9, f_out_10, f_out_11, f_out_12, f_out_13;
// Power down signals.
wire fDAC0_PD, fDAC1_PD, fDAC2_PD, fDAC3_PD, fDAC4_PD, fDAC5_PD, fDAC6_PD;

// 16-bit output shift register signals
wire outB0, outB1, outB2,  outB3,  outB4,  outB5,  outB6,  outB7, 
     outB8, outB9, outB10, outB11, outB12, outB13, outB14, outB15;

////**** END OF SIGNAL DECLARATIONS ****\\\\

////**** SIGNAL ASSIGNMENTS ****\\\\

//// FAST ADC'S SPI \\\\
// ADC's sleep mode is not enabled during testing.
assign ADCOFF = 0; 

//// FAST DAC'S \\\\
// Fast DAC output assignments; output fast inputs and deserialized frames.
assign f_out_0  = f_in_0;
assign f_out_1  = f_in_1;
assign f_out_2  = f_in_2;
assign f_out_3  = f_in_3;
assign f_out_4  = f_in_4;
assign f_out_5  = f_in_5;
assign f_out_6  = f_in_6;
assign f_out_7  = f_in_7;
assign f_out_8  = f_in_8;
assign f_out_9  = f_in_9;
assign f_out_10 = {fr1_out, fr0_out};
assign f_out_11 = {fr3_out, fr2_out};
assign f_out_12 = {fr4_out, fr0_out};
assign f_out_13 = f_in_0;

// Power down signals, set to never sleep.
assign fDAC0_PD = 0;
assign fDAC1_PD = 0;
assign fDAC2_PD = 0;
assign fDAC3_PD = 0;
assign fDAC4_PD = 0;
assign fDAC5_PD = 0;
assign fDAC6_PD = 0;

// 16-bit shift register B output assignments
assign outB0  = fDAC0_PD;
assign outB1  = fDAC1_PD;
assign outB2  = fDAC2_PD;
assign outB3  = fDAC3_PD;
assign outB4  = fDAC4_PD;
assign outB5  = fDAC5_PD;
assign outB6  = fDAC6_PD;
assign outB7  = 0;
assign outB8  = 0;
assign outB9  = 0;
assign outB10 = 0;
assign outB11 = 0;
assign outB12 = 0;
assign outB13 = 0;
assign outB14 = 0;
assign outB15 = 0;

////**** END OF SIGNAL ASSIGNMENTS ****\\\\

////**** MODULE DECLARATIONS ****\\\\

//// CLOCK INPUT \\\\  
//IBUF: Single-ended Input Buffer
IBUF#(.IBUF_LOW_PWR("FALSE"),  // Low power="TRUE", Highest performance="FALSE"
      .IOSTANDARD("LVCMOS18")) // Specify the input I/O standard
IBUF_inst (.O(clkg), // Clock buffer output
           .I(clk)); // Clock buffer input (connect directly to top-level port)
           
//// MMCM RESET \\\\
reset startup_reset0(clkg, 1, rst0);

//// GLOBAL CLOCKS \\\\

// Most of the clocks for this design come from this clock manager.
GlobalClocks#(
    div0, div1, div2, div3, div4, div5, div6,
    phs0, phs1, phs2, phs3, phs4, phs5, phs6,
    mmcm0loc)
GlobalClocks_inst0(clkg, rst0, clk100_out_int, clk100_int, clk200_int, clk400_int, clk400B_int, fDAC_clk, fDAC_clk_out);
// Explicit declaration of BUFG's and locking their locations helps with OOC of FastADCsDDR.
(* LOC = "BUFGCTRL_X0Y2" *)BUFG BUFG_0(.O(clk100_out), .I(clk100_out_int)); 
(* LOC = "BUFGCTRL_X0Y0" *)BUFG BUFG_1(.O(clk100),     .I(clk100_int)    ); 
(* LOC = "BUFGCTRL_X0Y3" *)BUFG BUFG_2(.O(clk200),     .I(clk200_int)    ); 
(* LOC = "BUFGCTRL_X0Y4" *)BUFG BUFG_3(.O(clk400),     .I(clk400_int)    ); 
(* LOC = "BUFGCTRL_X0Y5" *)BUFG BUFG_4(.O(clk400B),    .I(clk400B_int)   ); 

//// RESET AFTER FPGA PROGRAMMING, FOR EVERYTHING BUT MMCM \\\\
reset startup_reset(clk100, 1, rst);

//// FAST ADC'S \\\\
FastADCsDDR FastADCs_inst(
   // Clocking
   clk100_out, clk100, clk200, clk400, clk400B,
   // Reset
   rst,
   // Encode
   ENC_p, ENC_n,
   // Frame inputs
   FR0_p, FR0_n, FR1_p, FR1_n, FR2_p, FR2_n, FR3_p, FR3_n, FR4_p, FR4_n,
   // Serial data lines
   D00_p, D00_n, D01_p, D01_n, D10_p, D10_n, D11_p, D11_n, D20_p, D20_n, D21_p, D21_n, D30_p, D30_n, D31_p, D31_n, D40_p, D40_n, D41_p, D41_n,
   // Deserialized data
   f_in_0, f_in_1, f_in_2, f_in_3, f_in_4, f_in_5, f_in_6, f_in_7, f_in_8, f_in_9,
   // Deserialized frames
   fr0_out, fr1_out, fr2_out, fr3_out, fr4_out
);   

// SPI controller for FastADC's
FastADCs_SPI FastADCs_SPI_inst(clk100, rst, ADCOFF, fADC_CS0, fADC_CS1, fADC_CS2, fADC_CS3, fADC_CS4, fADC_SCK, fADC_SDI, fADC_SDO);

//// FAST DAC'S \\\\
FastDACs fDAC_inst(
    .clk_in(fDAC_clk), 
    .clk_out_in(fDAC_clk_out), 
    .s_in0( f_out_0 ), 
    .s_in1( f_out_1 ), 
    .s_in2( f_out_2 ), 
    .s_in3( f_out_3 ), 
    .s_in4( f_out_4 ), 
    .s_in5( f_out_5 ),
    .s_in6( f_out_6 ), 
    .s_in7( f_out_7 ), 
    .s_in8( f_out_8 ), 
    .s_in9( f_out_9 ), 
    .s_in10(f_out_10), 
    .s_in11(f_out_11), 
    .s_in12(f_out_12), 
    .s_in13(f_out_13),
    .fDACclkB_out(fDACclkB), 
    .fDACclkC_out(fDACclkC),
    .fDAC0_sel(fDAC0_sel), 
    .fDAC1_sel(fDAC1_sel), 
    .fDAC2_sel(fDAC2_sel),
    .fDAC3_sel(fDAC3_sel), 
    .fDAC4_sel(fDAC4_sel), 
    .fDAC5_sel(fDAC5_sel), 
    .fDAC6_sel(fDAC6_sel),
    .fDAC0_out(fDAC0_out), 
    .fDAC1_out(fDAC1_out), 
    .fDAC2_out(fDAC2_out),
    .fDAC3_out(fDAC3_out), 
    .fDAC4_out(fDAC4_out), 
    .fDAC5_out(fDAC5_out), 
    .fDAC6_out(fDAC6_out)
); 

// Output shift register B, 16-bits.
SRB_CTRL SR_B_CTRL0(
    .CLK_IN(clk50),
    .CLK_SR(SR_B_SCLK),
    // OUTPUT SIGNALS FOR EACH BIT OF SHIFT-REGISTER B
    .out0(outB15),
    .out1(outB14),  
    .out2(outB13),  
    .out3(outB12),  
    .out4(outB11),  
    .out5(outB10),  
    .out6(outB9),  
    .out7(outB8), 
    .out8(outB7),  
    .out9(outB6),  
    .out10(outB5), 
    .out11(outB4), 
    .out12(outB3), 
    .out13(outB2), 
    .out14(outB1), 
    .out15(outB0),
    // OUTPUT TO SHIFT-REGISTER B
    .SR_OUT(SR_B_IN),
    .STROBE_OUT(SR_B_STROBE)
);

////**** END OF MODULE DECLARATIONS ****\\\\

endmodule