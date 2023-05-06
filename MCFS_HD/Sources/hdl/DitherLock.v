`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module to generate dithers and demodulate an input.
// 
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////


module DitherLock#(parameter N_dithDly = 20'd1_000_000, parameter N_B = 16, parameter N_P = 9, parameter SIGNAL_SIZE = 25, parameter [0:0] zcmode = 0)
   (input wire clk,                               // Clock input
    input wire signed [N_B-1:0] s_in,             // Input signal
    input wire [N_B-1:0] divFast,                 // Dither clock dividers
    input wire [N_B-1:0] divSlow,
    input wire [3:0] inhmode,                     // Initial and ending phase of dither is inhmode*(22.5 deg) where 0 deg = the positive slope zero crossing. Adjusting this minimizes lock transients if inhibiting the dither for detection.
    input wire demod_bit,                         // Bit to select sine or cosine demodulation
    input wire PID_on,                            // Servo enable bit
    output reg DITHon,                            // Dither enable
    output wire signed [N_B-1:0] mod,             // Modulation output
    output wire signed [N_B-1:0] demod,           // Selected demodulated signal
    output wire signed [N_B-1:0] demod_out,       // Cosine demodulation
    output wire signed [N_B-1:0] demodQ_out,      // Sine demodulation
    output wire signed [N_B-1:0] demod2f_out,     // 2f cosine demodulation
    output wire signed [N_B-1:0] demod2fQ_out,    // 2f sine demodulation
    output wire signed [N_B-1:0] demod3f_out,     // 3f cosine demodulation
    output wire signed [N_B-1:0] demod3fQ_out,    // 3f sine demodulation
    output wire signed [SIGNAL_SIZE-1:0] demod_in,
    output wire                          inhtrig  // trigger for dither inhibit module
);
   
// Delay turn on of integrator by (N_dithDly/100_000_000) seconds
reg trig_int;
reg [19:0] counter = 20'd0;
always @(posedge clk) begin
    // Input trigger, high when PID_on     
    if (PID_on) trig_int <= 1'b1;
    else        trig_int <= 1'b0; 
    // Delay DITHon by N_dithDly counts of clk, zero if trig_int = 0
    if (trig_int && counter < N_dithDly) begin
        counter <= counter + 20'b1;
        DITHon <= 1'b0;
    end
    else if (trig_int && counter == N_dithDly) begin
        DITHon <= 1'b1;
        counter <= counter;
    end
    else begin
        counter <= 20'b0;
        DITHon <= 1'b0;
    end
end

// Lock-in amplifier
localparam demodSize = 35;
wire signed [N_B-1:0] LO_pre_int;
wire trig_out;
wire signed [demodSize-1:0] demod_int, demodQ_int, demod2f_int, demod2fQ_int, demod3f_int, demod3fQ_int;
lockIn#(demodSize)lockIn_inst(
    // Clocks
    clk, divFast, divSlow, inhmode,
    // Input signal
    s_in,
    // Modulation output      
    trig_out, LO_pre_int, mod, inhtrig,
    // Demodulated outputs
    demod_int, demodQ_int,
    demod2f_int, demod2fQ_int, demod3f_int, demod3fQ_int
);
// Select bits to output
assign demod_out = demod_int[16:1];
assign demodQ_out = demodQ_int[16:1];
assign demod2f_out = demod2f_int[15:0];
assign demod2fQ_out = demod2fQ_int[15:0];
assign demod3f_out = demod3f_int[15:0];
assign demod3fQ_out = demod3fQ_int[15:0];

// Select sine or cosine demod
// If demod_bit  = 0: in phase demod, if 1: 90 degrees quadrature demod
assign demod = (demod_bit == 1'b0) ? demod_out : demodQ_out;

// Scale demodulation, and force it to zero if dither is off
assign demod_in = (DITHon) ? demod_int : 'sd0;

endmodule