`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module to output display colors if beginning and ending serial programming handshakes match, or if the serial line has no input (0 or ffff). 
// 
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////
module serialHSmon(
    input wire clk,
    input wire [15:0] hs_i, hs_f,
    output reg [1:0] out
);
// Color codes from display submodule clr_str_4_st.v
//        2'b00: c0 <= red;
//        2'b01: c0 <= orange;
//        2'b10: c0 <= lightblue;
//        2'b11: c0 <= blue;
localparam [1:0] red = 2'b00, blue = 2'b11, lightblue = 2'b10;
always @(posedge clk) begin
    if (((hs_i==16'h0000)&&(hs_f==16'h0000))||((hs_i==16'hffff)&&(hs_f==16'hffff))) begin
        out <= blue;
    end    
    else begin
        if (hs_i == hs_f) begin
            out <= lightblue;
        end
        else begin
            out <= red;
        end
    end
end
endmodule