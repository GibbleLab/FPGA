`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module to change signed integer from -9 to 9 into a string for the display.
//
// Daniel Schussheim
//////////////////////////////////////////////////////////////////////////////////

module Dec2Str1B(
    input  wire               clk,
    input  wire signed [4:0]  N,
    output reg         [23:0] STR
);
// Hex codes for + and - sign and for a space
localparam [7:0] plus = 8'h2B, minus = 8'h2D, space = 8'h20, bad = 8'h3F; // bad is '?'
reg signed [4:0] N_temp;
reg is_neg;
always @(posedge clk) begin
    // Flip sign if negative; note that N is negative.
    if (N < 0) begin
        N_temp <= -N;
        is_neg <= 1'b1;
    end
    else begin 
        N_temp <= N;
        is_neg <= 1'b0;
    end
    // Make STR
    if (N_temp > 9) begin
        STR <= {bad, bad, bad}; // Print ??? if outside [-9, 9]
    end
    // Otherwise print "+ n" or "- |n|"
    else begin
        if (is_neg) STR <= {minus, space, 4'h3, N_temp[3:0]};
        else        STR <= {plus , space, 4'h3, N_temp[3:0]};
    end
end
endmodule