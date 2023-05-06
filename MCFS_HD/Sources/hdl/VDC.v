`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module outputs a 1-bit variable duty cycle pulse for Pulse Width Modulation servos.
// A scaled 4-bit averaging sequence is added to the duty cycle for 16x greater precision. 
// It also includes an adjustable turn-on phase for load diversity of multiple VDC servos.
// 
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module VDC#(
    parameter [31:0] BS = 3, dly_cnt = 0,
    parameter [5:0]  MULT = 6'd25
)(
    input  wire        clk, on, vdc_trig,
    input  wire signed [31:0] NH, NT,
    output wire        out
);

reg [32:0] cnt; // count, increments each clk cycle
// # of cycles to set output to 1. Value is latched because servos updates faster than the VDC frequency.
reg  signed [31:0] NH_temp; 
//// 4-bit signal that rounds LSB of the latched NH for increased precision \\\\
wire        [3:0]  rout;  // 4-bit averaging sequence.
wire signed [31:0] rndsh; // Scaled rout.

//// Load diversity \\\\
// The vdc_trig signal is shared to synchronize multiple VDC servo.
// It goes HIGH for one clk cycle (100 MHz) during each VDC clock cycle (1 kHz).
// The VDC counter, cnt, is initialized to cnt_start after every vdc_trig.
// Example: Initializing the counter to cnt_start = 20,000 delays VDC going high by delay_cnt = 80,000.
wire [32:0] cnt_start_int, cnt_start;
assign cnt_start_int = NT-dly_cnt;
assign cnt_start = ((dly_cnt > NT)||(dly_cnt <= 0))?(0):(cnt_start_int);

// Assign intermediate output to the output
reg out_temp;
assign out = (on)?(out_temp):(0); // If on is HIGH, output out_temp, otherwise output 0.
//// Generate Square Wave Output \\\\
always @(posedge clk) begin
    // On vdc_trig set the counter to the cnt_start. 
    // Otherwise increment the counter until it reaches NT, then set to 0.
    if (vdc_trig) begin
        if (dly_cnt < 0) cnt <= 0;
        else             cnt <= cnt_start;
    end
    else if (cnt >= NT-1) cnt <= 0;
    else                  cnt <= cnt + 1;
    // NH is the number of cycles to hold out HIGH.
    // If NH is negative or larger than NT, set the output to 0 or 1.
    if (NH < 0)       out_temp <= 0;
    else if (NH > NT) out_temp <= 1;
    // else, latch the value NH and sum with the current value of the averaging sequence when cnt = 0
    // output the VDC waveform.
    else begin
        if (cnt == 0) NH_temp <= NH + rndsh;
        // Set out to HIGH for NH counts, then 0 for the rest.
        if (cnt < NH_temp) out_temp <= 1;
        else               out_temp <= 0;
    end
end

// Averaging sequence to give 16x more duty cycle precision.
// It cycles the fractional bits in a sequence, most significant fractional bit every cycle, and LSB 8x slower. 
FastAVG4 FastAVG4_inst(clk, on, NT, rout);
// rout is the output from the averaging sequence. 
// Scale rout so its MSB corresponds to the most-significant fractional bit of NH.
// A multiplier and a bit-shift account for ratios of the VDC clock and shift register update rates.
// For example, if clk = 100 MHz, and the shift-register update rate is 2 MHz,
// increasing NH by 50 increases the pulse length by 1 shift register cycle. 
// Using MULT = 25 and BS = 3 makes the MSB of rout = 50, a full shift register cycle. 
assign rndsh = (MULT*rout) >> BS; 

endmodule