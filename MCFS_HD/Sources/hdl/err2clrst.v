`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Outputs a 2-bit number for temperature servo indicator colors to show if the error signal is positive or negative and its magnitude is greater or less than in0r
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module err2clrst(
    input wire clk,
    // Signal input and range.
    input wire signed [15:0] in0,
                             in0r,
    output reg        [1:0]  clrst
);

// Function that sets the state of the input.
// Low is 0, slightly low is 1,
// slightly high is 2, and high is 3.
function [1:0] state;
    input signed [15:0] in, inr;
    begin
        if (in < 0) begin
            if (in < -inr) state = 2'b00;
            else           state = 2'b01;
        end
        else begin
            if (in < inr) state = 2'b10;
            else          state = 2'b11;
        end
    end
endfunction

// Set the color state
always @(posedge clk) clrst <= state(in0, in0r);
                 
endmodule