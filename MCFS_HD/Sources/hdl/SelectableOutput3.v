`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// 3:1 output MUX.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////
module SelectableOutput3(
    // Clock
    input  wire               clk,
    // Select input, 0 for in0, 1 for in1, etc
    input  wire        [5:0]  sel,
    // Up to 3 input channels
    input  wire signed [15:0] in0, in1, in2,
    // Output
    output reg  signed [15:0] out);
// Output selected signal
always @(posedge clk) begin
    case (sel) 
        0: out <= in0;
        1: out <= in1;
        2: out <= in2;
    endcase
end
endmodule