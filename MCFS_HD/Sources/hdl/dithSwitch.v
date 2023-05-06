`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module to alternately enable two dithers to reduce potential interference between 2 locks to the same (361 nm SFG) cavity.
// After the FM_MOT EN goes HIGH, dither 1 starts, controlled by dithEN1 going high for cnt1_MAX + 1 cycles, after which dithEN0 goes HIGH for cnt0_MAX + 1 cycles
// The trig0/1 inputs pulse HIGH once per modulation cycle and are used here to count dither cycles.
// All dithers are disabled and the counters reset when EN goes LOW, e.g., during fluorescence detection. 
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module dithSwitch(
    input  wire clk, EN, trig0, trig1,
    input  wire [31:0] cnt0_MAX, cnt1_MAX,
    output reg dithEN0, dithEN1
);

reg [31:0] cnt = 0; // dither cycle counter
reg state = 0, lc0 = 0, lc1 = 0; // state selects the dither that is or will be enabled. lc0/1 indicate the last cycle of the corresponding dither
always @(posedge clk) begin
    if (EN) begin
        if (!state) begin // Dither 0 enabled

            if (cnt <= cnt0_MAX) begin
                // Enable dither 0 after the last cycle of dither 1.
                if (lc1) begin
                    if (trig1) begin
                        dithEN0 <= 1;
                        lc1     <= 0;
                    end
                    else begin 
                        dithEN0 <= dithEN0;    
                        lc1     <= lc1;
                    end
                    dithEN1 <= dithEN1; 
                    lc0     <= lc0;  
                    cnt     <= cnt;
                end
                // dither 0 is enabled for cnt0_MAX dither cycles.
                else begin
                    dithEN0 <= 1;
                    dithEN1 <= 0;
                    lc0     <= 0;
                    lc1     <= 0;
                    if (trig0) cnt <= cnt + 1;
                    else       cnt <= cnt;
                end
                state <= state;
            end
            // Last cycle of dither 0
            else begin
                dithEN0 <= 0;
                dithEN1 <= 0;
                lc0     <= 1;
                lc1     <= 0;
                cnt     <= 0;
                state   <= 1;
            end
        end
        else begin // Dither 1 enabled
            if (cnt <= cnt1_MAX) begin
                // Enable dither 1 after the last cycle of dither0.
                if (lc0) begin
                    dithEN0 <= dithEN0; 
                    if (trig0) begin
                        dithEN1 <= 1;
                        lc0     <= 0;
                    end
                    else begin 
                        dithEN1 <= dithEN1;    
                        lc0     <= lc0;
                    end
                    lc1 <= lc1;
                    cnt <= cnt;
                end
                //  dither 1 is enabled for cnt1_MAX dither cycles.
                else begin
                    dithEN0 <= 0;
                    dithEN1 <= 1;
                    lc0     <= 0;
                    lc1     <= 0;
                    if (trig1) cnt <= cnt + 1;
                    else       cnt <= cnt;  
                end 
                state <= state;
            end
            // Last cycle of dither 1
            else begin
                dithEN0 <= 0;
                dithEN1 <= 0;
                lc0     <= 0;
                lc1     <= 1;
                cnt     <= 0;
                state   <= 0;
            end
        end
    end
    // When the dithers are disabled, initialize the control and status signals – dither 1 is set as the first to be enabled.
    else begin
        dithEN0 <= 0;
        dithEN1 <= 0;
        lc0     <= 0;
        lc1     <= 0;
        cnt     <= 0;
        state   <= 1;
    end
end

endmodule