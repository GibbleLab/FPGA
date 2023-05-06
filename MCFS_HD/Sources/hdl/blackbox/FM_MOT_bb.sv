`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Blackbox module for FM_MOT for OOC synthesis and implementation.
//////////////////////////////////////////////////////////////////////////////////
module FM_MOT#(parameter SCALING = 24, DEMSC = 24)(
    /// Control and input signal \\\
    input  wire               clk,
    input  wire        [ 1:0] MOT_state,
    input  wire               on,
    input  wire signed [15:0] s_in,    // Input signal
    /// FM parameters \\\
    input  wire        [15:0] divFast,  // Dividers for the frequency of the sinusoidal segment of the 'FM' waveform
    input  wire        [15:0] divSlow,
    input  wire        [15:0] dithMean, // Mean of the FM
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

endmodule