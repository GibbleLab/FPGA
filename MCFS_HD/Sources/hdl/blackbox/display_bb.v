`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Blackbox module for OOC synthesis and implementation
//////////////////////////////////////////////////////////////////////////////////
module display(
    input wire reset, sclk,
    // bitcount input from SR_CTRL module
    input  wire [5:0] cnt_rst,
    input  wire [4:0] bitcount,
    output wire       active_out, data_active_out, // It seems these are complements of one another and not needed as outputs.
    // Outputs to SR_CTRL
    output reg CS0_OUT, CS1_OUT,
               PD_OUT, SCK, SDO,
    // Serial input
    input  wire SDI,
    // Lock state for servos
    input  wire [1:0] out_relockleds_0, out_relockleds_1, out_relockleds_2, out_relockleds_3, // LBO, 542_361, 820_542, 1083_ref
                      out_relockleds_4, out_relockleds_5, out_relockleds_6, // 1083_ref, 542_361, 1083_361, CAVITY SERVO 7
    // Stop and scan servo outputs to auto-lock modules
    output wire STOPservos,
                scan0, scan1, scan2, scan3, scan4, scan5, scan6,
                stop0, stop1, stop2, stop3, stop4, stop5, stop6,
    // State for cadmium oven and FM MOT program
    output wire [1:0] Cd_oven_state, MOT_state,
    // Triggers to increase or decrease gains: not currently used
//    output wire [1:0] inc1_I,
//    output wire [1:0] inc1_P,
//    output wire [1:0] inc1_fH,
//    output wire [1:0] inc1_D,
//    output wire [1:0] inc1_fL,
//    input  wire       Nrst1,
    // Temperature servo indicator color signals
    input  wire [1:0] clrst0,
    // 10 temperature servo indicator color signals
    input  wire [1:0] clrst1, clrst2, clrst3, clrst4, clrst5, clrst6, clrst7, clrst8, clrst9, clrst10
);
        
endmodule