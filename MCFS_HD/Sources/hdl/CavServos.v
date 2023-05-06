`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Parent module for 9 cavity servo modules. 
// The servos include a PID filter using an input error signal, auto-lock on transmission, reflection or SFG output, dither lock correction of the PID error signal offset, a slow feed forward scan input, and overflow/underflow protection.
//
// Servo 5 (BBO1083_361) is a dither lock, using either the SFG output or cavity transmission, and therefore doesn't have a separate input error signal (and then there is no dither lock correction).
// The other servos are Hansch-Couillaud locks.
// They have error signal corrections from slow dither locks to transmission [servos 0 (LBO), 1 (BBO542_326), Servo 3 (1083 reference cavity), reflection [Servo 2 (820), 6 (332), 7 and 8], or SFG output [Servos 4 (BBO542_361)].
//
// The auto-lock sweep parameters are min/max  or mean/amplitude [Servos 2 (820), 3 (1083 reference cavity), and 5 (BBO1083_361)]
//
// Servos 0 (LBO), 1 (BBO542_326), and 2 (820) have a slow feed-forward input.  Servo 2 (820) also has a very slow tuning input.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module CavServos#(parameter N_B = 16, N_P = 9, SIGNAL_SIZE = 25)(
    // Clock, PID enables, and filter signs.
    input wire 
        clk100, clk125kHz,
        STOPservos, stopLBO, stop542_326, stop820, stop1083, stop542_361, stop1083_361, stop_CS6, stop_CS7, stop_CS8,
        scanLBO, scan542_326, scan820, scan1083, scan542_361, scan1083_361, scan_CS6, scan_CS7, scan_CS8,
        dithEN, // dither enable
    // Auto-lock parameters
    input wire signed [15:0] 
        // Thresholds for locks, sweep maxima & minima or amplitudes and means
        locktrig0, stop_sweep_0, start_sweep_0, 
        locktrig1, stop_sweep_1, start_sweep_1, 
        locktrig2, amp_sweep_2, mean_sweep_2, mean820sh, // static shift of sweep mean
        locktrig3, amp_sweep_3, mean_sweep_3,  
        locktrig4, stop_sweep_4, start_sweep_4, 
        locktrig5, amp_sweep_5, mean_sweep_5, mean1083_361sh, // static shift of sweep mean
        locktrig6, stop_sweep_6, start_sweep_6, 
        locktrig7, stop_sweep_7, start_sweep_7, 
        locktrig8, stop_sweep_8, start_sweep_8, 
    // Sweep rates
    input wire [31:0] 
        sweep_rate_0, sweep_rate_1, sweep_rate_2, sweep_rate_3, sweep_rate_4, sweep_rate_5, sweep_rate_6, sweep_rate_7, sweep_rate_8,
    // static error signal offset
    input wire signed [N_B-1:0] 
        offset0s, offset1s, offset2s, offset3s, offset4s, offset5s, offset6s, offset7s, offset8s,
    input wire [N_B-1:0] 
        // Right bit shift of dither signal
        mod0scaling, mod1scaling, mod2scaling, mod3scaling, mod4scaling, mod5scaling, mod6scaling, mod7scaling, mod8scaling,
        // Clock divisors for dither frequencies f_clk/(60*divFast*divSlow).     
        divFast0, divSlow0, divFast1, divSlow1, divFast2, divSlow2, divFast3, divSlow3, divFast4, divSlow4, divFast5, divSlow5, 
        divFast6, divSlow6, divFast7, divSlow7, divFast8, divSlow8,
        // Dither inhibit mode. Sets the phase of the inhtrig output from DitherLock 
        input wire [3:0] inhmode0, inhmode1, inhmode2, inhmode3, inhmode4, inhmode5, inhmode6, inhmode7, inhmode8,
        input wire 
        // currently used to set filter sign.
        demod_bit0, demod_bit1, demod_bit2, demod_bit3, demod_bit4, demod_bit5, demod_bit6, demod_bit7, demod_bit8,
        // Sets demodulation quadrature: 0 is cos, 1 is sin 
        mod_sel0, mod_sel1, mod_sel2, mod_sel3, mod_sel4, mod_sel5, mod_sel6, mod_sel7, mod_sel8,
    // Dither lock integrator gains.
    input wire signed [9:0] bitshift0, bitshift1, bitshift2, bitshift3, bitshift4, bitshift5, bitshift6, bitshift7, bitshift8,
    // Inputs to filters.
    input wire signed [N_B-1:0] 
        e0_in, e1_in, e2_in, e3_in, e4_in, e6_in, e7_in, e8_in,
        trans0_in, trans1_in, trans2_in, ref2_in, trans3_in, trans4_in, sfg5_in, trans6_in, trans7_in, trans8_in,                                    
    output wire PID0_on, PID1_on, PID2_on, PID3_on, PID4_on, PID5_on, PID6_on, PID7_on, PID8_on,
    input  wire is_neg0, is_neg1, is_neg2, is_neg3, is_neg4, is_neg5, is_neg6, is_neg7, is_neg8,
    // PID gain and frequency bitshifts.
    input wire signed [9:0]
        NFI0, NI0, NFP0, NP0, ND0, NFD0, NGD0,
        NFI1, NI1, NFP1, NP1, ND1, NFD1, NGD1,
        NFI2, NI2, NFP2, NP2, ND2, NFD2, NGD2,
        NFI3, NI3, NFP3, NP3, ND3, NFD3, NGD3,
        NFI4, NI4, NFP4, NP4, ND4, NFD4, NGD4,
        NFI5, NI5, NFP5, NP5, ND5, NFD5, NGD5,
        NFI6, NI6, NFP6, NP6, ND6, NFD6, NGD6,
        NFI7, NI7, NFP7, NP7, ND7, NFD7, NGD7,
        NFI8, NI8, NFP8, NP8, ND8, NFD8, NGD8,
    // Feed-forward inputs
    input wire signed [N_B-1:0] 
        LBOff_in, BBO542ff_in, BBO820ff_in, offset820_in,
    // PID outputs.
    output wire signed [N_B-1:0] 
        servo0out, servo1out, servo2out, servo3out, servo4out, servo5out, servo6out, servo7out, servo8out,
    // Debug outputs
    // Dither, scaled dither, cos demodulation, sin demodulation, dither lock integrator input, and dither lock integrator output
    output wire signed [N_B-1:0]
        // Debug signals for LBO
        mod0_dg, mod0sc_dg, demod0_dg, demod0Q_dg, demod_in_sel0_dg, offset0_dg,
        // Debug signals for 326-542
        mod1_dg, mod1sc_dg, demod1_dg, demod1Q_dg, demod_in_sel1_dg, offset1_dg,
        // Debug signals for 820
        mod2_dg, mod2sc_dg, demod2_dg, demod2Q_dg, demod_in_sel2_dg, offset2_dg,
        // Debug signals for 1083 ref
        mod3_dg, mod3sc_dg, demod3_dg, demod3Q_dg, demod_in_sel3_dg, offset3_dg,
        // Debug signals for 361-542
        mod4_dg, mod4sc_dg, demod4_dg, demod4Q_dg, demod_in_sel4_dg, offset4_dg,
        // Debug signals for 361-1083
        mod5_dg, mod5sc_dg, demod5_dg, demod5Q_dg, demod_in_sel5_dg, offset5_dg,
        // Debug signals for 332
        mod6_dg, mod6sc_dg, demod6_dg, demod6Q_dg, demod_in_sel6_dg, offset6_dg,
        // Debug signals for cavity servo 7
        mod7_dg, mod7sc_dg, demod7_dg, demod7Q_dg, demod_in_sel7_dg, offset7_dg,
        // Debug signals for cavity servo 8
        mod8_dg, mod8sc_dg, demod8_dg, demod8Q_dg, demod_in_sel8_dg, offset8_dg
);

// Filter limits
localparam signed [SIGNAL_SIZE-1:0] 
    LL0 = 25'h1000000, UL0 = 25'h0FFFFFF,
    LL1 = 25'h1000000, UL1 = 25'h0FFFFFF,
    LL2 = 25'h1000000, UL2 = 25'h0FFFFFF,
    LL3 = 25'h1000000, UL3 = 25'h0FFFFFF,
    LL4 = 25'h1000000, UL4 = 25'h0FFFFFF,
    LL5 = 25'h1000000, UL5 = 25'h0FFFFFF,
    LL6 = 25'h1000000, UL6 = 25'h0FFFFFF,
    LL7 = 25'h1000000, UL7 = 25'h0FFFFFF,
    LL8 = 25'h1000000, UL8 = 25'h0FFFFFF;
// Internal fractional bits for I, P, D.
localparam [31:0] 
    CS0_ISCALING = 32, CS0_PSCALING = 32, CS0_DSCALING = 16,
    CS1_ISCALING = 32, CS1_PSCALING = 32, CS1_DSCALING = 16,
    CS2_ISCALING = 32, CS2_PSCALING = 32, CS2_DSCALING = 16,
    CS3_ISCALING = 32, CS3_PSCALING = 32, CS3_DSCALING = 16,
    CS4_ISCALING = 37, CS4_PSCALING = 32, CS4_DSCALING = 16, // 5 extra bits for I internal bits to reach lower I gains.
    CS5_ISCALING = 32, CS5_PSCALING = 32, CS5_DSCALING = 16,
    CS6_ISCALING = 32, CS6_PSCALING = 32, CS6_DSCALING = 16,
    CS7_ISCALING = 32, CS7_PSCALING = 32, CS7_DSCALING = 16,
    CS8_ISCALING = 32, CS8_PSCALING = 32, CS8_DSCALING = 16;

// Delay error signals by 1 clk100 cycle; it may not be necessary, but likely increases timing margin.
wire signed [SIGNAL_SIZE-1:0] err0, err1, err2, err3, err4, err5, err6, err7, err8;
reg  signed [SIGNAL_SIZE-1:0] err0_1, err1_1, err2_1, err3_1, err4_1, err5_1, err6_1, err7_1, err8_1;
always @(posedge clk100) begin
   // Register filter inputs
   err0_1 <= err0;
   err1_1 <= err1;
   err2_1 <= err2;
   err3_1 <= err3;
   err4_1 <= err4;
   err5_1 <= err5;
   err6_1 <= err6;
   err7_1 <= err7;
   err8_1 <= err8;
end

// Function to assign new output, if out of range, assign upper/lower limit.
function  signed [N_B-1:0] newOut;
    input signed [N_B+N_P+1:0] in0;
    input signed [N_B+N_P-1:0] upperLimit, lowerLimit;
    reg   signed [N_B+N_P+1:0] UL1, LL1;
    begin
        UL1 = upperLimit;
        LL1 = lowerLimit;
        if      (in0 >= UL1) newOut = UL1[N_B+N_P-1:N_P];
        else if (in0 <= LL1) newOut = LL1[N_B+N_P-1:N_P]; 
        else                 newOut = in0[N_B+N_P-1:N_P];
    end
endfunction

//**** LBO ****\\
/* SIGNAL DECLARATIONS */
/// Dither lock dither and offset and composite error signals
wire signed [N_B-1:0] mod0, mod0_in, mod0_on; // Dither outputs
wire signed [SIGNAL_SIZE-1:0] mod0scaled_out; // Scaled and shifted dither
wire DITHon0; // Dither on signal
localparam NIhld0 = 2; // Number of cycles to wait before enabling the dither lock integrator after the dither is enabled.
wire signed [SIGNAL_SIZE-1:0] offset0; // Composite error signal and offset from dither lock.
wire inhtrig0, inthld0; // Trigger to indicate position in dither cycle
/// PZT servo
wire signed [15:0] relock0_out;
wire STOPservoLBO, relock0_on, relock_state0;
// PID output and integrator output (for slow integrator when using low range DAC output for PID output).
wire signed [SIGNAL_SIZE-1:0] e0_out, e0_out_I;
reg  signed [N_B+N_P+1:0] servo0out0, servo0out1, servo0out2; // Pipelined output for adding the relock and feed-forward to the PID output.
wire signed [SIGNAL_SIZE-1:0] LBOff_lp; // Slow feed forward input, after low-pass filter.
reg signed [SIGNAL_SIZE-1:0] LBOff; // Scaled slow feed forward input.
/// Dither lock
// Delay turn on of integrator by 10 ms
localparam [19:0] N_dithDly_0 = 20'd1_000_000;
// Demodulated outputs
wire signed [N_B-1:0] demod_out0, demodQ_out0, demod2f_out0, demod2fQ_out0, demod3f_out0, demod3fQ_out0;
wire signed [SIGNAL_SIZE-1:0] demod_in0;
// Selectable demodulated output, not used currently, clearer to assign in top.sv.
wire signed [N_B-1:0] demod0;
wire updown0;
reg signed [SIGNAL_SIZE-1:0] demod_in_sel0; // Demodulated input to integrator.
/* SIGNAL ASSIGNMENTS*/
assign STOPservoLBO = (STOPservos || stopLBO);
// Delay relock by 1 cycle to likely increase timing margin.
always @(posedge clk100) begin
    servo0out0 <= relock0_out <<< N_P; 
    servo0out1 <= servo0out0 - LBOff_lp;
    servo0out2 <= servo0out1 + e0_out;
end
// Limit output.
assign servo0out = newOut(servo0out2, UL0, LL0);
/// FEED-FORWARD
// Scale slow input for feed-forward
always @(posedge clk100) begin
    LBOff <= (LBOff_in <<< N_P);
end
/// DITHER LOCK
// Select cos or sin demodulation.
always @(posedge clk100) begin
    if (mod_sel0) demod_in_sel0 <= (demodQ_out0 <<< N_P);
    else          demod_in_sel0 <= (demod_out0 <<< N_P);
end
// Assign dither lock integrator sign.
assign updown0 = demod_bit0;
/* MODULE DECLARATIONS */
// AUTOLOCK
AutoLock #(.reftrans("trans"), .mode("minmax"), .offmode("zero"), .sweepresetmode("zero")) 
AutoLock0(
    clk100, 0, STOPservoLBO, 0, 1, scanLBO,
    // Relock trigger level, and input signal
    locktrig0, trans0_in,
    // Sweep parameters and output
    start_sweep_0, stop_sweep_0, sweep_rate_0, relock0_out, relock_state0,
    // Hold and on output signals for PID module
    relock0_on, PID0_on
);
// Scaling and offset of error signal
ErrorScaleShift#(N_B, N_P, N_P, SIGNAL_SIZE)
ErrorScaleShift0(clk100, e0_in, offset0s, mod0_in, mod0scaling, offset0, DITHon0, mod0scaled_out, err0);
// Disable dither during MOT integration.
ditherInhibit#(N_B, NIhld0)dithInhibit0(clk100, dithEN, inhtrig0, mod0, inthld0, mod0_in);
// LBO PZT servo
CavPID#(SIGNAL_SIZE, CS0_ISCALING, CS0_PSCALING, CS0_DSCALING)
CavPID0_LBO(clk100, PID0_on, 1'b0, is_neg0, NFI0, NI0, NFP0, NP0, ND0, NFD0, NGD0, LL0, UL0, err0_1, e0_out, e0_out_I);
// Low-pass filter with 1.5 kHz cutoff for feed forward.
P1BS#(SIGNAL_SIZE, CS0_PSCALING, 1)
P1BS_LBOFF(clk100, 1'b1, 1'b0, 1'b0, -10'd54, 10'd70, LL0, UL0, LBOff, LBOff_lp);
// Dither lock
DitherLock#(N_dithDly_0, N_B, N_P, SIGNAL_SIZE)
DitherLock0(clk100, trans0_in, divFast0, divSlow0, inhmode0, demod_bit0, PID0_on, DITHon0,
mod0, demod0, demod_out0, demodQ_out0, demod2f_out0, demod2fQ_out0, demod3f_out0, demod3fQ_out0, demod_in0, inhtrig0); 
// Dither lock integrator
I1BS#(SIGNAL_SIZE, 29, 1)DLINT0(clk100, PID0_on, inthld0, updown0, -10'd244, bitshift0, LL0, UL0, 0, demod_in_sel0, offset0);

//**** BBO326_542 ****\\
/* SIGNAL DECLARATIONS */
/// Dither lock dither and offset and composite error signals
wire signed [N_B-1:0] mod1, mod1_in, mod1_on; // Dither outputs
wire signed [SIGNAL_SIZE-1:0] mod1scaled_out; // Scaled and shifted dither
wire DITHon1; // Dither on signal
localparam NIhld1 = 2; // Number of cycles to wait before un-holding the dither lock integrator after the dither is enabled.
wire signed [SIGNAL_SIZE-1:0] offset1; // Composite error signal and offset from dither lock.
wire inhtrig1, inthld1; // Trigger to indicate position in dither cycle
// Monitor output for slow DAC
wire signed [N_B - 1:0] offset1_out;
/// PZT servo
wire signed [15:0] relock1_out;
wire STOPservo542_326, relock1_on, relock_state1;
// PID output and integrator output (for slow integrator when using low range DAC output for PID output).
wire signed [SIGNAL_SIZE-1:0] e1_out, e1_out_I;
reg  signed [N_B+N_P+1:0] servo1out0, servo1out1, servo1out2; // Pipelined output for adding the relock and feed-forward to the PID output.
wire signed [SIGNAL_SIZE-1:0] BBO542ff_lp; // Slow feed forward input, after low-pass filter.
reg signed [SIGNAL_SIZE-1:0] BBO542ff, BBO542ff0, BBO542ff1; // Scaled slow feed forward input.
/// Dither lock
// Delay turn on of integrator by 10 ms
localparam [19:0] N_dithDly_1 = 20'd1_000_000;
// Demodulated outputs
wire signed [N_B-1:0] demod_out1, demodQ_out1, demod2f_out1, demod2fQ_out1, demod3f_out1, demod3fQ_out1; 
wire signed [SIGNAL_SIZE-1:0] demod_in1;  
// Selectable demodulated output, not used currently, clearer to assign in top.sv.
wire signed [N_B-1:0] demod1;
wire updown1;
reg  signed [SIGNAL_SIZE-1:0] demod_in_sel1; // Demodulated input to integrator.

/* SIGNAL ASSIGNMENTS */
assign STOPservo542_326 = (STOPservos || stop542_326);
// Delay relock by 1 cycle to help meet timing.
always @(posedge clk100) begin
    servo1out0 <= relock1_out <<< N_P; 
    servo1out1 <= servo1out0 - BBO542ff_lp;
    servo1out2 <= servo1out1 + e1_out;
end
// Limit output.
assign servo1out = newOut(servo1out2, UL1, LL1);
/// FEED-FORWARD
// Scale slow input for feed-forward
always @(posedge clk100) begin
    BBO542ff0 <= (BBO542ff_in <<< N_P);
    BBO542ff1 <= (BBO542ff0) + (BBO542ff0 >>> 1);
    BBO542ff  <= BBO542ff1 + (BBO542ff0 >>> 3); //1.68
end
/// DITHER LOCK
// Select cos or sin demodulation.
always @(posedge clk100) begin
    if (mod_sel1) demod_in_sel1 <= (demodQ_out1 <<< N_P);
    else          demod_in_sel1 <= (demod_out1 <<< N_P);
end
// Assign dither lock integrator sign.
assign updown1 = demod_bit1;

/* MODULE DECLARATIONS */
// AUTOLOCK
AutoLock #(.reftrans("trans"), .mode("minmax"), .offmode("zero"), .sweepresetmode("zero")) 
AutoLock1(
    // Clock
    clk100, 0, STOPservo542_326, 0, 1, scan542_326,
    // Relock trigger level, and input signal
    locktrig1, trans1_in,
    // Sweep parameters and output
    start_sweep_1, stop_sweep_1, sweep_rate_1, relock1_out, relock_state1,
    // Hold and on output signals for PID module
    relock1_on, PID1_on
);
// Scaling and offset of error signal
ErrorScaleShift#(N_B, N_P, N_P, SIGNAL_SIZE)
ErrorScaleShift1(clk100, e1_in, offset1s, mod1_in, mod1scaling, offset1, DITHon1, mod1scaled_out, err1);
// Disable dither during MOT integration.
ditherInhibit#(N_B, NIhld1)dithInhibit1(clk100, dithEN, inhtrig1, mod1, inthld1, mod1_in);
// BBO542_326 PZT servo
CavPID#(SIGNAL_SIZE, CS1_ISCALING, CS1_PSCALING, CS1_DSCALING)
CavPID1_BBO326542(clk100, PID1_on, 1'b0, is_neg1, NFI1, NI1, NFP1, NP1, ND1, NFD1, NGD1, LL1, UL1, err1_1, e1_out, e1_out_I);
// Low-pass filter with 1.5 kHz cutoff for feed forward.
P1BS#(SIGNAL_SIZE, CS1_PSCALING, 1)
P1BS_BBO542FF(clk100, 1'b1, 1'b0, 1'b0, -10'd54, 10'd70, LL1, UL1, BBO542ff, BBO542ff_lp);
// Dither lock
DitherLock#(N_dithDly_1, N_B, N_P, SIGNAL_SIZE)
DitherLock1(clk100, trans1_in, divFast1, divSlow1, inhmode1, 1'b0, PID1_on, DITHon1,
mod1, demod1, demod_out1, demodQ_out1, demod2f_out1, demod2fQ_out1, demod3f_out1, demod3fQ_out1, demod_in1, inhtrig1);
// Dither lock integrator
I1BS#(SIGNAL_SIZE, 29, 1)DLINT1(clk100, PID1_on, inthld1, updown1, -10'd244, bitshift1, LL1, UL1, 0, demod_in_sel1, offset1);

//**** BBO820 ****\\
/* SIGNAL DECLARATIONS */
// Relock parameters
// amplitude for autolock sweep
reg signed [15:0] amp_sweep_2_in;
// Unused mean of 0 going to AutoLock module - actual mean, feedforward and offset are added in this module.
localparam signed [15:0] mean_sweep_2_dum = 16'd0; // Generated sweep has 0 mean; mean_sweep_2 is added to the sweep below
/// Dither lock dither and offset and composite error signals
wire signed [N_B-1:0] mod2, mod2_in; // Dither outputs
wire signed [SIGNAL_SIZE-1:0] mod2scaled_out; // Scaled and shifted dither
wire DITHon2; // Dither on signal
localparam NIhld2 = 2; // Number of cycles to wait before un-holding the dither lock integrator after the dither is enabled.
wire signed [SIGNAL_SIZE-1:0] offset2; // Composite error signal and offset from dither lock.
wire inhtrig2, inthld2; // Trigger to indicate position in dither cycle
reg signed [N_B-1:0] relock2_out_1; // pipelined auto-lock signal to add mean to likely increase timing margin
// Monitor output for slow DAC
wire signed [N_B - 1:0] offset2_out, mod2_out;
/// PZT servo
wire signed [15:0] relock2_out;
wire STOPservo820, relock2_on, relock_state2;
// PID output and integrator output (for slow integrator when using low range DAC output for PID output).
wire signed [SIGNAL_SIZE-1:0] e2_out, e2_out_I;
reg  signed [N_B+N_P+1:0] servo2out0, servo2out1, servo2out2; // Pipelined output for adding the relock, feed-forward and low-passed offset from a slow input, to the PID output.
wire signed [SIGNAL_SIZE-1:0] BBO820ff_lp; // Slow feed forward input.
reg signed [SIGNAL_SIZE-1:0] BBO820ff, BBO820ff0, BBO820ff1; // Scaled slow feed forward input.
// Low-pass filtered input for 820 tuning offset, 3.8 Hz cutoff frequency.
wire signed [SIGNAL_SIZE-1:0] offset820_LP_in, offset820_LP;
/// Dither lock
// Delay turn on of integrator by 10 ms
localparam [19:0] N_dithDly_2 = 20'd1_000_000;
// Demodulated outputs
wire signed [N_B-1:0] demod_out2, demodQ_out2, demod2f_out2, demod2fQ_out2, demod3f_out2, demod3fQ_out2; 
wire signed [SIGNAL_SIZE-1:0] demod_in2; 
reg signed [SIGNAL_SIZE-1:0] demod_in_sel2;
// Selectable demodulated output, not used currently, clearer to assign in top.sv.
wire signed [N_B-1:0] demod2;
wire updown2;
reg signed [15:0] demod_out_820; // Demodulated output to slow DAC for monitoring lock.
reg [1:0] demod_out_820_sel = 2'd3; // Select signal to choose which demodulation to send out.

/* SIGNAL ASSIGNMENTS */
assign STOPservo820 = (STOPservos || stop820);
// Mean and amplitude adjustment for autolock sweep
always @(posedge clk100) amp_sweep_2_in  <= amp_sweep_2; 

// Delay relock by 2 cycles and slow feed-forward by 1 cycle to help meet timing.
always @(posedge clk100) begin
    servo2out0 <= (relock2_out_1 <<< N_P) + offset820_LP; 
    servo2out1 <= servo2out0 - (BBO820ff_lp <<< 1); 
    servo2out2 <= servo2out1 + e2_out;
end
// Limit output.
assign servo2out = newOut(servo2out2, UL2, LL2);

// FEED-FORWARD
// Scale slow input for feed-forward
always @(posedge clk100) begin
    BBO820ff0 <= (BBO820ff_in <<< N_P);
    BBO820ff1 <= (BBO820ff0 >>> 2) + (BBO820ff0 >>> 3);
    BBO820ff  <= BBO820ff1 + (BBO820ff0 >>> 6); //0.390625
end
// Add mean and filtered input to 820 output.
always @(posedge clk100) begin
    relock2_out_1 <= mean_sweep_2 + relock2_out; // Add sweep mean to sweep (with 0 mean)
end
assign offset820_LP_in = offset820_in <<< N_P;
/// DITHER LOCK
// Select cos or sin demodulation.
always @(posedge clk100) begin
    if (mod_sel2) demod_in_sel2 <= (demodQ_out2 <<< N_P);
    else          demod_in_sel2 <= (demod_out2 <<< N_P);
end
// Selectable output for monitoring dither lock for the 820 servo.
always @(posedge clk100) begin
    if      (demod_out_820_sel==0) demod_out_820 <= demod_out2;
    else if (demod_out_820_sel==1) demod_out_820 <= demodQ_out2;
    else if (demod_out_820_sel==2) demod_out_820 <= demod2f_out2;
    else                           demod_out_820 <= demod2fQ_out2;
end
// Assign dither lock integrator sign.
assign updown2 = demod_bit2;

/* MODULE DECLARATIONS */
// AUTOLOCK
AutoLock #(.reftrans("trans"), .mode("meanamp"), .offmode("zero"), .sweepresetmode("zero")) 
AutoLock2(
    // Clock
    clk100, 0, STOPservo820, 0, 1, scan820,
    // Relock trigger level, and input signal
    locktrig2, trans2_in,
    // Sweep parameters and output
    mean_sweep_2_dum, amp_sweep_2_in, sweep_rate_2, relock2_out, relock_state2,
    // Hold and on output signals for PID module
    relock2_on, PID2_on
);
// Scaling and offset of error signal
ErrorScaleShift#(N_B, N_P, N_P, SIGNAL_SIZE)
ErrorScaleShift2(clk100, e2_in, offset2s, mod2_in, mod2scaling, offset2, DITHon2, mod2scaled_out, err2);
// Disable dither during MOT integration.
ditherInhibit#(N_B, NIhld2)dithInhibit2(clk100, dithEN, inhtrig2, mod2, inthld2, mod2_in);
// 820 BBO PZT servo
CavPID#(SIGNAL_SIZE, CS2_ISCALING, CS2_PSCALING, CS2_DSCALING)
CavPID2_BBO820_0(clk100, PID2_on, 1'b0, is_neg2, NFI2, NI2, NFP2, NP2, ND2, NFD2, NGD2, LL2, UL2, err2_1, e2_out, e2_out_I);
// Low-pass filter with 1.5 kHz cutoff for feed forward.
P1BS#(SIGNAL_SIZE, CS2_PSCALING, 1)
P1BS_BBO820FF(clk100, 1'b1, 1'b0, 1'b0, -10'd54, 10'd70, LL2, UL2, BBO820ff, BBO820ff_lp);
// Dither lock
// Use reflection for demod
DitherLock#(N_dithDly_2, N_B, N_P, SIGNAL_SIZE)
DitherLock2(clk100, ref2_in, divFast2, divSlow2, inhmode2, demod_bit2, PID2_on, DITHon2,
mod2, demod2, demod_out2, demodQ_out2, demod2f_out2, demod2fQ_out2, demod3f_out2, demod3fQ_out2, demod_in2, inhtrig2);
// Dither lock integrator
I1BS#(SIGNAL_SIZE, 29, 1)DLINT2(clk100, PID2_on, inthld2, updown2, -10'd244, bitshift2, LL2, UL2, 0, demod_in_sel2, offset2);
// Low-pass filter for 820 offset input, 4.8 Hz cutoff frequency.
P1BS#(SIGNAL_SIZE, CS2_PSCALING, 1)
P1BS_BBO820offset(clk125kHz, 1'b1, 1'b0, 1'b0, -10'd48, 10'd76, LL2, UL2, offset820_LP_in, offset820_LP);

//**** 1083REF ****\\
/* SIGNAL DELCARATIONS */
// Unused mean of 0 going to AutoLock module - actual mean and feedforward are added in top.sv.
localparam signed [15:0] mean_sweep_3_dum = 16'd0;
/// Dither lock dither and offset and composite error signals
wire signed [N_B-1:0] mod3, mod3_in; // Dither outputs
wire signed [SIGNAL_SIZE-1:0] mod3scaled_out; // Scaled and shifted dither
wire DITHon3; // Dither on signal
localparam NIhld3 = 2; // Number of cycles to wait before un-holding the dither lock integrator after the dither is enabled.
wire signed [SIGNAL_SIZE-1:0] offset3; // Composite error signal and offset from dither lock.
wire inhtrig3, inthld3; // Trigger to indicate position in dither cycle
reg signed [N_B-1:0] relock3_out_1; // pipelined auto-lock signal to add mean without risking timing issues
/// PZT servo
wire signed [15:0] relock3_out;
wire STOPservo1083, relock3_on, relock_state3;
// PID output and integrator output (for slow integrator when using low range DAC output for PID output).
wire signed [SIGNAL_SIZE-1:0] e3_out, e3_out_I;
reg  signed [N_B+N_P+1:0] servo3out0, servo3out1; // Pipelined output for adding the relock to the PID output.
/// Dither lock
// Delay turn on of integrator by 10 ms
localparam [19:0] N_dithDly_3 = 20'd1_000_000;
// Demodulated outputs
wire signed [N_B-1:0] demod_out3, demodQ_out3, demod2f_out3, demod2fQ_out3, demod3f_out3, demod3fQ_out3; 
wire signed [SIGNAL_SIZE-1:0] demod_in3; 
reg signed [SIGNAL_SIZE-1:0] demod_in_sel3;
// Selectable demodulated output, not used currently, clearer to assign in top.sv.
wire signed [N_B-1:0] demod3;
wire updown3;

/* SIGNAL ASSIGNMENTS */
assign STOPservo1083 = stop1083;  
// Delay relock by 1 cycle to help meet timing.
always @(posedge clk100) begin
    servo3out0 <= relock3_out_1 <<< N_P; 
    servo3out1 <= servo3out0 + e3_out;
end
// Limit output.
assign servo3out = newOut(servo3out1, UL3, LL3);
/// DITHER LOCK
// Select cos or sin demodulation.
always @(posedge clk100) begin
    if (mod_sel3) demod_in_sel3 <= (demodQ_out3 <<< N_P);
    else          demod_in_sel3 <= (demod_out3 <<< N_P);
end
// Assign dither lock integrator sign.
assign updown3 = demod_bit3;
// Monitor output to slow DAC
assign mod3_out = 0;
// Add mean to relock signal
always @(posedge clk100) begin
    relock3_out_1 <= mean_sweep_3 + relock3_out;
end

/* MODULE DECLARATIONS */
// AUTOLOCK
AutoLock #(.reftrans("trans"), .mode("meanamp"), .offmode("zero"), .sweepresetmode("zero")) 
AutoLock3(
    // Clock
    clk100, 0, STOPservo1083, 0, 1, scan1083,
    // Relock trigger level, and input signal
    locktrig3, trans3_in,
    // Sweep parameters and output
    mean_sweep_3_dum, amp_sweep_3, sweep_rate_3, relock3_out, relock_state3,
    // Hold and on output signals for PID module
    relock3_on, PID3_on
);
// Scaling and offset of error signal
ErrorScaleShift#(N_B, N_P, N_P, SIGNAL_SIZE)
ErrorScaleShift3(clk100, e3_in, offset3s, mod3_in, mod3scaling, offset3, DITHon3, mod3scaled_out, err3);
// Disable dither during MOT integration.
ditherInhibit#(N_B, NIhld3)dithInhibit3(clk100, dithEN, inhtrig3, mod3, inthld3, mod3_in);
// 1083 REF PZT servo
CavPID#(SIGNAL_SIZE, CS3_ISCALING, CS3_PSCALING, CS3_DSCALING)
CavPID3_1083REF(clk100, PID3_on, 1'b0, is_neg3, NFI3, NI3, NFP3, NP3, ND3, NFD3, NGD3, LL3, UL3, err3_1, e3_out, e3_out_I);
// Dither lock
DitherLock#(N_dithDly_3, N_B, N_P, SIGNAL_SIZE)
DitherLock3(clk100, trans3_in, divFast3, divSlow3, inhmode3, demod_bit3, PID3_on, DITHon3,
mod3, demod3, demod_out3, demodQ_out3, demod2f_out3, demod2fQ_out3, demod3f_out3, demod3fQ_out3, demod_in3, inhtrig3);
// Dither lock integrator
I1BS#(SIGNAL_SIZE, 29, 1)DLINT3(clk100, PID3_on, inthld3, updown3, -10'd244, bitshift3, LL3, UL3, 0, demod_in_sel3, offset3);

//**** BBO361_542 ****\\
/* SIGNAL DECLARATIONS */
/// Dither lock dither and offset and composite error signals
// Logic for alternating dither on 361 lasers
wire dithEN4, dithEN5;
localparam [31:0] dithcnt4_MAX = 32'd10, dithcnt5_MAX = 32'd68;
wire inhtrig4, inhtrig5, inthld4, inthld5;
wire signed [N_B-1:0] mod4, mod4_in; // Dither outputs
wire signed [SIGNAL_SIZE-1:0] mod4scaled_out; // Scaled and shifted dither
wire DITHon4; // Dither on signal
localparam NIhld4 = 2; // Number of cycles to wait before un-holding the dither lock integrator after the dither is enabled.
wire signed [SIGNAL_SIZE-1:0] offset4; // Composite error signal and offset from dither lock.
/// PZT servo
wire signed [15:0] relock4_out;
wire STOPservo542_361, relock4_on, relock_state4;
// PID output and integrator output (for slow integrator when using low range DAC output for PID output).
wire signed [SIGNAL_SIZE-1:0] e4_out, e4_out_I;
reg signed [N_B+N_P+1:0] servo4out0, servo4out1; // Pipelined output for adding the relock to the PID output.
/// Dither lock
// Delay turn on of integrator by 10 ms
localparam [19:0] N_dithDly_4 = 20'd1_000_000;
// Demodulated outputs
wire signed [N_B-1:0] demod_out4, demodQ_out4, demod2f_out4, demod2fQ_out4, demod3f_out4, demod3fQ_out4; 
wire signed [SIGNAL_SIZE-1:0] demod_in4;  
// Selectable demodulated output, not used currently, clearer to assign in this module.
wire signed [N_B-1:0] demod4;
wire updown4;
reg  signed [SIGNAL_SIZE-1:0] demod_in_sel4; // Demodulated input to integrator.

/* SIGNAL ASSIGNMENTS */
assign STOPservo542_361 = (STOPservos || stop542_361);
// Delay relock by 1 cycle to help meet timing.
always @(posedge clk100) begin
    servo4out0 <= relock4_out <<< N_P; 
    servo4out1 <= servo4out0 + e4_out;
end
// Limit output.
assign servo4out = newOut(servo4out1, UL4, LL4);

/// DITHER LOCK
// Select cos or sin demodulation.
always @(posedge clk100) begin
    if (mod_sel4) demod_in_sel4 <= (demodQ_out4 <<< N_P);
    else          demod_in_sel4 <= (demod_out4 <<< N_P);
end
// Assign dither lock integrator sign.
assign updown4 = demod_bit4;

/* MODULE DECLARATIONS */
// AUTOLOCK
AutoLock #(.reftrans("trans"), .mode("minmax"), .offmode("zero"), .sweepresetmode("zero")) 
AutoLock4(
    // Clock
    clk100, 0, STOPservo542_361, 0, 1, scan542_361,
    // Relock trigger level, and input signal
    locktrig4, trans4_in,
    // Sweep parameters and output
    start_sweep_4, stop_sweep_4, sweep_rate_4, relock4_out, relock_state4,
    // Hold and on output signals for PID module
    relock4_on, PID4_on
);
// Logic for alternating dither on 361 lasers
dithSwitch dithSwitch_361(clk100, dithEN, inhtrig4, inhtrig5, dithcnt4_MAX, dithcnt5_MAX, dithEN4, dithEN5);
// Scaling and offset of error signal
ErrorScaleShift#(N_B, N_P, N_P, SIGNAL_SIZE)
ErrorScaleShift4(clk100, e4_in, offset4s, mod4_in, mod4scaling, offset4, DITHon4, mod4scaled_out, err4);
// Disable dither during MOT integration.
ditherInhibit#(N_B, NIhld4)dithInhibit4(clk100, dithEN4, inhtrig4, mod4, inthld4, mod4_in);
//**** BBO542_361 PZT servo ****\\
CavPID#(SIGNAL_SIZE, CS4_ISCALING, CS4_PSCALING, CS4_DSCALING)
CavPID4_BBO361542(clk100, PID4_on, 1'b0, is_neg4, NFI4, NI4, NFP4, NP4, ND4, NFD4, NGD4, LL4, UL4, err4_1, e4_out, e4_out_I);
// Dither lock
DitherLock#(N_dithDly_4, N_B, N_P, SIGNAL_SIZE)
DitherLock4(clk100, trans4_in, divFast4, divSlow4, inhmode4, 1'b0, PID4_on, DITHon4,
mod4, demod4, demod_out4, demodQ_out4, demod2f_out4, demod2fQ_out4, demod3f_out4, demod3fQ_out4, demod_in4, inhtrig4);
// Dither lock integrator
I1BS#(SIGNAL_SIZE, 29, 1)DLINT4(clk100, PID4_on, inthld4, updown4, -10'd244, bitshift4, LL4, UL4, 0, demod_in_sel4, offset4);

//**** BBO361_1083 ****\\
/* SIGNAL DECLARATIONS */
// Mean and amplitude adjustment for autolock sweep
reg signed [15:0] mean_sweep_5_in, amp_sweep_5_in;
// Disable signal for this auto-lock. To start this lock at an extreme of the ramp instead of the mean, to avoid cavity thermal instability for lock acquire of 542nm light.
wire relock5_dis;
/// Dither lock dither and offset and composite error signals
wire signed [N_B-1:0] mod5, mod5_in; // Dither outputs
wire signed [SIGNAL_SIZE-1:0] mod5scaled_out; // Scaled and shifted dither
wire DITHon5; // Dither on signal
localparam NIhld5 = 2; // Number of cycles to wait before un-holding the dither lock integrator after the dither is enabled.
wire signed [SIGNAL_SIZE-1:0] offset5; // Composite error signal and offset from dither lock.
/// PZT servo
wire signed [15:0] relock5_out;
wire STOPservo1083_361, relock5_on, relock_state5;
// PID output and integrator output (for slow integrator when using low range DAC output for PID output).
wire signed [SIGNAL_SIZE-1:0] e5_out, e5_out_I;
reg signed [N_B+N_P+1:0] servo5out0, servo5out1, servo5out2; // Pipelined output for adding the relock and dither to the PID output.
/// Dither lock
// Delay turn on of integrator by 10 ms
localparam [19:0] N_dithDly_5 = 20'd1_000_000;
// Demodulated outputs
wire signed [N_B-1:0] demod_out5, demodQ_out5, demod2f_out5, demod2fQ_out5, demod3f_out5, demod3fQ_out5; 
wire signed [SIGNAL_SIZE-1:0] demod_in5; // Unused.  
// Selectable demodulated output, not used currently, clearer to assign in top.sv.
wire signed [N_B-1:0] demod5;
reg  signed [SIGNAL_SIZE-1:0] demod_in_sel5, mod5_in_sc, mod5_in_sc0; // Demodulated input to integrator, and scaled dither.

/* SIGNAL ASSIGNMENTS */
assign STOPservo1083_361 = stop1083_361;
// Mean and amplitude adjustment for autolock sweep
always @(posedge clk100) begin
    amp_sweep_5_in  <= amp_sweep_5; 
    mean_sweep_5_in <= mean_sweep_5 + mean1083_361sh;
end
// Add the mean at the end, not here, so mean changes even when locked
assign relock5_dis = (scan542_361 || stop542_361); // Enable if not scanning 542, or if 542 is not stopped
/// DITHER LOCK
// Select cos or sin demodulation.
always @(posedge clk100) begin
    if (mod_sel5) demod_in_sel5 <= (demodQ_out5 <<< N_P);
    else          demod_in_sel5 <= (demod_out5  <<< N_P);
end
// Pipeline sum for this output because most signals are slow. Also scale the dither.
always @(posedge clk100) begin
    servo5out0 <= relock5_out <<< N_P;
    servo5out1 <= servo5out0 + mod5_in_sc;
    servo5out2 <= servo5out1 + e5_out;
    // Scale the dither
    mod5_in_sc0 <= mod5_in <<< N_P;
    if (DITHon5) mod5_in_sc <= (mod5_in_sc0 >>> mod5scaling);
    else         mod5_in_sc <= 0;
end
// Limit output.
assign servo5out = newOut(servo5out2, UL5, LL5);

/* MODULE DECLARATIONS */
// AUTOLOCK
AutoLock #(.reftrans("ref"), .mode("meanamp"), .offmode("mean"), .sweepresetmode("max")) 
AutoLock5(
    // Clock
    clk100, STOPservos, STOPservo1083_361, relock5_dis, PID4_on, scan1083_361,
    // Relock trigger level, and input signal
    locktrig5, sfg5_in,
    // Sweep parameters and output
    mean_sweep_5_in, amp_sweep_5_in, sweep_rate_5, relock5_out, relock_state5,
    // Hold and on output signals for PID module
    relock5_on, PID5_on
);
// Disable dither during MOT integration.
ditherInhibit#(N_B, NIhld5)dithInhibit5(clk100, dithEN5, inhtrig5, mod5, inthld5, mod5_in);
// Dither lock
// Use sfg output for demod
DitherLock#(N_dithDly_5, N_B, N_P, SIGNAL_SIZE) 
DitherLock5(clk100, sfg5_in, divFast5, divSlow5, inhmode5, demod_bit5, PID5_on, DITHon5,
mod5, demod5, demod_out5, demodQ_out5, demod2f_out5, demod2fQ_out5, demod3f_out5, demod3fQ_out5, demod_in5, inhtrig5);
// CavPID module gives a full PID in a compact notation for this dither lock.
CavPID#(SIGNAL_SIZE, CS5_ISCALING, CS5_PSCALING, CS5_DSCALING)
CavPID5_BBO3611083(clk100, PID5_on, inthld5, is_neg5, NFI5, NI5, NFP5, NP5, ND5, NFD5, NGD5, LL5, UL5, demod_in_sel5, e5_out, e5_out_I);

//**** 332 Servo ****\\
/* SIGNAL DECLARATIONS */
/// Dither lock dither and offset and composite error signals
wire signed [N_B-1:0] mod6, mod6_in, mod6_on; // Dither outputs
wire signed [SIGNAL_SIZE-1:0] mod6scaled_out; // Scaled and shifted dither
wire DITHon6; // Dither on signal	
localparam NIhld6 = 2; // Number of cycles to wait before un-holding the dither lock integrator after the dither is enabled.
wire signed [SIGNAL_SIZE-1:0] offset6; // Composite error signal and offset from dither lock.
wire inhtrig6, inthld6; // Trigger to indicate position in dither cycle
/// PZT servo
wire signed [15:0] relock6_out;
wire STOPservo_CS6, relock6_on, relock_state6;
// PID output and integrator output (for slow integrator when using low range DAC output for PID output).
wire signed [SIGNAL_SIZE-1:0] e6_out, e6_out_I;
reg  signed [N_B+N_P+1:0] servo6out0, servo6out1; // Pipelined output for adding the relock to the PID output.
/// Dither lock
// Delay turn on of integrator by 10 ms
localparam [19:0] N_dithDly_6 = 20'd1_000_000;
// Demodulated outputs
wire signed [N_B-1:0] demod_out6, demodQ_out6, demod2f_out6, demod2fQ_out6, demod3f_out6, demod3fQ_out6;
wire signed [SIGNAL_SIZE-1:0] demod_in6;
// Selectable demodulated output, not used currently, clearer to assign in top.sv.
wire signed [N_B-1:0] demod6;
wire updown6;
reg signed [SIGNAL_SIZE-1:0] demod_in_sel6; // Demodulated input to integrator.

/* SIGNAL ASSIGNMENTS */
assign STOPservo_CS6 = (STOPservos || stop_CS6);
// Delay relock by 1 cycle to help meet timing.
always @(posedge clk100) begin
    servo6out0 <= relock6_out <<< N_P; 
    servo6out1 <= servo6out0 + e6_out;
end
// Limit output.
assign servo6out = newOut(servo6out1, UL6, LL6);
/// DITHER LOCK
// Select cos or sin demodulation.
always @(posedge clk100) begin
    if (mod_sel6) demod_in_sel6 <= (demodQ_out6 <<< N_P);
    else          demod_in_sel6 <= (demod_out6 <<< N_P);
end
// Assign dither lock integrator sign.
assign updown6 = demod_bit6;

/* MODULE DECLARATIONS */
AutoLock #(.reftrans("trans"), .mode("minmax"), .offmode("zero"), .sweepresetmode("zero")) 
AutoLock6(
    // Clock
    clk100, 0, STOPservo_CS6, 0, 1, scan_CS6,
    // Relock trigger level, and input signal
    locktrig6, trans6_in,
    // Sweep parameters and output
    start_sweep_6, stop_sweep_6, sweep_rate_6, relock6_out, relock_state6,
    // Hold and on output signals for PID module
    relock6_on, PID6_on
);
// Scaling and offset of error signal
ErrorScaleShift#(N_B, N_P, N_P, SIGNAL_SIZE)
ErrorScaleShift6(clk100, e6_in, offset6s, mod6_in, mod6scaling, offset6, DITHon6, mod6scaled_out, err6);
// Disable dither during MOT integration.
ditherInhibit#(N_B, NIhld6)dithInhibit6(clk100, dithEN, inhtrig6, mod6, inthld6, mod6_in);
// 332 Servo
CavPID#(SIGNAL_SIZE, CS6_ISCALING, CS6_PSCALING, CS6_DSCALING)
CavPID6(clk100, PID6_on, 1'b0, is_neg6, NFI6, NI6, NFP6, NP6, ND6, NFD6, NGD6, LL6, UL6, err6_1, e6_out, e6_out_I);
// Dither lock
DitherLock#(N_dithDly_6, N_B, N_P, SIGNAL_SIZE)
DitherLock6(clk100, trans6_in, divFast6, divSlow6, inhmode6, demod_bit6, PID6_on, DITHon6,
mod6, demod6, demod_out6, demodQ_out6, demod2f_out6, demod2fQ_out6, demod3f_out6, demod3fQ_out6, demod_in6, inhtrig6); 
// Dither lock integrator
I1BS#(SIGNAL_SIZE, 29, 1)DLINT6(clk100, PID6_on, inthld6, updown6, -10'd244, bitshift6, LL6, UL6, 0, demod_in_sel6, offset6);

//**** Cavity Servo 7 ****\\
/* SIGNAL DECLARATIONS */
/// Dither lock dither and offset and composite error signals
wire signed [N_B-1:0] mod7, mod7_in, mod7_on; // Dither outputs
wire signed [SIGNAL_SIZE-1:0] mod7scaled_out; // Scaled and shifted dither
wire DITHon7; // Dither on signal	
localparam NIhld7 = 2; // Number of cycles to wait before un-holding the dither lock integrator after the dither is enabled.
wire signed [SIGNAL_SIZE-1:0] offset7; // Composite error signal and offset from dither lock.
wire inhtrig7, inthld7; // Trigger to indicate position in dither cycle
/// PZT servo
wire signed [15:0] relock7_out;
wire STOPservo_CS7, relock7_on, relock_state7;
// PID output and integrator output (for slow integrator when using low range DAC output for PID output).
wire signed [SIGNAL_SIZE-1:0] e7_out, e7_out_I;
reg  signed [N_B+N_P+1:0] servo7out0, servo7out1; // Pipelined output for adding the relock to the PID output.
/// Dither lock
// Delay turn on of integrator by 10 ms
localparam [19:0] N_dithDly_7 = 20'd1_000_000;
// Demodulated outputs
wire signed [N_B-1:0] demod_out7, demodQ_out7, demod2f_out7, demod2fQ_out7, demod3f_out7, demod3fQ_out7;
wire signed [SIGNAL_SIZE-1:0] demod_in7;
// Selectable demodulated output, not used currently, clearer to assign in top.sv.
wire signed [N_B-1:0] demod7;
wire updown7;
reg signed [SIGNAL_SIZE-1:0] demod_in_sel7; // Demodulated input to integrator.

/* SIGNAL ASSIGNMENTS */
assign STOPservo_CS7 = (STOPservos || stop_CS7);
// Delay relock by 1 cycle to help meet timing.
always @(posedge clk100) begin
    servo7out0 <= relock7_out <<< N_P; 
    servo7out1 <= servo7out0 + e7_out;
end
// Limit output.
assign servo7out = newOut(servo7out1, UL7, LL7);
/// DITHER LOCK
// Select cos or sin demodulation.
always @(posedge clk100) begin
    if (mod_sel7) demod_in_sel7 <= (demodQ_out7 <<< N_P);
    else          demod_in_sel7 <= (demod_out7 <<< N_P);
end
// Assign dither lock integrator sign.
assign updown7 = demod_bit7;

/* MODULE DECLARATIONS */
AutoLock #(.reftrans("trans"), .mode("minmax"), .offmode("zero"), .sweepresetmode("zero")) 
AutoLock7(
    // Clock
    clk100, 0, STOPservo_CS7, 0, 1, scan_CS7,
    // Relock trigger level, and input signal
    locktrig7, trans7_in,
    // Sweep parameters and output
    start_sweep_7, stop_sweep_7, sweep_rate_7, relock7_out, relock_state7,
    // Hold and on output signals for PID module
    relock7_on, PID7_on
);
// Scaling and offset of error signal
ErrorScaleShift#(N_B, N_P, N_P, SIGNAL_SIZE)
ErrorScaleShift7(clk100, e7_in, offset7s, mod7_in, mod7scaling, offset7, DITHon7, mod7scaled_out, err7);
// Disable dither during MOT integration.
ditherInhibit#(N_B, NIhld7)dithInhibit7(clk100, dithEN, inhtrig7, mod7, inthld7, mod7_in);
// Cavity PID
CavPID#(SIGNAL_SIZE, CS7_ISCALING, CS7_PSCALING, CS7_DSCALING)
CavPID7(clk100, PID7_on, 1'b0, is_neg7, NFI7, NI7, NFP7, NP7, ND7, NFD7, NGD7, LL7, UL7, err7_1, e7_out, e7_out_I);
// Dither lock
DitherLock#(N_dithDly_7, N_B, N_P, SIGNAL_SIZE)
DitherLock7(clk100, trans7_in, divFast7, divSlow7, inhmode7, demod_bit7, PID7_on, DITHon7,
mod7, demod7, demod_out7, demodQ_out7, demod2f_out7, demod2fQ_out7, demod3f_out7, demod3fQ_out7, demod_in7, inhtrig7); 
// Dither lock integrator
I1BS#(SIGNAL_SIZE, 29, 1)DLINT7(clk100, PID7_on, inthld7, updown7, -10'd244, bitshift7, LL7, UL7, 0, demod_in_sel7, offset7);

//**** Cavity Servo 8 ****\\
/* SIGNAL DECLARATIONS */
/// Dither lock dither and offset and composite error signals
wire signed [N_B-1:0] mod8, mod8_in; // Dither outputs
wire signed [SIGNAL_SIZE-1:0] mod8scaled_out; // Scaled and shifted dither
wire DITHon8; // Dither on signal	
localparam NIhld8 = 2; // Number of cycles to wait before un-holding the dither lock integrator after the dither is enabled.
wire signed [SIGNAL_SIZE-1:0] offset8; // Composite error signal and offset from dither lock.
wire inhtrig8, inthld8; // Trigger to indicate position in dither cycle
/// PZT servo
wire signed [15:0] relock8_out;
wire STOPservo_CS8, relock8_on, relock_state8;
// PID output and integrator output (for slow integrator when using low range DAC output for PID output).
wire signed [SIGNAL_SIZE-1:0] e8_out, e8_out_I;
reg  signed [N_B+N_P+1:0] servo8out0, servo8out1; // Pipelined output for adding the relock to the PID output.
/// Dither lock
// Delay turn on of integrator by 10 ms
localparam [19:0] N_dithDly_8 = 20'd1_000_000;
// Demodulated outputs
wire signed [N_B-1:0] demod_out8, demodQ_out8, demod2f_out8, demod2fQ_out8, demod3f_out8, demod3fQ_out8;
wire signed [SIGNAL_SIZE-1:0] demod_in8;
// Selectable demodulated output, not used currently, clearer to assign in top.sv.
wire signed [N_B-1:0] demod8;
wire updown8;
reg signed [SIGNAL_SIZE-1:0] demod_in_sel8; // Demodulated input to integrator.

/* SIGNAL ASSIGNMENTS */
assign STOPservo_CS8 = (STOPservos || stop_CS8);
// Delay relock by 1 cycle to help meet timing.
always @(posedge clk100) begin
    servo8out0 <= relock8_out <<< N_P; 
    servo8out1 <= servo8out0 + e8_out;
end
// Limit output.
assign servo8out = newOut(servo8out1, UL8, LL8);
/// DITHER LOCK
// Select cos or sin demodulation.
always @(posedge clk100) begin
    if (mod_sel8) demod_in_sel8 <= (demodQ_out8 <<< N_P);
    else          demod_in_sel8 <= (demod_out8 <<< N_P);
end
// Assign dither lock integrator sign.
assign updown8 = demod_bit8;

/* MODULE DECLARATIONS */
AutoLock #(.reftrans("trans"), .mode("minmax"), .offmode("zero"), .sweepresetmode("zero")) 
AutoLock8(
    // Clock
    clk100, 0, STOPservo_CS8, 0, 1, scan_CS8,
    // Relock trigger level, and input signal
    locktrig8, trans8_in,
    // Sweep parameters and output
    start_sweep_8, stop_sweep_8, sweep_rate_8, relock8_out, relock_state8,
    // Hold and on output signals for PID module
    relock8_on, PID8_on
);
// Scaling and offset of error signal
ErrorScaleShift#(N_B, N_P, N_P, SIGNAL_SIZE)
ErrorScaleShift8(clk100, e8_in, offset8s, mod8_in, mod8scaling, offset8, DITHon8, mod8scaled_out, err8);
// Disable dither during MOT integration.
ditherInhibit#(N_B, NIhld8)dithInhibit8(clk100, dithEN, inhtrig8, mod8, inthld8, mod8_in);
// Cavity PID
CavPID#(SIGNAL_SIZE, CS8_ISCALING, CS8_PSCALING, CS8_DSCALING)
CavPID8(clk100, PID8_on, 1'b0, is_neg8, NFI8, NI8, NFP8, NP8, ND8, NFD8, NGD8, LL8, UL8, err8_1, e8_out, e8_out_I);
// Dither lock
DitherLock#(N_dithDly_8, N_B, N_P, SIGNAL_SIZE)
DitherLock8(clk100, trans8_in, divFast8, divSlow8, inhmode8, demod_bit8, PID8_on, DITHon8,
mod8, demod8, demod_out8, demodQ_out8, demod2f_out8, demod2fQ_out8, demod3f_out8, demod3fQ_out8, demod_in8, inhtrig8); 
// Dither lock integrator
I1BS#(SIGNAL_SIZE, 29, 1)DLINT8(clk100, PID8_on, inthld8, updown8, -10'd244, bitshift8, LL8, UL8, 0, demod_in_sel8, offset8);

// Debug outputs.
// LBO
assign mod0_dg          = mod0_in;
assign mod0sc_dg        = mod0scaled_out[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign demod0_dg        = demod_out0;
assign demod0Q_dg       = demodQ_out0;
assign demod_in_sel0_dg = demod_in_sel0[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign offset0_dg       = offset0[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
// 326-542
assign mod1_dg          = mod1_in;
assign mod1sc_dg        = mod1scaled_out[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign demod1_dg        = demod_out1;
assign demod1Q_dg       = demodQ_out1;
assign demod_in_sel1_dg = demod_in_sel1[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign offset1_dg       = offset1[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
// 820
assign mod2_dg          = mod2_in;
assign mod2sc_dg        = mod2scaled_out[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign demod2_dg        = demod_out2;
assign demod2Q_dg       = demodQ_out2;
assign demod_in_sel2_dg = demod_in_sel2[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign offset2_dg       = offset2[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
// 1083 ref
assign mod3_dg          = mod3_in;
assign mod3sc_dg        = mod3scaled_out[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign demod3_dg        = demod_out3;
assign demod3Q_dg       = demodQ_out3;
assign demod_in_sel3_dg = demod_in_sel3[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign offset3_dg       = offset3[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
// 361-542
assign mod4_dg          = mod4_in;
assign mod4sc_dg        = mod4scaled_out[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign demod4_dg        = demod_out4;
assign demod4Q_dg       = demodQ_out4;
assign demod_in_sel4_dg = demod_in_sel4[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign offset4_dg       = offset4[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
// 361-1083
assign mod5_dg          = mod5_in;
assign mod5sc_dg        = mod5_in_sc[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign demod5_dg        = demod_out5;
assign demod5Q_dg       = demodQ_out5;
assign demod_in_sel5_dg = demod_in_sel5[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign offset5_dg       = e5_out[SIGNAL_SIZE-1:SIGNAL_SIZE-16]; // This dither lock uses the PID output.
// 332
assign mod6_dg          = mod6_in;
assign mod6sc_dg        = mod6scaled_out[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign demod6_dg        = demod_out6;
assign demod6Q_dg       = demodQ_out6;
assign demod_in_sel6_dg = demod_in_sel6[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign offset6_dg       = offset6[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
// Cavity servo 7
assign mod7_dg          = mod7_in;
assign mod7sc_dg        = mod7scaled_out[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign demod7_dg        = demod_out7;
assign demod7Q_dg       = demodQ_out7;
assign demod_in_sel7_dg = demod_in_sel7[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign offset7_dg       = offset7[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
// Cavity servo 7
assign mod8_dg          = mod8_in;
assign mod8sc_dg        = mod8scaled_out[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign demod8_dg        = demod_out8;
assign demod8Q_dg       = demodQ_out8;
assign demod_in_sel8_dg = demod_in_sel8[SIGNAL_SIZE-1:SIGNAL_SIZE-16];
assign offset8_dg       = offset8[SIGNAL_SIZE-1:SIGNAL_SIZE-16];

endmodule