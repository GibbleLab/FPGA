`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module to implement PID servos that can drive variable duty cycle temperature controls.
// Each servo includes a PID, tempPID, and a preset, temp_servo_startup_ramp, which is added to the PID output.
// The preset can ramp slowly to avoid thermal shocks. 
// Each PID is enabled when the temperature setpoint or the preset maximum is reached.
// The servo outputs are connected to the VDC modules that generate the variable duty cycle outputs. 
// The VDC outputs have a rounding sequence added to increase the duty cycle precision and adjustable phases for load diversity for multiple servos.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module TempServos#(
    // I/O length for PID filters
    parameter [31:0] 
        TSCd_FILTER_IO_SIZE  = 18,   
        TSREF_FILTER_IO_SIZE = 18,
        TS2_FILTER_IO_SIZE   = 18,
        TS3_FILTER_IO_SIZE   = 18,
        TS4_FILTER_IO_SIZE   = 18,
        TS5_FILTER_IO_SIZE   = 18,
        TS6_FILTER_IO_SIZE   = 18,
        TS7_FILTER_IO_SIZE   = 18,
        TS8_FILTER_IO_SIZE   = 18,
        TS9_FILTER_IO_SIZE   = 18,
        // Number of bits for multiplier coefficient.
        multCdBits  = 7,
        multREFBits = 7,
        mult2Bits   = 7,
        mult3Bits   = 7,
        mult4Bits   = 7,
        mult5Bits   = 7,
        mult6Bits   = 7,
        mult7Bits   = 7,
        mult8Bits   = 7,
        mult9Bits   = 7
)(
    // 100 MHz clock for VDC's, 125 kHz clock for PID's, and reset.
    input wire clk100, clk125kHz, rst,
    input wire [1:0] Cd_oven_state,
    // Temperature inputs/error signals.
    input wire signed [15:0] Tcd_in, Tref_in, T2_in, T3_in, T4_in, T5_in, T6_in, T7_in, T8_in, T9_in,
    // PID gains
    input wire signed [9:0]  
        NFI_Cd_in, NI_Cd_in, NFP_Cd_in, NP_Cd_in, ND_Cd_in, NFD_Cd_in, NGD_Cd_in,
        NFI_REF,   NI_REF,   NFP_REF,   NP_REF,   ND_REF,   NFD_REF,   NGD_REF, 
        NFI_2,     NI_2,     NFP_2,     NP_2,     ND_2,     NFD_2,     NGD_2,
        NFI_3,     NI_3,     NFP_3,     NP_3,     ND_3,     NFD_3,     NGD_3,
        NFI_4,     NI_4,     NFP_4,     NP_4,     ND_4,     NFD_4,     NGD_4,
        NFI_5,     NI_5,     NFP_5,     NP_5,     ND_5,     NFD_5,     NGD_5,
        NFI_6,     NI_6,     NFP_6,     NP_6,     ND_6,     NFD_6,     NGD_6,
        NFI_7,     NI_7,     NFP_7,     NP_7,     ND_7,     NFD_7,     NGD_7,
        NFI_8,     NI_8,     NFP_8,     NP_8,     ND_8,     NFD_8,     NGD_8,
        NFI_9,     NI_9,     NFP_9,     NP_9,     ND_9,     NFD_9,     NGD_9,
    // Servo enables
        input wire 
        TS_on_Cd_in, is_neg_Cd_in,
        TS_on_REF,   is_neg_REF,
        TS_on_2,     is_neg_2,
        TS_on_3,     is_neg_3,
        TS_on_4,     is_neg_4,
        TS_on_5,     is_neg_5,
        TS_on_6,     is_neg_6,
        TS_on_7,     is_neg_7,
        TS_on_8,     is_neg_8,
        TS_on_9,     is_neg_9,
    // Temperature set-point, offset, and (unused) shut-down condition
    input wire signed [TSCd_FILTER_IO_SIZE-1:0] 
        sp_Cd_in, offset_Cd_in, SHDN_Cd_in, 
    input wire signed [TSREF_FILTER_IO_SIZE-1:0] 
        sp_REF,   offset_REF,   SHDN_REF,
    input wire signed [TS2_FILTER_IO_SIZE-1:0] 
        sp_2, offset_2, SHDN_2,
    input wire signed [TS3_FILTER_IO_SIZE-1:0] 
        sp_3, offset_3, SHDN_3,
    input wire signed [TS4_FILTER_IO_SIZE-1:0] 
        sp_4, offset_4, SHDN_4,
    input wire signed [TS5_FILTER_IO_SIZE-1:0] 
        sp_5, offset_5, SHDN_5,
    input wire signed [TS6_FILTER_IO_SIZE-1:0] 
        sp_6, offset_6, SHDN_6,
    input wire signed [TS7_FILTER_IO_SIZE-1:0] 
        sp_7, offset_7, SHDN_7,
    input wire signed [TS8_FILTER_IO_SIZE-1:0] 
        sp_8, offset_8, SHDN_8,
    input wire signed [TS9_FILTER_IO_SIZE-1:0] 
        sp_9, offset_9, SHDN_9,
    // PID output multipliers to change overall gain.
    input wire signed [multCdBits -1:0] errmult_Cd, 
    input wire signed [multREFBits-1:0] errmult_REF, 
    input wire signed [mult2Bits  -1:0] errmult_2, 
    input wire signed [mult3Bits  -1:0] errmult_3, 
    input wire signed [mult4Bits  -1:0] errmult_4, 
    input wire signed [mult5Bits  -1:0] errmult_5, 
    input wire signed [mult6Bits  -1:0] errmult_6, 
    input wire signed [mult7Bits  -1:0] errmult_7, 
    input wire signed [mult8Bits  -1:0] errmult_8, 
    input wire signed [mult9Bits  -1:0] errmult_9,
    // PID outputs with preset.
    output wire signed [TSCd_FILTER_IO_SIZE-1:0] NH_Cd_out,
    output wire signed [TSREF_FILTER_IO_SIZE-1:0] NH_REF_out,
    output wire signed [TS2_FILTER_IO_SIZE-1:0] NH_2_out,
    output wire signed [TS3_FILTER_IO_SIZE-1:0] NH_3_out,
    output wire signed [TS4_FILTER_IO_SIZE-1:0] NH_4_out,
    output wire signed [TS5_FILTER_IO_SIZE-1:0] NH_5_out,
    output wire signed [TS6_FILTER_IO_SIZE-1:0] NH_6_out,
    output wire signed [TS7_FILTER_IO_SIZE-1:0] NH_7_out,
    output wire signed [TS8_FILTER_IO_SIZE-1:0] NH_8_out,
    output wire signed [TS9_FILTER_IO_SIZE-1:0] NH_9_out,
    // 1-bit VDC/PWM output
    output wire VDC_Cd, VDC_REF, VDC_2, VDC_3, VDC_4, VDC_5, VDC_6, VDC_7, VDC_8, VDC_9,
    // Color outputs for the display temperature error signal indicators
    output wire signed [15:0] TSclr0, TSclr1, TSclr2, TSclr3, TSclr4, TSclr5, TSclr6, TSclr7, TSclr8, TSclr9,

    // Debug outputs
    // output wire signed [TSREF_FILTER_IO_SIZE-1:0] 
    //     LL_REF_dg, UL_REF_dg, Nprst_REF_MAX_dg,
    // output wire signed [15:0] Tref_in_dg,
    // output wire signed [TSREF_FILTER_IO_SIZE-1:0] 
    //     offset_REF_dg, sp_REF_dg,
    // output wire signed [TSREF_FILTER_IO_SIZE-1:0]
    //     VDC_REF_in_dg, Nprst_REF_dg,
    // output wire signed [31:0] NH_in_REF_dg,
    // output wire signed [15:0] NHpre_REF_dg, NHi_REF_dg, NHp_REF_dg, NHd_REF_dg, NHpost_REF_dg

    output wire signed [TSCd_FILTER_IO_SIZE-1:0] 
        LL_Cd_dg, UL_Cd_dg, Nprst_Cd_MAX_dg,
    output wire signed [15:0] Tcd_in_dg,
    output wire signed [TSCd_FILTER_IO_SIZE-1:0] 
        offset_Cd_dg, sp_Cd_dg,
    output wire signed [TSCd_FILTER_IO_SIZE-1:0]
        VDC_Cd_in_dg, Nprst_Cd_dg,
    output wire signed [31:0] NH_in_Cd_dg,
    output wire signed [15:0] NHpre_Cd_dg, NHi_Cd_dg, NHp_Cd_dg, NHd_Cd_dg, NHpost_Cd_dg
);

// Delayed servo enable output for Cd Oven (instantiated below).
wire TS_on_Cd;
// Delayed servo enable outputs.
wire TS_on_Cd_out, TS_on_REF_out, TS_on_2_out, TS_on_3_out, TS_on_4_out, TS_on_5_out, TS_on_6_out, TS_on_7_out, TS_on_8_out, TS_on_9_out;
// This module delays the enable signals for 10 ms after a reset pulse.
TS_on_dly#(1_000_000)
TS_on_dly_inst(
    clk100, rst, 
    TS_on_Cd,     TS_on_REF,     TS_on_2,     TS_on_3,     TS_on_4,     TS_on_5,     TS_on_6,     TS_on_7,     TS_on_8,     TS_on_9, 
    TS_on_Cd_out, TS_on_REF_out, TS_on_2_out, TS_on_3_out, TS_on_4_out, TS_on_5_out, TS_on_6_out, TS_on_7_out, TS_on_8_out, TS_on_9_out
);

// Global counter to synchronize the VDC's.
// VDC internal cycle counters are reset by VDCtrig.
reg [31:0] cnt_vdc = 32'd0;
reg VDCtrig;
localparam [31:0] cnt_vdc_max = 32'd100_000;
always @(posedge clk100) begin
    if (cnt_vdc == cnt_vdc_max-1) cnt_vdc <= 32'd0;
    else                          cnt_vdc <= cnt_vdc + 32'd1;
    if (cnt_vdc == 32'd0)                 VDCtrig <= 1;
    else VDCtrig <= 0;
end

//**** Cd oven temperature controller ****\\
// Parameter declarations
localparam [31:0] 
        TSCd_ISCALING       = 28, // Internal scaling for PID filters
        TSCd_PSCALING       = 12, // Internal scaling for PID filters
        TSCd_DSCALING       = 25, // Internal scaling for PID filters
        TSCd_BS             = 3,  // Bit shift for sub-cycle higher precision sequence
        TSCd_on_dly_cnt     = 0;  // Turn on delay of VDC in 100 MHz cycles (load diversity)
localparam [5:0]  TSCd_MULT = 6'd25;
// Signal declarations
// Hardcoded parameters for 99C servo
localparam [0:0] TS_on_Cd_1 = 1;
localparam signed [TSCd_FILTER_IO_SIZE-1:0] sp_Cd_1 = 'd324;
// Hardcoded parameters for 119C servo
localparam TS_on_Cd_2 = 1;
localparam signed [TSCd_FILTER_IO_SIZE-1:0] sp_Cd_2 = 'd390;
// Other signals for temperature servo
localparam signed [31:0] NT_Cd = cnt_vdc_max; // Total number of cycles (determines frequency) for VDC_CLK_Cd
localparam signed [TSCd_FILTER_IO_SIZE-1:0] 
    LL_Cd = 'd0, UL_Cd = 'd99_900, // Limits 99.9%/0% of 100000 which gives 0-99.9% with 0 preset, 100_000 is 100%
    Nprst_Cd = 'd0; // 0% duty cycle preset at NT_5=100000
wire is_neg_Cd;
wire signed [9:0]  NFI_Cd, NI_Cd, NFP_Cd, NP_Cd, ND_Cd, NFD_Cd, NGD_Cd; // PID gains
wire signed [TSCd_FILTER_IO_SIZE-1:0] sp_Cd, offset_Cd, SHDN_Cd; // Temperature setpoint, input offset, shutdown condition
wire signed [TSCd_FILTER_IO_SIZE-1:0] VDC_Cd_in; // Input to integrator whose output determines duty cycle of VDC_CLK_Cd
wire signed [TSCd_FILTER_IO_SIZE-1:0] NH_out_Cd; // Temporary storage signal.
wire signed [31:0] NH_in_Cd;
// Error signal assignment.
assign VDC_Cd_in = Tcd_in + offset_Cd - sp_Cd;

//**** Cd oven temperature controller ****\\
// Different parameter assignments for different oven states
Cd_Oven_PARAM_ASSIGN#(TSCd_FILTER_IO_SIZE)Cd_Oven_PARAM_ASSIGN_inst(
    clk100, Cd_oven_state,
    // Input parameters (99, mode=1)
    TS_on_Cd_1,  is_neg_Cd_in, NFI_Cd_in, NI_Cd_in, NFP_Cd_in, NP_Cd_in, ND_Cd_in, NFD_Cd_in, NGD_Cd_in, sp_Cd_1, offset_Cd_in, SHDN_Cd_in, 
    // Input parameters (119, mode
    TS_on_Cd_2,  is_neg_Cd_in, NFI_Cd_in, NI_Cd_in, NFP_Cd_in, NP_Cd_in, ND_Cd_in, NFD_Cd_in, NGD_Cd_in, sp_Cd_2, offset_Cd_in, SHDN_Cd_in, 
    // Input parameters (Cd, mode
    TS_on_Cd_in, is_neg_Cd_in, NFI_Cd_in, NI_Cd_in, NFP_Cd_in, NP_Cd_in, ND_Cd_in, NFD_Cd_in, NGD_Cd_in, sp_Cd_in, offset_Cd_in, SHDN_Cd_in,
    // Output parameters
    TS_on_Cd,    is_neg_Cd,    NFI_Cd,    NI_Cd,    NFP_Cd,    NP_Cd,    ND_Cd,    NFD_Cd,    NGD_Cd,    sp_Cd,    offset_Cd,    SHDN_Cd  
);
// Temperature PID (without debugging outputs)

// tempPID#(TSCd_FILTER_IO_SIZE, TSCd_ISCALING, TSCd_PSCALING, TSCd_DSCALING)
// tempPID_Cd(
//     clk125kHz,   // 1 MHz, 100 MHz clocks
//     TS_on_Cd_out, is_neg_Cd, // PID on/negative signals
//     NFI_Cd, NI_Cd, NFP_Cd, NP_Cd, ND_Cd, NFD_Cd, NGD_Cd,  
//     errmult_Cd,
//     LL_Cd, UL_Cd, // PID limits, with prst, determine the range of duty-cycles
//     VDC_Cd_in,      // input to filter
//     NH_out_Cd       // PID output            
// );

// Temperature PID with debugging outputs.
tempPID_dg#(TSCd_FILTER_IO_SIZE, TSCd_ISCALING, TSCd_PSCALING, TSCd_DSCALING)
tempPID_Cd(
    clk125kHz,   // 1 MHz, 100 MHz clocks
    TS_on_Cd_out, is_neg_Cd, // PID on/negative signals
    NFI_Cd, NI_Cd, NFP_Cd, NP_Cd, ND_Cd, NFD_Cd, NGD_Cd,  
    errmult_Cd,
    LL_Cd, UL_Cd, // PID limits, with prst, determine the range of duty-cycles
    VDC_Cd_in,      // input to filter
    NH_out_Cd,      // PID output            
    NHpre_Cd_dg, NHi_Cd_dg, NHp_Cd_dg, NHd_Cd_dg, NHpost_Cd_dg          
);

// Add preset to output of filter.
assign NH_in_Cd = NH_out_Cd + Nprst_Cd;
assign NH_Cd_out = NH_in_Cd; 
// Declaration of VDC. Outputs variable duty cycle pulses to drive a digital output. 
VDC#(TSCd_BS, TSCd_on_dly_cnt, TSCd_MULT)VDC_INST_Cd(clk100, TS_on_Cd_out, VDCtrig, NH_in_Cd, NT_Cd, VDC_Cd);
                                                    
assign LL_Cd_dg          = LL_Cd; 
assign UL_Cd_dg          = UL_Cd;
assign Nprst_Cd_MAX_dg   = 0;
assign Tcd_in_dg         = Tcd_in;
assign offset_Cd_dg      = offset_Cd;
assign sp_Cd_dg          = sp_Cd;
assign VDC_Cd_in_dg      = VDC_Cd_in;
assign Nprst_Cd_dg       = Nprst_Cd;
assign NH_in_Cd_dg       = NH_in_Cd;

//**** Reference cavity temperature controller (temperature controller 1) ****\\
// Parameter declarations
localparam [31:0] 
        TSREF_ISCALING       = 28, // Internal scaling for PID filters
        TSREF_PSCALING       = 17, // Internal scaling for PID filters
        TSREF_DSCALING       = 33, // Internal scaling for PID filters
        TSREF_BS             = 3,  // Bit shift for sub-cycle higher precision sequence
        TSREF_on_dly_cnt     = 30000;  // Turn on delay of VDC in 100 MHz cycles (load diversity)
localparam [5:0]  TSREF_MULT = 6'd25;
// Signal declarations
localparam signed [31:0] NT_REF = cnt_vdc_max; // Total number of cycles (determines frequency) for VDC_CLK_REF
// These numbers are left-shifted by 7 to pad for the fractional filter bits, and by 4 to scale the multipler gain (so *16 = gain of 1).
localparam signed [TSREF_FILTER_IO_SIZE-1:0]  
    LL_REF = -'d81_250, UL_REF = 'd18_750, // Limits +18.75/-81.25% of 100000 which gives 0%-100% with the 81.25% preset
    Nprst_REF_MAX = 'd81_250; // 81.25% duty cycle preset at NT_5=100000
localparam signed [TSREF_FILTER_IO_SIZE+24-1:0] step_REF = Nprst_REF_MAX <<< 4; // Ramp over 134s/16
wire signed [TSREF_FILTER_IO_SIZE-1:0] Nprst_REF;
wire signed [TSREF_FILTER_IO_SIZE-1:0] VDC_REF_in; // Input to integrator whose output determines duty cycle of VDC_CLK_REF
wire signed [TSREF_FILTER_IO_SIZE-1:0] NH_out_REF; // Temporary storage signal.
wire signed [31:0] NH_in_REF;
wire PID_EN_REF;
// Error signal assignment.
assign VDC_REF_in = Tref_in + offset_REF - sp_REF;
// Start-up ramp.
temp_servo_startup_ramp#(TSREF_FILTER_IO_SIZE, 1)temp_servo_startup_ramp_REF(clk125kHz, TS_on_REF_out, VDC_REF_in, Nprst_REF_MAX, step_REF, PID_EN_REF, Nprst_REF);
// Temperature PID (without debugging outputs)
tempPID#(TSREF_FILTER_IO_SIZE, TSREF_ISCALING, TSREF_PSCALING, TSREF_DSCALING)
tempPID_REF(
    clk125kHz,   // 1 MHz, 100 MHz clocks
    PID_EN_REF, is_neg_REF, // PID on/negative signals
    NFI_REF, NI_REF, NFP_REF, NP_REF, ND_REF, NFD_REF, NGD_REF,  
    errmult_REF,
    LL_REF, UL_REF, // PID limits, with prst, determine the range of duty-cycles
    VDC_REF_in,      // input to filter
    NH_out_REF       // PID output  
);
// Temperature PID with debugging outputs.
// tempPID_dg#(TSREF_FILTER_IO_SIZE, TSREF_ISCALING, TSREF_PSCALING, TSREF_DSCALING)
// tempPID_REF(
//     clk125kHz,   // 1 MHz, 100 MHz clocks
//     PID_EN_REF, is_neg_REF, // PID on/negative signals
//     NFI_REF, NI_REF, NFP_REF, NP_REF, ND_REF, NFD_REF, NGD_REF,  
//     errmult_REF,
//     LL_REF, UL_REF, // PID limits, with prst, determine the range of duty-cycles
//     VDC_REF_in,      // input to filter
//     NH_out_REF,       // PID output  
//     NHpre_REF_dg, NHi_REF_dg, NHp_REF_dg, NHd_REF_dg, NHpost_REF_dg          
// );

// Add preset to output of filter.
assign NH_in_REF = NH_out_REF + Nprst_REF; 
assign NH_REF_out = NH_in_REF; 
// Declaration of VDC. Outputs variable duty cycle pulses to drive output. 
VDC#(TSREF_BS, TSREF_on_dly_cnt, TSREF_MULT)VDC_INST_REF(clk100, TS_on_REF_out, VDCtrig, NH_in_REF, NT_REF, VDC_REF);

// assign LL_REF_dg          = LL_REF; 
// assign UL_REF_dg          = UL_REF;
// assign Nprst_REF_MAX_dg   = Nprst_REF_MAX;
// assign Tref_in_dg         = Tref_in;
// assign offset_REF_dg      = offset_REF;
// assign sp_REF_dg          = sp_REF;
// assign VDC_REF_in_temp_dg = 0;//VDC_REF_in_temp;
// assign VDC_REF_in_dg      = VDC_REF_in;
// assign Nprst_REF_dg       = Nprst_REF;
// assign NH_in_REF_dg       = NH_in_REF;

//**** Temperature controller 2 ****\\
// Parameter declarations
localparam [31:0] 
        TS2_ISCALING       = 28, // Internal scaling for PID filters
        TS2_PSCALING       = 12, // Internal scaling for PID filters
        TS2_DSCALING       = 22, // Internal scaling for PID filters
        TS2_BS             = 3,  // Bit shift for sub-cycle higher precision sequence
        TS2_on_dly_cnt     = 60000;  // Turn on delay of VDC in 100 MHz cycles (load diversity)
localparam [5:0]  TS2_MULT = 6'd25;
// Signal declarations
localparam  signed [31:0] NT_2 = cnt_vdc_max; // Total number of cycles (determines frequency) for VDC_CLK_2
localparam signed [TS2_FILTER_IO_SIZE-1:0] 
    LL_2 = -'d45000, UL_2 =  'd45000, // Limits +/-45% of 100000 which gives 0%-90% with the 45% preset
    Nprst_2_MAX =  'd45000; // 45% duty cycle preset at NT_2=100000 
localparam signed [TS2_FILTER_IO_SIZE+24-1:0] step_2 = Nprst_2_MAX; // Ramp over 134 s.
wire signed [TS2_FILTER_IO_SIZE-1:0] Nprst_2;
wire signed [TS2_FILTER_IO_SIZE-1:0] VDC_2_in; // Input to integrator whose output determines duty cycle of VDC_CLK_2.
wire signed [TS2_FILTER_IO_SIZE-1:0] NH_out_2; // Temporary storage signal.
wire signed [31:0] NH_in_2;
wire PID_EN_2;
// Error signal assignment.
assign VDC_2_in = T2_in + offset_2 - sp_2;
// Start-up ramp.
temp_servo_startup_ramp#(TS2_FILTER_IO_SIZE, 1)temp_servo_startup_ramp_2(clk125kHz, TS_on_2_out, VDC_2_in, Nprst_2_MAX, step_2, PID_EN_2, Nprst_2);
// Temperature PID (without debugging outputs)
tempPID#(TS2_FILTER_IO_SIZE, TS2_ISCALING, TS2_PSCALING, TS2_DSCALING)
tempPID_2(
    clk125kHz,   // 1 MHz, 100 MHz clocks
    PID_EN_2, is_neg_2, // PID on/negative signals
    NFI_2, NI_2, NFP_2, NP_2, ND_2, NFD_2, NGD_2,  
    errmult_2,
    LL_2, UL_2, // PID limits, with prst, determine the range of duty-cycles
    VDC_2_in,      // input to filter
    NH_out_2       // PID output            
);
// Add preset to output of filter.
assign NH_in_2 = NH_out_2 + Nprst_2; 
assign NH_2_out = NH_in_2; 
// Declaration of VDC. Outputs variable duty cycle pulses to drive output. 
VDC#(TS2_BS, TS2_on_dly_cnt, TS2_MULT)VDC_INST_2(clk100, TS_on_2_out, VDCtrig, NH_in_2, NT_2, VDC_2);

//**** Temperature controller 3 (361 BBO with limits) ****\\
// Parameter declarations
localparam [31:0] 
        TS3_ISCALING       = 28, // Internal scaling for PID filters
        TS3_PSCALING       = 12, // Internal scaling for PID filters
        TS3_DSCALING       = 22, // Internal scaling for PID filters
        TS3_BS             = 3,  // Bit shift for sub-cycle higher precision sequence
        TS3_on_dly_cnt     = 90000;  // Turn on delay of VDC in 100 MHz cycles (load diversity)
localparam [5:0]  TS3_MULT = 6'd25;
// Signal declarations
localparam  signed [31:0] NT_3 = cnt_vdc_max; // Total number of cycles (determines frequency) for VDC_CLK_3
localparam signed [TS3_FILTER_IO_SIZE-1:0] 
    LL_3 = -'d45000, UL_3 =  'd45000, // Limits +/-45% of 100000 which gives 0%-90% with the 45% preset
    Nprst_3_MAX =  'd45000; // 45% duty cycle preset at NT_3=100000 
localparam signed [TS3_FILTER_IO_SIZE+24-1:0] step_3 = Nprst_3_MAX; // Ramp over 134 s.
wire signed [TS3_FILTER_IO_SIZE-1:0] Nprst_3;
wire signed [TS3_FILTER_IO_SIZE-1:0] VDC_3_in; // Input to integrator whose output determines duty cycle of VDC_CLK_3.
wire signed [TS3_FILTER_IO_SIZE-1:0] NH_out_3; // Temporary storage signal.
wire signed [31:0] NH_in_3;
wire PID_EN_3;
// Error signal assignment.
assign VDC_3_in = T3_in + offset_3 - sp_3; 
// Start-up ramp.
temp_servo_startup_ramp#(TS3_FILTER_IO_SIZE, 1)temp_servo_startup_ramp_3(clk125kHz, TS_on_3_out, VDC_3_in, Nprst_3_MAX, step_3, PID_EN_3, Nprst_3);
// Temperature PID (without debugging outputs)
tempPID#(TS3_FILTER_IO_SIZE, TS3_ISCALING, TS3_PSCALING, TS3_DSCALING)
tempPID_3(
    clk125kHz,   // 1 MHz, 100 MHz clocks
    PID_EN_3, is_neg_3, // PID on/negative signals
    NFI_3, NI_3, NFP_3, NP_3, ND_3, NFD_3, NGD_3,  
    errmult_3,
    LL_3, UL_3, // PID limits, with prst, determine the range of duty-cycles
    VDC_3_in,      // input to filter
    NH_out_3       // PID output            
);
// Add preset to output of filter.
assign NH_in_3 = NH_out_3 + Nprst_3; 
assign NH_3_out = NH_in_3; 
// Declaration of VDC. Outputs variable duty cycle pulses to drive output. 
VDC#(TS3_BS, TS3_on_dly_cnt, TS3_MULT)VDC_INST_3(clk100, TS_on_3_out, VDCtrig, NH_in_3, NT_3, VDC_3);

//**** Temperature controller 4 (480 PPLN with limits) ****\\
// Parameter declarations
localparam [31:0] 
        TS4_ISCALING       = 28, // Internal scaling for PID filters
        TS4_PSCALING       = 12, // Internal scaling for PID filters
        TS4_DSCALING       = 22, // Internal scaling for PID filters
        TS4_BS             = 3,  // Bit shift for sub-cycle higher precision sequence
        TS4_on_dly_cnt     = 20000;  // Turn on delay of VDC in 100 MHz cycles (load diversity)
localparam [5:0]  TS4_MULT = 6'd25;
// Signal declarations
localparam  signed [31:0] NT_4 = cnt_vdc_max; // Total number of cycles (determines frequency) for VDC_CLK_4
localparam signed [TS4_FILTER_IO_SIZE-1:0] 
    LL_4 = -'d45000, UL_4 =  'd45000, // Limits +/-45% of 100000 which gives 0%-90% with the 45% preset
    Nprst_4_MAX =  'd45000; // 50% duty cycle preset at NT_4=100000 
localparam signed [TS4_FILTER_IO_SIZE+24-1:0] step_4 = Nprst_4_MAX; // Ramp over 134 s.
wire signed [TS4_FILTER_IO_SIZE-1:0] Nprst_4;
wire signed [TS4_FILTER_IO_SIZE-1:0] VDC_4_in; // Input to integrator whose output determines duty cycle of VDC_CLK_4.
wire signed [TS4_FILTER_IO_SIZE-1:0] NH_out_4; // Temporary storage signal.
wire signed [31:0] NH_in_4;
wire PID_EN_4;
// Error signal assignment.
assign VDC_4_in = T4_in + offset_4 - sp_4; 
// Start-up ramp.
temp_servo_startup_ramp#(TS4_FILTER_IO_SIZE, 1)temp_servo_startup_ramp_4(clk125kHz, TS_on_4_out, VDC_4_in, Nprst_4_MAX, step_4, PID_EN_4, Nprst_4);
// Temperature PID (without debugging outputs)
tempPID#(TS4_FILTER_IO_SIZE, TS4_ISCALING, TS4_PSCALING, TS4_DSCALING)
tempPID_4(
    clk125kHz,   // 1 MHz, 100 MHz clocks
    PID_EN_4, is_neg_4, // PID on/negative signals
    NFI_4, NI_4, NFP_4, NP_4, ND_4, NFD_4, NGD_4,  
    errmult_4,
    LL_4, UL_4, // PID limits, with prst, determine the range of duty-cycles
    VDC_4_in,      // input to filter
    NH_out_4       // PID output            
);
// Add preset to output of filter.
assign NH_in_4 = NH_out_4 + Nprst_4; 
assign NH_4_out = NH_in_4; 
// Declaration of VDC. Outputs variable duty cycle pulses to drive output. 
VDC#(TS4_BS, TS4_on_dly_cnt, TS4_MULT)VDC_INST_4(clk100, TS_on_4_out, VDCtrig, NH_in_4, NT_4, VDC_4);

//**** Temperature controller 5 (468 PPLN with limits) ****\\
// Parameter declarations
localparam [31:0] 
        TS5_ISCALING       = 28, // Internal scaling for PID filters
        TS5_PSCALING       = 12, // Internal scaling for PID filters
        TS5_DSCALING       = 22, // Internal scaling for PID filters
        TS5_BS             = 3,  // Bit shift for sub-cycle higher precision sequence
        TS5_on_dly_cnt     = 50000;  // Turn on delay of VDC in 100 MHz cycles (load diversity)
localparam [5:0]  TS5_MULT = 6'd25;
// Signal declarations
localparam  signed [31:0] NT_5 = cnt_vdc_max; // Total number of cycles (determines frequency) for VDC_CLK_5
localparam signed [TS5_FILTER_IO_SIZE-1:0]
    LL_5 = -'d40000, UL_5 = 'd50000, // Limits -40%/+50% of 100000 which gives 0%-90% with the 40% preset
    Nprst_5_MAX = 'd40000; // 40% duty cycle preset at NT_5=100000
localparam signed [TS5_FILTER_IO_SIZE+24-1:0] step_5 = Nprst_5_MAX; // Ramp over 134 s.
wire signed [TS5_FILTER_IO_SIZE-1:0] Nprst_5;
wire signed [TS5_FILTER_IO_SIZE-1:0] VDC_5_in; // Input to integrator whose output determines duty cycle of VDC_CLK_5.
wire signed [TS5_FILTER_IO_SIZE-1:0] NH_out_5; // Temporary storage signal.
wire signed [31:0] NH_in_5;
wire PID_EN_5;
// Error signal assignment.
assign VDC_5_in = T5_in + offset_5 - sp_5; 
// Start-up ramp.
temp_servo_startup_ramp#(TS5_FILTER_IO_SIZE, 1)temp_servo_startup_ramp_5(clk125kHz, TS_on_5_out, VDC_5_in, Nprst_5_MAX, step_5, PID_EN_5, Nprst_5);
// Temperature PID (without debugging outputs)
tempPID#(TS5_FILTER_IO_SIZE, TS5_ISCALING, TS5_PSCALING, TS5_DSCALING)
tempPID_5(
    clk125kHz,   // 1 MHz, 100 MHz clocks
    PID_EN_5, is_neg_5, // PID on/negative signals
    NFI_5, NI_5, NFP_5, NP_5, ND_5, NFD_5, NGD_5,  
    errmult_5,
    LL_5, UL_5, // PID limits, with prst, determine the range of duty-cycles
    VDC_5_in,      // input to filter
    NH_out_5       // PID output            
);
// Add preset to output of filter.
assign NH_in_5 = NH_out_5 + Nprst_5; 
assign NH_5_out = NH_in_5; 
// Declaration of VDC. Outputs variable duty cycle pulses to drive output. 
VDC#(TS5_BS, TS5_on_dly_cnt, TS5_MULT)VDC_INST_5(clk100, TS_on_5_out, VDCtrig, NH_in_5, NT_5, VDC_5);

//**** Temperature controller 6 (361 BBO) ****\\
// Parameter declarations
localparam [31:0] 
        TS6_ISCALING       = 28, // Internal scaling for PID filters
        TS6_PSCALING       = 17, // Internal scaling for PID filters
        TS6_DSCALING       = 33, // Internal scaling for PID filters
        TS6_BS             = 3,  // Bit shift for sub-cycle higher precision sequence
        TS6_on_dly_cnt     = 80000;  // Turn on delay of VDC in 100 MHz cycles (load diversity)
localparam [5:0]  TS6_MULT = 6'd25;
// Signal declarations
localparam  signed [31:0] NT_6 = cnt_vdc_max; // Total number of cycles (determines frequency) for VDC_CLK_6
// These numbers are left-shifted by 7 to pad for the fractional filter bits, and by 4 to scale the multipler gain (so *16 = gain of 1).
localparam signed [TS6_FILTER_IO_SIZE-1:0]
    LL_6 = -'d80_000, UL_6 = 'd10_000, // Limits -80%/+10% of 100000 which gives 0%-90% with the 80% preset
    Nprst_6_MAX = 'd80_000; // 80% duty cycle preset at NT_5=100000
localparam signed [TS6_FILTER_IO_SIZE+24-1:0] step_6 = Nprst_6_MAX; // Ramp over 134 s.
wire signed [TS6_FILTER_IO_SIZE-1:0] Nprst_6;
wire signed [TS6_FILTER_IO_SIZE-1:0] VDC_6_in; // Input to integrator whose output determines duty cycle of VDC_CLK_6.
wire signed [TS6_FILTER_IO_SIZE-1:0] NH_out_6; // Temporary storage signal.
wire signed [31:0] NH_in_6;
wire PID_EN_6;
// Error signal assignment.
assign VDC_6_in = T6_in + offset_6 - sp_6; 
// Start-up ramp.
temp_servo_startup_ramp#(TS6_FILTER_IO_SIZE, 1)temp_servo_startup_ramp_6(clk125kHz, TS_on_6_out, VDC_6_in, Nprst_6_MAX, step_6, PID_EN_6, Nprst_6);
// Temperature PID (without debugging outputs)
tempPID#(TS6_FILTER_IO_SIZE, TS6_ISCALING, TS6_PSCALING, TS6_DSCALING)
tempPID_6(
    clk125kHz,   // 1 MHz clocks
    PID_EN_6, is_neg_6, // PID on/negative signals
    NFI_6, NI_6, NFP_6, NP_6, ND_6, NFD_6, NGD_6,  
    errmult_6,
    LL_6, UL_6, // PID limits, with prst, determine the range of duty-cycles
    VDC_6_in,      // input to filter
    NH_out_6       // PID output            
);
// Add preset to output of filter.
assign NH_in_6 = NH_out_6 + Nprst_6; 
assign NH_6_out = NH_in_6; 
// Declaration of VDC. Outputs variable duty cycle pulses to drive output. 
VDC#(TS6_BS, TS6_on_dly_cnt, TS6_MULT)VDC_INST_6(clk100, TS_on_6_out, VDCtrig, NH_in_6, NT_6, VDC_6);

//**** Temperature controller 7 (480 PPLN) ****\\
// Parameter declarations
localparam [31:0] 
        TS7_ISCALING       = 28, // Internal scaling for PID filters
        TS7_PSCALING       = 12, // Internal scaling for PID filters
        TS7_DSCALING       = 22, // Internal scaling for PID filters
        TS7_BS             = 3,  // Bit shift for sub-cycle higher precision sequence
        TS7_on_dly_cnt     = 10000;  // Turn on delay of VDC in 100 MHz cycles (load diversity)
localparam [5:0]  TS7_MULT = 6'd25;
// Signal declarations
localparam  signed [31:0] NT_7 = cnt_vdc_max; // Total number of cycles (determines frequency) for VDC_CLK_7
localparam signed [TS7_FILTER_IO_SIZE-1:0]
    LL_7 = -'d60000, UL_7 = 'd25000, // Limits -60%/+25% of 100000 which gives 0%-85% with the 60% preset
    Nprst_7_MAX = 'd60000; // 50% duty cycle preset at NT_7=100000
    localparam signed [TS7_FILTER_IO_SIZE+24-1:0] step_7 = Nprst_7_MAX <<< 2;; // Ramp over 134s/4.
    wire signed [TS7_FILTER_IO_SIZE-1:0] Nprst_7;
wire signed [TS7_FILTER_IO_SIZE-1:0] VDC_7_in; // Input to integrator whose output determines duty cycle of VDC_CLK_7.
wire signed [TS7_FILTER_IO_SIZE-1:0] NH_out_7; // Temporary storage signal.
wire signed [31:0] NH_in_7;
wire PID_EN_7;
// Error signal assignment.
assign VDC_7_in = T7_in + offset_7 - sp_7; 
// Start-up ramp.
temp_servo_startup_ramp#(TS7_FILTER_IO_SIZE, 1)temp_servo_startup_ramp_7(clk125kHz, TS_on_7_out, VDC_7_in, Nprst_7_MAX, step_7, PID_EN_7, Nprst_7);
// Temperature PID (without debugging outputs)
tempPID#(TS7_FILTER_IO_SIZE, TS7_ISCALING, TS7_PSCALING, TS7_DSCALING)
tempPID_7(
    clk125kHz,   // 1 MHz clocks
    PID_EN_7, is_neg_7, // PID on/negative signals
    NFI_7, NI_7, NFP_7, NP_7, ND_7, NFD_7, NGD_7,  
    errmult_7,
    LL_7, UL_7, // PID limits, with prst, determine the range of duty-cycles
    VDC_7_in,      // input to filter
    NH_out_7       // PID output            
);
// Add preset to output of filter.
assign NH_in_7 = NH_out_7 + Nprst_7;
assign NH_7_out = NH_in_7;  
// Declaration of VDC. Outputs variable duty cycle pulses to drive output. 
VDC#(TS7_BS, TS7_on_dly_cnt, TS7_MULT)VDC_INST_7(clk100, TS_on_7_out, VDCtrig, NH_in_7, NT_7, VDC_7);

//**** Temperature controller 8 (468 PPLN) ****\\
// Parameter declarations
localparam [31:0] 
        TS8_ISCALING       = 28, // Internal scaling for PID filters
        TS8_PSCALING       = 12, // Internal scaling for PID filters
        TS8_DSCALING       = 22, // Internal scaling for PID filters
        TS8_BS             = 3,  // Bit shift for sub-cycle higher precision sequence
        TS8_on_dly_cnt     = 40000;  // Turn on delay of VDC in 100 MHz cycles (load diversity)
localparam [5:0]  TS8_MULT = 6'd25;
// Signal declarations
localparam  signed [31:0] NT_8 = cnt_vdc_max; // Total number of cycles (determines frequency) for VDC_CLK_8
// These numbers are left-shifted by 7 to pad for the fractional filter bits, and by 4 to scale the multipler gain (so *16 = gain of 1).
localparam signed [TS8_FILTER_IO_SIZE-1:0]
    LL_8 = -'d40000, UL_8 = 'd40000, // Limits -40%/+40% of 100000 which gives 0%-80% with the 40% preset
    Nprst_8_MAX = 'd40000; // 40% duty cycle preset at NT_8=100000
localparam signed [TS8_FILTER_IO_SIZE+24-1:0] step_8 = Nprst_8_MAX <<< 2; // Ramp over 134s/4
wire signed [TS8_FILTER_IO_SIZE-1:0] Nprst_8;
wire signed [TS8_FILTER_IO_SIZE-1:0] VDC_8_in; // Input to integrator whose output determines duty cycle of VDC_CLK_8.
wire signed [TS8_FILTER_IO_SIZE-1:0] NH_out_8; // Temporary storage signal.
wire signed [31:0] NH_in_8;
wire PID_EN_8;
// Error signal assignment.
assign VDC_8_in = T8_in + offset_8 - sp_8; 
// Start-up ramp.
temp_servo_startup_ramp#(TS8_FILTER_IO_SIZE, 1)temp_servo_startup_ramp_8(clk125kHz, TS_on_8_out, VDC_8_in, Nprst_8_MAX, step_8, PID_EN_8, Nprst_8);
// Temperature PID (with reduced precision of PID frequencies)
tempPID_rolloff_bitshift#(TS8_FILTER_IO_SIZE, TS8_ISCALING, TS8_PSCALING, TS8_DSCALING)
tempPID_8(
    clk125kHz,   // 1 MHz clocks
    PID_EN_8, is_neg_8, // PID on/negative signals
    NFI_8, NI_8, NFP_8, NP_8, ND_8, NFD_8, NGD_8,  
    errmult_8,
    LL_8, UL_8, // PID limits, with prst, determine the range of duty-cycles
    VDC_8_in,      // input to filter
    NH_out_8       // PID output            
);
// Add preset to output of filter.
assign NH_in_8 = NH_out_8 + Nprst_8; 
assign NH_8_out = NH_in_8; 
// Declaration of VDC. Outputs variable duty cycle pulses to drive output. 
VDC#(TS8_BS, TS8_on_dly_cnt, TS8_MULT)VDC_INST_8(clk100, TS_on_8_out, VDCtrig, NH_in_8, NT_8, VDC_8);

//**** Temperature controller 9 ****\\
// Parameter declarations
localparam [31:0] 
        TS9_ISCALING       = 28, // Internal scaling for PID filters
        TS9_PSCALING       = 12, // Internal scaling for PID filters
        TS9_DSCALING       = 22, // Internal scaling for PID filters
        TS9_BS             = 3,  // Bit shift for sub-cycle higher precision sequence
        TS9_on_dly_cnt     = 70000;  // Turn on delay of VDC in 100 MHz cycles (load diversity)
localparam [5:0]  TS9_MULT = 6'd25;
// Signal declarations
localparam  signed [31:0] NT_9 = cnt_vdc_max; // Total number of cycles (determines frequency) for VDC_CLK_9
localparam signed [TS9_FILTER_IO_SIZE-1:0]
    LL_9 = -'d40000, UL_9 = 'd40000, // Limits -40%/+40% of 100000 which gives 0%-80% with the 40% preset
    Nprst_9_MAX =  'd40000; // 40% duty cycle preset at NT_8=100000
localparam signed [TS9_FILTER_IO_SIZE+24-1:0] step_9 = Nprst_9_MAX; // Ramp over 134 s.
wire signed [TS9_FILTER_IO_SIZE-1:0] Nprst_9;
wire signed [TS9_FILTER_IO_SIZE-1:0] VDC_9_in; // Input to integrator whose output determines duty cycle of VDC_CLK_9.
wire signed [TS9_FILTER_IO_SIZE-1:0] NH_out_9; // Temporary storage signal.
wire signed [31:0] NH_in_9;
wire PID_EN_9;
// Error signal assignment.
assign VDC_9_in = T9_in + offset_9 - sp_9; 
// Start-up ramp.
temp_servo_startup_ramp#(TS9_FILTER_IO_SIZE, 1)temp_servo_startup_ramp_9(clk125kHz, TS_on_9_out, VDC_9_in, Nprst_9_MAX, step_9, PID_EN_9, Nprst_9);
// Temperature PID (without debugging outputs)
tempPID#(TS9_FILTER_IO_SIZE, TS9_ISCALING, TS9_PSCALING, TS9_DSCALING)
tempPID_9(
    clk125kHz,   // 1 MHz clocks
    PID_EN_9, is_neg_9, // PID on/negative signals
    NFI_9, NI_9, NFP_9, NP_9, ND_9, NFD_9, NGD_9,  
    errmult_9,
    LL_9, UL_9, // PID limits, with prst, determine the range of duty-cycles
    VDC_9_in,      // input to filter
    NH_out_9       // PID output            
);
// Add preset to output of filter.
assign NH_in_9 = NH_out_9 + Nprst_9; 
assign NH_9_out = NH_in_9; 
// Declaration of VDC. Outputs variable duty cycle pulses to drive output. 
VDC#(TS9_BS, TS9_on_dly_cnt, TS9_MULT)VDC_INST_9(clk100, TS_on_9_out, VDCtrig, NH_in_9, NT_9, VDC_9);

// Temperature servo indicator color signal assignments
assign TSclr0 = VDC_Cd_in[15:0];
assign TSclr1 = VDC_REF_in[15:0];
assign TSclr2 = VDC_2_in[15:0];
assign TSclr3 = VDC_3_in[15:0];
assign TSclr4 = VDC_4_in[15:0];
assign TSclr5 = VDC_5_in[15:0];
assign TSclr6 = VDC_6_in[15:0];
assign TSclr7 = VDC_7_in[15:0];
assign TSclr8 = VDC_8_in[15:0];
assign TSclr9 = VDC_9_in[15:0];

endmodule