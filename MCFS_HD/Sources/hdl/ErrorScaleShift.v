`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module to bit-shift and add a modulation and offsets to a servo error signal.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module ErrorScaleShift#(
    parameter N_B = 16, 
    parameter N_P = 9, 
    parameter N_err_sh = N_P, 
    parameter SIGNAL_SIZE = 25
)(
    input wire clk,
    input wire signed [N_B-1:0] e_in,           // Input error signal
    input wire signed [N_B-1:0] offsetS,        // Static offset
    input wire signed [N_B-1:0] mod,            // Modulation
    input wire signed [N_B-1:0] modscaling,     // Modulation right bit-shift
    input wire signed [SIGNAL_SIZE-1:0] offset, // Dynamic offset from dither integrator
    input wire DITHon,                          // Logical signal to turn on dither
    output wire signed [SIGNAL_SIZE-1:0] modscaled_out,
    output wire signed [SIGNAL_SIZE-1:0] err);  // Error signal output
    
wire signed [N_B-1:0] mod_on; // Modulation outputs
wire signed [SIGNAL_SIZE-1:0] modscaled; // Scaled and shifted modulation, and filtered modulation
// Scale modulation
assign mod_on = (DITHon)? mod : 16'd0;
assign modscaled = (mod_on <<< N_P) >>> modscaling;
assign modscaled_out = modscaled;
reg signed [SIGNAL_SIZE-1:0] err_reg_0, err_reg_1, err_reg_2, err_reg_3;
always @(posedge clk) begin
    err_reg_2 <= offset;
    err_reg_1 <= err_reg_2 - (offsetS <<< N_P);
    err_reg_0 <= err_reg_1 + modscaled;
end

assign err = err_reg_0 + (e_in <<< N_err_sh);
 
endmodule