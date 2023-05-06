`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module outputs a hex RGB color code depending on the input's sign and magnitude. 
// A large negative input yields dark red, small and negative orange, small and positive light blue, and large positive blue. 
// Used in display.v.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module clr_str_4_st(
    input wire clk,
    // Signal input and range.
    input wire  [1:0] clrst,
    // Output color.
    output reg [23:0] c0
);

// The color codes in hex RGB.
parameter [23:0] blue      = 24'h0000ff,
                 red       = 24'hff0000,
                 orange    = 24'hff8c00,
                 lightblue = 24'hadd8e6;

// Set the colors
// reg [1:0] state0;
always @(posedge clk) begin
    // Set color c0.
    case (clrst)
        2'b00: c0 <= red;
        2'b01: c0 <= orange;
        2'b10: c0 <= lightblue;
        2'b11: c0 <= blue;
    endcase
end
                 
endmodule