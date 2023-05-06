`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// 8:1 output MUX.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////
module SelectableOutput8(
    // Clock
    input  wire               clk,
    // Select input, 0 for in0, 1 for in1, etc
    input  wire        [5:0]  sel,
    // Up to 8 input channels
    input  wire signed [15:0] in0, in1, in2, in3, in4, in5, in6, in7,
    // Output
    output reg  signed [15:0] out);

// Output selected signal
always @(posedge clk) begin
case (sel) 
    0: out <= in0;
    1: out <= in1;
    2: out <= in2;
    3: out <= in3;
    4: out <= in4;
    5: out <= in5;
    6: out <= in6;
    7: out <= in7;
endcase
end
endmodule