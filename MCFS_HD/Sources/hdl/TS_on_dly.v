`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// This module delays the TS_on signals by N clk cycles after a reset pulse. 
// It is used to delay the Temp Servo enables after the FPGA is reprogrammed.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module TS_on_dly#(parameter N = 1_000_000)(
    // Clock and control signals
    input  wire clk, rst, TS_on_Cd_3,     TS_on_REF,     TS_on_2,     TS_on_3,     TS_on_4,     TS_on_5,     TS_on_6,     TS_on_7,     TS_on_8,     TS_on_9, 
    output reg            TS_on_Cd_3_out, TS_on_REF_out, TS_on_2_out, TS_on_3_out, TS_on_4_out, TS_on_5_out, TS_on_6_out, TS_on_7_out, TS_on_8_out, TS_on_9_out  
);

// Initialize in the off state.
reg [31:0] cnt = 0;
reg rst_trig = 0;

always @(posedge clk) begin
    // rst_trig = 0 to start, then changes to 1, and stays 1, after posedge of a rst pulse.
    if (rst_trig) rst_trig <= 1;
    else begin
        if (rst) rst_trig <= 1; // Once rst_trig goes HIGH, currently it is never set LOW, so a subsequent rst would not repeat the delayed enable. 
        else rst_trig <= 0;
    end
    if (rst_trig) begin
        if (cnt < N-1) begin
            cnt <= cnt + 1;
            TS_on_Cd_3_out <= 0;
            TS_on_REF_out  <= 0;
            TS_on_2_out    <= 0;
            TS_on_3_out    <= 0;
            TS_on_4_out    <= 0;
            TS_on_5_out    <= 0;
            TS_on_6_out    <= 0;
            TS_on_7_out    <= 0;
            TS_on_8_out    <= 0;
            TS_on_9_out    <= 0;
        end
        else begin
            cnt <= cnt;
            TS_on_Cd_3_out <= TS_on_Cd_3;
            TS_on_REF_out  <= TS_on_REF;
            TS_on_2_out    <= TS_on_2;
            TS_on_3_out    <= TS_on_3;
            TS_on_4_out    <= TS_on_4;
            TS_on_5_out    <= TS_on_5;
            TS_on_6_out    <= TS_on_6;
            TS_on_7_out    <= TS_on_7;
            TS_on_8_out    <= TS_on_8;
            TS_on_9_out    <= TS_on_9;
        end
    end
    // Output 0 until rst triggers cnt.
    else begin
        cnt <= 0;
        TS_on_Cd_3_out <= 0;
        TS_on_REF_out  <= 0;
        TS_on_2_out    <= 0;
        TS_on_3_out    <= 0;
        TS_on_4_out    <= 0;
        TS_on_5_out    <= 0;
        TS_on_6_out    <= 0;
        TS_on_7_out    <= 0;
        TS_on_8_out    <= 0;
        TS_on_9_out    <= 0;
    end
end
    
endmodule