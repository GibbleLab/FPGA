`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module to monitor the fast ADC frames and output a corresponding display color.
// 
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////
module FRmon(
    input wire clk,
    input wire [7:0] FR0, FR1, FR2, FR3, FR4,
    output reg [1:0] out
);
// Color codes from display submodule clr_str_4_st.v
//        2'b00: c0 <= red;
//        2'b01: c0 <= orange;
//        2'b10: c0 <= lightblue;
//        2'b11: c0 <= blue;
localparam [1:0] red = 2'b00, orange = 2'b01, lightblue = 2'b10;
localparam [7:0] FRcor = 8'hf0;
reg f0, f1, f2, f3, f4;
reg ftest, trig;
reg [31:0] cnt;
localparam [31:0] cntMAX = 32'd3_000_000_000; // 30 seconds
always @(posedge clk) begin
    f0 <= (FR0==FRcor);
    f1 <= (FR1==FRcor);
    f2 <= (FR2==FRcor);
    f3 <= (FR3==FRcor);
    f4 <= (FR4==FRcor);
    ftest <= !(f0&f1&f2&f3&f4);
    // If any frame is incorrect, set count to max and output to red.
    if (ftest) begin
        cnt <= cntMAX;
        out <= red;
    end
    // If all frames are correct, set the output to orange for 30 seconds, otherwise light blue.
    else begin
        if (cnt > 0) begin
            cnt <= cnt - 1;
            out <= orange;
        end
        else begin
            cnt <= cnt;
            out <= lightblue;
        end        
    end 
end

endmodule