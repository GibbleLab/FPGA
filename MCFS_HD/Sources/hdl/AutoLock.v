`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//// SUMMARY
// Auto-lock module that can be configured in several modes.
// Uses either transmission or reflection as an input (which changes the threshold comparison from > to <) and minimum/maximum or mean/amplitude as sweep parameters.
// It sets the output to zero or the mean if the servo is stopped, and resets the sweep to zero or the maximum.
// 
//// PORT DESCRIPTIONS
// clk: input clock
// STOPservos: input for primary stop-servo logic signal. It resets sweep_out and sets the PID outputs to 0.
// STOPthisServo: input for secondary stop-servo logic signal, which also resets sweep_out and sets the PID outputs to 0. 
// primary_servo_mode: if the lock state of a servo depends on another servo, this connects to the (scan || stop) control signals of the primary servo.
// primary_servo_locked: if the lock state of a servo depends on another servo, this connects to the PID_on of the primary servo.
// scan: input from display to continuously sweep.
// trig_in: threshold for lock
// s_in: input signal that lock triggers locking when it exceeds the threshold.
// minmean: minimum or mean of scan, dependent on "mode".
// maxamp: maximum or amplitude of scan, dependent on "mode".
// stepsize: fractional step of sweep output
// sweep_out: sweep output
// state_out: sweep state (GOINGUP or GOINGDOWN)
// relock_on: HIGH if sweep is on.
// PIDon: Output to turn on PID's.
//
//// PERMITTED MODE OPTIONS
// reftrans = "ref" or "trans", mode = "minmax" or "meanamp", offmode = "zero" or "mean", sweepresetmode = "zero" or "max"
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module AutoLock#(parameter reftrans = "trans", mode = "minmax", offmode = "zero", sweepresetmode = "zero")(
    input  wire               clk, // Clock
    input  wire               STOPservos,
    input  wire               STOPthisServo,
    input  wire               primary_servo_mode,
    input  wire               primary_servo_locked,
    input  wire               scan,
    // Relock trigger level, and input signal
    input  wire signed [15:0] trig_in,
    input  wire signed [15:0] s_in,
    // Sweep parameters and output
    input  wire signed [15:0] minmean,
    input  wire signed [15:0] maxamp,
    input  wire        [31:0] stepsize,
    output reg  signed [15:0] sweep_out,
    output wire               state_out,
    // Output logic signals for PID module
    output wire               relock_on,
    output reg                PIDon
);

// Assign minimum and maximum
reg signed [15:0] min, max;
always @(posedge clk) begin
    if (mode == "meanamp") begin
        min <= minmean - maxamp;
        max <= minmean + maxamp;
    end
    else if (mode == "minmax") begin
        min <= minmean;
        max <= maxamp;
    end
    else begin
        min <= 0;
        max <= 0;
    end
end
reg on; // Sweep hold
reg sweepEN; // Sweep enable
// Set the states of the internal enable signal (sweepEN) for the auto-lock sweep, the internal sweep hold signal (on), and the output enable signal for the PID (PIDon).
always @(posedge clk) begin
    if (STOPservos) begin
        on <= 1'b0;
        PIDon   <= 1'b0;
        sweepEN <= 1'b0;
    end
    else begin
        if (STOPthisServo) begin
            on <= 1'b0;
            PIDon   <= 1'b0;
            sweepEN <= 1'b0;
        end
        else begin
            if (scan) begin
                on <= 1'b1;
                PIDon   <= 1'b0;
                sweepEN <= 1'b1;
            end
            else begin
                if (primary_servo_mode) begin
                    on <= 1'b0;
                    PIDon   <= 1'b0;
                    sweepEN <= 1'b0;
                end
                else begin
                    if (primary_servo_locked) begin
                        if (reftrans == "ref") begin
                            if ($signed(s_in) < $signed(trig_in)) begin
                                on <= 1'b0;
                                PIDon   <= 1'b1;
                                sweepEN <= 1'b1;
                            end 
                            else begin
                                on <= 1'b1;
                                PIDon   <= 1'b0;
                                sweepEN <= 1'b1;
                            end
                        end
                        else if (reftrans == "trans") begin
                            if ($signed(s_in) > $signed(trig_in)) begin
                                on <= 1'b0;
                                PIDon   <= 1'b1;
                                sweepEN <= 1'b1;
                            end 
                            else begin
                                on <= 1'b1;
                                PIDon   <= 1'b0;
                                sweepEN <= 1'b1;
                            end
                        end
                        else begin
                            on <= 1'b0;
                            PIDon   <= 1'b0;
                            sweepEN <= 1'b0;
                        end
                    end
                    else begin
                        on <= 1'b0;
                        PIDon   <= 1'b0;
                        sweepEN <= 1'b0;
                    end
                end
            end
        end
    end
end
// Sweep, which turns on after a delay
wire signed [15:0] sweep_out_int;
Sweep#(.SIGNAL_OUT_SIZE(16), .resetmode(sweepresetmode))
Sweep_inst(clk, sweepEN, !on, min, max, stepsize, state_out, sweep_out_int);
assign relock_on = on;
// Assign the output depending on offmode.
// In the offmode state "off" the module output is either zero or the sweep mean.
// The stop stop-servo variables are control signals, e.g., from the display.
// The primary servo control signal enables this auto-lock sweep after the primary servo is locked. This input should be hard-coded to 1 if there is no primary servo.
always @(posedge clk) begin
    if (offmode == "mean") begin
        if (STOPservos) sweep_out <= minmean;
        else begin
            if (STOPthisServo) sweep_out <= minmean;
            else begin
                if (primary_servo_mode) sweep_out <= minmean;
                else                   sweep_out <= sweep_out_int;
            end
        end
    end
    else if (offmode == "zero") 
         sweep_out <= sweep_out_int;
    else sweep_out <= 0;
end

endmodule