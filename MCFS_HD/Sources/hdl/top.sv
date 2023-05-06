`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Top-level module with 9 cavity and 8 temperature servos, FM-MOT arbitrary waveforms and DSP, and a LCD touchscreen driver.
// Synthesized and Implemented in Vivado 2020.1.
// This file has 5 sections: 
// SIGNAL DECLARATIONS, SIGNAL ASSIGNMENTS, MODULE DECLARATIONS, FAST DAC TESTING SECTION, and PARAMETER REASSIGNMENT.
// PARAMETER REASSIGNMENT could as well go in the SIGNAL ASSIGNMENTS section. It is at the end because it is long, and simple.
//
//// TABLE OF CONTENTS \\\\
    ////**** SIGNAL DECLARATIONS ****\\\\
        //// CLOCK AND RESET DECLARATIONS \\\\          
        //// FAST ADC'S \\\\
        //// SLOW ADC'S \\\\
        //// SERIAL LINE \\\\
        //// CAVITY SERVO SIGNAL DECLARATIONS \\\\
            /// CAVITY SERVO SIGNAL NAME DECLARATIONS
            //**** LBO ****\\
            //**** BBO326_542 ****\\
            //**** BBO820 ****\\
            //**** 1083REF ****\\
            //**** BBO361_542 ****\\
            //**** BBO361_1083 ****\\
            //**** 332 Servo ****\\
            //**** Cavity Servo 7 ****\\
            //**** Cavity Servo 8 ****\\
        //// SELECTABLE OUTPUT \\\\
        //// FM MOT SCAN \\\\
        //// TEMPERATURE SERVOS \\\\
            //**** Cd oven temperature controller ****\\
            //**** Reference cavity temperature controller (temperature controller 1) ****\\
            ////**** Temperature controller 2 ****\\
            ////**** Temperature controller 3 (361 BBO without limits) ****\\
            ////**** Temperature controller 4 (480 PPLN without limits) ****\\
            ////**** Temperature controller 5 (468 PPLN without limits) ****\\
            //**** Temperature controller 6 (361 BBO) ****\\
            //**** Temperature controller 7 (480 PPLN) ****\\
            //**** Temperature controller 8 (468 PPLN) ****\\
            //**** Temperature controller 9 ****\\
        //// PARAMETER REASSIGNMENT \\\\
        //// FAST DAC'S \\\\
        //// SLOW DAC'S \\\\ 
        //// DISPLAY MODULES \\\\
    
    ////**** SIGNAL ASSIGNMENTS ****\\\\
        //// SLOW ADC'S \\\\
        //// SERIAL LINE \\\\
        //// OTHER DIGITAL OUTPUTS \\\\
        //// CAVITY SERVO ASSIGNMENTS \\\\
        //// SELECTABLE OUTPUT \\\\
        //// FM MOT SCAN \\\\
        //// TEMPERATURE SERVOS \\\\
        //// FAST DAC'S \\\\
        //// SLOW DAC'S \\\\ 
        //// DISPLAY MODULES \\\\
        
    ////**** MODULE DECLARATIONS ****\\\\
        //// CLOCK INPUT \\\\
        //// MMCM RESET \\\\
        //// GLOBAL CLOCKS \\\\
        //// GLOBAL RESET FOR EVERYTHING BUT MMCM \\\\
        //// FAST ADC'S \\\\
        //// SLOW ADC'S \\\\
        //// SERIAL LINE \\\\
        //// CAVITY SERVOS \\\\
        //// SELECTABLE OUTPUT \\\\
        //// FM MOT SCAN \\\\
        //// TEMPERATURE SERVOS \\\\
        //// PARAMETER REASSIGNMENT \\\\
        //// FAST DAC'S \\\\
        //// SLOW DAC'S \\\\ 
        //// DISPLAY MODULES \\\\
    
    ////**** FAST DAC TESTING SECTION ****\\\\

    ////**** PARAMETER REASSIGNMENT ****\\\\

// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module top(
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
    // Connector C digital inputs or outputs.
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
    div0 = 8,     div1 = 8, div2 = 4, div3 = 2,     div4 = 2,     div5 = 4, div6 = 4,
    phs0 = 11.25, phs1 = 0, phs2 = 0, phs3 = 337.5, phs4 = 337.5, phs5 = 0, phs6 = 123.75, // the phases of clk400 and clk400B were calibrated for the fast ADC's and centered on the 2D working phase region.
    div0b = 8, div1b = 8, div2b = 8, div3b = 40, div4b = 16, div5b = 8, div6b = 8,
    phs0b = 0, phs1b = 0, phs2b = 0, phs3b = 0,  phs4b = 0, phs5b = 0, phs6b = 0;
parameter mmcm0loc = "MMCME2_ADV_X1Y2", mmcm1loc = "MMCME2_ADV_X1Y1";
wire clk100_out, clk100, clk200, clk400, clk400B, fDAC_clk, fDAC_clk_out; // Output from BUFG's.
wire clk100_out_int, clk100_int, clk200_int, clk400_int, clk400B_int; // Pre-buffered clock signals.
wire sADC_clk,     sADC_clk_in,     clk20,     clk50; // Output from BUFG's.
wire sADC_clk_int, sADC_clk_in_int, clk20_int, clk50_int; // Pre-buffered clock signals.
wire sADC_clk_out, clk5_in, clk6_in; // Currently unused MMCM outputs.
wire clk125kHz;

//// FAST ADC'S \\\\
(* keep = "true" *)wire signed [15:0] f_in_0, f_in_1, f_in_2, f_in_3, f_in_4, f_in_5, f_in_6, f_in_7, f_in_8, f_in_9; // 16-bit data
(* keep = "true" *)wire [7:0] fr0_out, fr1_out, fr2_out, fr3_out, fr4_out; // Deserialized FRAME for each fast ADC, nominally 8'b11110000
wire ADCOFF; // Signal to trigger SPI programming to put all fast ADC's in sleep mode.

//// SLOW ADC'S \\\\
/// Parameters
parameter N = 100; // Number of clock cycles in 1 conversion; 100 = 1 us with 100 MHz clock.
parameter N_CNV = 50; // Number of cycles to hold CNV high; 40 ns minimum.
parameter N_CH = 24; // Number of elements in the repeating conversion sequence. N_CH>8 allows the 8 ADC channels to be sampled at different rates and non-sequentially.
/// Wires
(* DONT_TOUCH *) // This attribute prevents synthesis from eliminating these signals during optimization - used for OOC implementation of the slow ADC module.
// 16-bit conversion data from chip0 (0-7) and chip1 (8-15).
wire signed [15:0] s_in_0_int, s_in_1_int, s_in_2_int,  s_in_3_int,  s_in_4_int,  s_in_5_int,  s_in_6_int,  s_in_7_int,
                   s_in_8_int, s_in_9_int, s_in_10_int, s_in_11_int, s_in_12_int, s_in_13_int, s_in_14_int, s_in_15_int;
// Slow ADC conversion data with a sign flip.
(* DONT_TOUCH *)
wire signed [15:0]  s_in_0, s_in_1, s_in_2,  s_in_3,  s_in_4,  s_in_5,  s_in_6,  s_in_7,
                    s_in_8, s_in_9, s_in_10, s_in_11, s_in_12, s_in_13, s_in_14, s_in_15;
wire sADC_rst; // Reset signal for slow ADC.
// Channel sequence
wire [2:0] SEQ [0:N_CH-1];
// Slow ADC power down signals.
wire sADC0_PD, sADC1_PD;

/// Triggers and delayed power down signals. PDall1 powers down fast DAC chip 1, which is used for the 1083 reference cavity servo, and PDall powers down all other fast ADC's and the slow ADC chip 0.
localparam [25:0] cntMAX_PD = 26'd3_750_000; 
wire PDtrig, PDtrig1, PDall, PDall1;

//// SERIAL LINE \\\\
// Serial input data (names correspond to those in Excel macros).
wire signed [34:0] 
    x1,  x2,  x3,  x4,  x5,  x6,  x7,  x8,  x9, 
    x10, x11, x12, x13, x14, x15, x16, x17, x18, 
    x19, x20, x21, x22, x23, x24, x25, x26, x27;
// Serial input data begins and ends with a handshake, handshake_default + servo_number
wire [15:0] handshake_i, handshake_f;
wire serial_in, serial_trig_in; // Serial input data and trigger from synthesizer.

//// CAVITY SERVO SIGNAL DECLARATIONS \\\\
/// CAVITY SERVO SIGNAL NAME DECLARATIONS 
// Transmission, reflection, error signal
wire signed [15:0] trans0_in, trans1_in, trans2_in, ref2_in, trans3_in, trans4_in, sfg5_in, trans6_in, trans7_in, trans8_in,
                   e0_in, e1_in, e2_in, e3_in, e4_in, e6_in, e7_in, e8_in,
                   LBOff_in, BBO542ff_in, BBO820ff_in, offset820_in;
// Signals from touchscreen, set mode to OFF, SCAN, SERVO, ...
(*DONT_TOUCH*)
wire STOPservos, // Turns off servos and relocks, from LCD touchscreen
     scanLBO, scan542_326, scan820, scan1083, scan542_361, scan1083_361, scan_CS6,
     stopLBO, stop542_326, stop820, stop1083, stop542_361, stop1083_361, stop_CS6;
reg stop_CS7, stop_CS8, scan_CS7, scan_CS8; // The display does not currently have a button for these. They are assigned and changed in PARAMETER REASSIGNMENT.
// Cavity servo filter signal size parameters
parameter N_H = 0;                       // Overflow Bits
parameter N_B = 16;                      // Number of bits from ADC/DAC
parameter N_P = 9;                       // Servo fractional bits
parameter SIGNAL_SIZE = N_H + N_B + N_P; // Number of bits in and out of filters

wire dithEN; // dither enable
wire PID0_on, PID1_on, PID2_on, PID3_on, PID4_on, PID5_on, PID6_on, PID7_on, PID8_on; // Enables for the PID's

//**** LBO ****\\
// PID bit shifts (gains and frequencies).
reg signed [9:0] NI0 = 56, NFI0 = -240, NP0 = 58, NFP0 = -24, ND0 = 8, NFD0 = -52, NGD0 = -26;
reg is_neg0 = 1'b1; // Filter sign
// Relock, Dither lock modulation and offset, and composite error signals parameters
reg signed [15:0] locktrig0     = 98;    // Threshold for lock
reg  signed [N_B-1:0] offset0s = -270; // Static offset
reg signed [15:0] start_sweep_0 = -180; // Sweep minimum
reg signed [15:0] stop_sweep_0  = 5280;   // Sweep maximum
reg        [31:0] sweep_rate_0  = 64; // Sweep rate
// Dither lock frequency and amplitude and integration parameters, clock dividers that set modulation frequency f_clk/(60*divFast*divSlow).     
reg signed [9:0] bitshift0 = 28; // Dither integrator gain.
reg [N_B-1:0] divFast0 = 16, divSlow0 = 68, mod0scaling = 10; // Right bit shift of modulation signal
reg demod_bit0 = 1'b0; // demodulation sign.
reg mod_sel0 = 1'b0; // Sets demodulation quadrature: 0 is cos, 1 is sin
reg [3:0] inhmode0 = 3; // Initial and ending dither phase/22.5 deg where 0 is the positive slope zero crossing.
// servo output to fast DAC 
wire signed [N_B-1:0] servo0out; // Limited servo output to fast DAC.

//**** BBO326_542 ****\\
// PID bit shifts (gains and frequencies).
reg signed [9:0] NI1 = 52, NFI1 = -240, NP1 = -4, NFP1 = -28, ND1 = -4, NFD1 = -56, NGD1 = -26;
reg is_neg1 = 1'b0; // Filter sign
// Relock, Dither lock modulation and offset, and composite error signals parameters
reg signed [15:0] locktrig1     = 66;     // Threshold for lock
reg  signed [N_B-1:0] offset1s = -120; // Static offset
reg signed [15:0] start_sweep_1 = 0; // Sweep minimum
reg signed [15:0] stop_sweep_1  = 2912;     // Sweep maximum
reg        [31:0] sweep_rate_1  = 8; // Sweep rate
// Dither lock frequency and amplitude and integration parameters, Clock dividers that set modulation frequency f_clk/(60*divFast*divSlow).     
reg signed [9:0] bitshift1 = 24; // Dither integrator gain.
reg [N_B-1:0] divFast1 = 16'd24, divSlow1 = 16'd69, mod1scaling = 9; // Right bit shift of modulation signal
reg demod_bit1 = 1'b0; // demodulation sign.
reg mod_sel1 = 1'b0; // Sets demodulation quadrature: 0 is cos, 1 is sin
reg [3:0] inhmode1 = 4'd4; // Initial and ending dither phase/22.5 deg where 0 is the positive slope zero crossing.
// Monitor output for slow DAC
wire signed [N_B-1:0] offset1_out;
// servo output to fast DAC 
wire signed [N_B-1:0] servo1out; // Limited servo output to fast DAC.

//**** BBO820 ****\\
// PID bit shifts (gains and frequencies).
reg signed [9:0] NI2 = 48, NFI2 = -240, NP2 = 68, NFP2 = -40, ND2 = 4, NFD2 = -84, NGD2 = -38;
reg is_neg2 = 1'b1; // Filter sign
// Relock, Dither lock modulation and offset, and composite error signals parameters
reg signed [15:0] locktrig2    = 328;  // Threshold for lock
reg signed [N_B-1:0] offset2s = -541; // Static offset, 0V
reg signed [15:0] mean_sweep_2 = 3641; // Sweep mean
reg signed [15:0] mean820sh    = 0;    // Static shift
reg signed [15:0] amp_sweep_2  = 1456; // Sweep amplitude
reg        [31:0] sweep_rate_2 = 8; // Sweep rate
// Dither lock frequency and amplitude and integration parameters, Clock dividers that set modulation frequency f_clk/(60*divFast*divSlow).     
reg signed [9:0] bitshift2 = 24; // Dither integrator gain.
reg [N_B-1:0] divFast2 = 36, divSlow2 = 69, mod2scaling = 10; // Right bit shift of modulation signal
reg demod_bit2 = 1'b1; // demodulation sign.
reg mod_sel2 = 1'b0; // Sets demodulation quadrature: 0 is cos, 1 is sin
reg [3:0] inhmode2 = 4'd2; // Initial and ending dither phase/22.5 deg where 0 is the positive slope zero crossing.
// Monitor output for slow DAC
wire signed [N_B-1:0] offset2_out, mod2_out;
wire signed [N_B-1:0] servo2out; // Limited servo output to fast DAC.

//**** 1083REF ****\\
// PID bit shifts (gains and frequencies).
reg signed [9:0] NI3 = 52, NFI3 = -240, NP3 = 84, NFP3 = -28, ND3 = 38, NFD3 = -56, NGD3 = -28;
reg is_neg3 = 1'b1; // Filter sign
// Relock, Dither lock modulation and offset, and composite error signals parameters
reg signed [15:0] locktrig3 = 16;    // Threshold for lock
reg  signed [N_B-1:0] offset3s = -180; // Static offset
reg signed [15:0] mean_sweep_3 = 0;   // Sweep mean
reg signed [15:0] amp_sweep_3 = 5279; // Sweep amplitude
reg        [31:0] sweep_rate_3 = 8;   // Sweep rate
// Dither lock frequency and amplitude and integration parameters, Clock dividers that set modulation frequency f_clk/(60*divFast*divSlow).     
reg signed [9:0] bitshift3 = 24; // Dither integrator gain.
reg [N_B-1:0] divFast3 = 23, divSlow3 = 46, mod3scaling = 11; // Right bit shift of modulation signal
reg demod_bit3 = 1'b0; // demodulation sign.
reg mod_sel3 = 1'b0; // Sets demodulation quadrature: 0 is cos, 1 is sin
reg [3:0] inhmode3 = 4'd0; // Initial and ending dither phase/22.5 deg where 0 is the positive slope zero crossing.
wire signed [N_B-1:0] servo3out; // Limited servo output to fast DAC.

//**** BBO361_542 ****\\
// PID bit shifts (gains and frequencies).
reg signed [9:0] NI4 = 84, NFI4 = -240, NP4 = 80, NFP4 = -24, ND4 = -4, NFD4 = -60, NGD4 = -26;
reg is_neg4 = 1'b0; // Filter sign
// Relock, Dither lock modulation and offset, and composite error signals parameters
reg signed [15:0] locktrig4 = 33;       // Threshold for lock
reg  signed [N_B-1:0] offset4s = -57; // Static offset
reg signed [15:0] start_sweep_4 = 1502; // Sweep minimum
reg signed [15:0] stop_sweep_4 = 4597;  // Sweep maximum
reg        [31:0] sweep_rate_4 = 64; // Sweep rate
// Dither lock frequency and amplitude and integration parameters, Clock dividers that set modulation frequency f_clk/(60*divFast*divSlow).     
reg signed [9:0] bitshift4 = 8; // Dither integrator gain.
reg [N_B-1:0] divFast4 = 24, divSlow4 = 69, mod4scaling = 13; // Right bit shift of modulation signal
reg demod_bit4 = 1'b1; // demodulation sign.
reg mod_sel4 = 1'b1; // Sets demodulation quadrature: 0 is cos, 1 is sin
reg [3:0] inhmode4 = 4'd3; // Initial and ending dither phase/22.5 deg where 0 is the positive slope zero crossing.
/// PZT servo
wire signed [N_B-1:0] servo4out; // Limited servo output to fast DAC.

//**** BBO361_1083 ****\\
// PID bit shifts (gains and frequencies).
reg signed [9:0] NI5 = 44, NFI5 = -240, NP5 = 68, NFP5 = -40, ND5 = -4, NFD5 = -56, NGD5 = -28;
reg is_neg5 = 1'b0; // Filter sign
// Relock, Dither lock modulation and offset, and composite error signals parameters
reg signed [15:0] locktrig5 = 2949;    // Threshold for lock
reg  signed [N_B-1:0] offset5s = 0; // Static offset
reg signed [15:0] mean_sweep_5 = 4915; // Sweep mean
reg signed [15:0] mean1083_361sh = 16'd0;  // Static shift of sweep mean.
reg signed [15:0] amp_sweep_5 = 364;   // Sweep amplitude
reg        [31:0] sweep_rate_5 = 16; // Sweep rate
// Dither lock frequency and amplitude and integration parameters, Clock dividers that set modulation frequency f_clk/(60*divFast*divSlow).     
reg signed [9:0] bitshift5 = -4; // Dither integrator gain.
reg [N_B-1:0] divFast5 = 37, divSlow5 = 17, mod5scaling = 12; // Right bit shift of modulation signal
reg demod_bit5 = 1'b0; // demodulation sign.
reg mod_sel5 = 1'b0; // Sets demodulation quadrature: 0 is cos, 1 is sin
reg [3:0] inhmode5 = 4'd5; // Initial and ending dither phase/22.5 deg where 0 is the positive slope zero crossing.
/// PZT servo
wire signed [N_B-1:0] servo5out; // Limited servo output to fast DAC.

//**** 332 Servo ****\\
// PID bit shifts (gains and frequencies).
reg signed [9:0] NI6 = 56, NFI6 = -240, NP6 = 58, NFP6 = -24, ND6 = 8, NFD6 = -52, NGD6 = -26;
reg is_neg6 = 1'b1; // Filter sign
// Relock, Dither lock modulation and offset, and composite error signals parameters
reg signed [15:0] locktrig6    = 98;    // Threshold for lock
reg  signed [N_B-1:0] offset6s = 108; // Static offset
reg signed [15:0] start_sweep_6 = -16'd180; // Sweep minimum
reg signed [15:0] stop_sweep_6  = 16'd5280;   // Sweep maximum
reg        [31:0] sweep_rate_6  = 32'd64; // Sweep rate
// Dither lock frequency and amplitude and integration parameters, Clock dividers that set modulation frequency f_clk/(60*divFast*divSlow).     
reg signed [9:0] bitshift6 = 28; // Dither integrator gain.
reg [N_B-1:0] divFast6 = 16'd16, divSlow6 = 16'd68, mod6scaling = 10; // Right bit shift of modulation signal
reg demod_bit6 = 1'b0; // demodulation sign.
reg mod_sel6 = 1'b0; // Sets demodulation quadrature: 0 is cos, 1 is sin
reg [3:0] inhmode6 = 4'd4; // Initial and ending dither phase/22.5 deg where 0 is the positive slope zero crossing.
wire signed [N_B-1:0] servo6out; // Limited servo output to fast DAC.

//**** Cavity Servo 7 ****\\
// PID bit shifts (gains and frequencies).
reg signed [9:0] NI7 = 56, NFI7 = -240, NP7 = 58, NFP7 = -24, ND7 = 8, NFD7 = -52, NGD7 = -26;
reg is_neg7 = 1'b1; // Filter sign
// Relock, Dither lock modulation and offset, and composite error signals parameters
reg signed [15:0] locktrig7    = 98;    // Threshold for lock
reg  signed [N_B-1:0] offset7s = 108; // Static offset
reg signed [15:0] start_sweep_7 = -16'd180; // Sweep minimum
reg signed [15:0] stop_sweep_7  = 16'd5280;   // Sweep maximum
reg        [31:0] sweep_rate_7  = 32'd64; // Sweep rate
// Dither lock frequency and amplitude and integration parameters, Clock dividers that set modulation frequency f_clk/(60*divFast*divSlow).     
reg signed [9:0] bitshift7 = 28; // Dither integrator gain.
reg [N_B-1:0] divFast7 = 16'd16, divSlow7 = 16'd68, mod7scaling = 10; // Right bit shift of modulation signal
reg demod_bit7 = 1'b0; // demodulation sign.
reg mod_sel7 = 1'b0; // Sets demodulation quadrature: 0 is cos, 1 is sin
reg [3:0] inhmode7 = 4'd4; // Initial and ending dither phase/22.5 deg where 0 is the positive slope zero crossing.
// servo output to fast DAC 
wire signed [N_B-1:0] servo7out; // Limited servo output to fast DAC.

//**** Cavity Servo 8 ****\\
// PID bit shifts (gains and frequencies).
reg signed [9:0] NI8 = 56, NFI8 = -240, NP8 = 58, NFP8 = -24, ND8 = 8, NFD8 = -52, NGD8 = -26;
reg is_neg8 = 1'b1; // Filter sign
// Relock, Dither lock modulation and offset, and composite error signals parameters
reg signed [15:0] locktrig8    = 98;    // Threshold for lock
reg  signed [N_B-1:0] offset8s = 108; // Static offset
reg signed [15:0] start_sweep_8 = -16'd180; // Sweep minimum
reg signed [15:0] stop_sweep_8  = 16'd5280;   // Sweep maximum
reg        [31:0] sweep_rate_8  = 32'd64; // Sweep rate
// Dither lock frequency and amplitude and integration parameters, Clock dividers that set modulation frequency f_clk/(60*divFast*divSlow).     
reg signed [9:0] bitshift8 = 28; // Dither integrator gain.
reg [N_B-1:0] divFast8 = 16'd16, divSlow8 = 16'd68, mod8scaling = 10; // Right bit shift of modulation signal
reg demod_bit8 = 1'b0; // demodulation sign.
reg mod_sel8 = 1'b0; // Sets demodulation quadrature: 0 is cos, 1 is sin
reg [3:0] inhmode8 = 4'd4; // Initial and ending dither phase/22.5 deg where 0 is the positive slope zero crossing.
// servo output to fast DAC 
wire signed [N_B-1:0] servo8out; // Limited servo output to fast DAC.

// Cavity servo debug signals
wire signed [N_B-1:0]
    // Debug signals for LBO
    mod0_dg, mod0sc_dg, demod0_dg, demod0Q_dg, demod_in_sel0_dg, offset0_dg,
    // Debug signals for 326-542
    mod1_dg, mod1sc_dg, demod1_dg, demod1Q_dg, demod_in_sel1_dg, offset1_dg,
    // Debug signals for 820
    mod2_dg, mod2sc_dg, demod2_dg, demod2Q_dg, demod_in_sel2_dg, offset2_dg,
    // Debug signals for 1083 ref
    mod3_dg, mod3sc_dg, demod3_dg, demod3Q_dg, demod_in_sel3_dg, offset3_dg,
    // Debug signals for 361-542
    mod4_dg, mod4sc_dg, demod4_dg, demod4Q_dg, demod_in_sel4_dg, offset4_dg,
    // Debug signals for 361-1083
    mod5_dg, mod5sc_dg, demod5_dg, demod5Q_dg, demod_in_sel5_dg, offset5_dg,
    // Debug signals for 332
    mod6_dg, mod6sc_dg, demod6_dg, demod6Q_dg, demod_in_sel6_dg, offset6_dg,
    // Debug signals for cavity servo 7
    mod7_dg, mod7sc_dg, demod7_dg, demod7Q_dg, demod_in_sel7_dg, offset7_dg,
    // Debug signals for cavity servo 8
    mod8_dg, mod8sc_dg, demod8_dg, demod8Q_dg, demod_in_sel8_dg, offset8_dg;

//// SELECTABLE OUTPUT \\\\
// MUX outputs
wire signed [N_B-1:0] varOut0, varOut1;

//// FM MOT SCAN \\\\
/// There are 3 operating modes for the FM_MOT module, controlled by the touchscreen.
// Params for OFF state.
reg                  FMon_0 = 0;
reg        [N_B-1:0] FMdivFast_0 = 16'd3, FMdivSlow_0 = 16'd11, FMsc_0 = -16'd1;
reg signed [N_B-1:0] FMmean_0 = 16'd15847;
reg        [N_B-1:0] dtD_0 = 16'd10101, dt1_0 = 16'd51, dt2_0 = 16'd101, dt3_0 = 16'd886, dtUP_0 = 16'd15, dtDOWN_0 = 16'd5;
reg signed [23:0]    D1_0 = 24'd34, D2_0 = 24'd0, DUP_0 = 24'd0, DDOWN_0 = 24'd347;
reg signed [N_B-1:0] FMIntMax_0 = 16'd0, dt4_0 = -16'd1;
reg        [N_B-1:0] dt5_0 = 16'd1, dt6_0 = 16'd202;
reg signed [23:0]    D5_0 = 16'd0, D6_0 = 16'd0;
reg        [N_B-1:0] dt8_0 = 16'd842, FMINTBS_0 = 16'd8, FMDEMCBS_0 = 16'd10, FMDEMSBS_0 = 16'd10;
reg signed [N_B-1:0] cImin_0 = 16'd0;
reg signed [23:0]    DcI_0 = 24'd0;
reg        [3:0]     selFM0_0 = 13, selFM1_0 = 14, selFM2_0 = 5;
// Params for saturated absorption.
reg                  FMon_1 = 1;
reg        [N_B-1:0] FMdivFast_1 = 16'd3, FMdivSlow_1 = 16'd11, FMsc_1 = -16'd1;
reg signed [N_B-1:0] FMmean_1 = 16'd15847;
reg        [N_B-1:0] dtD_1 = 16'd10101, dt1_1 = 16'd51, dt2_1 = 16'd101, dt3_1 = 16'd886, dtUP_1 = 16'd15, dtDOWN_1 = 16'd5;
reg signed [23:0]    D1_1 = 24'd34, D2_1 = 24'd0, DUP_1 = 24'd0, DDOWN_1 = 24'd347;
reg signed [N_B-1:0] FMIntMax_1 = 16'd8520, dt4_1 = -16'd1;
reg        [N_B-1:0] dt5_1 = 16'd1, dt6_1 = 16'd202;
reg signed [23:0]    D5_1 = 16'd0, D6_1 = 16'd0;
reg        [N_B-1:0] dt8_1 = 16'd842, FMINTBS_1 = 16'd8, FMDEMCBS_1 = 16'd10, FMDEMSBS_1 = 16'd10;
reg signed [N_B-1:0] cImin_1 = 16'd8192;
reg signed [23:0]    DcI_1 = 24'd0;
reg        [3:0]     selFM0_1 = 13, selFM1_1 = 14, selFM2_1 = 5;
// Params for FM MOT
reg                  FMon_2 = 1'b1;
reg        [N_B-1:0] FMdivFast_2 = 16'd3, FMdivSlow_2 = 16'd11, FMsc_2 = 16'd16;
reg signed [N_B-1:0] FMmean_2 = -16'd6515;
reg        [N_B-1:0] dtD_2 = 16'd20141, dt1_2 = 16'd51, dt2_2 = 16'd101, dt3_2 = 16'd879, dtUP_2 = 16'd5, dtDOWN_2 = 16'd45;
reg signed [23:0]    D1_2 = 24'd34, D2_2 = 24'd11, DUP_2 = 24'd10846, DDOWN_2 = 24'd63;
reg signed [N_B-1:0] FMIntMax_2 = 16'd8520, dt4_2 = -16'd1;
reg        [N_B-1:0] dt5_2 = 16'd1, dt6_2 = 16'd202;
reg signed [23:0]    D5_2 = 24'd52059, D6_2 = 24'd0;
reg        [N_B-1:0] dt8_2 = 16'd842, FMINTBS_2 = 16'd8, FMDEMCBS_2 = 16'd10, FMDEMSBS_2 = 16'd10;
reg signed [N_B-1:0] cImin_2 = 16'd8192;
reg signed [23:0]    DcI_2 = 24'd0;
reg        [3:0]     selFM0_2 = 13, selFM1_2 = 14, selFM2_2 = 5;
// Params for 361nm MET MOT
reg                  FMon_3 = 1'b1;
reg        [N_B-1:0] FMdivFast_3 = 16'd3, FMdivSlow_3 = 16'd11, FMsc_3 = 16'd16;
reg signed [N_B-1:0] FMmean_3 = -16'd6515;
reg        [N_B-1:0] dtD_3 = 16'd20141, dt1_3 = 16'd51, dt2_3 = 16'd101, dt3_3 = 16'd5930, dtUP_3 = 16'd5, dtDOWN_3 = 16'd45;
reg signed [23:0]    D1_3 = 24'd34, D2_3 = 24'd11, DUP_3 = 24'd0, DDOWN_3 = 24'd63;
reg signed [N_B-1:0] FMIntMax_3 = 16'd8520, dt4_3 = -16'd1;
reg        [N_B-1:0] dt5_3 = 16'd1, dt6_3 = 16'd202;
reg signed [23:0]    D5_3 = 24'd52059, D6_3 = 16'd0;
reg        [N_B-1:0] dt8_3 = 16'd842, FMINTBS_3 = 16'd8, FMDEMCBS_3 = 16'd10, FMDEMSBS_3 = 16'd10;
reg signed [N_B-1:0] cImin_3 = 16'd8192;
reg signed [23:0]    DcI_3 = 24'd0;
reg        [3:0]     selFM0_3 = 13, selFM1_3 = 14, selFM2_3 = 5;
// Other params and signals for FM_MOT
parameter FMINTSC = 24, FMDEMODSC = 24;
wire                  FMon;
wire signed [N_B-1:0] FMin;
wire        [N_B-1:0] FMdivFast, FMdivSlow, FMsc;
wire signed [N_B-1:0] FMmean;
wire        [N_B-1:0] dtD, dt1, dt2, dt3, dtUP, dtDOWN;
wire signed [23:0]    D1, D2, DUP, DDOWN;
wire signed [N_B-1:0] FMIntMax, dt4;
wire        [N_B-1:0] dt5, dt6;
wire signed [23:0]    D5, D6;
wire        [N_B-1:0] dt8, FMINTBS, FMDEMCBS, FMDEMSBS;
wire signed [N_B-1:0] FMIntDiff, FMIntDiffDiff, FMdemodCOS, FMdemodSIN, FM, Int;
wire                  FMtrigD;
wire signed [N_B-1:0] cImin;
wire signed [23:0]    DcI;
wire signed [N_B-1:0] cI;
reg  signed [15:0] FMin0, FMin1;
reg  signed [SIGNAL_SIZE-1:0] FMin2;
wire [3:0] selFM0, selFM1, selFM2;

// FM_MOT mode (0 = off, 1 = sat. abs., 2 = 326 FM MOT, 3 = 361nm MET MOT)
wire [1:0] FM_MOT_state;
// Trigger for fmMOTmem to record gated integration of input signal (atom fluorescence).
wire memtrig;
parameter MOTMEMSIZE = 1024, MOTMEMSIGSIZE = 16, MOTADDRWIDTH = 10;
(* DONT_TOUCH *)wire [MOTMEMSIGSIZE-1:0] MOTDiffMem, MOTDiffDiffMem;
(* DONT_TOUCH *)wire [31:0] read_addr;

//// TEMPERATURE SERVOS \\\\

// Signals for debug
// (* keep = "true" *)wire [31:0] cnt_dly_Cd_out, cnt_dly_REF_out, cnt_dly_2_out, cnt_dly_3_out, cnt_dly_4_out, cnt_dly_5_out, cnt_dly_6_out, cnt_dly_7_out, cnt_dly_8_out, cnt_dly_9_out;
// (* keep = "true" *)wire [32:0] cnt_Cd_out,     cnt_REF_out,     cnt_2_out,     cnt_3_out,     cnt_4_out,     cnt_5_out,     cnt_6_out,     cnt_7_out,     cnt_8_out,     cnt_9_out;
// (* keep = "true" *)wire [31:0] cnt_out_VDCsync;

//**** Cd oven temperature controller ****\\
// Parameter declarations
parameter [31:0] TSCd_FILTER_IO_SIZE = 18, multCdBits = 7; // IO length for PID filters, and multiplier width
// Programmable parameters from serial input
reg signed [9:0]  NI_Cd_3 = 56, NFI_Cd_3 = -240, NP_Cd_3 = 36, NFP_Cd_3 = -72, ND_Cd_3 = -32, NFD_Cd_3 = -120, NGD_Cd_3 = -40; // PID gains
reg         is_neg_Cd_3 = 1, TS_on_Cd_3 = 1;
reg signed [TSCd_FILTER_IO_SIZE-1:0] sp_Cd_3 = 18'd423, offset_Cd_3 = -18'd393 , SHDN_Cd_3 = 18'd0;
reg signed [multCdBits-1:0] errmult_Cd = 16; // Post-filter multiplier for the temperature servo PID output, which is then scaled by errmult/16
wire signed [15:0] Tcd_in; 
wire signed [TSCd_FILTER_IO_SIZE-1:0] NH_Cd_out;
wire VDC_Cd; // 1-bit VDC/PWM output
wire [1:0] Cd_oven_state;

// Signals for debug
wire signed [TSCd_FILTER_IO_SIZE-1:0] LL_Cd_dg, UL_Cd_dg, Nprst_Cd_MAX_dg;
wire signed [15:0] Tcd_in_dg;
wire signed [TSCd_FILTER_IO_SIZE-1:0] offset_Cd_dg, sp_Cd_dg;
wire signed [TSCd_FILTER_IO_SIZE-1:0] VDC_Cd_in_dg, Nprst_Cd_dg;
wire signed [31:0] NH_in_Cd_dg;
wire signed [15:0] NHpre_Cd_dg, NHi_Cd_dg, NHp_Cd_dg, NHd_Cd_dg, NHpost_Cd_dg;

//**** Reference cavity temperature controller (temperature controller 1) ****\\
// Parameter declarations
parameter [31:0] TSREF_FILTER_IO_SIZE = 18, multREFBits = 7; // IO length for PID filters, and multiplier width
// Signal declarations
reg  signed [9:0]  NI_REF = 52, NFI_REF = -240, NP_REF = 28, NFP_REF = -64, ND_REF = 106, NFD_REF = -128, NGD_REF = -64; // PID gains
reg         is_neg_REF = 1, TS_on_REF = 1; // On and sign signals for integrator
reg  signed [TSREF_FILTER_IO_SIZE-1:0] sp_REF = 0, offset_REF = 0, SHDN_REF = 0; // Temperature setpoint, input offset, shutdown condition
reg signed [multREFBits-1:0] errmult_REF = 16; // Post-filter multiplier for the temperature servo PID output, which is then scaled by errmult/16
wire signed [15:0] Tref_in; 
(* keep = "true" *)wire signed [TSREF_FILTER_IO_SIZE-1:0] NH_REF_out;
wire VDC_REF; // 1-bit VDC output

// Signals for debug
// (* keep = "true" *)wire signed [TSREF_FILTER_IO_SIZE-1:0] LL_REF_dg, UL_REF_dg, Nprst_REF_MAX_dg;
// (* keep = "true" *)wire signed [15:0] Tref_in_dg;
// (* keep = "true" *)wire signed [TSREF_FILTER_IO_SIZE-1:0] offset_REF_dg, sp_REF_dg;
// (* keep = "true" *)wire signed [TSREF_FILTER_IO_SIZE-1:0] VDC_REF_in_dg, Nprst_REF_dg;
// (* keep = "true" *)wire signed [31:0] NH_in_REF_dg;
// (* keep = "true" *)wire signed [15:0] NHpre_REF_dg, NHi_REF_dg, NHp_REF_dg, NHd_REF_dg, NHpost_REF_dg;

//**** Temperature controller 2 ****\\
// Parameter declarations
parameter [31:0] TS2_FILTER_IO_SIZE = 18, mult2Bits = 7; // IO length for PID filters, and multiplier width
// Signal declarations
reg  signed [9:0]  NI_2 = 72, NFI_2 = -240, NP_2 = 44, NFP_2 = -32, ND_2 = 84, NFD_2 = -68, NGD_2 = -33; // PID gains
reg         is_neg_2 = 1, TS_on_2 = 1; // On and sign signals for integrator
reg  signed [TS2_FILTER_IO_SIZE-1:0] sp_2 = 0, offset_2 = 0, SHDN_2 = 0; // Temperature setpoint, input offset, shutdown condition
reg signed [mult2Bits-1:0] errmult_2 = 16; // Post-filter multiplier for the temperature servo PID output, which is then scaled by errmult/16
wire signed [15:0] T2_in; 
wire signed [TS2_FILTER_IO_SIZE-1:0] NH_2_out;
wire VDC_2; // 1-bit VDC output

//**** Temperature controller 3 (361 BBO with limits) ****\\
// Parameter declarations
parameter [31:0] TS3_FILTER_IO_SIZE = 18, mult3Bits = 7; // IO length for PID filters, and multiplier width
// Signal declarations
reg  signed [9:0]  NI_3 = 72, NFI_3 = -240, NP_3 = 44, NFP_3 = -32, ND_3 = 84, NFD_3 = -68, NGD_3 = -33; // PID gains
reg         is_neg_3 = 1, TS_on_3 = 1; // On and sign signals for integrator
reg  signed [TS3_FILTER_IO_SIZE-1:0] sp_3 = 0, offset_3 = 0, SHDN_3 = 0; // Temperature setpoint, input offset, shutdown condition
reg signed [mult3Bits-1:0] errmult_3 = 16; // Post-filter multiplier for the temperature servo PID output, which is then scaled by errmult/16
wire signed [15:0] T3_in; 
wire signed [TS3_FILTER_IO_SIZE-1:0] NH_3_out;
wire VDC_3; // 1-bit VDC output

//**** Temperature controller 4 (480 PPLN with limits) ****\\
// Parameter declarations
parameter [31:0] TS4_FILTER_IO_SIZE = 18, mult4Bits = 7; // IO length for PID filters, and multiplier width
// Signal declarations
reg  signed [9:0]  NI_4 = 72, NFI_4 = -240, NP_4 = 44, NFP_4 = -32, ND_4 = 84, NFD_4 = -68, NGD_4 = -33; // PID gains
reg         is_neg_4 = 1, TS_on_4 = 1; // On and sign signals for integrator
reg  signed [TS4_FILTER_IO_SIZE-1:0] sp_4 = 0, offset_4 = 0, SHDN_4 = 0; // Temperature setpoint, input offset, shutdown condition
reg signed [mult4Bits-1:0] errmult_4 = 16; // Post-filter multiplier for the temperature servo PID output, which is then scaled by errmult/16
wire signed [15:0] T4_in; 
wire signed [TS4_FILTER_IO_SIZE-1:0] NH_4_out;
wire VDC_4; // 1-bit VDC output

// Not used - Temperature controller 5 output disconnected in 'Assign shift-register outputs' of out15 below
//**** Temperature controller 5 (468 PPLN with limits) ****\\
// Parameter declarations
parameter [31:0] TS5_FILTER_IO_SIZE = 18, mult5Bits = 7; // IO length for PID filters, and multiplier width
// Signal declarations
reg  signed [9:0]  NI_5 = 72, NFI_5 = -240, NP_5 = 44, NFP_5 = -32, ND_5 = 84, NFD_5 = -68, NGD_5 = -33; // PID gains
reg         is_neg_5 = 1, TS_on_5 = 1; // On and sign signals for integrator
reg  signed [TS5_FILTER_IO_SIZE-1:0] sp_5 = 0, offset_5 = 0, SHDN_5 = 0; // Temperature setpoint, input offset, shutdown condition
reg signed [mult5Bits-1:0] errmult_5 = 16; // Post-filter multiplier for the temperature servo PID output, which is then scaled by errmult/16
wire signed [15:0] T5_in; 
wire signed [TS5_FILTER_IO_SIZE-1:0] NH_5_out;
wire VDC_5; // 1-bit VDC output

//**** Temperature controller 6 (361 BBO) ****\\
// Parameter declarations
parameter [31:0] TS6_FILTER_IO_SIZE = 18, mult6Bits = 7; // IO length for PID filters, and multiplier width
// Signal declarations
reg  signed [9:0]  NI_6 = 48, NFI_6 = -240, NP_6 = 28, NFP_6 = -64, ND_6 = 120, NFD_6 = -120, NGD_6 = -60; // PID gains
reg         is_neg_6 = 1, TS_on_6 = 1; // On and sign signals for integrator
reg  signed [TS6_FILTER_IO_SIZE-1:0] sp_6 = 0, offset_6 = 0, SHDN_6 = 0; // Temperature setpoint, input offset, shutdown condition
reg signed [mult6Bits-1:0] errmult_6 = 16; // Post-filter multiplier for the temperature servo PID output, which is then scaled by errmult/16
wire signed [15:0] T6_in; 
wire signed [TS6_FILTER_IO_SIZE-1:0] NH_6_out;
wire VDC_6; // 1-bit VDC output

//**** Temperature controller 7 (480 PPLN) ****\\
// Parameter declarations
parameter [31:0] TS7_FILTER_IO_SIZE = 18, mult7Bits = 7; // IO length for PID filters, and multiplier width
// Signal declarations
reg  signed [9:0]  NI_7 = 72, NFI_7 = -240, NP_7 = 44, NFP_7 = -32, ND_7 = 84, NFD_7 = -68, NGD_7 = -33; // PID gains
reg         is_neg_7 = 1, TS_on_7 = 1; // On and sign signals for integrator
reg  signed [TS7_FILTER_IO_SIZE-1:0] sp_7 = 0, offset_7 = 0, SHDN_7 = 0; // Temperature setpoint, input offset, shutdown condition
reg signed [mult7Bits-1:0] errmult_7 = 16; // Post-filter multiplier for the temperature servo PID output, which is then scaled by errmult/16
wire signed [15:0] T7_in; 
wire signed [TS7_FILTER_IO_SIZE-1:0] NH_7_out;
wire VDC_7; // 1-bit VDC output

//**** Temperature controller 8 (468 PPLN) ****\\
// Parameter declarations
parameter [31:0] TS8_FILTER_IO_SIZE = 18, mult8Bits = 7; // IO length for PID filters, and multiplier width
// Signal declarations
reg  signed [9:0]  NI_8 = 72, NFI_8 = -240, NP_8 = 36, NFP_8 = -36, ND_8 = -56, NFD_8 = -64, NGD_8 = -31; // PID gains
reg         is_neg_8 = 1, TS_on_8 = 1; // On and sign signals for integrator
reg  signed [TS8_FILTER_IO_SIZE-1:0] sp_8 = 0, offset_8 = 0, SHDN_8 = 0; // Temperature setpoint, input offset, shutdown condition
reg signed [mult8Bits-1:0] errmult_8 = 16; // Post-filter multiplier for the temperature servo PID output, which is then scaled by errmult/16
wire signed [15:0] T8_in; 
wire signed [TS8_FILTER_IO_SIZE-1:0] NH_8_out;
wire VDC_8; // 1-bit VDC output

// Not used - Temperature controller 9 output disconnected in 'Assign shift-register outputs' of out16 below
//**** Temperature controller 9 ****\\
// Parameter declarations
parameter [31:0] TS9_FILTER_IO_SIZE = 18, mult9Bits = 7; // IO length for PID filters, and multiplier width
// Signal declarations
reg  signed [9:0]  NI_9 = 72, NFI_9 = -240, NP_9 = 44, NFP_9 = -32, ND_9 = 84, NFD_9 = -68, NGD_9 = -33; // PID gains
reg         is_neg_9 = 1, TS_on_9 = 1; // On and sign signals for integrator
reg  signed [TS9_FILTER_IO_SIZE-1:0] sp_9 = 0, offset_9 = 0, SHDN_9 = 0; // Temperature setpoint, input offset, shutdown condition
reg signed [mult9Bits-1:0] errmult_9 = 16; // Post-filter multiplier for the temperature servo PID output, which is then scaled by errmult/16
wire signed [15:0] T9_in; 
wire signed [TS9_FILTER_IO_SIZE-1:0] NH_9_out;
wire VDC_9; // 1-bit VDC output

// Display temperature error signal indicator color signals
wire signed [15:0] TSclr0, TSclr1, TSclr2, TSclr3, TSclr4, TSclr5, TSclr6, TSclr7, TSclr8, TSclr9;

//// PARAMETER REASSIGNMENT \\\\
localparam [N_B-1:0] handshake_default = 16'h6364; // In hex, the ASCII for c = 63, d = 64. 
// Signals that are HIGH when initial and final handshakes match.
wire hs20, hs21, hs08, hs09, hs00, hs01, hs02, hs03, hs04, hs05, hs06, hs07, hs23, hs24, hs33, hs34, hs35, hs36, hs37, hs38, hs39, hs40, hs41;

//// FAST DAC'S \\\\
// Inputs to DAC's
(* keep = "true" *)wire signed [15:0]
    f_out_0, f_out_1, f_out_2, f_out_3, f_out_4, f_out_5, 
    f_out_6, f_out_7, f_out_8, f_out_9, f_out_10, f_out_11, f_out_12, f_out_13;
// Power down signals.
wire fDAC0_PD, fDAC1_PD, fDAC2_PD, fDAC3_PD, fDAC4_PD, fDAC5_PD, fDAC6_PD;

//// SLOW DAC'S \\\\
(*DONT_TOUCH*) // Intermediate outputs to DAC's before sign flip
wire signed [15:0] sout0_int, sout1_int, sout2_int, sout3_int, sout4_int, sout5_int, sout6_int, sout7_int, sout8_int, sout9_int, sout10_int, sout11_int, sout12_int, sout13_int, sout14_int, sout15_int;
// Output to DAC's with sign flip.
wire  signed [15:0] sout0, sout1, sout2, sout3, sout4, sout5, sout6, sout7, sout8, sout9, sout10, sout11, sout12, sout13, sout14, sout15;
parameter N0 = 24, N1 = 24; // Number of DAC channels in the channel sequences
wire [2:0] CH0d [0:N0-1]; // Channel sequence for chip0.
wire [2:0] CH1d [0:N1-1]; // Channel sequence for chip1.
//Debug outputs
wire [23:0] data_out0d, data_out1d;
wire sDAC1_CS_d;
// Correction for bipolar error if sampling channels above 50 kSPS (unused currently)
// (max specification, see distortion and an offset at zero at higher sampling rates)
// wire signed [15:0] n0 [0:7]; 
// wire signed [15:0] n1 [0:7]; 

//// DISPLAY MODULES \\\\
// Signals to allow for a manual reset of display.
wire EN_rst_disp; // Display reset, either after the FPGA is programmed, or from the serial input.
reg EN_rst_disp_spr; // Display reset from the serial input
reg [31:0] cntrsthld; // Signals to reset the display during the reset of the FPGA after programming.
reg rst_trig, rsthld;
wire rstd; // reset for the shift register module, which resets the display.

// RELOCK LEDS generates the logic signals when unlocked, or unlocked in the past 5 seconds.
wire [1:0] out_relockleds_0, out_relockleds_1, out_relockleds_2, out_relockleds_3, out_relockleds_4, out_relockleds_5, out_relockleds_6, out_relockleds_7, out_relockleds_8;

(* DONT_TOUCH *)
wire CS0, CS1, PD, SDO, SCK, // Display SPI bus signals
     SDI, INT,
     // Shift register signals
     out0,  out1,  out2,  out3,  out4,  out5,  out6,  out7, 
     out8,  out9,  out10, out11, out12, out13, out14, out15,
     out16, out17, out18, out19, out20, out21, out22, out23, 
     in0,  in1,  in2,  in3,  in4,  in5,  in6,  in7, 
     in8,  in9,  in10, in11, in12, in13, in14, in15,
     in16, in17, in18, in19, in20, in21, in22, in23;

(* DONT_TOUCH *)
wire [5:0] cnt_rst; // Counters for the display module.
wire [4:0] bitcount;
wire [1:0] inc1_I, inc1_P, inc1_D, inc1_fL; // Gain increment counters, currently unused.
wire Nrst1; // For gain increment logic, currently unused.
// Low-pass filtered temperature error signals for color indicators on the display.
wire signed [15:0] 
    disp_temp_0_in,
    disp_temp_1_in, disp_temp_2_in, disp_temp_3_in, disp_temp_4_in, disp_temp_5_in,
    disp_temp_6_in, disp_temp_7_in, disp_temp_8_in, disp_temp_9_in, disp_temp_10_in;
// Color state for temperature servo indicators on the display.
wire [1:0] clr_temp_0_in, 
           clr_temp_1_in, clr_temp_2_in, clr_temp_3_in, clr_temp_4_in, clr_temp_5_in, 
           clr_temp_6_in, clr_temp_7_in, clr_temp_8_in, clr_temp_9_in, clr_temp_10_in;
reg clr_on0 = 0; // Delayed enable for temperature display filters.
reg [23:0] on_cnt = 24'hffffff; // Counter for delayed turn on of temperature display filters.
parameter signed [15:0] fmin = 16'h8000, fmax = 16'h7FFF; // Limits for temperature display filters

// 16-bit output shift register signals
wire outB0, outB1, outB2,  outB3,  outB4,  outB5,  outB6,  outB7, 
     outB8, outB9, outB10, outB11, outB12, outB13, outB14, outB15;

////**** END OF SIGNAL DECLARATIONS ****\\\\

////**** SIGNAL ASSIGNMENTS ****\\\\
// Flip signs of slow inputs and outputs to account for inverting amps.
SignFlip SignFlip_inst(
    sADC_clk, clk20, 
    s_in_0_int, s_in_1_int, s_in_2_int, s_in_3_int, s_in_4_int, s_in_5_int, s_in_6_int, s_in_7_int, s_in_8_int, s_in_9_int, s_in_10_int, s_in_11_int, s_in_12_int, s_in_13_int, s_in_14_int, s_in_15_int,	
    sout0_int,  sout1_int,  sout2_int,  sout3_int,  sout4_int,  sout5_int,  sout6_int,  sout7_int, sout8_int,  sout9_int,   sout10_int,  sout11_int,  sout12_int,  sout13_int,  sout14_int,  sout15_int,
    s_in_0, s_in_1, s_in_2, s_in_3, s_in_4, s_in_5, s_in_6, s_in_7, s_in_8, s_in_9, s_in_10, s_in_11, s_in_12, s_in_13, s_in_14, s_in_15,
    sout0,  sout1,  sout2,  sout3,  sout4,  sout5,  sout6,  sout7,  sout8,  sout9,  sout10,  sout11,  sout12,  sout13,  sout14,  sout15
);

//// FAST ADC'S SPI \\\\
// Turn off fADC's if the STOP SERVOS button is pressed and the 1083 reference cavity servo is set to STOP mode.
// The fADC's will turn off 30 seconds after ADCOFF goes HIGH.
// If ADCOFF goes LOW before 30 seconds pass, the sleep command is not sent to the fast ADC's, to avoid unintended shutdowns.
assign ADCOFF = STOPservos && stop1083; 

//// SLOW ADC'S \\\\
assign sADC_rst = rst;
// Channel sequence
assign SEQ[0]  = 3'd0;
assign SEQ[1]  = 3'd1;
assign SEQ[2]  = 3'd2;
assign SEQ[3]  = 3'd3;
assign SEQ[4]  = 3'd4;
assign SEQ[5]  = 3'd5;
assign SEQ[6]  = 3'd6;
assign SEQ[7]  = 3'd7;
assign SEQ[8]  = 3'd0;
assign SEQ[9]  = 3'd1;
assign SEQ[10] = 3'd2;
assign SEQ[11] = 3'd3;
assign SEQ[12] = 3'd4;
assign SEQ[13] = 3'd5;
assign SEQ[14] = 3'd6;
assign SEQ[15] = 3'd7;
assign SEQ[16] = 3'd0;
assign SEQ[17] = 3'd1;
assign SEQ[18] = 3'd2;
assign SEQ[19] = 3'd3;
assign SEQ[20] = 3'd4;
assign SEQ[21] = 3'd5;
assign SEQ[22] = 3'd6;
assign SEQ[23] = 3'd7; 
// Power down signals
assign sADC0_PD = PDall; // Slow ADC 0 powers down along with the fast DAC's.
assign sADC1_PD = 0; // Slow ADC 1, which reads the temperature servo inputs, does not power down.

/// Power down signals for fast DAC's and slow ADC 0.
// If FM_MOT_state is OFF and STOPservos is true, PDtrig is 1'b0.
assign PDtrig = !((FM_MOT_state == 'b0) && STOPservos);
// This power-down for the 1083 reference cavity fast DAC, goes low if PDtrig is low AND stop1083 is pressed.
assign PDtrig1 = PDtrig || !stop1083; 

//// SERIAL LINE \\\\
assign serial_in      = C12; // C12
assign serial_trig_in = A14; // A14

//// OTHER DIGITAL OUTPUTS \\\\
assign B14 = 0;
assign A15 = 0;
assign B15 = 0;
assign A19 = 0;
assign U16 = 0;
assign M22 = 0;
assign R26 = 0;
assign P26 = 0;
assign N26 = 0;
assign M25 = 0;
assign L25 = 0;
assign M26 = 0;

//// CAVITY SERVO ASSIGNMENTS \\\\
/// TRANSMISSION, REFLECTION, AND ERROR SIGNAL ASSIGNMENTS
assign trans0_in = s_in_0;
assign trans1_in = s_in_1;
assign ref2_in   = s_in_2;
assign trans2_in = s_in_3;
assign trans3_in = s_in_9; // Transmission for the 1083 reference cavity is on the slow ADC chip that does not power down.
assign trans4_in = s_in_5;
assign sfg5_in   = s_in_6;
assign trans6_in = s_in_8;
assign trans7_in = s_in_13;
assign trans8_in = f_in_8;
assign e0_in     = f_in_0;
assign e1_in     = f_in_1;
assign e2_in     = f_in_2;
assign e3_in     = f_in_3;
assign e4_in     = f_in_4;
assign e6_in     = f_in_5;
assign e7_in     = f_in_7;
assign e8_in     = f_in_9;

assign LBOff_in    = s_in_7;
assign BBO542ff_in = s_in_7; 
assign BBO820ff_in = s_in_7;
assign offset820_in = s_in_4;

assign scan_CS7 = in7;
assign stop_CS7 = in8;
assign scan_CS8 = in9;
assign stop_CS8 = in10;

//// FM MOT SCAN \\\\
// Pipeline and scale input for gated integrator of FM-MOT module.
always @(posedge clk100) begin
    FMin0 <= -f_in_6;
    FMin1 <= FMin0;
    FMin2 <= FMin1 <<< N_P; // Scaled input for filters
end
// Assign input, with no scaling.
assign FMin = FMin1; 

//// TEMPERATURE SERVOS \\\\
// Input signal assignments
assign Tcd_in  = s_in_11; // Use s_in_11 (+-10 V range)
assign Tref_in = s_in_12; // Use s_in_12 (+-10 V range)
assign T2_in   = s_in_10; // Use s_in_10 (+-10 V range)
assign T3_in   = s_in_10; // Use s_in_10 (+-10 V range)
assign T4_in   = s_in_10; // Use s_in_10 (+-10 V range)
assign T5_in   = s_in_15; // Use s_in_15 (+-10 V range)
assign T6_in   = s_in_10; // Use s_in_13 (+-10 V range)
assign T7_in   = s_in_14; // Use s_in_14 (+-10 V range)
assign T8_in   = s_in_15; // Use s_in_15 (+-10 V range)
assign T9_in   = s_in_15; // Use s_in_15 (+-10 V range)

//// FAST DAC'S \\\\
// Fast DAC output assignments
assign f_out_0  = servo0out;
assign f_out_1  = servo1out;
assign f_out_2  = servo2out;
assign f_out_3  = servo3out;
assign f_out_4  = servo4out;
assign f_out_5  = servo5out;
assign f_out_6  = -FM;
assign f_out_7  = Int;
assign f_out_8  = cI;
assign f_out_9  = varOut0;
assign f_out_10 = varOut1;
assign f_out_11 = servo6out;
assign f_out_12 = servo7out;
assign f_out_13 = servo8out;

// Power down signals, set to 0 to be always on.
assign fDAC0_PD = PDall;
assign fDAC1_PD = PDall1; // This chip has the output for the 1083 reference cavity servo.
assign fDAC2_PD = PDall;
assign fDAC3_PD = PDall;
assign fDAC4_PD = PDall;
assign fDAC5_PD = PDall;
assign fDAC6_PD = PDall;

//// SLOW DAC'S \\\\
assign sout0_int  = demod_in_sel1_dg;   // 542-326 demodulation
assign sout1_int  = demod_in_sel2_dg;   // 820 demodulation
assign sout2_int  = demod_in_sel4_dg;   // 542-361 demodulation
assign sout3_int  = {fr0_out, fr1_out}; // Fast ADC chips 0 and 1 frames
assign sout4_int  = {fr2_out, fr3_out}; // Fast ADC chips 2 and 3 frames
assign sout5_int  = e3_in;              // 1083 ref error signal
assign sout6_int  = e0_in;              // LBO error signal
assign sout7_int  = e1_in;              // 542-326 error signal
assign sout8_int  = e2_in;              // 820 error signal
assign sout9_int  = e3_in;              // 542-361 error signal
assign sout10_int = trans4_in;          // 542-361 transmission
assign sout11_int = sfg5_in;            // 361 SFG output
assign sout12_int = trans3_in;          // 1083 ref transmission
assign sout13_int = trans0_in;          // LBO transmission
assign sout14_int = trans1_in;          // 542-326 transmission
assign sout15_int = trans2_in;          // 820 transmission

// Outputs for debugging reference cavity temperature servo
// assign sout4_int  = Tref_in_dg;               // Input from slow ADC
// assign sout5_int  = offset_REF_dg[15:0];      // Offset
// assign sout6_int  = sp_REF_dg[15:0];          // Set-point
// assign sout7_int  = 0;                        // 0
// assign sout8_int  = VDC_REF_in_dg[15:0];      // Tref_in + offset_REF - sp_REF
// assign sout9_int  = Nprst_REF_dg[17:2];       // Preset/4
// assign sout10_int = NHpre_REF_dg;             // I+P+D (LSB's) after sum/rounding before multiplication
// assign sout11_int = NH_in_REF_dg[17:2];       // [PID_output + Nprst_REF (input to VDC module)]/4
// assign sout12_int = NHi_REF_dg;               // Integral
// assign sout13_int = NHp_REF_dg;               // Proportional
// assign sout14_int = NHd_REF_dg;               // Differential
// assign sout15_int = NHpost_REF_dg;            // I+P+D (LSB's) after multiplication

// Outputs for debugging Cd oven temperature servo
// assign sout4_int  = Tcd_in_dg;               // Input from slow ADC
// assign sout5_int  = offset_Cd_dg[15:0];      // Offset
// assign sout6_int  = sp_Cd_dg[15:0];          // Set-point
// assign sout7_int  = 0;                        // 0
// assign sout8_int  = VDC_Cd_in_dg[15:0];      // Tcd_in + offset_Cd - sp_Cd
// assign sout9_int  = Nprst_Cd_dg[17:2];       // Preset/4
// assign sout10_int = NHpre_Cd_dg;             // I+P+D (LSB's) after sum/rounding before multiplication
// assign sout11_int = NH_in_Cd_dg[17:2];       // [PID_output + Nprst_Cd (input to VDC module)]/4
// assign sout12_int = NHi_Cd_dg;               // Integral
// assign sout13_int = NHp_Cd_dg;               // Proportional
// assign sout14_int = NHd_Cd_dg;               // Differential
// assign sout15_int = NHpost_Cd_dg;            // I+P+D (LSB's) after multiplication

// Channel sequence for slow DAC0
assign CH0d[0]  = 0;
assign CH0d[1]  = 1;
assign CH0d[2]  = 2;
assign CH0d[3]  = 3;
assign CH0d[4]  = 4;
assign CH0d[5]  = 5;
assign CH0d[6]  = 6;
assign CH0d[7]  = 7;
assign CH0d[8]  = 0;
assign CH0d[9]  = 1;
assign CH0d[10] = 2;
assign CH0d[11] = 3;
assign CH0d[12] = 4;
assign CH0d[13] = 5;
assign CH0d[14] = 6;
assign CH0d[15] = 7;
assign CH0d[16] = 0;
assign CH0d[17] = 1;
assign CH0d[18] = 2;
assign CH0d[19] = 3;
assign CH0d[20] = 4;
assign CH0d[21] = 5;
assign CH0d[22] = 6;
assign CH0d[23] = 7;
// Same channel sequence for both slow DAC's
assign CH1d = CH0d;
// // Bipolar correction if sampling channels above 50 kSPS 
// // (max specification, see distortion and an offset at zero above this) 
// assign n0[0] = 0, n0[1] = 0, n0[2] = 0, n0[3] = 0, n0[4] = 0, n0[5] = 0, n0[6] = 0, n0[7] = 0;
// assign n1[0] = 0, n1[1] = 0, n1[2] = 0, n1[3] = 0, n1[4] = 0, n1[5] = 0, n1[6] = 0, n1[7] = 0;

//// DISPLAY MODULES \\\\

// The display is reset by its own instance of reset.v, which is enabled by the serial input line (EN_rst_disp_spr) or by reset.v after the FPGA is programmed. 
// Because the reset after the FPGA is programmed does not stay high long enough to trigger the display's reset, it is instead enabled by rsthld, which goes HIGH after the FPGA is programmed and stays HIGH for long enough to enable the display's reset.
always @(posedge clk100) begin
    if (rst_trig) begin
        if (cntrsthld <50_000) begin
            rsthld <= 1;
            cntrsthld <= cntrsthld + 1;
        end else begin
            rsthld <= 0;
            cntrsthld <= cntrsthld;
            rst_trig <= 0;
        end
    end else begin
        if (rst) rst_trig <= 1;
        rsthld <= 0;
        cntrsthld <= 0;
    end
end
// The display resets after the FPGA is programmed, or from the serial input.
assign EN_rst_disp = EN_rst_disp_spr||rsthld;

// Assign shift-register outputs.
assign out0  = SCK; 
assign out1  = SDO; 
assign out2  = PD; 
assign out3  = CS0; 
assign out4  = CS1;
assign out5  = VDC_Cd; 
assign out6  = VDC_REF; 
assign out7  = VDC_6;
assign out8  = VDC_7;
assign out9  = VDC_8;
assign out10 = 0;
assign out11 = 0;
assign out12 = VDC_2;
assign out13 = VDC_3;
assign out14 = VDC_4;
assign out15 = 0;//VDC_5; // Temp Controller 5 disabled
assign out16 = 0;//VDC_9; // Temp Controller 9 disabled
assign out17 = 0;
assign out18 = out_relockleds_7[0];
assign out19 = out_relockleds_7[1];
assign out20 = out_relockleds_8[0];
assign out21 = out_relockleds_8[1];
assign out22 = 0;
assign out23 = FMtrigD;

// Signal for adjustable gain buttons, currently unused.
assign Nrst1 = 0;
// Delayed enable of the temperature display filters, e.g., after the FPGA is programmed
always@(posedge clk100) begin
    if (on_cnt > 0) begin
        clr_on0 <= 0;
        on_cnt <= on_cnt - 1;
    end
    else begin
        clr_on0 <= 1;
        on_cnt <= 0;
    end
end
// Set unused temperature indicators to dark blue. (Indicators 9 and 10 monitor the serial line input handshaking and fADC frames.)
assign disp_temp_5_in = 'd100;

// 16-bit shift register B output assignments
assign outB0  = fDAC0_PD;
assign outB1  = fDAC1_PD;
assign outB2  = fDAC2_PD;
assign outB3  = fDAC3_PD;
assign outB4  = fDAC4_PD;
assign outB5  = fDAC5_PD;
assign outB6  = fDAC6_PD;
assign outB7  = sADC0_PD;
assign outB8  = sADC1_PD;
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
// Phase shifted clocks for sADC from here 
GlobalClocks#(
    div0b, div1b, div2b, div3b, div4b, div5b, div6b,
    phs0b, phs1b, phs2b, phs3b, phs4b, phs5b, phs6b,
    mmcm1loc)
GlobalClocks_inst1(clkg, rst0, sADC_clk_int, sADC_clk_out, sADC_clk_in_int, clk20_int, clk50_int, clk5_in, clk6_in);
(* LOC = "BUFGCTRL_X0Y8" *)BUFG BUFG_5(.O(sADC_clk), .I(sADC_clk_int)); 
(* LOC = "BUFGCTRL_X0Y9" *)BUFG BUFG_6(.O(sADC_clk_in), .I(sADC_clk_in_int)); 
(* LOC = "BUFGCTRL_X0Y10" *)BUFG BUFG_7(.O(clk20), .I(clk20_int)); 
(* LOC = "BUFGCTRL_X0Y11" *)BUFG BUFG_8(.O(clk50), .I(clk50_int)); 

// 125 kHz clock
gated_clk#(10'd800)gated_clk_125kHz(clk100, clk125kHz);

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

// SLOW ADC'S \\\\
SlowADCs #(N, N_CNV, N_CH) 
SlowADCs_inst(
    sADC_clk, sADC_clk_in, sADC_rst, 
    sADC_SCKO0,sADC_SCKO1, sADC_SDO0, sADC_SDO1, sADC_BUSY0, sADC_BUSY1, 
    sADC_CNV, sADC_SCKI, sADC_SDI, sADC_CS0, sADC_CS1, 
    SEQ, 
    s_in_0_int, s_in_1_int, s_in_2_int,  s_in_3_int,  s_in_4_int,  s_in_5_int,  s_in_6_int,  s_in_7_int, 
    s_in_8_int, s_in_9_int, s_in_10_int, s_in_11_int, s_in_12_int, s_in_13_int, s_in_14_int, s_in_15_int
);

/// Fast DAC and Slow ADC Power Down Signals
Sig1Dly Sig1Dly_PD_INST( clk125kHz, PDtrig,  cntMAX_PD, PDall);
Sig1Dly Sig1Dly_PD_INST1(clk125kHz, PDtrig1, cntMAX_PD, PDall1);

//// SERIAL LINE \\\\
serialLine serial0(
   clk100,
   serial_in, serial_trig_in,
   handshake_i, handshake_f,
   x1,  x2,  x3,  x4,  x5,  x6,  x7,  x8,  x9, 
   x10, x11, x12, x13, x14, x15, x16, x17, x18, 
   x19, x20, x21, x22, x23, x24, x25, x26, x27
);

//// CAVITY SERVOS \\\\
CavServos#(N_B, N_P, SIGNAL_SIZE)
CavServos_inst(
    // Clock, PID enables, and filter signs.
    clk100, clk125kHz,
    STOPservos, stopLBO, stop542_326, stop820, stop1083, stop542_361, stop1083_361, stop_CS6, stop_CS7, stop_CS8,
    scanLBO, scan542_326, scan820, scan1083, scan542_361, scan1083_361, scan_CS6, scan_CS7, scan_CS8,
    dithEN, // dither enable
    // Relock parameters
    locktrig0, stop_sweep_0, start_sweep_0, // Threshold for lock, sweep maximum, sweep minimum
    locktrig1, stop_sweep_1, start_sweep_1, // Threshold for lock, sweep maximum, sweep minimum
    locktrig2, amp_sweep_2, mean_sweep_2, mean820sh, // Threshold for lock, sweep amplitude, sweep mean, static shift to mean
    locktrig3, amp_sweep_3, mean_sweep_3,  // Threshold for lock, sweep amplitude, sweep mean
    locktrig4, stop_sweep_4, start_sweep_4, // Threshold for lock, sweep maximum, sweep minimum
    locktrig5, amp_sweep_5, mean_sweep_5, mean1083_361sh, // Threshold for lock, sweep amplitude, sweep mean, static shift to mean
    locktrig6, stop_sweep_6, start_sweep_6, // Threshold for lock, sweep maximum, sweep minimum
    locktrig7, stop_sweep_7, start_sweep_7, // Threshold for lock, sweep maximum, sweep minimum
    locktrig8, stop_sweep_8, start_sweep_8, // Threshold for lock, sweep maximum, sweep minimum
    // Sweep rate
    sweep_rate_0, sweep_rate_1, sweep_rate_2, sweep_rate_3, sweep_rate_4, sweep_rate_5, sweep_rate_6, sweep_rate_7, sweep_rate_8,
    // static error signal offset
    offset0s, offset1s, offset2s, offset3s, offset4s, offset5s, offset6s, offset7s, offset8s,
    // Right bit shift of modulation signal
    mod0scaling, mod1scaling, mod2scaling, mod3scaling, mod4scaling, mod5scaling, mod6scaling, mod7scaling, mod8scaling,
    // Clock dividers that set modulation frequency f_clk/(60*divFast*divSlow).     
    divFast0, divSlow0, divFast1, divSlow1, divFast2, divSlow2, divFast3, divSlow3, divFast4, divSlow4, divFast5, divSlow5, 
    divFast6, divSlow6, divFast7, divSlow7, divFast8, divSlow8,
    // Dither inhibit mode. Sets the phase of the inhtrig output from DitherLock.
    inhmode0, inhmode1, inhmode2, inhmode3, inhmode4, inhmode5, inhmode6, inhmode7, inhmode8,
    // Demodulation signs.
    demod_bit0, demod_bit1, demod_bit2, demod_bit3, demod_bit4, demod_bit5, demod_bit6, demod_bit7, demod_bit8,
    // Sets demodulation quadrature: 0 is cos, 1 is sin 
    mod_sel0, mod_sel1, mod_sel2, mod_sel3, mod_sel4, mod_sel5, mod_sel6, mod_sel7, mod_sel8,
    // Dither lock integrator gains.
    bitshift0, bitshift1, bitshift2, bitshift3, bitshift4, bitshift5, bitshift6, bitshift7, bitshift8,
    // Inputs to filters.
    e0_in, e1_in, e2_in, e3_in, e4_in, e6_in, e7_in, e8_in,
    trans0_in, trans1_in, trans2_in, ref2_in, trans3_in, trans4_in, sfg5_in, trans6_in, trans7_in, trans8_in,                                    
    PID0_on, PID1_on, PID2_on, PID3_on, PID4_on, PID5_on, PID6_on, PID7_on, PID8_on,
    is_neg0, is_neg1, is_neg2, is_neg3, is_neg4, is_neg5, is_neg6, is_neg7, is_neg8,
    // PID gains and frequencies.
    NFI0, NI0, NFP0, NP0, ND0, NFD0, NGD0,
    NFI1, NI1, NFP1, NP1, ND1, NFD1, NGD1,
    NFI2, NI2, NFP2, NP2, ND2, NFD2, NGD2,
    NFI3, NI3, NFP3, NP3, ND3, NFD3, NGD3,
    NFI4, NI4, NFP4, NP4, ND4, NFD4, NGD4,
    NFI5, NI5, NFP5, NP5, ND5, NFD5, NGD5,
    NFI6, NI6, NFP6, NP6, ND6, NFD6, NGD6,
    NFI7, NI7, NFP7, NP7, ND7, NFD7, NGD7,
    NFI8, NI8, NFP8, NP8, ND8, NFD8, NGD8,
    // Feed-forward inputs
    LBOff_in, BBO542ff_in, BBO820ff_in, offset820_in,
    // PID outputs.
    servo0out, servo1out, servo2out, servo3out, servo4out, servo5out, servo6out, servo7out, servo8out,
    // Debug signals for LBO
    // Modulation, scaled modulation, cos demodulation, sin demodulation, dither lock integrator input, dither lock integrator output, 
    mod0_dg, mod0sc_dg, demod0_dg, demod0Q_dg, demod_in_sel0_dg, offset0_dg,
    // Debug signals for 326-542
    mod1_dg, mod1sc_dg, demod1_dg, demod1Q_dg, demod_in_sel1_dg, offset1_dg,
    // Debug signals for 820
    mod2_dg, mod2sc_dg, demod2_dg, demod2Q_dg, demod_in_sel2_dg, offset2_dg,
    // Debug signals for 1083 ref
    mod3_dg, mod3sc_dg, demod3_dg, demod3Q_dg, demod_in_sel3_dg, offset3_dg,
    // Debug signals for 361-542
    mod4_dg, mod4sc_dg, demod4_dg, demod4Q_dg, demod_in_sel4_dg, offset4_dg,
    // Debug signals for 361-1083
    mod5_dg, mod5sc_dg, demod5_dg, demod5Q_dg, demod_in_sel5_dg, offset5_dg,
    // Debug signals for 332
    mod6_dg, mod6sc_dg, demod6_dg, demod6Q_dg, demod_in_sel6_dg, offset6_dg,
    // Debug signals for cavity servo 7
    mod7_dg, mod7sc_dg, demod7_dg, demod7Q_dg, demod_in_sel7_dg, offset7_dg,
    // Debug signals for cavity servo 8
    mod8_dg, mod8sc_dg, demod8_dg, demod8Q_dg, demod_in_sel8_dg, offset8_dg
);

//// SELECTABLE OUTPUT \\\\
// Selectable Output Module Instance 0
SelectableOutput15 SelectableOutput15_INST0(
    clk100, selFM0,
//  0        1          2          3           
    mod0_dg, mod0sc_dg, demod0_dg, demod0Q_dg, 
//  4        5          6          7
    mod1_dg, mod1sc_dg, demod1_dg, demod1Q_dg, 
//  8        9          10         11
    mod2_dg, mod2sc_dg, demod2_dg, demod2Q_dg,
//  12       13         14         15 (unchanged)
    FMin,    FMIntDiff, FMIntDiffDiff,
    // Selectable output
    varOut0
);
// Selectable Output Module Instance 1
SelectableOutput15 SelectableOutput15_INST1(
    clk100, selFM1,
//  0        1          2          3           
    mod3_dg, mod3sc_dg, demod3_dg, demod3Q_dg, 
//  4        5          6          7
    mod4_dg, mod4sc_dg, demod4_dg, demod4Q_dg, 
//  8        9          10         11
    mod5_dg, mod5sc_dg, demod5_dg, demod5Q_dg,
//  12       13         14         15 (unchanged)
    FMin,    FMIntDiff, FMIntDiffDiff,
    // Selectable output
    varOut1
);

//// FM MOT SCAN \\\\
// Assign parameters for the FM_MOT modes.
FM_MOT_PARAM_ASSIGN#(N_B)FM_MOT_PARAM_ASSIGN_inst(
    clk100, FM_MOT_state,
    // Input parameters (OFF, mode=0)
    FMon_0, FMdivFast_0, FMdivSlow_0, FMsc_0, FMmean_0, dtD_0, dt1_0, dt2_0, dt3_0, dtUP_0, dtDOWN_0, D1_0, D2_0, DUP_0, DDOWN_0,
    FMIntMax_0, dt4_0, dt5_0, dt6_0, D5_0, D6_0, dt8_0, FMINTBS_0, FMDEMCBS_0, FMDEMSBS_0, cImin_0, DcI_0, selFM0_0, selFM1_0, selFM2_0,
    // Input parameters (saturated absorption, mode=1)
    FMon_1, FMdivFast_1, FMdivSlow_1, FMsc_1, FMmean_1, dtD_1, dt1_1, dt2_1, dt3_1, dtUP_1, dtDOWN_1, D1_1, D2_1, DUP_1, DDOWN_1,
    FMIntMax_1, dt4_1, dt5_1, dt6_1, D5_1, D6_1, dt8_1, FMINTBS_1, FMDEMCBS_1, FMDEMSBS_1, cImin_1, DcI_1, selFM0_1, selFM1_1, selFM2_1,
    // Input parameters (FM MOT, mode=2)
    FMon_2, FMdivFast_2, FMdivSlow_2, FMsc_2, FMmean_2, dtD_2, dt1_2, dt2_2, dt3_2, dtUP_2, dtDOWN_2, D1_2, D2_2, DUP_2, DDOWN_2,
    FMIntMax_2, dt4_2, dt5_2, dt6_2, D5_2, D6_2, dt8_2, FMINTBS_2, FMDEMCBS_2, FMDEMSBS_2, cImin_2, DcI_2, selFM0_2, selFM1_2, selFM2_2,
    // Input parameters (361nm MET MOT, mode=2)
    FMon_3, FMdivFast_3, FMdivSlow_3, FMsc_3, FMmean_3, dtD_3, dt1_3, dt2_3, dt3_3, dtUP_3, dtDOWN_3, D1_3, D2_3, DUP_3, DDOWN_3,
    FMIntMax_3, dt4_3, dt5_3, dt6_3, D5_3, D6_3, dt8_3, FMINTBS_3, FMDEMCBS_3, FMDEMSBS_3, cImin_3, DcI_3, selFM0_3, selFM1_3, selFM2_3,
    // Output parameters (to FM_MOT module)
    FMon, FMdivFast, FMdivSlow, FMsc, FMmean, dtD, dt1, dt2, dt3, dtUP, dtDOWN, D1, D2, DUP, DDOWN, 
    FMIntMax, dt4, dt5, dt6, D5, D6, dt8, FMINTBS, FMDEMCBS, FMDEMSBS, cImin, DcI, selFM0, selFM1, selFM2
);
// Module declaration.
FM_MOT#(FMINTSC, FMDEMODSC)
FM_MOT0(
   clk100, FM_MOT_state, FMon, FMin,
   // FM parameters 
   FMdivFast, FMdivSlow, FMmean, FMsc, 
   dtD, dt1, D1, dt2, D2, dt3, dtUP, DUP, dtDOWN, DDOWN, 
   // Intensity ramp parameters
   FMIntMax, dt4, dt5, D5, dt6, D6, 
   // Integration parameters
   dt8, FMINTBS, FMDEMCBS, FMDEMSBS, 
   // Gated integrator and demodulation, FM trigger, and FM and intensity ramp outputs
   FMIntDiff, FMIntDiffDiff, FMdemodCOS, FMdemodSIN, FMtrigD, FM, Int, 
   // MOT coil signal, and enable signals for cavity dithers and DSP ram module.
   cI, dithEN, memtrig
);
// Saves FM-MOT difference and difference-of-difference signals, and outputs them to an ILA.
fmMOTmem#(MOTMEMSIZE, MOTMEMSIGSIZE, MOTADDRWIDTH)fmMOTmem_inst(clk100, memtrig, FMIntDiff, FMIntDiffDiff, MOTDiffMem, MOTDiffDiffMem, read_addr);

//// TEMPERATURE SERVOS \\\\
TempServos#(
    // IO length for PID filters, and multiplier width
    TSCd_FILTER_IO_SIZE, TSREF_FILTER_IO_SIZE,
        TS2_FILTER_IO_SIZE, TS3_FILTER_IO_SIZE, TS4_FILTER_IO_SIZE, TS5_FILTER_IO_SIZE,
        TS6_FILTER_IO_SIZE, TS7_FILTER_IO_SIZE, TS8_FILTER_IO_SIZE,
        TS9_FILTER_IO_SIZE,
        multCdBits, multREFBits, mult2Bits, mult3Bits, mult4Bits, 
        mult5Bits,  mult6Bits,   mult7Bits, mult8Bits, mult9Bits
)TempServos_inst(
    clk100, clk125kHz, rst,
    Cd_oven_state,
    // Temperature error signals.
    Tcd_in, Tref_in, T2_in, T3_in, T4_in, T5_in, T6_in, T7_in, T8_in, T9_in,
    // PID gains
    NFI_Cd_3, NI_Cd_3, NFP_Cd_3, NP_Cd_3, ND_Cd_3, NFD_Cd_3, NGD_Cd_3,
    NFI_REF,   NI_REF,   NFP_REF,   NP_REF,   ND_REF,   NFD_REF,   NGD_REF, 
    NFI_2,     NI_2,     NFP_2,     NP_2,     ND_2,     NFD_2,     NGD_2,
    NFI_3,     NI_3,     NFP_3,     NP_3,     ND_3,     NFD_3,     NGD_3,
    NFI_4,     NI_4,     NFP_4,     NP_4,     ND_4,     NFD_4,     NGD_4,
    NFI_5,     NI_5,     NFP_5,     NP_5,     ND_5,     NFD_5,     NGD_5,
    NFI_6,     NI_6,     NFP_6,     NP_6,     ND_6,     NFD_6,     NGD_6,
    NFI_7,     NI_7,     NFP_7,     NP_7,     ND_7,     NFD_7,     NGD_7,
    NFI_8,     NI_8,     NFP_8,     NP_8,     ND_8,     NFD_8,     NGD_8,
    NFI_9,     NI_9,     NFP_9,     NP_9,     ND_9,     NFD_9,     NGD_9,
    TS_on_Cd_3, is_neg_Cd_3,
    TS_on_REF,   is_neg_REF,
    TS_on_2,     is_neg_2,
    TS_on_3,     is_neg_3,
    TS_on_4,     is_neg_4,
    TS_on_5,     is_neg_5,
    TS_on_6,     is_neg_6,
    TS_on_7,     is_neg_7,
    TS_on_8,     is_neg_8,
    TS_on_9,     is_neg_9,
    sp_Cd_3, offset_Cd_3, SHDN_Cd_3, 
    sp_REF,  offset_REF,  SHDN_REF,
    sp_2, offset_2, SHDN_2,
    sp_3, offset_3, SHDN_3,
    sp_4, offset_4, SHDN_4,
    sp_5, offset_5, SHDN_5,
    sp_6, offset_6, SHDN_6,
    sp_7, offset_7, SHDN_7,
    sp_8, offset_8, SHDN_8,
    sp_9, offset_9, SHDN_9,
    errmult_Cd, errmult_REF, errmult_2, errmult_3, errmult_4, errmult_5, errmult_6, errmult_7, errmult_8, errmult_9,
    // PID outputs with presets added.
    NH_Cd_out, NH_REF_out, NH_2_out, NH_3_out, NH_4_out, NH_5_out, NH_6_out, NH_7_out, NH_8_out, NH_9_out,
    // 1-bit VDC/PWM outputs
    VDC_Cd, VDC_REF, VDC_2, VDC_3, VDC_4, VDC_5, VDC_6, VDC_7, VDC_8, VDC_9,
    // Display temperature servo indicator color signals
    TSclr0, TSclr1, TSclr2, TSclr3, TSclr4, TSclr5, TSclr6, TSclr7, TSclr8, TSclr9,
    // Outputs for debugging
    // LL_REF_dg, UL_REF_dg, Nprst_REF_MAX_dg,
    // Tref_in_dg,
    // offset_REF_dg, sp_REF_dg, VDC_REF_in_dg, Nprst_REF_dg,
    // NH_in_REF_dg,
    // NHpre_REF_dg, NHi_REF_dg, NHp_REF_dg, NHd_REF_dg, NHpost_REF_dg
    LL_Cd_dg, UL_Cd_dg, Nprst_Cd_MAX_dg,
    Tcd_in_dg,
    offset_Cd_dg, sp_Cd_dg, VDC_Cd_in_dg, Nprst_Cd_dg,
    NH_in_Cd_dg,
    NHpre_Cd_dg, NHi_Cd_dg, NHp_Cd_dg, NHd_Cd_dg, NHpost_Cd_dg
    // Outputs for debugging
    // cnt_dly_Cd_out, cnt_dly_REF_out, cnt_dly_2_out, cnt_dly_3_out, cnt_dly_4_out, cnt_dly_5_out, cnt_dly_6_out, cnt_dly_7_out, cnt_dly_8_out, cnt_dly_9_out,
    // cnt_Cd_out,     cnt_REF_out,     cnt_2_out,     cnt_3_out,     cnt_4_out,     cnt_5_out,     cnt_6_out,     cnt_7_out,     cnt_8_out,     cnt_9_out,
    // cnt_out_VDCsync
);

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

//// SLOW DAC'S \\\\
// Clock is 20 MHz to allow channels to be read at the max specified rate of 50 kSPS.
SlowDACs#(N0, N1)
sDACinst(
   clk20, rst, // Clock and reset
   sDAC_SDO, sDAC_SCK, sDAC0_CS, sDAC1_CS, sDAC_SDI, // SPI wires
   CH0d, CH1d, //n0, n1, // Channel sequences for chip 0 and chip 1
   sout0, sout1, sout2, sout3, sout4, sout5, sout6, sout7, sout8, sout9, sout10, sout11, sout12, sout13, sout14, sout15
);

//// DISPLAY MODULES \\\\
// Cavity servo lock state modules.
RelockLEDs RelockLEDs_0(clk100, !PID0_on, out_relockleds_0);
RelockLEDs RelockLEDs_1(clk100, !PID1_on, out_relockleds_1);
RelockLEDs RelockLEDs_2(clk100, !PID2_on, out_relockleds_2);
RelockLEDs RelockLEDs_3(clk100, !PID3_on, out_relockleds_3);
RelockLEDs RelockLEDs_4(clk100, !PID4_on, out_relockleds_4);
RelockLEDs RelockLEDs_5(clk100, !PID5_on, out_relockleds_5);
RelockLEDs RelockLEDs_6(clk100, !PID6_on, out_relockleds_6);
RelockLEDs RelockLEDs_7(clk100, !PID7_on, out_relockleds_7);
RelockLEDs RelockLEDs_8(clk100, !PID8_on, out_relockleds_8);
// Reset for SR_CTRL to allow for manual reset of the display module from the serial input.
reset rst_disp(clk100, EN_rst_disp, rstd);
// Shift-register controller.
(*DONT_TOUCH*)
SR_CTRL SR_CTRL0(
    // Reset and clock input (use the same as the display), and shift register clock output
    rstd, clk50, SR_SCLK,
    // Controls for and from the display program
    cnt_rst, bitcount, active, data_active,
    // OUTPUTS TO SR
    out23, out22, out21, out20, out19, out18, out17, out16, 
    out15, out14, out13, out12, out11, out10, out9,  out8,
    out7,  out6,  out5,  out4,  out3,  out2,  out1,  out0,
    // INPUT SIGNALS FROM INPUT SHIFT-REGISTER
    SDI,  INT,  in2,  in3,  in4,  in5,  in6,  in7, 
    in8,  in9,  in10, in11, in12, in13, in14, in15,
    in16, in17, in18, in19, in20, in21, in22, in23,
    // SHIFT-REGISTER SIGNALS
    SR_IN, SR_STROBE, SR_OUT
);

// Low-pass filters for the temperature error signal indicators on the display.
// These filters have P = 1/4 and f = 2.4 Hz. 
// Example instantiation: P1BS#(SIGNAL_SIZE, SCALING)P1BS_inst(clk, on, hold, is_neg, NF, NP, LL, UL, s_in, s_out);
P1BS#(16, 32, 1)LP0 (clk125kHz, clr_on0, 1'b0, 1'b0, -10'd52, 10'd68, fmin, fmax, TSclr0, disp_temp_0_in);
P1BS#(16, 32, 1)LP1 (clk125kHz, clr_on0, 1'b0, 1'b0, -10'd52, 10'd68, fmin, fmax, TSclr1, disp_temp_1_in);
P1BS#(16, 32, 1)LP2 (clk125kHz, clr_on0, 1'b0, 1'b0, -10'd52, 10'd68, fmin, fmax, TSclr2, disp_temp_2_in);
P1BS#(16, 32, 1)LP3 (clk125kHz, clr_on0, 1'b0, 1'b0, -10'd52, 10'd68, fmin, fmax, TSclr3, disp_temp_3_in);
P1BS#(16, 32, 1)LP4 (clk125kHz, clr_on0, 1'b0, 1'b0, -10'd52, 10'd68, fmin, fmax, TSclr4, disp_temp_4_in);
// P1BS#(16, 32, 1)LP5 (clk125kHz, clr_on0, 1'b0, 1'b0, -10'd52, 10'd68, fmin, fmax, TSclr5, disp_temp_5_in);  // Unused
P1BS#(16, 32, 1)LP6 (clk125kHz, clr_on0, 1'b0, 1'b0, -10'd52, 10'd68, fmin, fmax, TSclr6, disp_temp_6_in);
P1BS#(16, 32, 1)LP7 (clk125kHz, clr_on0, 1'b0, 1'b0, -10'd52, 10'd68, fmin, fmax, TSclr7, disp_temp_7_in);
P1BS#(16, 32, 1)LP8 (clk125kHz, clr_on0, 1'b0, 1'b0, -10'd52, 10'd68, fmin, fmax, TSclr8, disp_temp_8_in);
// P1BS#(16, 32, 1)LP9 (clk125kHz, clr_on0, 1'b0, 1'b0, -10'd52, 10'd68, fmin, fmax, TSclr9, disp_temp_9_in);  // Unused
// P1BS#(16, 32, 1)LP10(clk125kHz, clr_on0, 1'b0, 1'b0, -10'd52, 10'd68, fmin, fmax, TSclr10,disp_temp_10_in); // Unused

// Modules to set color codes for temperature servo indicators on the display.
err2clrst err2clrst_INST_0( clk50, disp_temp_0_in,  16'd33, clr_temp_0_in );
err2clrst err2clrst_INST_1( clk50, disp_temp_1_in,  16'd33, clr_temp_1_in );
err2clrst err2clrst_INST_2( clk50, disp_temp_2_in,  16'd33, clr_temp_2_in );
err2clrst err2clrst_INST_3( clk50, disp_temp_3_in,  16'd33, clr_temp_3_in );
err2clrst err2clrst_INST_4( clk50, disp_temp_4_in,  16'd33, clr_temp_4_in );
err2clrst err2clrst_INST_5( clk50, disp_temp_5_in,  16'd33, clr_temp_5_in );
err2clrst err2clrst_INST_6( clk50, disp_temp_6_in,  16'd33, clr_temp_6_in );
err2clrst err2clrst_INST_7( clk50, disp_temp_7_in,  16'd33, clr_temp_7_in );
err2clrst err2clrst_INST_8( clk50, disp_temp_8_in,  16'd33, clr_temp_8_in );
// err2clrst err2clrst_INST_9( clk50, disp_temp_9_in,  16'd33, clr_temp_9_in );
// err2clrst err2clrst_INST_10(clk50, disp_temp_10_in, 16'd33, clr_temp_10_in);

// Fast ADC frame monitor. Uses last indicator in the row of temperature error signal indicators. 
// Red means a frame is incorrect, orange means all frames are correct, but at least one was incorrect in the last 5 seconds, light blue is all are correct for more than 5 seconds.
FRmon FRmon_inst(clk100, fr0_out, fr1_out, fr2_out, fr3_out, fr4_out, clr_temp_10_in);
// Monitor for serial programming. Checks if handshakes match. Changes color of the penultimate indicator in the row of temperature error signal indicators.
// Dark blue for all 0's or all 1's (SRS off), red for non-matching nontrivial handshakes, light blue for matching nontrivial handshakes.
serialHSmon serialHSmon_inst(clk100, handshake_i, handshake_f, clr_temp_9_in);

// Display module
display disp0(
    rst, clk50,
    cnt_rst, bitcount, // inputs from SR_CTRL module.
    active, data_active,
    // Outputs to SR_CTRL
    CS0, CS1, PD, SCK, SDO, SDI,
    // Lock state indicators for servos
    out_relockleds_0, out_relockleds_1, out_relockleds_2, out_relockleds_3, out_relockleds_4, out_relockleds_5, out_relockleds_6,
    // Stop and scan servo outputs to auto-lock modules
    STOPservos, 
    scanLBO, scan542_326, scan820, scan1083, scan542_361, scan1083_361, scan_CS6,
    stopLBO, stop542_326, stop820, stop1083, stop542_361, stop1083_361, stop_CS6,
    // States for cadmium oven and fm_mot
    Cd_oven_state, FM_MOT_state,    
    // Temperature servo indicator color signals
    clr_temp_0_in, clr_temp_1_in, clr_temp_2_in, clr_temp_3_in, clr_temp_4_in, clr_temp_5_in,
    clr_temp_6_in, clr_temp_7_in, clr_temp_8_in, clr_temp_9_in, clr_temp_10_in
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

////**** FAST DAC TESTING SECTION ****\\\\

// Here we include independent full-scale ramps for each fast DAC output and simpler 3-step "small" ramps for testing.
// Only one section, FULL-SCALE RAMPS or SMALL RAMPS, should be uncommented, as well as the corresponding section of the PARAMETER REASSIGNMENT at the end of this file.
// Additionally, the above assignments of fast DAC signals (assign f_out_N = ...) should in principle be commented out when using the test ramps, although these should work without commenting out those as long as they remain above these assignments. 

//// FULL-SCALE RAMPS \\\\
// // Signals for full-scale ramps with different ramp rates to test the fast DAC's, including centering clock phases.
// localparam signed [15:0] minval = -16'd32768, maxval = 16'd32767;
// reg [31:0] stepsize0  = 32'd100, stepsize1  = 32'd200, stepsize2  = 32'd300, stepsize3  = 32'd400, stepsize4  = 32'd500, stepsize5  = 32'd600, stepsize6  = 32'd700, stepsize7  = 32'd800, stepsize8  = 32'd900, stepsize9  = 32'd1000, stepsize10 = 32'd1100, stepsize11 = 32'd1200, stepsize12 = 32'd1300, stepsize13 = 32'd1400;
// reg r0on  = 1, r1on  = 1, r2on  = 1, r3on  = 1, r4on  = 1, r5on  = 1, r6on  = 1, r7on  = 1, r8on  = 1, r9on  = 1, r10on = 1, r11on = 1, r12on = 1, r13on = 1;
// reg signed [15:0] amp0  = 16'd32000,  amp1  = 16'd32000, amp2  = 16'd32000, amp3  = 16'd32000, amp4  = 16'd32000, amp5  = 16'd32000, amp6  = 16'd32000, amp7  = 16'd32000, amp8  = 16'd32000, amp9  = 16'd32000, amp10 = 16'd32000, amp11 = 16'd32000, amp12 = 16'd32000, amp13 = 16'd32000;
// wire state_out0, state_out1, state_out2, state_out3, state_out4, state_out5, state_out6, state_out7, state_out8, state_out9, state_out10, state_out11, state_out12, state_out13;
// wire signed [15:0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13;
// // Assign full-scale ramps to outputs.
// assign f_out_0  = r0, f_out_1  = r1, f_out_2  = r2, f_out_3  = r3, f_out_4  = r4, f_out_5  = r5, f_out_6  = r6, f_out_7  = r7, f_out_8  = r8, f_out_9  = r9, f_out_10 = r10, f_out_11 = r11, f_out_12 = r12, f_out_13 = r13;
// // Sweep instances for each fDAC channel.
// Sweep#(16, "null")Sweep0( clk100, r0on,  0, -amp0,  amp0,  stepsize0 , state_out0 , r0 );
// Sweep#(16, "null")Sweep1( clk100, r1on,  0, -amp1,  amp1,  stepsize1 , state_out1 , r1 );
// Sweep#(16, "null")Sweep2( clk100, r2on,  0, -amp2,  amp2,  stepsize2 , state_out2 , r2 );
// Sweep#(16, "null")Sweep3( clk100, r3on,  0, -amp3,  amp3,  stepsize3 , state_out3 , r3 );
// Sweep#(16, "null")Sweep4( clk100, r4on,  0, -amp4,  amp4,  stepsize4 , state_out4 , r4 );
// Sweep#(16, "null")Sweep5( clk100, r5on,  0, -amp5,  amp5,  stepsize5 , state_out5 , r5 );
// Sweep#(16, "null")Sweep6( clk100, r6on,  0, -amp6,  amp6,  stepsize6 , state_out6 , r6 );
// Sweep#(16, "null")Sweep7( clk100, r7on,  0, -amp7,  amp7,  stepsize7 , state_out7 , r7 );
// Sweep#(16, "null")Sweep8( clk100, r8on,  0, -amp8,  amp8,  stepsize8 , state_out8 , r8 );
// Sweep#(16, "null")Sweep9( clk100, r9on,  0, -amp9,  amp9,  stepsize9 , state_out9 , r9 );
// Sweep#(16, "null")Sweep10(clk100, r10on, 0, -amp10, amp10, stepsize10, state_out10, r10);
// Sweep#(16, "null")Sweep11(clk100, r11on, 0, -amp11, amp11, stepsize11, state_out11, r11);
// Sweep#(16, "null")Sweep12(clk100, r12on, 0, -amp12, amp12, stepsize12, state_out12, r12);
// Sweep#(16, "null")Sweep13(clk100, r13on, 0, -amp13, amp13, stepsize13, state_out13, r13);

// //// SMALL RAMPS, 5 STEP WAVEFORMS WITH ADJUSTABLE AMPLITUDES AND OFFSETS \\\\
// // Declarations for small ramps to test LSB's and measure fast DAC bipolar offset, with amplitudes of 5 LSB.
// reg [31:0] NN0  = 32'd222_222, NN1  = 32'd222_222, NN2  = 32'd320_513, NN3  = 32'd222_222, NN4  = 32'd320_513, NN5  = 32'd111_111, NN6  = 32'd222_222, NN7  = 32'd222_222, NN8  = 32'd222_222, NN9  = 32'd222_222, NN10 = 32'd222_222, NN11 = 32'd320_513, NN12 = 32'd320_513, NN13 = 32'd320_513;
// wire signed [15:0] stp0, stp1, stp2, stp3, stp4, stp5, stp6, stp7, stp8, stp9, stp10, stp11, stp12, stp13;
// reg signed [15:0] offs0  = 1, offs1  = 0, offs2  = 0, offs3  = 0, offs4  = 0, offs5  = 0, offs6  = 0, offs7  = 0, offs8  = 0, offs9  = 0, offs10 = 0, offs11 = 2, offs12 = 0, offs13 = 0;
// wire signed [15:0] rmp_sml_0_out, rmp_sml_1_out, rmp_sml_2_out, rmp_sml_3_out, rmp_sml_4_out, rmp_sml_5_out, rmp_sml_6_out, rmp_sml_7_out, rmp_sml_8_out, rmp_sml_9_out, rmp_sml_10_out, rmp_sml_11_out, rmp_sml_12_out, rmp_sml_13_out;
// // Assign small ramps to outputs.
// assign f_out_0  = rmp_sml_0_out, f_out_1  = rmp_sml_1_out, f_out_2  = rmp_sml_2_out, f_out_3  = rmp_sml_3_out, f_out_4  = rmp_sml_4_out, f_out_5  = rmp_sml_5_out, f_out_6  = rmp_sml_6_out, f_out_7  = rmp_sml_7_out, f_out_8  = rmp_sml_8_out, f_out_9  = rmp_sml_9_out, f_out_10 = rmp_sml_10_out, f_out_11 = rmp_sml_11_out, f_out_12 = rmp_sml_12_out, f_out_13 = rmp_sml_13_out;
// assign stp0  = 1, stp1  = 1, stp2  = 1, stp3  = 1, stp4  = 1, stp5  = 1, stp6  = 1, stp7  = 1, stp8  = 1, stp9  = 1, stp10 = 1, stp11 = 1, stp12 = 1, stp13 = 1;
// // rmp_sml instances for each fDAC channel.
// rmp_sml rmp_sml0(clk100,  NN0,  stp0,  offs0,  rmp_sml_0_out);
// rmp_sml rmp_sml1(clk100,  NN1,  stp1,  offs1,  rmp_sml_1_out);
// rmp_sml rmp_sml2(clk100,  NN2,  stp2,  offs2,  rmp_sml_2_out);
// rmp_sml rmp_sml3(clk100,  NN3,  stp3,  offs3,  rmp_sml_3_out);
// rmp_sml rmp_sml4(clk100,  NN4,  stp4,  offs4,  rmp_sml_4_out);
// rmp_sml rmp_sml5(clk100,  NN5,  stp5,  offs5,  rmp_sml_5_out);
// rmp_sml rmp_sml6(clk100,  NN6,  stp6,  offs6,  rmp_sml_6_out);
// rmp_sml rmp_sml7(clk100,  NN7,  stp7,  offs7,  rmp_sml_7_out);
// rmp_sml rmp_sml8(clk100,  NN8,  stp8,  offs8,  rmp_sml_8_out);
// rmp_sml rmp_sml9(clk100,  NN9,  stp9,  offs9,  rmp_sml_9_out);
// rmp_sml rmp_sml10(clk100, NN10, stp10, offs10, rmp_sml_10_out);
// rmp_sml rmp_sml11(clk100, NN11, stp11, offs11, rmp_sml_11_out);
// rmp_sml rmp_sml12(clk100, NN12, stp12, offs12, rmp_sml_12_out);
// rmp_sml rmp_sml13(clk100, NN13, stp13, offs13, rmp_sml_13_out);

////**** END OF FAST DAC TESTING SECTION ****\\\\

////**** PARAMETER REASSIGNMENT ****\\\\
// Logical wires, HIGH if initial and final handshakes match
assign hs20 = ( (handshake_i == handshake_default + 16'd20) && (handshake_f == handshake_default + 16'd20) );
assign hs21 = ( (handshake_i == handshake_default + 16'd21) && (handshake_f == handshake_default + 16'd21) );
assign hs08 = ( (handshake_i == handshake_default + 16'd08) && (handshake_f == handshake_default + 16'd08) );
assign hs09 = ( (handshake_i == handshake_default + 16'd09) && (handshake_f == handshake_default + 16'd09) );
assign hs00 = ( (handshake_i == handshake_default + 16'd00) && (handshake_f == handshake_default + 16'd00) );
assign hs01 = ( (handshake_i == handshake_default + 16'd01) && (handshake_f == handshake_default + 16'd01) );
assign hs02 = ( (handshake_i == handshake_default + 16'd02) && (handshake_f == handshake_default + 16'd02) );
assign hs03 = ( (handshake_i == handshake_default + 16'd03) && (handshake_f == handshake_default + 16'd03) );
assign hs22 = ( (handshake_i == handshake_default + 16'd22) && (handshake_f == handshake_default + 16'd22) );
assign hs04 = ( (handshake_i == handshake_default + 16'd04) && (handshake_f == handshake_default + 16'd04) );
assign hs05 = ( (handshake_i == handshake_default + 16'd05) && (handshake_f == handshake_default + 16'd05) );
assign hs06 = ( (handshake_i == handshake_default + 16'd06) && (handshake_f == handshake_default + 16'd06) );
assign hs07 = ( (handshake_i == handshake_default + 16'd07) && (handshake_f == handshake_default + 16'd07) );
assign hs23 = ( (handshake_i == handshake_default + 16'd23) && (handshake_f == handshake_default + 16'd23) );
assign hs24 = ( (handshake_i == handshake_default + 16'd24) && (handshake_f == handshake_default + 16'd24) );
assign hs33 = ( (handshake_i == handshake_default + 16'd33) && (handshake_f == handshake_default + 16'd33) );
assign hs34 = ( (handshake_i == handshake_default + 16'd34) && (handshake_f == handshake_default + 16'd34) );
assign hs35 = ( (handshake_i == handshake_default + 16'd35) && (handshake_f == handshake_default + 16'd35) );
assign hs36 = ( (handshake_i == handshake_default + 16'd36) && (handshake_f == handshake_default + 16'd36) );
assign hs37 = ( (handshake_i == handshake_default + 16'd37) && (handshake_f == handshake_default + 16'd37) );
assign hs38 = ( (handshake_i == handshake_default + 16'd38) && (handshake_f == handshake_default + 16'd38) );
assign hs39 = ( (handshake_i == handshake_default + 16'd39) && (handshake_f == handshake_default + 16'd39) );
assign hs40 = ( (handshake_i == handshake_default + 16'd40) && (handshake_f == handshake_default + 16'd40) );
assign hs41 = ( (handshake_i == handshake_default + 16'd41) && (handshake_f == handshake_default + 16'd41) );
assign hs100 = ( (handshake_i == handshake_default + 16'd100) && (handshake_f == handshake_default + 16'd100) );
// Dummy variable that can be useful to correctly implement OOC modules. Assigning signals in the 
// parameter reassignment loop can prevent signals from being optimized away. This can be more reliable
// than using only the (* DONT_TOUCH *) attribute.
assign hsdum = ( (handshake_i == handshake_default + 16'd11) && (handshake_f == handshake_default + 16'd11) );
// Reassign parameters from serialLine
always @(posedge clk100) begin 

//// CAVITY SERVO PARAMETER REASSIGNMENTS \\\\

//**** LBO ****\\
    if (hs20) begin
        // Change servo bit shifts
        NI0 <= x1[9:0];  NP0 <= x3[9:0];  ND0 <= x5[9:0];
        NFI0 <= x2[9:0]; NFP0 <= x4[9:0]; NFD0 <= x6[9:0]; NGD0 <= x7[9:0];
        is_neg0       <= x8[0];
        // PI_on0        <= x9[0];
        // Change sweep params
        locktrig0     <= x10[15:0]; // Threshold to enable PID
        offset0s      <= x11[15:0]; // voltage offset
        start_sweep_0 <= x12[15:0]; // 16-bit signed
        stop_sweep_0  <= x13[15:0]; // 16-bit signed
        sweep_rate_0  <= x14[31:0]; // 32-bit (power of 2)
        // Frequency and amplitude of modulation and dither integration parameters
        bitshift0       <= x15[9:0];
        divFast0        <= x16[15:0];
        divSlow0        <= x17[15:0];
        mod0scaling     <= x18[15:0];
        demod_bit0      <= x19[1];
        mod_sel0        <= x19[0];
        // Mode to set phase of the trigger for dither inhibit.
        inhmode0        <= x21[3:0];
        case (FM_MOT_state) 
            0: selFM0_0 <= x24[3:0]; 
            1: selFM0_1 <= x24[3:0]; 
            2: selFM0_2 <= x24[3:0];
            3: selFM0_3 <= x24[3:0];
        endcase
        case (FM_MOT_state) 
            0: selFM1_0 <= x24[7:4]; 
            1: selFM1_1 <= x24[7:4];  
            2: selFM1_2 <= x24[7:4];  
            3: selFM1_3 <= x24[7:4];
        endcase
        EN_rst_disp_spr <= x26[24];
    end

    //**** BBO326_542 ****\\
    if (hs21) begin
        // Change servo bit shifts
        NI1 <= x1[9:0];  NP1 <= x3[9:0];  ND1 <= x5[9:0];
        NFI1 <= x2[9:0]; NFP1 <= x4[9:0]; NFD1 <= x6[9:0]; NGD1 <= x7[9:0];
        is_neg1       <= x8[0];
        // PI_on1        <= x9[0];
        // Change sweep params
        locktrig1     <= x10[15:0]; // Threshold to enable PID
        offset1s      <= x11[15:0]; // voltage offset
        start_sweep_1 <= x12[15:0]; // 16-bit signed
        stop_sweep_1  <= x13[15:0]; // 16-bit signed
        sweep_rate_1  <= x14[31:0]; // 32-bit (power of 2)
        // Frequency and amplitude of modulation and dither integration parameters
        bitshift1       <= x15[9:0];
        divFast1        <= x16[15:0];
        divSlow1        <= x17[15:0];
        mod1scaling     <= x18[15:0];
        demod_bit1      <= x19[1];
        mod_sel1        <= x19[0];
        // Mode to set phase of the trigger for dither inhibit.
        inhmode1        <= x21[3:0];
        case (FM_MOT_state) 
            0: selFM0_0 <= x24[3:0]; 
            1: selFM0_1 <= x24[3:0]; 
            2: selFM0_2 <= x24[3:0];
            3: selFM0_3 <= x24[3:0];
        endcase
        case (FM_MOT_state) 
            0: selFM1_0 <= x24[7:4]; 
            1: selFM1_1 <= x24[7:4];  
            2: selFM1_2 <= x24[7:4];  
            3: selFM1_3 <= x24[7:4];
        endcase
        EN_rst_disp_spr <= x26[24];
    end

    //**** BBO820 ****\\
    if (hs08) begin
        // Change servo bit shifts
        NI2 <= x1[9:0];  NP2 <= x3[9:0];  ND2 <= x5[9:0];
        NFI2 <= x2[9:0]; NFP2 <= x4[9:0]; NFD2 <= x6[9:0]; NGD2 <= x7[9:0];
        is_neg2       <= x8[0];
        // PI_on2        <= x9[0];
        // Change sweep params
        locktrig2     <= x10[15:0]; // Threshold to enable PID
        offset2s      <= x11[15:0]; // voltage offset
        mean_sweep_2  <= x12[15:0]; // 16-bit signed
        mean820sh     <= x12[31:16]; // currently has a port in CavServos but is unconnected. Port could be deleted.
        amp_sweep_2   <= x13[15:0]; // 16-bit signed
        sweep_rate_2  <= x14[31:0]; // 32-bit (power of 2)
        // Frequency and amplitude of modulation and dither integration parameters
        bitshift2       <= x15[9:0];
        divFast2        <= x16[15:0];
        divSlow2        <= x17[15:0];
        mod2scaling     <= x18[15:0];
        demod_bit2      <= x19[1];
        mod_sel2        <= x19[0];
        // Mode to set phase of the trigger for dither inhibit.
        inhmode2        <= x21[3:0];
        case (FM_MOT_state) 
            0: selFM0_0 <= x24[3:0]; 
            1: selFM0_1 <= x24[3:0]; 
            2: selFM0_2 <= x24[3:0];
            3: selFM0_3 <= x24[3:0];
        endcase
        case (FM_MOT_state) 
            0: selFM1_0 <= x24[7:4]; 
            1: selFM1_1 <= x24[7:4];  
            2: selFM1_2 <= x24[7:4];  
            3: selFM1_3 <= x24[7:4];
        endcase
        EN_rst_disp_spr <= x26[24];
    end

    //**** 1083REF ****\\
    if (hs00) begin
        // Change servo bit shifts
        NI3 <= x1[9:0];  NP3 <= x3[9:0];  ND3 <= x5[9:0];
        NFI3 <= x2[9:0]; NFP3 <= x4[9:0]; NFD3 <= x6[9:0]; NGD3 <= x7[9:0];
        is_neg3       <= x8[0];
        // PI_on3        <= x9[0];
        // Change sweep params
        locktrig3     <= x10[15:0]; // Threshold to enable PID
        offset3s      <= x11[15:0]; // voltage offset
        mean_sweep_3  <= x12[15:0]; // 16-bit signed
        amp_sweep_3   <= x13[15:0]; // 16-bit signed
        sweep_rate_3  <= x14[31:0]; // 32-bit (power of 2)
        // Frequency and amplitude of modulation and dither integration parameters
        bitshift3       <= x15[9:0];
        divFast3        <= x16[15:0];
        divSlow3        <= x17[15:0];
        mod3scaling     <= x18[15:0];
        demod_bit3      <= x19[1];
        mod_sel3        <= x19[0];
        // Mode to set phase of the trigger for dither inhibit.
        inhmode3        <= x21[3:0];
        case (FM_MOT_state) 
            0: selFM0_0 <= x24[3:0]; 
            1: selFM0_1 <= x24[3:0]; 
            2: selFM0_2 <= x24[3:0];
            3: selFM0_3 <= x24[3:0];
        endcase
        case (FM_MOT_state) 
            0: selFM1_0 <= x24[7:4]; 
            1: selFM1_1 <= x24[7:4];  
            2: selFM1_2 <= x24[7:4];  
            3: selFM1_3 <= x24[7:4];
        endcase
        EN_rst_disp_spr <= x26[24];
    end

    //**** BBO361_542 ****\\
    if (hs02) begin
        // Change servo bit shifts
        NI4 <= x1[9:0];  NP4 <= x3[9:0];  ND4 <= x5[9:0];
        NFI4 <= x2[9:0]; NFP4 <= x4[9:0]; NFD4 <= x6[9:0]; NGD4 <= x7[9:0];
        is_neg4       <= x8[0];
        // PI_on4        <= x9[0];
        // Change sweep params
        locktrig4     <= x10[15:0]; // Threshold to enable PID
        offset4s      <= x11[15:0]; // voltage offset
        start_sweep_4 <= x12[15:0]; // 16-bit signed
        stop_sweep_4  <= x13[15:0]; // 16-bit signed
        sweep_rate_4  <= x14[31:0]; // 32-bit (power of 2)
        // Frequency and amplitude of modulation and dither integration parameters
        bitshift4       <= x15[9:0];
        divFast4        <= x16[15:0];
        divSlow4        <= x17[15:0];
        mod4scaling     <= x18[15:0];
        demod_bit4      <= x19[1];
        mod_sel4        <= x19[0];
        // Mode to set phase of the trigger for dither inhibit.
        inhmode4        <= x21[3:0];
        case (FM_MOT_state) 
            0: selFM0_0 <= x24[3:0]; 
            1: selFM0_1 <= x24[3:0]; 
            2: selFM0_2 <= x24[3:0];
            3: selFM0_3 <= x24[3:0];
        endcase
        case (FM_MOT_state) 
            0: selFM1_0 <= x24[7:4]; 
            1: selFM1_1 <= x24[7:4];  
            2: selFM1_2 <= x24[7:4];  
            3: selFM1_3 <= x24[7:4];
        endcase
        EN_rst_disp_spr <= x26[24];
    end

    //**** BBO361_1083 ****\\
    if (hs03) begin
        // Change servo bit shifts
        NI5 <= x1[9:0];  NP5 <= x3[9:0];  ND5 <= x5[9:0];
        NFI5 <= x2[9:0]; NFP5 <= x4[9:0]; NFD5 <= x6[9:0]; NGD5 <= x7[9:0];
        is_neg5       <= x8[0];
        // PI_on5        <= x9[0];
        // Change sweep params
        locktrig5     <= x10[15:0]; // Threshold to enable PID
        offset5s      <= x11[15:0]; // voltage offset
        mean_sweep_5  <= x12[15:0]; // 16-bit signed
        mean1083_361sh <= x12[31:16];
        amp_sweep_5   <= x13[15:0]; // 16-bit signed
        sweep_rate_5  <= x14[31:0]; // 32-bit (power of 2)
        // Frequency and amplitude of modulation and dither integration parameters
        bitshift5       <= x15[9:0];
        divFast5        <= x16[15:0];
        divSlow5        <= x17[15:0];
        mod5scaling     <= x18[15:0];
        demod_bit5      <= x19[1];
        mod_sel5        <= x19[0];
        // Mode to set phase of the trigger for dither inhibit.
        inhmode5        <= x21[3:0];
        case (FM_MOT_state) 
            0: selFM0_0 <= x24[3:0]; 
            1: selFM0_1 <= x24[3:0]; 
            2: selFM0_2 <= x24[3:0];
            3: selFM0_3 <= x24[3:0];
        endcase
        case (FM_MOT_state) 
            0: selFM1_0 <= x24[7:4]; 
            1: selFM1_1 <= x24[7:4];  
            2: selFM1_2 <= x24[7:4];  
            3: selFM1_3 <= x24[7:4];
        endcase
        EN_rst_disp_spr <= x26[24];
    end

    //**** 332 Servo ****\\
    if (hs22) begin
        // Change servo bit shifts
        NI6 <= x1[9:0];  NP6 <= x3[9:0];  ND6 <= x5[9:0];
        NFI6 <= x2[9:0]; NFP6 <= x4[9:0]; NFD6 <= x6[9:0]; NGD6 <= x7[9:0];
        is_neg6       <= x8[0];
        // PI_on6        <= x9[0];
        // Change sweep params
        locktrig6     <= x10[15:0]; // Threshold to enable PID
        offset6s      <= x11[15:0]; // voltage offset
        start_sweep_6 <= x12[15:0]; // 16-bit signed
        stop_sweep_6  <= x13[15:0]; // 16-bit signed
        sweep_rate_6  <= x14[31:0]; // 32-bit (power of 2)
        // Frequency and amplitude of modulation and dither integration parameters
        bitshift6       <= x15[9:0];
        divFast6        <= x16[15:0];
        divSlow6        <= x17[15:0];
        mod6scaling     <= x18[15:0];
        demod_bit6      <= x19[1];
        mod_sel6        <= x19[0];
        // Mode to set phase of the trigger for dither inhibit.
        inhmode6        <= x21[3:0];
        case (FM_MOT_state) 
            0: selFM0_0 <= x24[3:0]; 
            1: selFM0_1 <= x24[3:0]; 
            2: selFM0_2 <= x24[3:0];
            3: selFM0_3 <= x24[3:0];
        endcase
        case (FM_MOT_state) 
            0: selFM1_0 <= x24[7:4]; 
            1: selFM1_1 <= x24[7:4];  
            2: selFM1_2 <= x24[7:4];  
            3: selFM1_3 <= x24[7:4];
        endcase
        EN_rst_disp_spr <= x26[24];
    end

    //**** Cavity Servo 7 ****\\
    if (hs23) begin
        // Change servo bit shifts
        NI7 <= x1[9:0];  NP7 <= x3[9:0];  ND7 <= x5[9:0];
        NFI7 <= x2[9:0]; NFP7 <= x4[9:0]; NFD7 <= x6[9:0]; NGD7 <= x7[9:0];
        is_neg7       <= x8[0];
        // PI_on7        <= x9[0];
        // Change sweep params
        locktrig7     <= x10[15:0]; // Threshold to enable PID
        offset7s      <= x11[15:0]; // voltage offset
        start_sweep_7 <= x12[15:0]; // 16-bit signed
        stop_sweep_7  <= x13[15:0]; // 16-bit signed
        sweep_rate_7  <= x14[31:0]; // 32-bit (power of 2)
        // Frequency and amplitude of modulation and dither integration parameters
        bitshift7       <= x15[9:0];
        divFast7        <= x16[15:0];
        divSlow7        <= x17[15:0];
        mod7scaling     <= x18[15:0];
        demod_bit7      <= x19[1];
        mod_sel7        <= x19[0];
        // stop_CS7 <= x19[2];
        // scan_CS7 <= x19[3];   
        // Mode to set phase of the trigger for dither inhibit.
        inhmode7        <= x21[3:0];
        case (FM_MOT_state) 
            0: selFM0_0 <= x24[3:0]; 
            1: selFM0_1 <= x24[3:0]; 
            2: selFM0_2 <= x24[3:0];
            3: selFM0_3 <= x24[3:0];
        endcase
        case (FM_MOT_state) 
            0: selFM1_0 <= x24[7:4]; 
            1: selFM1_1 <= x24[7:4];  
            2: selFM1_2 <= x24[7:4];  
            3: selFM1_3 <= x24[7:4];
        endcase
        EN_rst_disp_spr <= x26[24];
    end

    //**** Cavity Servo 8 ****\\
    if (hs24) begin
        // Change servo bit shifts
        NI8 <= x1[9:0];  NP8 <= x3[9:0];  ND8 <= x5[9:0];
        NFI8 <= x2[9:0]; NFP8 <= x4[9:0]; NFD8 <= x6[9:0]; NGD8 <= x7[9:0];
        is_neg8       <= x8[0];
        // PI_on8        <= x9[0];
        // Change sweep params
        locktrig8     <= x10[15:0]; // Threshold to enable PID
        offset8s      <= x11[15:0]; // voltage offset
        start_sweep_8 <= x12[15:0]; // 16-bit signed
        stop_sweep_8  <= x13[15:0]; // 16-bit signed
        sweep_rate_8  <= x14[31:0]; // 32-bit (power of 2)
        // Frequency and amplitude of modulation and dither integration parameters
        bitshift8       <= x15[9:0];
        divFast8        <= x16[15:0];
        divSlow8        <= x17[15:0];
        mod8scaling     <= x18[15:0];
        demod_bit8      <= x19[1];
        mod_sel8        <= x19[0];
        // stop_CS8 <= x19[2];
        // scan_CS8 <= x19[3];
        // Mode to set phase of the trigger for dither inhibit.
        inhmode8        <= x21[3:0];
        case (FM_MOT_state) 
            0: selFM0_0 <= x24[3:0]; 
            1: selFM0_1 <= x24[3:0]; 
            2: selFM0_2 <= x24[3:0];
            3: selFM0_3 <= x24[3:0];
        endcase
        case (FM_MOT_state) 
            0: selFM1_0 <= x24[7:4]; 
            1: selFM1_1 <= x24[7:4];  
            2: selFM1_2 <= x24[7:4];  
            3: selFM1_3 <= x24[7:4];
        endcase
        EN_rst_disp_spr <= x26[24];
    end

    //// FM MOT PARAMETER REASSIGNMENTS \\\\
    // FM_MOT_state = 1;
    if (hs04) begin
        FMdivFast_1 <= x1;
        FMdivSlow_1 <= x2; 
        FMmean_1    <= x3;
        FMsc_1      <= x4;
        dtD_1       <= x5;
        dt1_1       <= x6;
        D1_1        <= x7;
        dt2_1       <= x8;
        D2_1        <= x9;
        dt3_1       <= x10;
        dtUP_1      <= x11;
        DUP_1       <= x12;
        dtDOWN_1    <= x13;
        DDOWN_1     <= x14;
        FMIntMax_1  <= x15;
        dt4_1       <= x16;
        dt5_1       <= x17;
        D5_1        <= x18; 
        dt6_1       <= x19; 
        D6_1        <= x20; 
        dt8_1       <= x21; 
        FMINTBS_1   <= x22; 
        FMDEMCBS_1  <= x23;
        FMDEMSBS_1  <= x24;
        cImin_1     <= x25;
        DcI_1       <= x26;
        FMon_1      <= x27[0]; 
        selFM0_1    <= x27[ 9: 5]; 
        selFM1_1    <= x27[19:15]; 
        selFM2_1    <= x27[29:25]; 
        EN_rst_disp_spr <= x26[24];
    end
    // FM_MOT_state = 2;
    if (hs05) begin
        FMdivFast_2 <= x1;
        FMdivSlow_2 <= x2; 
        FMmean_2    <= x3;
        FMsc_2      <= x4;
        dtD_2       <= x5;
        dt1_2       <= x6;
        D1_2        <= x7;
        dt2_2       <= x8;
        D2_2        <= x9;
        dt3_2       <= x10;
        dtUP_2      <= x11;
        DUP_2       <= x12;
        dtDOWN_2    <= x13;
        DDOWN_2     <= x14;
        FMIntMax_2  <= x15;
        dt4_2       <= x16;
        dt5_2       <= x17;
        D5_2        <= x18; 
        dt6_2       <= x19; 
        D6_2        <= x20; 
        dt8_2       <= x21; 
        FMINTBS_2   <= x22; 
        FMDEMCBS_2  <= x23;
        FMDEMSBS_2  <= x24;
        cImin_2     <= x25;
        DcI_2       <= x26;
        FMon_2      <= x27[0]; 
        selFM0_2    <= x27[ 9: 5]; 
        selFM1_2    <= x27[19:15]; 
        selFM2_2    <= x27[29:25];
        EN_rst_disp_spr <= x26[24];
    end
    // FM_MOT_state = 3;
    if (hs06) begin
        FMdivFast_3 <= x1;
        FMdivSlow_3 <= x2; 
        FMmean_3    <= x3;
        FMsc_3      <= x4;
        dtD_3       <= x5;
        dt1_3       <= x6;
        D1_3        <= x7;
        dt2_3       <= x8;
        D2_3        <= x9;
        dt3_3       <= x10;
        dtUP_3      <= x11;
        DUP_3       <= x12;
        dtDOWN_3    <= x13;
        DDOWN_3     <= x14;
        FMIntMax_3  <= x15;
        dt4_3       <= x16;
        dt5_3       <= x17;
        D5_3        <= x18; 
        dt6_3       <= x19; 
        D6_3        <= x20; 
        dt8_3       <= x21; 
        FMINTBS_3   <= x22; 
        FMDEMCBS_3  <= x23;
        FMDEMSBS_3  <= x24;
        cImin_3     <= x25;
        DcI_3       <= x26;
        FMon_3      <= x27[0]; 
        selFM0_3    <= x27[ 9: 5]; 
        selFM1_3    <= x27[19:15]; 
        selFM2_3    <= x27[29:25]; 
        EN_rst_disp_spr <= x26[24];
    end

    //// TEMPERATURE SERVO PARAMETER REASSIGNMENTS \\\\

    // To remove adjustability of PID rolloff frequencies, comment out lines such as:
    // // NFP_x <= x4[9:0]; // NFD_x <= x6[9:0]; // NGD_x <= x7[9:0];, and possibly NFI_x

    //**** Cd oven temperature controller ****\\
    if (hs07) begin
        NI_Cd_3     <= x1[9:0]; NP_Cd_3     <= x3[9:0]; // ND_Cd_3     <= x5[9:0];
        NFI_Cd_3    <= x2[9:0]; NFP_Cd_3    <= x4[9:0]; // NFD_Cd_3    <= x6[9:0]; NGD_Cd_3    <= x7[9:0];
        is_neg_Cd_3 <= x8[0];
        TS_on_Cd_3  <= x9[0];
        sp_Cd_3     <= x10[TSCd_FILTER_IO_SIZE-1:0]; // temperature setpoint
        offset_Cd_3 <= x11[TSCd_FILTER_IO_SIZE-1:0]; // voltage offset
        // Nprst_Cd_3  <= x12[31:0];
        // LL_Cd_3     <= x13[31:0] - Nprst_Cd_3;NT_Cd_3_in  <= x14[31:0] - Nprst_Cd_3;
        // NT_Cd_3     <= x15[31:0];
        errmult_Cd <= x16[multCdBits-1:0];
        EN_rst_disp_spr <= x26[24];
    end

    //**** Reference cavity temperature controller (temperature controller 1) ****\\
    if (hs33) begin
        NI_REF     <= x1[9:0]; NP_REF     <= x3[9:0]; ND_REF     <= x5[9:0];
        NFI_REF    <= x2[9:0]; NFP_REF    <= x4[9:0]; NFD_REF    <= x6[9:0]; NGD_REF    <= x7[9:0];
        is_neg_REF <= x8[0];
        TS_on_REF  <= x9[0];
        sp_REF     <= x10[TSREF_FILTER_IO_SIZE-1:0]; // temperature setpoint
        offset_REF <= x11[TSREF_FILTER_IO_SIZE-1:0]; // voltage offset
        // Nprst_REF  <= x12[31:0];
        // LL_REF     <= x13[31:0] - Nprst_REF; NT_REF_in  <= x14[31:0] - Nprst_REF;
        // NT_REF     <= x15[31:0];
        errmult_REF <= x16[multREFBits-1:0];
        EN_rst_disp_spr <= x26[24];
    end

    //**** Temperature controller 2 ****\\
    if (hs34) begin
        // NI_2     <= x1[9:0]; NP_2     <= x3[9:0]; ND_2     <= x5[9:0];
        // NFI_2    <= x2[9:0]; NFP_2    <= x4[9:0]; NFD_2    <= x6[9:0]; NGD_2    <= x7[9:0];
        is_neg_2 <= x8[0];
        TS_on_2  <= x9[0];
        sp_2     <= x10[TS2_FILTER_IO_SIZE-1:0]; // temperature setpoint
        offset_2 <= x11[TS2_FILTER_IO_SIZE-1:0]; // voltage offset
        // Nprst_2  <= x12[31:0];
        // LL_2     <= x13[31:0] - Nprst_2; NT_2_in  <= x14[31:0] - Nprst_2;
        // NT_2     <= x15[31:0];
        errmult_2 <= x16[mult2Bits-1:0];
        EN_rst_disp_spr <= x26[24];
    end

    //**** Temperature controller 3 (361 BBO with limits) ****\\
    if (hs35) begin
        // NI_3     <= x1[9:0]; NP_3     <= x3[9:0]; ND_3     <= x5[9:0];
        // NFI_3    <= x2[9:0]; NFP_3    <= x4[9:0]; NFD_3    <= x6[9:0]; NGD_3    <= x7[9:0];
        is_neg_3 <= x8[0];
        TS_on_3  <= x9[0];
        sp_3     <= x10[TS3_FILTER_IO_SIZE-1:0]; // temperature setpoint
        offset_3 <= x11[TS3_FILTER_IO_SIZE-1:0]; // voltage offset
        // Nprst_3  <= x12[31:0];
        // LL_3     <= x13[31:0] - Nprst_3; NT_3_in  <= x14[31:0] - Nprst_3;
        // NT_3     <= x15[31:0];
        errmult_3 <= x16[mult3Bits-1:0];
        EN_rst_disp_spr <= x26[24];
    end

    //**** Temperature controller 4 (480 PPLN with limits) ****\\
    if (hs36) begin
        // NI_4     <= x1[9:0]; NP_4     <= x3[9:0]; ND_4     <= x5[9:0];
        // NFI_4    <= x2[9:0]; NFP_4    <= x4[9:0]; NFD_4    <= x6[9:0]; NGD_4    <= x7[9:0];
        is_neg_4 <= x8[0];
        TS_on_4  <= x9[0];
        sp_4     <= x10[TS4_FILTER_IO_SIZE-1:0]; // temperature setpoint
        offset_4 <= x11[TS4_FILTER_IO_SIZE-1:0]; // voltage offset
        // Nprst_4  <= x12[31:0];
        // LL_4     <= x13[31:0] - Nprst_4; NT_4_in  <= x14[31:0] - Nprst_4;
        // NT_4     <= x15[31:0];
        errmult_4 <= x16[mult4Bits-1:0];
        EN_rst_disp_spr <= x26[24];
    end

    //**** Temperature controller 5 (468 PPLN with limits) ****\\
    if (hs37) begin
        // NI_5     <= x1[9:0]; NP_5     <= x3[9:0]; ND_5     <= x5[9:0];
        // NFI_5    <= x2[9:0]; NFP_5    <= x4[9:0]; NFD_5    <= x6[9:0]; NGD_5    <= x7[9:0];
        is_neg_5 <= x8[0];
        TS_on_5  <= x9[0];
        sp_5     <= x10[TS5_FILTER_IO_SIZE-1:0]; // temperature setpoint
        offset_5 <= x11[TS5_FILTER_IO_SIZE-1:0]; // voltage offset
        // Nprst_5  <= x12[31:0];
        // LL_5     <= x13[31:0] - Nprst_5; NT_5_in  <= x14[31:0] - Nprst_5;
        // NT_5     <= x15[31:0];
        errmult_5 <= x16[mult5Bits-1:0];
        EN_rst_disp_spr <= x26[24];
    end

    //**** Temperature controller 6 (361 BBO) ****\\
    if (hs38) begin
        NI_6     <= x1[9:0]; NP_6     <= x3[9:0]; ND_6     <= x5[9:0];
        NFI_6    <= x2[9:0]; NFP_6    <= x4[9:0]; NFD_6    <= x6[9:0]; NGD_6    <= x7[9:0];
        is_neg_6 <= x8[0];
        TS_on_6  <= x9[0];
        sp_6     <= x10[TS6_FILTER_IO_SIZE-1:0]; // temperature setpoint
        offset_6 <= x11[TS6_FILTER_IO_SIZE-1:0]; // voltage offset
        // Nprst_6  <= x12[31:0];
        // LL_6     <= x13[31:0] - Nprst_6; NT_6_in  <= x14[31:0] - Nprst_6;
        // NT_6     <= x15[31:0];
        errmult_6 <= x16[mult6Bits-1:0];
        EN_rst_disp_spr <= x26[24];
    end

    //**** Temperature controller 7 (480 PPLN) ****\\
    if (hs39) begin
        NI_7     <= x1[9:0]; NP_7     <= x3[9:0]; ND_7     <= x5[9:0];
        // NFI_7    <= x2[9:0]; NFP_7    <= x4[9:0]; NFD_7    <= x6[9:0]; NGD_7    <= x7[9:0];
        is_neg_7 <= x8[0];
        TS_on_7  <= x9[0];
        sp_7     <= x10[TS7_FILTER_IO_SIZE-1:0]; // temperature setpoint
        offset_7 <= x11[TS7_FILTER_IO_SIZE-1:0]; // voltage offset
        // Nprst_7  <= x12[31:0];
        // LL_7     <= x13[31:0] - Nprst_7; NT_7_in  <= x14[31:0] - Nprst_7;
        // NT_7     <= x15[31:0];
        errmult_7 <= x16[mult7Bits-1:0];
        EN_rst_disp_spr <= x26[24];
    end

    //**** Temperature controller 8 (468 PPLN) ****\\
    if (hs40) begin
        // NI_8     <= x1[9:0]; NP_8     <= x3[9:0]; ND_8     <= x5[9:0];
        // NFI_8    <= x2[9:0]; NFP_8    <= x4[9:0]; NFD_8    <= x6[9:0]; NGD_8    <= x7[9:0];
        is_neg_8 <= x8[0];
        TS_on_8  <= x9[0];
        sp_8     <= x10[TS8_FILTER_IO_SIZE-1:0]; // temperature setpoint
        offset_8 <= x11[TS8_FILTER_IO_SIZE-1:0]; // voltage offset
        // Nprst_8  <= x12[31:0];
        // LL_8     <= x13[31:0] - Nprst_8; NT_8_in  <= x14[31:0] - Nprst_8;
        // NT_8     <= x15[31:0];
        errmult_8 <= x16[mult8Bits-1:0];
        EN_rst_disp_spr <= x26[24];
    end

    //**** Temperature controller 9 ****\\
    if (hs41) begin
        // NI_9     <= x1[9:0]; NP_9     <= x3[9:0]; ND_9     <= x5[9:0];
        // NFI_9    <= x2[9:0]; NFP_9    <= x4[9:0]; NFD_9    <= x6[9:0]; NGD_9    <= x7[9:0];
        is_neg_9 <= x8[0];
        TS_on_9  <= x9[0];
        sp_9     <= x10[TS9_FILTER_IO_SIZE-1:0]; // temperature setpoint
        offset_9 <= x11[TS9_FILTER_IO_SIZE-1:0]; // voltage offset
        // Nprst_9  <= x12[31:0];
        // LL_9     <= x13[31:0] - Nprst_9; NT_9_in  <= x14[31:0] - Nprst_9;
        // NT_9     <= x15[31:0];
        errmult_9 <= x16[mult9Bits-1:0];
        EN_rst_disp_spr <= x26[24];
    end

    // // Uncomment to adjust full-scale ramps to debug fast DAC's.
    // if (hs100) begin
    //     r0on  <= x1[0]; r1on  <= x1[1]; r2on  <= x1[2]; r3on  <= x1[3]; r4on  <= x1[4]; r5on  <= x1[5]; r6on  <= x1[6]; r7on  <= x1[7]; r8on  <= x1[8]; r9on  <= x1[9]; r10on <= x1[10]; r11on <= x1[11]; r12on <= x1[12]; r13on <= x1[13];
    // end
    
    // // Uncomment to adjust small ramps to debug the fast DAC's.   
    // if (hs100) begin
    //     NN0    <= x1[31:0];  NN1    <= x2[31:0];   NN2    <= x3[31:0];   NN3    <= x4[31:0];   NN4    <= x5[31:0];   NN5    <= x6[31:0];   NN6    <= x7[31:0];   NN7    <= x8[31:0];   NN8    <= x9[31:0];   NN9    <= x10[31:0];  NN10   <= x11[31:0];  NN11   <= x12[31:0];  NN12   <= x13[31:0];  NN13   <= x14[31:0]; 
    //     offs0  <= x15[15:0]; offs1  <= x16[15:0];  offs2  <= x17[15:0];  offs3  <= x18[15:0];  offs4  <= x19[15:0];  offs5  <= x20[15:0];  offs6  <= x21[15:0];  offs7  <= x22[15:0];  offs8  <= x23[15:0];  offs9  <= x24[15:0];  offs10 <= x25[15:0];  offs11 <= x26[15:0];  offs12 <= x27[15:0];  offs13 <= x27[15:0];
    // end

end

endmodule