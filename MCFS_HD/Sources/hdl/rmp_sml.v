`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Makes a stepped waveform with an adjustable offset, useful for checking carry transitions of fast DAC's.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////


module rmp_sml(
    input wire clk,
    input wire [31:0] N,
    input wire signed [15:0] step, offset,
    output reg signed [15:0] out
);
    
//// Stepped waveform\\\\
// parameters
localparam stepsizeLO = 2'd1;
localparam [5:0] N0 = 6'd8;  //Hold
localparam [5:0] N1 = 6'd10; //Slow ramp
localparam [5:0] N2 = 6'd2;  //Fast ramp
localparam [2:0] s0 = 3'd0, s1 = 3'd1, s2 = 3'd2, s3 = 3'd3, s4 = 3'd4, s5 = 3'd5, s6 = 3'd6, s7 = 3'd7;

function [8:0] nextstate;
    input [2:0] state;
    input [5:0] count;
    begin
        case (state)
            s0: begin
                if (count <(N0-1)) nextstate = {count + 6'b1, s0};
                else nextstate = {6'b0, s1};
            end
            s1: begin
                if (count <(N1-1)) nextstate = {count + 6'b1, s1};
                else nextstate = {6'b0, s2};
            end
            s2: begin
                if (count <(N2-1)) nextstate = {count + 6'b1, s2};
                else nextstate = {6'b0, s3};
            end
            s3: begin
                if (count <(N1-1)) nextstate = {count + 6'b1, s3};
                else nextstate = {6'b0, s4};
            end
            s4: begin
                if (count <(N0-1)) nextstate = {count + 6'b1, s4};
                else nextstate = {6'b0, s5};
            end
            s5: begin
                if (count <(N1-1)) nextstate = {count + 6'b1, s5};
                else nextstate = {6'b0, s6};
            end 
            s6: begin
                if (count <(N2-1)) nextstate = {count + 6'b1, s6};
                else nextstate = {6'b0, s7};
            end 
            s7: begin
                if (count <(N1-1)) nextstate = {count + 6'b1, s7};
                else nextstate = {6'b0, s0};
            end 
            default: nextstate = {6'b0, s0};
        endcase 
    end
endfunction

reg signed [15:0] out0;
reg [31:0] cnt;
reg [5:0] cnts;
reg [2:0] state;
always @(posedge clk) begin
    if (cnt < (N-1)) begin
        cnt <= cnt + 1;
        state <= state;
        cnts <= cnts;
    end
    else begin
        cnt <= 0;
        {cnts, state} <= nextstate(state, cnts);
        case (state)
            s0: out0 <= 0;
            s1: out0 <= step;
            s2: out0 <= step <<< 1;
            s3: out0 <= step;
            s4: out0 <= 0;
            s5: out0 <= -step;
            s6: out0 <= -step <<< 1;
            s7: out0 <= -step;
        endcase         
    end
    out <= offset + out0;
end

endmodule