`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module to ramp temperature servo duty cycle to prst_MAX over a timescale of up to several minutes.
// When the error signal, err, changes sign, the PID is enabled and the ramp continues to prst_MAX.
// The ONATMAX selects either enabling the PID once the ramp reaches prst_MAX or holding to enable once the error signal changes sign.
// The preset ramp changes by step/2^24 each clock cycle, so step should be 93 to ramp from 0 to 100000 (100%) in 3 minutes.
// 
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////
module temp_servo_startup_ramp#(
    parameter SIGSIZE = 18, // Size of input signal
    // ONATMAX = 1 sets PID_EN HIGH when prst reaches prst_MAX,  
    // ONATMAX = 0 leaves PID_EN controlled by the error signal sign change 
    parameter [0:0] ONATMAX = 0 
)(
    input wire clk, on,
    input wire signed [SIGSIZE-1:0] err, prst_MAX,
    input wire signed [SIGSIZE+24-1:0] step,
    output reg PID_EN,
    output reg [SIGSIZE-1:0] prst
);

reg [SIGSIZE+24:0] prst_temp;
reg sgn0, sgn1, sgnf, sgntrig;
always @(posedge clk) begin
    prst <= prst_temp[SIGSIZE+24-1:24];
    // Sign of current and previous error signals.
    sgn0 <= err[SIGSIZE-1];
    sgn1 <= sgn0;
    sgnf = sgn0 != sgn1; // HIGH if sign changed
    if (on) begin
        if (sgntrig) begin
            // Ramp to max.
            if (prst_temp < prst_MAX <<< 24) prst_temp <= prst_temp + step;
            else                             prst_temp <= prst_temp;
            sgntrig <= sgntrig;
            PID_EN <= PID_EN;
        end 
        else begin
            // Enable PID if sign flipped and hold ramp.
            if (sgnf) begin
                prst_temp <= prst_temp;
                sgntrig <= 1;
                PID_EN <= 1;
            end 
            else begin
                // Ramp prst if it is less than prst_MAX, and hold PID_EN
                if (prst_temp < prst_MAX <<< 24) begin
                    prst_temp <= prst_temp + step;
                    PID_EN <= PID_EN;
                // If prst = prst_MAX, hold PID_EN or set to 1, depending on ONATMAX parameter.
                end 
                else begin
                    prst_temp <= prst_temp;
                    if (ONATMAX) PID_EN <= 1;
                    else         PID_EN <= PID_EN;
                end
                sgntrig <= sgntrig;
            end
        end
    end
    // Reset parameters if not on.
    else begin
        prst_temp <= 0;
        PID_EN <= 0;
        sgntrig <= 0;
    end
end

endmodule