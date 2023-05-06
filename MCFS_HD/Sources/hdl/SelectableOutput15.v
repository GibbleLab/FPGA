`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// 15:1 output MUX. Input sel=15 doesn’t change the selected output.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////
module SelectableOutput15(
    // Clock
    input  wire               clk,
    // Select input, 0 for in0, 1 for in1, etc
    input  wire        [3:0]  sel,
    // Up to 15 input channels
    input  wire signed [15:0] 
        in0, in1, in2,  in3,  in4,  in5,  in6,  in7,
        in8, in9, in10, in11, in12, in13, in14,
    // Output
    output reg  signed [15:0] out);
// This signal is used when sel==15 to leave the selected output unchanged.
reg [3:0] stemp;
// Output appropriate signal
always @(posedge clk) begin
    // Continue to output the same signal if sel == 15.
    if (sel == 15) stemp <= stemp;
    // Otherwise output the selected signal
    else           stemp <= sel;
    case (stemp) 
        0:      out <= in0;
        1:      out <= in1;
        2:      out <= in2;
        3:      out <= in3;
        4:      out <= in4;
        5:      out <= in5;
        6:      out <= in6;
        7:      out <= in7;
        8:      out <= in8;
        9:      out <= in9;
        10:     out <= in10;
        11:     out <= in11;
        12:     out <= in12;
        13:     out <= in13;
        14:     out <= in14;
    endcase
end
endmodule