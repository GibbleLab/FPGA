`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module instantiates firmware for 7 MAX5785, 200 MSPS DAC's, including clocks and data buffers.
// Each channel updates at 100 MSPS.
//
// Daniel Schussheim
//////////////////////////////////////////////////////////////////////////////////
module FastDACs(
    input wire clk_in, clk_out_in, 
    input wire signed [15:0] 
        s_in0, s_in1, s_in2, s_in3, s_in4, s_in5,
        s_in6, s_in7, s_in8, s_in9, s_in10, s_in11, s_in12, s_in13,
    output wire fDACclkB_out, fDACclkC_out,
    output wire 
        fDAC0_sel, fDAC1_sel, fDAC2_sel,
        fDAC3_sel, fDAC4_sel, fDAC5_sel, fDAC6_sel,
    output wire signed [15:0] 
    fDAC0_out, fDAC1_out, fDAC2_out,
    fDAC3_out, fDAC4_out, fDAC5_out, fDAC6_out
);  

wire clk, clk_out;
(* LOC = "BUFGCTRL_X0Y6"*)BUFG BUFG_clk (.O(clk), .I(clk_in));
(* LOC = "BUFGCTRL_X0Y7"*)BUFG BUFG_clk_out (.O(clk_out), .I(clk_out_in));

// Signal declarations
wire fDACclk, fDACclkDum1, fDACclkDum2, fDACclkDum3, fDACclkDum4, fDACclkDum5, fDACclkDum6;
wire fDAC0_sel_int, fDAC1_sel_int, fDAC2_sel_int,
     fDAC3_sel_int, fDAC4_sel_int, fDAC5_sel_int, fDAC6_sel_int;
wire signed [15:0] 
    fDAC0_int, fDAC1_int, fDAC2_int,
    fDAC3_int, fDAC4_int, fDAC5_int, fDAC6_int;

////////// Input and output buffers \\\\\\\\\\
// _sel outputs
// fDAC0
(* DONT_TOUCH = "TRUE" *)
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST")) 
OBUF_sel0(.O(fDAC0_sel), .I(fDAC0_sel_int));
// fDAC1
(* DONT_TOUCH = "TRUE" *)
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST")) 
OBUF_sel1(.O(fDAC1_sel), .I(fDAC1_sel_int));
// fDAC2
(* DONT_TOUCH = "TRUE" *)
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST")) 
OBUF_sel2(.O(fDAC2_sel), .I(fDAC2_sel_int));
// fDAC3
(* DONT_TOUCH = "TRUE" *)
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST"))
OBUF_sel3(.O(fDAC3_sel), .I(fDAC3_sel_int));
// fDAC4
(* DONT_TOUCH = "TRUE" *)
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST")) 
OBUF_sel4(.O(fDAC4_sel), .I(fDAC4_sel_int));
// fDAC5
(* DONT_TOUCH = "TRUE" *)
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST"))
OBUF_sel5(.O(fDAC5_sel), .I(fDAC5_sel_int));
// fDAC6
(* DONT_TOUCH = "TRUE" *)
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST"))
OBUF_sel6(.O(fDAC6_sel), .I(fDAC6_sel_int));

genvar i;
// Data pins
generate
for (i = 0; i < 16 ; i = i + 1) begin: pins
    // fDAC0
    (* DONT_TOUCH = "TRUE" *)
    OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST")) 
    OBUF_inst0(.O(fDAC0_out[i]), .I(fDAC0_int[i]));
    // fDAC1
    (* DONT_TOUCH = "TRUE" *)
    OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST")) 
    OBUF_inst1(.O(fDAC1_out[i]), .I(fDAC1_int[i]));
    // fDAC2
    (* DONT_TOUCH = "TRUE" *)
    OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST")) 
    OBUF_inst2(.O(fDAC2_out[i]), .I(fDAC2_int[i]));
    // fDAC3
    (* DONT_TOUCH = "TRUE" *)
    OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST")) 
    OBUF_inst3(.O(fDAC3_out[i]), .I(fDAC3_int[i]));
    // fDAC4
    (* DONT_TOUCH = "TRUE" *)
    OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST")) 
    OBUF_inst4(.O(fDAC4_out[i]), .I(fDAC4_int[i]));
    // fDAC5
    (* DONT_TOUCH = "TRUE" *)
    OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST")) 
    OBUF_inst5(.O(fDAC5_out[i]), .I(fDAC5_int[i]));
    // fDAC6
    (* DONT_TOUCH = "TRUE" *)
    OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST")) 
    OBUF_inst6(.O(fDAC6_out[i]), .I(fDAC6_int[i]));
end
endgenerate
// Output clock
wire fDACclkB_int, fDACclkC_int;
// fDACclkB
(* DONT_TOUCH = "TRUE" *)
ODDR #(.DDR_CLK_EDGE("OPPOSITE_EDGE"), .INIT(1'b0), .SRTYPE("SYNC")) 
ODDR_fDACclkB(.Q(fDACclkB_int), .C(clk_out), .CE(1'b1), .D1(1'b1), .D2(1'b0),.R(1'b0), .S(1'b0));
(* DONT_TOUCH = "TRUE" *)
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST")) 
OBUF_clkB(.O(fDACclkB_out), .I(fDACclkB_int));
// fDACclkC
(* DONT_TOUCH = "TRUE" *)
ODDR #(.DDR_CLK_EDGE("OPPOSITE_EDGE"), .INIT(1'b0), .SRTYPE("SYNC")) 
ODDR_fDACclkC(.Q(fDACclkC_int), .C(clk_out), .CE(1'b1), .D1(1'b1), .D2(1'b0), .R(1'b0), .S(1'b0));
(* DONT_TOUCH = "TRUE" *)
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("FAST")) 
OBUF_clkC(.O(fDACclkC_out), .I(fDACclkC_int));
////////// 7 instances of the MAX5875 firmware module \\\\\\\\\\
MAX5875 FAST_DAC_0(
    .clk_in(clk), 
    .s_in0(s_in0), 
    .s_in1(s_in1),  
    .clk_out(fDACclk), 
    .sel(fDAC0_sel_int), 
    .s_out(fDAC0_int)
);
MAX5875 FAST_DAC_1(
    .clk_in(clk), 
    .s_in0(s_in2), 
    .s_in1(s_in3),  
    .clk_out(fDACclkDum1), 
    .sel(fDAC1_sel_int), 
    .s_out(fDAC1_int)
);
MAX5875 FAST_DAC_2(
    .clk_in(clk), 
    .s_in0(s_in4), 
    .s_in1(s_in5),  
    .clk_out(fDACclkDum2), 
    .sel(fDAC2_sel_int), 
    .s_out(fDAC2_int)
);
MAX5875 FAST_DAC_3(
    .clk_in(clk), 
    .s_in0(s_in6), 
    .s_in1(s_in7),  
    .clk_out(fDACclkDum3), 
    .sel(fDAC3_sel_int), 
    .s_out(fDAC3_int)
);
MAX5875 FAST_DAC_4(
    .clk_in(clk), 
    .s_in0(s_in8), 
    .s_in1(s_in9),  
    .clk_out(fDACclkDum4), 
    .sel(fDAC4_sel_int), 
    .s_out(fDAC4_int)
);
MAX5875 FAST_DAC_5(
    .clk_in(clk), 
    .s_in0(s_in10), 
    .s_in1(s_in11),  
    .clk_out(fDACclkDum5), 
    .sel(fDAC5_sel_int), 
    .s_out(fDAC5_int)
);
MAX5875 FAST_DAC_6(
    .clk_in(clk), 
    .s_in0(s_in12), 
    .s_in1(s_in13),  
    .clk_out(fDACclkDum6), 
    .sel(fDAC6_sel_int), 
    .s_out(fDAC6_int)
);

endmodule