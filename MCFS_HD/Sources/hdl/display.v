`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module to drive NHD-3.5-320240FT-CTXL-T New Haven Displays. It should work with other displays using FT81x chips. It includes touchscreen buttons to change servo's states and arbitrary waveforms. To function it needs its header file and other modules,
// (dec2str gain_inc_trig, IncGains, SR_CTRL) to function. To use multiple displays, the CS line has to be addressed and the program adjusted for multiple displays. 
// 
// The display:
// - is first initialized
// - receives commands from the FPGA to specify objects on the screen (buttons, text)
// - sends data when button objects are touched
// The display commands are 56+1 bit words: a 3 byte address, 4 bytes of data, and a dummy bit. 
// The dummy bit is a place-holder for a single sclk cycle at the end of each 56-bit word.
// During this sclk cycle the next 56-bit word from cmdarr is loaded.
// 
// Lam Tran, Daniel Schussheim, and Kurt Gibble
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
    input  wire [1:0] clrst0, // Cd Oven temperature servo indicator color signal
    // 10 temperature servo indicator color signals
    input  wire [1:0] clrst1, clrst2, clrst3, clrst4, clrst5, clrst6, clrst7, clrst8, clrst9, clrst10
);
// signal, function, and task declarations in header
`include "LCD_header.vh"

// Signals to synchronize this module and the SR_CTRL module.
assign active_out = active; // It seems this is not needed as an output.
assign data_active_out = data_active; // It seems this is not needed as an output.
// Relock states (locked, unlocked1s/1minute, unlocked). Input from top module.
assign out_relockledsarr[1] = out_relockleds_0;
assign out_relockledsarr[2] = out_relockleds_1;
assign out_relockledsarr[3] = out_relockleds_2;
assign out_relockledsarr[4] = out_relockleds_3;
assign out_relockledsarr[5] = 2'b01;
assign out_relockledsarr[6] = out_relockleds_4;
assign out_relockledsarr[7] = out_relockleds_5;
assign out_relockledsarr[8] = out_relockleds_6;
// Stop and scan variables    
assign STOPservos = touch_count9;
assign scan0 = scanarr[1];
assign scan1 = scanarr[2];
assign scan2 = scanarr[3];
assign scan3 = scanarr[4];
assign scan4 = scanarr[6];
assign scan5 = scanarr[7];
assign scan6 = scanarr[8];
assign stop0 = stoparr[1];
assign stop1 = stoparr[2];
assign stop2 = stoparr[3];
assign stop3 = stoparr[4];
assign stop4 = stoparr[6];
assign stop5 = stoparr[7];
assign stop6 = stoparr[8];

// Modules to adjust gains via the display. These modules are currently commented out so gains are not adjustable from the display.
/*
// If this section is uncommented, only the gains for the LBO (servo 1) would be adjustable. Making additional servos adjustable is straightforward: copy the signal declarations, module instantiations, and cases below that are used for the LBO.
// Convert a decimal number to a string (to show how many increments or decrements of a parameter).
Dec2Str1B Dec2Str_gainCnt(sclk, N_CNT_1[tcnt_gain], CNT_STR);
// This module produces the signal that IncGains uses to increase or decrease a particular gain.
//gain_inc_trig#(5)gain_inc_trig0(sclk, tcnt_gain, N_CNT_1[1], N_CNT_1[2], N_CNT_1[3], N_CNT_1[4], N_CNT_1[5], inc1_I, inc1_P, inc1_fH, inc1_fL);
gain_inc_trig#(5)gain_inc_trig0(sclk, tcnt_gain, N_CNT_1[1], N_CNT_1[2], N_CNT_1[3], N_CNT_1[4], N_CNT_1[5], inc1_I, inc1_P, inc1_D, inc1_fL);
// The 3 status signals below are used to reset the click counters to 0 when the gains are reprogrammed from a serial input.
reg Nrst1_temp, Nrst1_flag = 1'b0, Nrst1_flag_old;
*/


// Set colors for Cd servo button
clr_str_4_st cs4s0( sclk, clrst0,  htrclr[0]);
// Set colors for other servo indicators
clr_str_4_st cs4s1( sclk, clrst1,  htrclr[1]);
clr_str_4_st cs4s2( sclk, clrst2,  htrclr[2]);
clr_str_4_st cs4s3( sclk, clrst3,  htrclr[3]);
clr_str_4_st cs4s4( sclk, clrst4,  htrclr[4]);
clr_str_4_st cs4s5( sclk, clrst5,  htrclr[5]);
clr_str_4_st cs4s6( sclk, clrst6,  htrclr[6]);
clr_str_4_st cs4s7( sclk, clrst7,  htrclr[7]);
clr_str_4_st cs4s8( sclk, clrst8,  htrclr[8]);
clr_str_4_st cs4s9( sclk, clrst9,  htrclr[9]);
clr_str_4_st cs4s10(sclk, clrst10, htrclr[10]);

// The main loop that initializes the display and sends the normal list of display commands.

// *** See LCDheader.vh for signal definitions. *** \\
always @(posedge sclk) begin
// The logic below would need to be uncommented to adjust the LBO gains from the display.
//// Reset N_CNT_1[5:0]'s to count the button clicks for adjustable gains
//Nrst1_flag_old <= Nrst1_flag; // Nrst1_flag changes when the click counters N_CNT_1[5:0] are reset, which in turn resets Nrst1_temp to LOW so that the click counters are not continually reset.
//if (Nrst1) Nrst1_temp <= 1'b1; // Nrst1_temp goes HIGH when the serial line updates gains. Nrst1 stays HIGH to enable the click counters N_CNT_1[5:0] to be reset, which happens once per cmdarr transfer.
//else begin // Nrst1_temp remains HIGH until the click counters are reset to 0.
//    if (Nrst1_flag_old != Nrst1_flag) begin // Nrst1_flag changes after the click counters are reset when the serial input updates the gains.
//        Nrst1_temp <= 1'b0;
//    end
//end

// Assign initial values when reset goes high
if (cnt_rst == 1) assign_initial_values;

if (cnt_rst != 1) begin    
    if (active == 1) begin
        PD_OUT  <= PD;
        SDO     <= hostcmd[poscount_active]; // Set SDO to 0
        SCK     <= spiclock;
        
        if (bitcount == 0) begin
            if (CS == 1) spiclock <= 0;
            else spiclock <= clockout;
        end

        if (bitcount == 24) begin // Use 24 for a 24-bit shift-register interface, and 16 for a 16-bit.
            if (clockout == 0) poscount_active <= poscount_active;
            else begin
                if (poscount_active == 25) begin
                    wait_count0 <= wait_count0 +1;
                    if (wait_count0 == resetpulse) begin
                         PD <= 1;
                         wait_count0 <= 0;
                         wait_count1 <= wait_count1 +1;
                    end
                    if (wait_count1 == PDuptime) begin
                         poscount_active <= poscount_active - 1;
                         CS <= 0;
                         wait_count1 <= 0;
                    end
                end
                if (poscount_active == 1) CS <= 1;
                if (poscount_active == 0) begin
                    wait_count <= wait_count + 1;                    
                    if (wait_count == bootuptime) begin 
                        active <= 0;
                        data_active <= 1;
                        CS <= 0;
                        wait_count <= 0;
                        poscount_active <= 25;
                        wait_count5 <= debouncer;
                        regtouchtag_temp <= 0;
                    end 
                end
                else begin
                    if (poscount_active < 25) poscount_active <= poscount_active - 1;
                end
            end
            clockout <= !clockout;          
        end
    end 
          
            if (data_active == 1) begin
                
                PD_OUT  <= PD;
                case(iniorcmd)
                    0: SDO <= iniarr[count][poscount];
                    1: SDO <= cmdarr[count][poscount];
                endcase
                SCK     <= spiclock;
 
                if (bitcount == 0) begin
////////////////////////////////////////// READ DATA FROM THE DISPLAY /////////////////////////////////////////////
                    if (iniorcmd == 1) begin    
                        if (cmdarr[count][56] == 0) begin
                            if ((poscount == readposcount)&&(readbitcount < 16)&&(clockout == 0)) begin
                                readtemp <= {readtemp, SDI};
                                readposcount <= readposcount - 1;
                                readbitcount <= readbitcount + 1;
                            end
                            
                            if (readbitcount == 16) begin
                                readposcount <= 22;
                                readbitcount <= 0;
                                if ((count == countMAX) || (count == 2))
                                    regtouchtag <= {readtemp[7:0], readtemp [15:8]};
                                if ((count == countMAX-1) || (count == 1))
                                    regcmdread <= {readtemp[7:0], readtemp [15:8]};
                                if ((count == countMAX-2) || (count == 0))
                                    regcmdwrite <= {readtemp[7:0], readtemp [15:8]};
                                readtemp <= 0;  
                            end    
                        end
                    end
///////////////////////////////////////////END OF READ PART////////////////////////////////////////////// 
                    if (CS == 1) spiclock <= 0;
                    else spiclock <= clockout;
                end
                        
                if (bitcount == 24) begin // Use 24 for a 24-bit shift-register interface, use 16 for a 16-bit, etc.
                    if (clockout == 0)
                        poscount <= poscount;
                    else begin
                        if (poscount == 1)
                            CS <= 1;
                    
                        if (poscount == 0) begin
                            if (iniorcmd == 0) begin 
                                if (count < 22) begin
                                    count <= count + 1;
                                    poscount <= 56;
                                    CS <= 0;
                                end
                                else begin
                                    count <= 0; 
                                    poscount <= 56; 
                                    CS <= 0;
                                    iniorcmd <= 1;
                                end
                            end
                            if (iniorcmd == 1) begin 
                                if (count < countMAX) begin
                                    if (count == 1) begin
                                        if (regcmdwrite == regcmdread) begin
                                            currentoffset <= regcmdwrite;
                                            count <= count + 1;
                                            poscount <= 56;
                                            CS <= 0;
                                                
                                            //START: SET COLORS
                                            for (i = 1; i < 5; i = i + 1) begin
                                                if (touch_countarr[i] == 2) begin
                                                    statearr[i] <= " Scn";
                                                    colorarr[i] <= scancolor;
                                                    scanarr[i] <= 1'b1;
                                                    stoparr[i] <= 1'b0;
                                                end
                                                if (touch_countarr[i] == 1) begin
                                                    statearr[i] <= " Stp";
                                                    colorarr[i] <= adjcolor;
                                                    scanarr[i] <= 1'b0;
                                                    stoparr[i] <= 1'b1;
                                                end
                                                if (touch_countarr[i] == 0) begin
                                                    statearr[i] <= textarr[i];
                                                    scanarr[i] <= 1'b0;
                                                    stoparr[i] <= 1'b0;
                                                    if      (out_relockledsarr[i] == 2'b00) colorarr[i] <= greenarr[i];
                                                    else if (out_relockledsarr[i] == 2'b10) colorarr[i] <= unlock1s;
                                                    else                                    colorarr[i] <= unlock;
                                                end  
                                            end
                                            //// Three rightmost buttons on bottom row, BBO361 542 and 1083 and cavity servo 8 \\\\
                                            
                                            // for (i = 6; i < 8; i = i + 1) begin
                                            for (i = 6; i < 9; i = i + 1) begin
                                                if (touch_countarr[i] == 2) begin
                                                    statearr[i] <= " Scn";
                                                    colorarr[i] <= scancolor;
                                                    scanarr[i] <= 1'b1;
                                                    stoparr[i] <= 1'b0;
                                                end
                                                if (touch_countarr[i] == 1) begin
                                                    statearr[i] <= " Stp";
                                                    colorarr[i] <= adjcolor;
                                                    scanarr[i] <= 1'b0;
                                                    stoparr[i] <= 1'b1;
                                                end
                                                if (touch_countarr[i] == 0) begin
                                                    statearr[i] <= textarr[i];
                                                    scanarr[i] <= 1'b0;
                                                    stoparr[i] <= 1'b0;
                                                    if      (out_relockledsarr[i] == 2'b00) colorarr[i] <= greenarr[i];
                                                    else if (out_relockledsarr[i] == 2'b10) colorarr[i] <= unlock1s;
                                                    else                                    colorarr[i] <= unlock;
                                                end  
                                            end
                                            
                                            // cd oven temp servo button on bottom row
                                            case (touch_countarr[5])                                                 
                                                0: begin
                                                    statearr[5] <= "OFF";
                                                    colorarr[5] <= adjcolor;
                                                end
                                                1: begin 
                                                    statearr[5] <= "99 ";
                                                    colorarr[5] <= htrclr[0];
                                                end
                                                2: begin 
                                                    statearr[5] <= "119";
                                                    colorarr[5] <= htrclr[0];
                                                end
                                                3: begin 
                                                    statearr[5] <= "Cd ";
                                                    colorarr[5] <= htrclr[0];
                                                end
                                            endcase

                                            case (touch_countarr[10]) 
                                                0: begin
                                                    statearr[10] <= "OFF";
                                                    colorarr[10] <= adjcolor;
                                                end
                                                1: begin 
                                                    statearr[10] <= "SAT";
                                                    colorarr[10] <= motclr1;
                                                end
                                                2: begin 
                                                    statearr[10] <= "MOT";
                                                    colorarr[10] <= motclr2;
                                                end
                                                3: begin 
                                                    statearr[10] <= "MET";
                                                    colorarr[10] <= motclr3;
                                                end
                                            endcase
                                            
                                            //END: SET COLORS
                                        end
                                        else begin // regcmdwrite != regcmdread
                                            count <= 0;
                                            poscount <= 56;
                                            CS <= 0;
                                        end      
                                    end
                                        
                                    else begin // count != 1
                                        if (count == 2) begin
                                            assign_displaylist;   
                                        end                     
                                        count <= count + 1;
                                        poscount <= 56;
                                        CS <= 0;
                                    end
                                end
                                            
                                // When count = countMAX repeat cycle    
                                else begin
                                    //start: interpret touched tags
                                    regtouchtag_temp <= regtouchtag;
                                    if (regtouchtag_temp != regtouchtag) begin
                                        wait_count5 <= 0;
                                        //start: reset button
                                        if ((regtouchtag_temp == 0) && (wait_count5 == debouncer)) begin
                                            // Start/stop servo button (turns all servos on/off)
                                            if (regtouchtag == 9) begin
                                                touch_count9 <= touch_count9 + 1;
                                                if (touch_count9 == 0) startorstop <= "STRT";
                                                else                   startorstop <= "STOP";
                                            end
                                            // Successively update each servo button (1-4, 6-8: LBO, 542, 820, 1083, 542_361, 1083_361, Cavity servo 6)                                            
                                            if ((regtouchtag < 5)||(regtouchtag==6)||(regtouchtag==7)||(regtouchtag==8)) begin
                                                if (touch_countarr[regtouchtag] < 2) touch_countarr[regtouchtag] <= touch_countarr[regtouchtag] + 1;
                                                else                                 touch_countarr[regtouchtag] <= 0;
                                            end
                                            // Update Cd oven and FM MOT buttons
                                            if ((regtouchtag == 5) || (regtouchtag == 10)) begin
                                                if (touch_countarr[regtouchtag] < 3) touch_countarr[regtouchtag] <= touch_countarr[regtouchtag] + 1;
                                                else touch_countarr[regtouchtag] <= 0;
                                            end

// Uncomment this section to make gains adjustable from the display
                                            // Counter to specify the gain adjustment state 
//                                            if (regtouchtag == 5) begin
//                                            if (regtouchtag == 6) begin
////                                                if (tcnt_gain < 5) tcnt_gain <= tcnt_gain + 1;
//                                                if (tcnt_gain < 4) tcnt_gain <= tcnt_gain + 1;
//                                                else tcnt_gain <= 0;
//                                            end
//                                            // Increment or decrement the counter for the gain button
//                                            if ((regtouchtag == 7) ||(regtouchtag == 8))begin
//                                                // Adjust servo 1
//                                                if (tcnt_adj == 0) begin // Servo gains are LOCKed
//                                                    if (tcnt_gain == 0)   N_CNT_1[tcnt_gain] <= 0;
//                                                    // else increment the gain
//                                                    else begin
////                                                        if (regtouchtag == 6) N_CNT_1[tcnt_gain] <= N_CNT_1[tcnt_gain] + 1;
//                                                        if (regtouchtag == 7) N_CNT_1[tcnt_gain] <= N_CNT_1[tcnt_gain] + 1;
//                                                        else                  N_CNT_1[tcnt_gain] <= N_CNT_1[tcnt_gain] - 1;
//                                                    end
//                                                end
//                                            end
//                                            // End of gain adjustment
                                        end
                                        //end: reset button
                                    end
//                                    // When the gains are updated via the serial line, reset N_CNT_1[5:0]
//                                    else if (Nrst1_temp) begin
//                                        Nrst1_flag <= !Nrst1_flag; // Flip the flag signal after a reset
//                                        N_CNT_1[0] <= 5'd0;
//                                        N_CNT_1[1] <= 5'd0;
//                                        N_CNT_1[2] <= 5'd0;
//                                        N_CNT_1[3] <= 5'd0;
//                                        N_CNT_1[4] <= 5'd0;
//                                        N_CNT_1[5] <= 5'd0;
//                                    end
                                    // Debouncer
                                    else begin
                                        if (regtouchtag_temp == 0) begin
                                            if (wait_count5 < debouncer)
                                                wait_count5 <= wait_count5 + 1;
                                        end
                                    end         
                                    //end: interpret touched tags
                                               
                                    count <= 0; //repeat display list
                                    poscount <= 56; //0
                                    if ((regtouchtag_temp == 0) && (wait_count5 == debouncer) && (regtouchtag == 10))
                                        CS <= 1;
                                    else
                                        CS <= 0; // repeat
                                end      
                            end
                        end
                        else
                            poscount <= poscount - 1;
                    end
                    clockout <= !clockout;
                end
            end 
        end
    end

// Same CS for all displays.
always @(posedge sclk) begin
    CS0_OUT <= CS;
    CS1_OUT <= CS;
end

assign Cd_oven_state = touch_countarr[5], 
       MOT_state     = touch_countarr[10];
                   
endmodule