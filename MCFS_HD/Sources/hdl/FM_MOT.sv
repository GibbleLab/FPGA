`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// This module outputs 3 synchronized arbitrary waveforms and has a gated integrator with a background subtraction during the detection and background times.
// The arbitrary waveform generation is based on a state machine, as opposed to a waveform stored in memory.
// The first waveform 'FM' is a VCO frequency control, which frequency modulates the VCO output, and then successively ramps the frequency for cooling, detection, and clearing.
// The second waveform 'Int' is an intensity control, constant for the FM, then two ramps, and then constant for detection and clearing.
// The third 'cI' is a three-level digital trigger for the supply for a MOT gradient coil driver.
// The module's gated integrator with a background subtraction is assigned to IntDiff. The differences of successive IntDiff's 
// give a difference of differences, IntDiffDiff, e.g., subtracting the cold atom fluorescence for a reversed MOT gradient.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////
module FM_MOT#(parameter SCALING = 24, DEMSC = 24)(
    /// Control and input signal \\\
    input  wire               clk,
    input  wire        [ 1:0] MOT_state,
    input  wire               on,
    input  wire signed [15:0] s_in,    // Input signal
    /// FM parameters \\\
    input  wire        [15:0] divFast,  // Dividers for the frequency of the sinusoidal FM segment of the 'FM' waveform
    input  wire        [15:0] divSlow,
    input  wire        [15:0] dithMean, // Mean of the sinusoidal FM segment.
    input  wire signed [15:0] dithSc,
    // The amplitude parameters D1...D6 have 14 fractional bits
    input  wire        [15:0] dtD,      // Length of FM, in FM cycles
    input  wire        [15:0] dt1,      // Number of FM cycles for the first ramp
    input  wire signed [23:0] D1,       // Step-size, every 10 ns, for the 1st ramp of 'FM'.
    input  wire        [15:0] dt2,      // Number of FM cycles for the second ramp
    input  wire signed [23:0] D2,       // Step-size for the 2nd ramp of 'FM'.
    input  wire        [15:0] dt3,      // Number of FM cycles to keep 'FM' constant for the cooling/detection
    input  wire        [15:0] dtUP,
    input  wire        [23:0] DUP,
    input  wire        [15:0] dtDOWN,   // Number of FM cycles to ramp to the start of the 'FM' waveform (normally 2 50 kHz FM cycles, or 40 us)
    input  wire signed [23:0] DDOWN,    // Step-size for the ramp to the start of 'FM'
    /// Intensity ramp parameters \\\
    input  wire signed [15:0] IntMax,   // Starting point for 'Int' waveform
    input  wire signed [15:0] dt4,      // Number of FM cycles between the end of the FM and the first ramp of 'Int'; can be positive or negative
    input  wire        [15:0] dt5,      // Number of FM cycles for the first ramp of 'Int'
    input  wire signed [23:0] D5,       // Step-size for the 1st ramp of 'Int'. 
    input  wire        [15:0] dt6,      // Number of FM cycles for the second ramp of 'Int'
    input  wire signed [23:0] D6,       // Step-size for the 2nd ramp of 'Int'.
    /// Integration and lockin output signals \\\
    input  wire        [15:0] dt8, // Number of FM cycles to integrate
    input  wire        [15:0] INTBS,
    input  wire        [15:0] DEMCBS,
    input  wire        [15:0] DEMSBS,
    output reg  signed [15:0] IntDiffOut, IntDiffDiffOut,
    output reg  signed [15:0] demodCOS, demodSIN,
    /// Outputs \\\
    output wire               trigD,
    output reg  signed [15:0] FM,      // VCO frequency control
    output reg  signed [15:0] Int,     // Intensity control signal
    output reg  signed [15:0] cI,     // 2-level trigger for the MOT coil current
    output reg                dithEN, // ENABLE signal for cavity dithers, so they are disabled during detection times, 1 enable, 0 disable
    output reg                memtrig
);
wire signed [15:0] sig;
assign sig = s_in;
////// LOCKIN MODULE \\\\\\ 
wire trig_out;
wire signed [15:0] dith_pre, dith;
wire signed [DEMSC-1:0] demod_out, demodQ_out, demod2f_out, demod2fQ_out, demod3f_out, demod3fQ_out;
wire [3:0] inhmode = 0;
wire inhtrig;
lockIn#(DEMSC)
lockIn_inst(
    clk, divFast, divSlow, inhmode,
    sig, trig_out, 
    dith_pre, dith, inhtrig,
    demod_out,   demodQ_out,
    demod2f_out, demod2fQ_out,
    demod3f_out, demod3fQ_out
);
assign trigD = trig_out;

reg signed [15:0] dith_sc, dith_sc_int, dith_sh, dithSc1;
reg [13:0] BS0;
reg [1:0]  BS1;
always @(posedge clk) begin    
    BS1 <= dithSc1[1:0];
    if (dithSc<0) begin
        dith_sc <= 16'd0;
    end
    else begin
        dithSc1 <= dithSc;
        BS0     <= ((dithSc1+14'b1)>>>2); //rounding, including rounding up for 2'b11 case.
        BS1     <= dithSc1[1:0];
        case (BS1)
            2'b00: dith_sc_int <= dith; // 1
            2'b11:   dith_sc_int <= dith - (dith >>> {BS1[0], BS1[1]}); // 1.75
            default: dith_sc_int <= dith + (dith >>> {BS1[0], BS1[1]}); // 1.25 and 1.5
        endcase
        dith_sc <= (dith_sc_int <<< BS0);
    end
    dith_sh = dith_sc + dithMean;
end
////// END OF LOCKIN MODULE \\\\\\

////// GLOBAL COUNTER AND TIMES TO DO DIFFERENT SEGMENTS OF 'FM' \\\\\\
reg [15:0] cntMAX, cnt = 16'd0;
reg [15:0] Dt1, Dt2, Dt3, DtCLR, DtHLD, DtDWN, DtINT2, DtDOWN, Dt4, Dt5, Dt6, Dt7, DtINT1;
always @(posedge clk) begin
    // The Dtxxx <= expressions below set the starting times in FM cycles of each section of the VCO frequency control waveform 'FM'.
    // The 'FM' waveform begins with a sinusoidal output, to FM a VCO, for dtD FM cycles, followed by a 2-part ramp for dt1 and dt2 FM cycles.
    // 'FM' then holds for dt3, for cooling and detection with the gated integrator.
    // The next segment of 'FM' is a clearing interval.
    // The clearing is a ramp for dtUP, hold for dt8 - 2 x dtUP, and another ramp for dtUP, back to the detection voltage/frequency.
    // After clearing, 'FM' holds again for dt8 for background subtraction.
    // After the background interval, 'FM' ramps for dtDOWN cycles to its starting level, and 'FM' repeats.
    DtDOWN <= DtINT2 + dtDOWN;           // End of ramp to the 'FM' starting value.
    DtINT2 <= DtDWN + dt8;               // Ramp to the initial level of 'FM' waveform.
    DtDWN  <= DtHLD + dtUP;              // 'FM' remains constant for the background gated integration.
    DtHLD  <= DtCLR - dtUP + dt8 - dtUP; // Ramp to the level for the second integration.
    DtCLR  <= Dt3 + dtUP;                // 'FM' remains constant for the clearing pulse.
    Dt3    <= Dt2 + dt3;                 // Ramp to clearing frequency.
    Dt2    <= Dt1 + dt2;                 // Detection segment with gated integration
    Dt1    <= dtD + dt1;                 // Second segment of the ramp
    // The 'Int' waveform holds its initial value for dtD + dt4 FM cycles, where dt4 can be positive or negative.
    // It then ramps for dt5 FM cycles, then again for dt6 FM cycles, with generally different ramp slopes.
    // After the second ramp, 'Int' is constant until cntMAX, and then repeats.
    Dt7    <= cntMAX;    // End of 'Int' waveform.
    Dt6    <= Dt5 + dt6; // 'Int' remains constant for integration and clearing.
    Dt5    <= Dt4 + dt5; // Second ramp.
    Dt4    <= dtD + dt4; // First ramp, can begin before or after the end of the sinusoidal frequency modulation segment.
    // Integration times
    DtINT1 <= Dt3 - dt8; // Begin first integration
    if      (trig_out && (cnt <  (cntMAX-1))) cnt <= cnt + 16'd1; // Count FM cycles
    else if (trig_out && (cnt >= (cntMAX-1))) cnt <= 16'd0;
    else if (cnt == 0) begin
        cntMAX <= dtD+dt1+dt2+dt3+(dt8+dt8)+dtDOWN; // Total length of waveforms
        cnt <= cnt;
    end
    else cnt <= cnt;
end

////// END OF GLOBAL COUNTER AND TIMES FOR DIFFERENT STAGES OF 'FM' \\\\\\

///// 'FM' SCAN \\\\\\
//// COMBINATORIAL PART \\\\
// The fmNextState function outputs the current state, from the count input, to successively set the 'FM' state to its 9 segments: sinusoidal FM output, first and second ramp, constant for detection, clearing, constant for background gated integration, and ramp to start.
localparam [4:0] DITH = 5'd0,
                 RMP1 = 5'd1,
                 RMP2 = 5'd2,
                 HLD1 = 5'd3,
                 CLUP = 5'd4,
                 CHLD = 5'd5,
                 CDWN = 5'd6,
                 HLD2 = 5'd7,
                 DOWN = 5'd8;
function [4:0] fmNextState;
    input [4:0]  OldState;
    input [15:0] count;
    input [15:0] countDmax;
    input [15:0] cnt1max;
    input [15:0] cnt2max;
    input [15:0] cnt3max;
    input [15:0] cnt4max;
    input [15:0] cnt5max;
    input [15:0] cnt6max;
    input [15:0] cnt7max;
    input [15:0] cntDOWNmax;
    
    case (OldState)
        default: fmNextState = DITH;
        DITH: begin
            if (count<countDmax)
                 fmNextState = DITH;
            else fmNextState = RMP1;
        end
        RMP1: begin
            if ((count >= countDmax) && (count < cnt1max))
                 fmNextState = RMP1;
            else fmNextState = RMP2;
        end
        RMP2: begin
            if ((count >= cnt1max) && (count < cnt2max))
                 fmNextState = RMP2;
            else fmNextState = HLD1;
        end
        HLD1: begin
            if ((count >= cnt2max) && (count < cnt3max))
                 fmNextState = HLD1;
            else fmNextState = CLUP;
        end
        CLUP: begin
            if ((count >= cnt3max)&&(count < cnt4max))
                 fmNextState = CLUP;
            else fmNextState = CHLD;
        end
        CHLD: begin
            if ((count >= cnt4max)&&(count < cnt5max))
                 fmNextState = CHLD;
            else fmNextState = CDWN;
        end
        CDWN: begin
            if ((count >= cnt5max)&&(count < cnt6max))
                 fmNextState = CDWN;
            else fmNextState = HLD2;
        end
        HLD2: begin
            if ((count >= cnt6max)&&(count < cnt7max))
                 fmNextState = HLD2;
            else fmNextState = DOWN;
        end
        DOWN: begin
            if ((count >= cnt7max) && (count < cntDOWNmax))
                 fmNextState = DOWN;
            else fmNextState = DITH;        
        end
     endcase
endfunction

//// SEQUENTIAL PART \\\\
localparam rampSc = 14;
reg [4:0] FMstate;
reg [rampSc+15:0] FMtemp;
always @(posedge clk) begin
    FMstate <= fmNextState(FMstate, cnt, dtD, Dt1, Dt2, Dt3, DtCLR, DtHLD, DtDWN, DtINT2, DtDOWN);
    case (FMstate)
        // All segments are an integral number of FM cycles
        DITH: begin
            // The internal waveform FMtemp has 14 fractional bits.
            // The steps D1, D2, DUP, DDOWN, D5, and D6 have 24 bits, so the 14 LSB's are fractional, and the 10 MSB's correspond to FM bits 9:0.
            FMtemp <= (dith_sh <<< rampSc);
            FM <= FMtemp[rampSc+15:rampSc];
        end
        // First ramp from minimum of the FM
        RMP1: begin
            FMtemp <= FMtemp + D1;
            FM     <= FMtemp[rampSc+15:rampSc];
        end
        // Second ramp, continuing from first
        RMP2: begin
            FMtemp <= FMtemp + D2;        
            FM   <= FMtemp[rampSc+15:rampSc];
        end
        // Constant value 
        HLD1: begin
            FMtemp <= FMtemp;        
            FM   <= FMtemp[rampSc+15:rampSc];
        end
        CLUP: begin
            FMtemp <= FMtemp + DUP;        
            FM   <= FMtemp[rampSc+15:rampSc];
        end
        CHLD: begin
            FMtemp <= FMtemp;        
            FM   <= FMtemp[rampSc+15:rampSc];
        end
        CDWN: begin
            FMtemp <= FMtemp - DUP;        
            FM   <= FMtemp[rampSc+15:rampSc];
        end
        HLD2: begin
            FMtemp <= FMtemp;        
            FM   <= FMtemp[rampSc+15:rampSc];
        end
        // Ramp to dither minimum
        DOWN: begin
            FMtemp <= FMtemp - DDOWN;        
            FM     <= FMtemp[rampSc+15:rampSc];
        end
    endcase
end

////// END OF FM SCAN \\\\\\

////// INTENSITY RAMP \\\\\\

// The INextState function outputs the current state, from the count input, to successively set the 'Int' state to its 4 segments: constant output during the sinusoidal FM, first and second ramp, and constant for the integration and clearing.

//// COMBINATORIAL PART \\\\
localparam [1:0] IDITH = 2'd0,
                 IDWN1 = 2'd1,
                 IDWN2 = 2'd2,
                 IWAIT = 2'd3;
                 
function [1:0] INextState;
    input [1:0]  OldState;
    input [15:0] count;
    input [15:0] countDmax;
    input [15:0] countI1max;
    input [15:0] countI2max;  
    input [15:0] countIWAITmax;
        
    case (OldState)
        default: INextState = IDITH;
        IDITH: begin
            if(count<countDmax) INextState = IDITH;
            else INextState = IDWN1;
        end
        IDWN1: begin
            if((count>=countDmax)&&(count<countI1max)) INextState = IDWN1;
            else INextState = IDWN2;
        end
        IDWN2: begin
            if((count>=countI1max)&&(count<countI2max)) INextState = IDWN2;
            else INextState = IWAIT;
        end
        IWAIT: begin
            if((count>=countI2max)&&(count<countIWAITmax)) INextState = IWAIT;
            else INextState = IDITH;
        end    
    endcase
endfunction

//// SEQUENTIAL PART \\\\
reg [1:0] IState;
reg [15:0] DtI;
reg [rampSc+15:0] Inttemp; // 'Inttemp' has 14 fractional bits.
always @(posedge clk) begin
    DtI <= dtD + dt4;
    IState <= INextState(IState, cnt, DtI, Dt5, Dt6, Dt7);
    case (IState)
        IDITH: begin // Constant intensity 'Int' during the FM
            Inttemp  <= (IntMax <<< rampSc);
            Int      <= Inttemp[rampSc+15:rampSc];
        end
        IDWN1: begin // First ramp, from initial 'Int' level
            Inttemp <= Inttemp - D5;
            Int     <= Inttemp[rampSc+15:rampSc];
        end
        IDWN2: begin // Second ramp, continuing from first
            Inttemp <= Inttemp - D6;        
            Int     <= Inttemp[rampSc+15:rampSc];
        end
        IWAIT: begin // Constant 'Int' until the end of 'FM'.
            Inttemp <= Inttemp;        
            Int     <= Inttemp[rampSc+15:rampSc];
        end
    endcase    
end
////// END OF INTENSITY RAMP \\\\\\
// Dither enable is used by dithInhibit modules in the cavity servos to inhibit the cavity servo dithers for detection.
// dithEN goes HIGH at the beginning of the 'FM' waveform.
// dithEN goes LOW 100 FM cycles either before the integration starts or before the end of the FM, whichever is earlier. 
always @(posedge clk) begin
    if (on) begin
        if (FMstate==DITH) begin
            if (cnt<1) begin
                dithEN <= 1;
            end
            else begin
                if (DtI < dtD) begin // If the gated integrator starts before the end of the FM, disable the dithers 100 FM cycles before integrating
                    if (cnt >= (DtI-100)) dithEN <= 0;
                    else                  dithEN <= 1;
                end
                else begin // If the gated integrator starts after the end of the FM, disable the dither 100 FM cycles before the end of the FM
                    if (cnt >= (dtD-100)) dithEN <= 0;
                    else                  dithEN <= 1;
                end
            end
        end
        else dithEN <= 0;
    end
    else dithEN = 1;
end

////// INTEGRATION AFTER RAMP AND GATED INTEGRATOR OUTPUTS \\\\\\
// Function has two states: wait for integration, and integrating.
localparam [1:0] INTGWT = 2'd0,
                 INTGR1 = 2'd1,
                 INTGR2 = 2'd2,
                 INTGR3 = 2'd3;
function [1:0] IntNextState;
    input [1:0]  OldState;
    input [15:0] cnt;
    input [15:0] cntmax0;
    input [15:0] cntmax1;
    input [15:0] cntmax2;
    input [15:0] cntmax3;
    
    case (OldState)
        default: IntNextState = INTGWT;
        INTGWT: begin
            if ((cnt>=cntmax3)||(cnt<cntmax0)) IntNextState = INTGWT;
            else IntNextState = INTGR1;
        end
        INTGR1: begin
            if ((cnt>=cntmax0)&&(cnt<cntmax1)) IntNextState = INTGR1;
            else IntNextState = INTGR2;
        end
        INTGR2: begin
            if ((cnt>=cntmax1)&&(cnt<cntmax2)) IntNextState = INTGR2;
            else IntNextState = INTGR3;
        end
        INTGR3: begin
            if ((cnt>=cntmax2)&&(cnt<cntmax3)) IntNextState = INTGR3;
            else IntNextState = INTGWT;
        end
    endcase
endfunction

// Integrate the input signal during the detection and background intervals, before and after clearing, and subtract the gated integration of the background.
reg [1:0] IntState;
reg [15:0] IntWaitMax, IntStop, sigSave;
reg signed [SCALING+15:0] IntSigTemp, IntDiff, IntDiffsc;
reg signed [0:1][SCALING+15:0] IntSigTemp_old, IntDiffTemp_old;
reg [2:0] scnt; // counter for results
always @(posedge clk) begin
    IntState <= IntNextState(IntState, cnt, DtINT1, Dt3, DtDWN, DtINT2);
    case(IntState)
        INTGWT: begin
            if (scnt==0) begin
                IntSigTemp_old[1] <= IntSigTemp_old[0];
                scnt <= scnt + 3'd1;
            end
            else if (scnt==1) begin
                IntSigTemp_old[0] <= IntSigTemp;
                scnt <= scnt + 3'd1;
            end
            else if ((scnt==2)||(scnt==3)||(scnt==4)) begin
                IntSigTemp <= 'd0;
                IntDiff    <= IntSigTemp_old[1]-IntSigTemp_old[0];
                IntDiffsc  <= (IntDiff <<< INTBS);
                IntDiffOut <= IntDiffsc[SCALING+15:SCALING];
                scnt       <= scnt + 3'd1;
            end
            else begin
                IntSigTemp_old <= IntSigTemp_old;
                IntSigTemp     <= IntSigTemp;
                IntDiff        <= IntDiff;
                IntDiffsc      <= IntDiffsc;
                IntDiffOut     <= IntDiffOut;
                scnt           <= scnt;
            end
        end
        INTGR1: begin
            IntSigTemp <= IntSigTemp + sig;
            scnt <= 3'd0;
        end        
        INTGR2: begin
            if (scnt==0) begin
                IntSigTemp_old[1] <= IntSigTemp_old[0];
                scnt <= scnt + 3'd1;
            end
            else if (scnt==1) begin 
                IntSigTemp_old[0] <= IntSigTemp;
                scnt <= scnt + 3'd1;
            end
            else if (scnt==2) begin
                IntSigTemp <= 'd0;
                scnt <= scnt + 3'd1;
            end
            else begin
                IntSigTemp_old <= IntSigTemp_old;
                IntSigTemp <= IntSigTemp;
                scnt <= scnt;
            end
        end
        INTGR3: begin
            IntSigTemp <= IntSigTemp + sig;
            scnt <= 3'd0;
        end        
    endcase
end

reg cntPN = 1'b0;
reg swTrig;
always @(posedge clk) begin
    // trigger unless MOT_state is OFF.
    if (MOT_state == 2'b00) cI <= 0; // OFF state is 2'b00.
    // 'cI' waveform: a 50% duty cycle three-level (0 V, 13 V, and 14.5 V) waveform. Used as a digital trigger for an arbitrary waveform generator that drives the MOT gradient coils. 
    // It begins HIGH and, at cnt = cntMAX/2, goes LOW.
    else begin
        if (cntPN)   begin
            if (cnt < (cntMAX>>1)) cI <= 16'd23666; // 13 V
            else                   cI <= 16'b0;
        end
        else begin
            if (cnt < (cntMAX>>1)) cI <= 16'd26396; // 14.5 V
            else                   cI <= 16'b0;
        end
    end
    // Change cntPN once every cntMAX FM cycles to alternately select the two high levels.
    if (cnt==0 && swTrig) begin
        cntPN  <= !cntPN;
        swTrig <= 1'b0;
    end
    // Set swTrig to 1, allowing cntPN to be changed after cnt resets to 0.
    else if (cnt == DtHLD) begin
        cntPN  <= cntPN;
        swTrig <= 1'b1;
    end
    else begin
        cntPN  <= cntPN;
        swTrig <= swTrig;
    end
end

// Average demodulated outputs during the FM.
reg signed [DEMSC+15:0] DEMC_temp, DEMS_temp, DEMCsc, DEMSsc;
always @(posedge clk) begin
    if (FMstate==DITH) begin
        if(trig_out) begin
            DEMC_temp <= DEMC_temp + demod_out; // Integrate over all FM cycles.
            DEMS_temp <= DEMS_temp + demodQ_out;
        end
    end
    else if (FMstate==RMP1) begin         
        DEMCsc <= (DEMC_temp <<< DEMCBS); // Scale to assign data to 16 MSB's
        DEMSsc <= (DEMS_temp <<< DEMSBS);  
        demodCOS <= DEMCsc[DEMSC+15:DEMSC]; // Take 16 MSB's
        demodSIN <= DEMSsc[DEMSC+15:DEMSC];
    end
    else begin
        DEMC_temp <= 'd0;
        DEMS_temp <= 'd0; 
        DEMCsc    <= 'd0;
        DEMSsc    <= 'd0;  
    end
end 
////// END OF INTEGRATION AFTER RAMP AND DEMODULATED OUTPUTS \\\\\\

// Take the difference of differences of the integrated signal (with a sign flip for successive 'FM' waveforms),
// for example, to give the fluorescence of cold atoms.
reg signed [0:1][15:0] IntDiffMem = 0;
reg signed [15:0] IntDiffDiff = 0;
reg signed [15:0] IntDiffDiff_temp;
reg recBit;
always @(posedge clk) begin
    // The if block below stores the gated integrator output when 'FM' begins its sinusoidal segment, i.e., cnt = 0 and recBit = 1.
    // recBit is set to 0 when the data is written to IntDiffMem, and set to 1 after the sinusoidal phase of 'FM' ends, so the gated integrator output can be recorded when the FM begins. 
    // The integrated data is stored in a 2 element array IntDiffMem; the previous cycle's data is in the [0] element, and the most recent data in [1].
    // The old and new are subtracted and written to IntDiffDiff to give a difference of background-free integrated data, e.g., for both signs of the MOT magnetic field gradient, trapping and anti-trapping fields.
    if (FMstate==DITH) begin
        if (recBit) begin
            if (cntPN) IntDiffMem[0:1] <= {IntDiffMem[0], IntDiffOut   };
            else       IntDiffMem[0:1] <= {IntDiffOut   , IntDiffMem[1]};
            IntDiffDiff  <= IntDiffMem[0]-IntDiffMem[1];
            recBit <= 1'b0; // Record gated integrator output when the FM begins 
        end
    end
    else recBit <= 1'b1; // Set recBit to 1 allowing data to be recorded once cnt resets to 0.
    IntDiffDiffOut <= IntDiffDiff;
end
////// END OF STORE AND READ OUT MOST RECENT RESULTS \\\\\\

// Make memtrig, a signal that goes HIGH for 1 clk cycle at the beginning of 'FM'. 
// Used to by fmMOTmem.sv to record the latest data sample to Block RAM.
reg RB;
always @(posedge clk) begin
    if (recBit) begin
        RB <= 1;
        memtrig <= memtrig;
    end
    else begin
        if (RB == 1) begin
            RB <= 0;
            memtrig <= 1;
        end
        else begin
            RB <= RB;
            memtrig <= 0;
        end
    end
end

endmodule