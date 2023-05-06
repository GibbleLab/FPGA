`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Lock-in module that generates a nearly sinusoidal modulation and demodulates an input signal with no sensitivity to the 3rd harmonic of the demodulation frequency.
// The size of the demodulated output is adjustable to accommodate long demodulation times.
// Modulation amplitude is 119*divSlow
// 
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////
module lockIn#(parameter demodSize = 16)(
    // Clocking
    input  wire                 clk, 
    input  wire        [15:0]   divFast,
    input  wire        [15:0]   divSlow, 
    input  wire        [3:0]    inhmode, 
    // Input signal
    input  wire signed [15:0]   s_in,
    // Modulation output      
    output reg                 trig_out,
    output wire signed [15:0]  LO_pre_int,
    output wire signed [15:0]  LOint_out,
    output wire                inhtrig, // trigger goes high for one cycle 1 cycle at the phase selected by inhmode.
    // Demodulated outputs
    output wire signed [demodSize-1:0] demod_out,    // Demod at f
    output wire signed [demodSize-1:0] demodQ_out,   // Quadrature Demod component with 90 degrees phase shift
    output wire signed [demodSize-1:0] demod2f_out,  // Demod at 2f
    output wire signed [demodSize-1:0] demod2fQ_out, // Quadrature Demod
    output wire signed [demodSize-1:0] demod3f_out,  // Demod at 3f
    output wire signed [demodSize-1:0] demod3fQ_out  // Quadrature Demod
);

//////// TRIGGERS \\\\\\\\
// These set the "fast" and "slow" integration timescales for the modulation filtering.
reg slow_trig, fast_trig;
reg [15:0] fast_count = 16'd0, slow_count = 16'd0;
always @(posedge clk) begin
    if (fast_count < divFast-1) begin
        fast_count <= fast_count + 16'd1;
        fast_trig <= 1'b0;
    end
    else begin
        fast_count <= 16'd0;
        fast_trig <= 1'b1;
    end
    if (slow_count < divSlow-1) begin
        if (fast_trig) begin
            slow_count <= slow_count + 16'd1;
            slow_trig <= 1'b0;
        end
        else begin
            slow_count <= slow_count;
            slow_trig <= 1'b0;
        end
    end
    else begin
        if (fast_trig) begin
            slow_count <= 16'd0;
            slow_trig <= 1'b1;
        end
        else begin
            slow_count <= slow_count;
            slow_trig <= 1'b0;
        end
    end   
end

//////// End TRIGGERS \\\\\\\\

//////// GENERATE MODULATION \\\\\\\\
//// Approximate sinewave modulation waveform\\\\
// parameters
localparam stepsizeLO = 2'd1;
localparam [5:0] N0 = 6'd8;  //Hold
localparam [5:0] N1 = 6'd10; //Slow ramp
localparam [5:0] N2 = 6'd2;  //Fast ramp

// Modulation generated from integrating a waveform with no 3rd harmonic.
// Integrated result has small 5f, 7f,... harmonics

// State machine to generate initial waveform
localparam TP0 = 4'b0000;
localparam DN0 = 4'b0001;
localparam DN1 = 4'b0010;
localparam DN2 = 4'b0011;
localparam BTM = 4'b0100;
localparam UP0 = 4'b0101;
localparam UP1 = 4'b0110;
localparam UP2 = 4'b0111;
localparam TP1 = 4'b1000;

// Combinatorial part
function [19:0] LOnextState;
    
input        [3:0]  state;
input        [15:0] cmax0;
input        [15:0] cmax1;
input        [15:0] cmax2;
input        [15:0] counter;

begin
    case(state)
        TP0: begin
            if (counter < ((cmax0>>1)-1) ) begin
                LOnextState = {counter + 16'b1, TP0};
            end
            else begin
                LOnextState = {16'b0, DN0};
            end
        end
        DN0: begin
            if (counter < (cmax1-1) ) begin
                LOnextState = {counter + 16'b1, DN0};
            end
            else begin
                LOnextState = {16'b0, DN1};
            end
        end
        DN1: begin
            if (counter < (cmax2-1) ) begin
                LOnextState = {counter + 16'b1, DN1};
            end
            else begin
                LOnextState = {16'b0, DN2};
            end
        end
        DN2: begin
            if (counter < (cmax1-1) ) begin
                LOnextState = {counter + 16'b1, DN2};
            end
            else begin
                LOnextState = {16'b0, BTM};
            end
        end
        BTM: begin
            if (counter < ((cmax0)-1) ) begin
                LOnextState = {counter + 16'b1, BTM};
            end
            else begin
                LOnextState = {16'b0, UP0};
            end
        end
        UP0: begin
            if (counter < (cmax1-1) ) begin
                LOnextState = {counter + 16'b1, UP0};
            end
            else begin
                LOnextState = {16'b0, UP1};
            end
        end
        UP1: begin
            if (counter < (cmax2-1)) begin
                LOnextState = {counter + 16'b1, UP1};
            end
            else begin
                LOnextState = {16'b0, UP2};
            end
        end
        UP2: begin
            if (counter < (cmax1-1) ) begin
                LOnextState = {counter + 16'b1, UP2};
            end
            else begin
                LOnextState = {16'b0, TP1};
            end
        end
        TP1: begin
            if (counter < ((cmax0>>1) - 1) ) begin
                LOnextState = {counter + 16'b1, TP1};
            end
            else begin
                LOnextState = {16'b0, TP0};
            end
        end
    endcase
end

endfunction

// Adjustable starting and ending phase of waveform
reg signed [4:0] LO_out_int; // large divSLOW/ divFAST may overflow 
assign LO_pre_int = LO_out_int;
reg [19:0] LOf;
reg [3:0] LOstate = TP0;
reg [15:0] LOcounter = 16'b0;
// Sequential part
always @(posedge clk) begin
    if (slow_trig) begin
    LOf = LOnextState(LOstate, N0, N1, N2, LOcounter);
    LOcounter = LOf[19:4];
    LOstate = LOf[3:0];
    case(LOstate)
        TP0: begin
            LO_out_int <= N1+N2;
        end
        DN0: begin
            LO_out_int <= LO_out_int - (stepsizeLO);
        end
        DN1: begin
            LO_out_int <= LO_out_int - (stepsizeLO << 1);
        end
        DN2: begin
            LO_out_int <= LO_out_int - (stepsizeLO);
        end
        BTM: begin
            LO_out_int <= LO_out_int;
        end
        UP0: begin
            LO_out_int <= LO_out_int + (stepsizeLO);
        end
        UP1: begin
            LO_out_int <= LO_out_int + (stepsizeLO << 1);
        end
        UP2: begin
            LO_out_int <= LO_out_int + (stepsizeLO);
        end
        TP1: begin
            LO_out_int <= LO_out_int;
        end
    endcase
    end
end

// Need to start integration of waveform with offset of divSlow/2*startVal to have mean of 0.
reg signed [25:0] LOintOffset;
always @(posedge clk) begin
    if (slow_trig) begin
        if ( (LOstate == TP1) && (LOcounter == 16'b0) ) begin
            LOintOffset = (((divSlow)+((divSlow)<<1)))<<1; // 6*divSlow
        end
    end
end

// Integrate 2nd waveform to generate the modulation
// Extra bits are included for overflow. Output is scaled later
reg signed [25:0] LOint;
reg [15:0] resetCounter = 16'b0;
always @(posedge clk) begin
    if (fast_trig) begin
        if ( (LOcounter == ((N0>>1) - 1)) && (LOstate == TP1) && (resetCounter == (divSlow-16'b1) ) ) begin
            LOint <= LOintOffset;
            resetCounter <= 16'b0;
        end
        else if ( (LOcounter == ((N0>>1) - 1)) && (LOstate == TP1) && (resetCounter < (divSlow-16'b1) ) ) begin
            LOint <= LOint + LO_out_int;
            resetCounter <= resetCounter + 16'b1;
        end
        else begin
            LOint <= LOint + LO_out_int;
        end
    end
end

// Triggers at various phases of the modulation. These are used by the ditherInhibit module to start and stop the modulation.
// phase = inhmode*(22.5 degrees), where 0 degrees is the positive slope zero crossing.
wire 
    inhtrig0, inhtrig1, inhtrig2,  inhtrig3,  inhtrig4,  inhtrig5,  inhtrig6,  inhtrig7, 
    inhtrig8, inhtrig9, inhtrig10, inhtrig11, inhtrig12, inhtrig13, inhtrig14, inhtrig15;
assign inhtrig0  = ( (LOstate==8) && (LOcounter==3) && (fast_count==(divFast>>1))            && (slow_count==(divSlow>>1))            ); // zero crossing with a positive slope, 0 deg
assign inhtrig1  = ( (LOstate==0) && (LOcounter==3) && (fast_count==(divFast>>2))            && (slow_count==(divSlow>>2))            ); // 22.5 deg
assign inhtrig2  = ( (LOstate==1) && (LOcounter==2) && (fast_count==0)                       && (slow_count==(divSlow-1))             ); // 45 deg
assign inhtrig3  = ( (LOstate==1) && (LOcounter==6) && (fast_count==(divFast>>2+divFast>>1)) && (slow_count==(divSlow>>2+divSlow>>1)) ); // 67.5 deg
assign inhtrig4  = ( (LOstate==2) && (LOcounter==0) && (fast_count==(divFast>>1))            && (slow_count==(divSlow>>1))            ); // maximum, 90 deg
assign inhtrig5  = ( (LOstate==3) && (LOcounter==2) && (fast_count==(divFast>>2))            && (slow_count==(divSlow>>2))            ); // 112.5 deg
assign inhtrig6  = ( (LOstate==3) && (LOcounter==5) && (fast_count==0)                       && (slow_count==(divSlow-1))             ); // 135 deg
assign inhtrig7  = ( (LOstate==3) && (LOcounter==9) && (fast_count==(divFast>>2+divFast>>1)) && (slow_count==(divSlow>>2+divSlow>>1)) ); // 157.5 deg
assign inhtrig8  = ( (LOstate==4) && (LOcounter==3) && (fast_count==(divFast>>1))            && (slow_count==(divSlow>>1))            ); // minimum, 180 deg
assign inhtrig9  = ( (LOstate==4) && (LOcounter==7) && (fast_count==(divFast>>2))            && (slow_count==(divSlow>>2))            ); // 202.5 deg
assign inhtrig10 = ( (LOstate==5) && (LOcounter==2) && (fast_count==0)                       && (slow_count==(divSlow-1))             ); // 225 deg
assign inhtrig11 = ( (LOstate==5) && (LOcounter==6) && (fast_count==(divFast>>2+divFast>>1)) && (slow_count==(divSlow>>2+divSlow>>1)) ); // 247.5 deg
assign inhtrig12 = ( (LOstate==6) && (LOcounter==0) && (fast_count==(divFast>>1))            && (slow_count==(divSlow>>1))            ); // maximum, 270 deg
assign inhtrig13 = ( (LOstate==7) && (LOcounter==2) && (fast_count==(divFast>>2))            && (slow_count==(divSlow>>2))            ); // 292.5 deg
assign inhtrig14 = ( (LOstate==7) && (LOcounter==5) && (fast_count==0)                       && (slow_count==(divSlow-1))             ); // 315 deg
assign inhtrig15 = ( (LOstate==7) && (LOcounter==9) && (fast_count==(divFast>>2+divFast>>1)) && (slow_count==(divSlow>>2+divSlow>>1)) ); // 337.5 deg

// Function to assign the desired trigger to the output.
function trig_assign;
    input [3:0] mode;
    input trig0, trig1, trig2,  trig3,  trig4,  trig5,  trig6,  trig7, 
          trig8, trig9, trig10, trig11, trig12, trig13, trig14, trig15;
    case (mode)
        0:  trig_assign = trig0;
        1:  trig_assign = trig1;
        2:  trig_assign = trig2;
        3:  trig_assign = trig3;
        4:  trig_assign = trig4;
        5:  trig_assign = trig5;
        6:  trig_assign = trig6;
        7:  trig_assign = trig7;
        8:  trig_assign = trig8;
        9:  trig_assign = trig9;
        10: trig_assign = trig10;
        11: trig_assign = trig11;
        12: trig_assign = trig12;
        13: trig_assign = trig13;
        14: trig_assign = trig14;
        15: trig_assign = trig15;
        default: trig_assign = trig0;
    endcase 
endfunction
// Assignment of the trigger to the output inhtrig.
assign  inhtrig = trig_assign(inhmode, inhtrig0, inhtrig1, inhtrig2,  inhtrig3,  inhtrig4,  inhtrig5,  inhtrig6,  inhtrig7, 
                                       inhtrig8, inhtrig9, inhtrig10, inhtrig11, inhtrig12, inhtrig13, inhtrig14, inhtrig15);
//////// END MODULATION GENERATION \\\\\\\\

//////// OUTPUT TRIGGER AT MODULATION MAX \\\\\\\\
// Makes a trigger that goes high for 1 clk cycle when LOint is a maximum
reg trigtrig;
always @(posedge clk) begin
    if (LOint>0) begin
        if (LO_out_int==16'd0)
            if (trigtrig) begin
                trig_out <= 1'b1;
                trigtrig <= 1'b0;
            end
            else
                trig_out <= 1'b0;
        end
    else begin
        trigtrig <= 1'b1;
    end
end
//////// END OUTPUT TRIGGER AT MODULATION MAX \\\\\\\\

//////// DEMODULATION AT MODULATION FREQUENCY AND ITS HARMONICS \\\\\\\\
// This demodulation waveform has 12 steps, [0,1,1,1,1,0,0,-1,-1,-1,-1,0]. It yields no sensitivity to three times the demodulation frequency.

localparam Z0 = 3'b000;
localparam TP = 3'b001;
localparam Z1 = 3'b010;
localparam BT = 3'b011;
localparam Z2 = 3'b100;

function [18:0] demodNextState;

input [2:0]  state;
input [15:0] cmax0;
input [15:0] cmax1;
input [15:0] counter;

begin
    case(state)
        Z0: begin
            if ( counter < ( (cmax0 >> 1) - 1 ) ) begin
                demodNextState = {counter + 16'b1, Z0};
            end
            else begin
                demodNextState = {16'b0, TP};
            end
        end
        TP: begin
            if ( counter < ( cmax1 - 1 ) ) begin
                demodNextState = {counter + 16'b1, TP};
            end
            else begin
                demodNextState = {16'b0, Z1};
            end      
        end
        Z1: begin
            if ( counter < ( cmax0 - 1 ) ) begin
                demodNextState = {counter + 16'b1, Z1};
            end
            else begin
                demodNextState = {16'b0, BT};
            end
        end
        BT: begin
            if ( counter < ( cmax1 - 1 ) ) begin
                demodNextState = {counter + 16'b1, BT};
            end
            else begin
                demodNextState = {16'b0, Z2};
            end
        end
        Z2: begin
            if ( counter < ( (cmax0 >> 1) - 1 ) ) begin
                demodNextState = {counter + 16'b1, Z2};
            end
            else begin
                demodNextState = {16'b0, Z0};
            end
        end
    endcase
end

endfunction

// Demodulation at f, 2f, and 3f. 

// f
localparam [5:0] Nd0 = 6'd10; // Number of cycles with 0 gain
localparam [5:0] Nd1 = 6'd20; // number of cycles adding/subtracting

reg signed [demodSize-1:0] sum_new = 'b0, sum_old = 'b0;

reg [15:0] demodCounter = 16'b0;
reg [18:0] demodf;
reg [2:0] demodState = Z0;

reg signed [demodSize-1:0] sumQ_new = 'b0, sumQ_old = 'b0;
reg [15:0] demodQCounter = (Nd1 >> 1) - 1;
reg [18:0] demodQf;
reg [2:0] demodQState = TP;

// 2f
localparam [5:0] Nd2f0 = 6'd4; // Number of cycles with 0 gain
localparam [5:0] Nd2f1 = 6'd11; // number of cycles adding/subtracting

reg signed [demodSize-1:0] sum2f_new = 'b0, sum2f_old = 'b0;

reg [15:0] demod2fCounter = 16'b0;
reg [18:0] demod2ff;
reg [2:0] demod2fState = Z0;

reg signed [demodSize-1:0] sum2fQ_new = 'b0, sum2fQ_old = 'b0;

reg [15:0] demod2fQCounter = (Nd2f1 >> 1) - 1;
reg [18:0] demod2fQf;
reg [2:0] demod2fQState = TP;

// 3f
localparam [5:0] Nd3f0 = 6'd2; // Number of cycles with 0 gain
localparam [5:0] Nd3f1 = 6'd8; // number of cycles adding/subtracting

reg signed [demodSize-1:0] sum3f_new = 'b0, sum3f_old = 'b0;

reg [15:0] demod3fCounter = 16'b0;
reg [18:0] demod3ff;
reg [2:0] demod3fState = Z0;

reg signed [demodSize-1:0] sum3fQ_new = 'b0, sum3fQ_old = 'b0;

reg [15:0] demod3fQCounter = (Nd3f1 >> 1) - 1;
reg [18:0] demod3fQf;
reg [2:0] demod3fQState = TP;

always @(posedge clk) begin
if (slow_trig) begin
////////// f In phase demod \\\\\\\\\\
demodf = demodNextState(demodState, Nd0, Nd1, demodCounter);
demodCounter = demodf[18:3];
demodState = demodf[2:0];
case(demodState)
    Z0: begin
        sum_new <= sum_new;
    end
    TP: begin
        sum_new <= sum_new + s_in;
    end
    Z1: begin
        sum_new <= sum_new;
    end
    BT: begin
        sum_new <= sum_new - s_in;
    end
    Z2: begin
        if (demodCounter == ( (Nd0 >> 1) - 1 ) ) begin
            sum_old   = sum_new;
            sum_new   = 'b0;
        end
        else begin
            sum_new   <= sum_new;
        end
    end
endcase

////////// f Quadrature demod \\\\\\\\\\
demodQf = demodNextState(demodQState, Nd0, Nd1, demodQCounter);
demodQCounter = demodQf[18:3];
demodQState = demodQf[2:0];
case(demodQState)
    Z0: begin
        sumQ_new <= sumQ_new;
    end
    TP: begin
        sumQ_new <= sumQ_new + s_in;
    end
    Z1: begin
        sumQ_new <= sumQ_new;
    end
    BT: begin
        sumQ_new <= sumQ_new - s_in;
    end
    Z2: begin
        if (demodQCounter == ( (Nd0 >> 1) - 1 ) ) begin
            sumQ_old   = sumQ_new;
            sumQ_new   = 'b0;
        end
        else begin
            sumQ_new   <= sumQ_new;
        end
    end
endcase

////////// 2f in phase demod \\\\\\\\\\
demod2ff = demodNextState(demod2fState, Nd2f0, Nd2f1, demod2fCounter);
demod2fCounter = demod2ff[18:3];
demod2fState = demod2ff[2:0];
case(demod2fState)
    Z0: begin
        sum2f_new <= sum2f_new;
    end
    TP: begin
        sum2f_new <= sum2f_new + s_in;
    end
    Z1: begin
        sum2f_new <= sum2f_new;
    end
    BT: begin
        sum2f_new <= sum2f_new - s_in;
    end
    Z2: begin
        if (demod2fCounter == ( (Nd2f0 >> 1) - 1 ) ) begin
            sum2f_old   = sum2f_new;
            sum2f_new   = 'b0;
        end
        else begin
            sum2f_new   <= sum2f_new;
        end
    end
endcase

////////// 2f Quadrature demod \\\\\\\\\\
demod2fQf = demodNextState(demod2fQState, Nd2f0, Nd2f1, demod2fQCounter);
demod2fQCounter = demod2fQf[18:3];
demod2fQState = demod2fQf[2:0];
case(demod2fQState)
    Z0: begin
        sum2fQ_new <= sum2fQ_new;
    end
    TP: begin
        sum2fQ_new <= sum2fQ_new + s_in;
    end
    Z1: begin
        sum2fQ_new <= sum2fQ_new;
    end
    BT: begin
        sum2fQ_new <= sum2fQ_new - s_in;
    end
    Z2: begin
        if (demod2fQCounter == ( (Nd2f0 >> 1) - 1 ) ) begin
            sum2fQ_old   = sum2fQ_new;
            sum2fQ_new   = 'b0;
        end
        else begin
            sum2fQ_new   <= sum2fQ_new;
        end
    end
endcase

////////// 3f in phase demod \\\\\\\\\\
demod3ff = demodNextState(demod3fState, Nd3f0, Nd3f1, demod3fCounter);
demod3fCounter = demod3ff[18:3];
demod3fState = demod3ff[2:0];
case(demod3fState)
    Z0: begin
        sum3f_new <= sum3f_new;
    end
    TP: begin
        sum3f_new <= sum3f_new + s_in;
    end
    Z1: begin
        sum3f_new <= sum3f_new;
    end
    BT: begin
        sum3f_new <= sum3f_new - s_in;
    end
    Z2: begin
        if (demod3fCounter == ( (Nd3f0 >> 1) - 1 ) ) begin
            sum3f_old   = sum3f_new;
            sum3f_new   = 'b0;
        end
        else begin
            sum3f_new   <= sum3f_new;
        end
    end
endcase

////////// 3f Quadrature demod \\\\\\\\\\
demod3fQf = demodNextState(demod3fQState, Nd3f0, Nd3f1, demod3fQCounter);
demod3fQCounter = demod3fQf[18:3];
demod3fQState = demod3fQf[2:0];
case(demod3fQState)
    Z0: begin
        sum3fQ_new <= sum3fQ_new;
    end
    TP: begin
        sum3fQ_new <= sum3fQ_new + s_in;
    end
    Z1: begin
        sum3fQ_new <= sum3fQ_new;
    end
    BT: begin
        sum3fQ_new <= sum3fQ_new - s_in;
    end
    Z2: begin
        if (demod3fQCounter == ( (Nd3f0 >> 1) - 1 ) ) begin
            sum3fQ_old = sum3fQ_new;
            sum3fQ_new = 'b0;
        end
        else begin
            sum3fQ_new <= sum3fQ_new;
        end
    end
endcase

end
end
//////// END DEMODULATION \\\\\\\\

//////// ASSIGN OUTPUTS \\\\\\\\
assign LOint_out    = LOint;
assign demod_out    = sum_old;
assign demodQ_out   = sumQ_old;
assign demod2f_out  = sum2f_old;
assign demod2fQ_out = sum2fQ_old;
assign demod3f_out  = sum3f_old;
assign demod3fQ_out = sum3fQ_old;

endmodule