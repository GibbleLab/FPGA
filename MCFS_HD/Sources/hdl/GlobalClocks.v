`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module to generate several synchronized clocks, based on the MMCME2_BASE primitive template in the Xilinx HDL Libraries Guide (UG953), version 2012.2.
// 
// Daniel Schussheim
//////////////////////////////////////////////////////////////////////////////////

module GlobalClocks#(
    parameter real 
        div0 = 8, div1 = 4, div2 = 2, div3 = 4, div4 = 4,      div5 = 8, div6 = 80,
        phs0 = 0, phs1 = 0, phs2 = 0, phs3 = 0, phs4 = 123.75, phs5 = 0, phs6 = 0,
    parameter mmcmloc = "MMCME2_ADV_X1Y2"
)(
    input  wire clk_in,
    input  wire rst,
    output wire clk0, clk1, clk2, clk3, clk4, clk5, clk6
);

wire clk0B, clk1B, clk2B, clk3B, clkFB, clkFBB, LOCKED;
// MMCME2_BASE: Base Mixed Mode Clock Manager
// 7 Series
// Xilinx HDL Libraries Guide, version 2012.2
(* LOC = mmcmloc *)
MMCME2_BASE #(
    .BANDWIDTH("OPTIMIZED"), // Jitter programming (OPTIMIZED, HIGH, LOW)
    .CLKFBOUT_MULT_F(8.0), // Multiplicative factor (2.000-64.000) for all CLKOUTn's frequencies.
    .CLKFBOUT_PHASE(0.0), // Phase offset in degrees of CLKFB (-360.000-360.000).
    .CLKIN1_PERIOD(10.0), // Input clock period in ns with ps resolution (e.g. 15.625 is 64 MHz).
    .CLKOUT0_DIVIDE_F(div0), // Frequency divisor for CLKOUTn (1.000-128.000). fn = 800 MHz/divn
    .CLKOUT1_DIVIDE(div1), // div1-div6 must be integers
    .CLKOUT2_DIVIDE(div2),
    .CLKOUT3_DIVIDE(div3),
    .CLKOUT4_DIVIDE(div4),
    .CLKOUT5_DIVIDE(div5),
    .CLKOUT6_DIVIDE(div6),
    // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT6_DUTY_CYCLE(0.5),
    // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
    .CLKOUT0_PHASE(phs0),
    .CLKOUT1_PHASE(phs1),
    .CLKOUT2_PHASE(phs2),
    .CLKOUT3_PHASE(phs3),
    .CLKOUT4_PHASE(phs4),
    .CLKOUT5_PHASE(phs5),
    .CLKOUT6_PHASE(phs6),
    .CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
    .DIVCLK_DIVIDE(1), // Overall frequency divisor (1-106) for all generated clocks.
    .REF_JITTER1(0.0), // Reference input jitter in the unit interval (0.000-0.999).
    .STARTUP_WAIT("FALSE")) // If STARTUP_WAIT is TRUE, DONE goes HIGH after the MMCM locks. DONE is unused in our design, which resets 100 mu s after the FPGA is programmed.
MMCME2_BASE_inst (
    // Clock Outputs: 1-bit (each) output: User configurable clock outputs
    .CLKOUT0(clk0),     // 1-bit output: CLKOUT0
    .CLKOUT0B(clk0B),   // 1-bit output: Inverted CLKOUT0
    .CLKOUT1(clk1),     // 1-bit output: CLKOUT1
    .CLKOUT1B(clk1B),   // 1-bit output: Inverted CLKOUT1
    .CLKOUT2(clk2),     // 1-bit output: CLKOUT2
    .CLKOUT2B(clk2B),   // 1-bit output: Inverted CLKOUT2
    .CLKOUT3(clk3),     // 1-bit output: CLKOUT3
    .CLKOUT3B(clk3B),   // 1-bit output: Inverted CLKOUT3
    .CLKOUT4(clk4),     // 1-bit output: CLKOUT4
    .CLKOUT5(clk5),     // 1-bit output: CLKOUT5
    .CLKOUT6(clk6),     // 1-bit output: CLKOUT6
    // Feedback Clocks: 1-bit (each) output: Clock feedback ports
    .CLKFBOUT(clkFB),   // 1-bit output: Feedback clock
    .CLKFBOUTB(clkFBB), // 1-bit output: Inverted CLKFBOUT
    // Status Ports: 1-bit (each) output: MMCM status ports
    .LOCKED(LOCKED),    // 1-bit output: LOCK
    // Clock Inputs: 1-bit (each) input: Clock input
    .CLKIN1(clk_in),    // 1-bit input: Clock
    // Control Ports: 1-bit (each) input: MMCM control ports
    .PWRDWN(1'b0),      // 1-bit input: Power-down
    .RST(1'b0),         // 1-bit input: Reset
    // Feedback Clocks: 1-bit (each) input: Clock feedback ports
    .CLKFBIN(clkFB));   // 1-bit input: Feedback clock
// End of MMCME2_BASE_inst instantiation

endmodule