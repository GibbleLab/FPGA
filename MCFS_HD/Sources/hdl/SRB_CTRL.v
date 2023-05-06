`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module to read and write the serial shift-register B output lines.
// There are 16-bits out, latched by STROBE.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////


module SRB_CTRL(
    // Clocks
    input  wire CLK_IN,
    output wire CLK_SR,
    // OUTPUTS FOR EACH SHIFT-REGISTER BIT
    input  wire 
        out0,  out1,  out2,  out3,  out4,  out5,  out6,  out7, 
        out8,  out9,  out10, out11, out12, out13, out14, out15,
    // SERIAL OUTPUT AND STROBE TO SHIFT-REGISTER
    output wire SR_OUT,
    output wire STROBE_OUT
);

reg SR_OUT_INT, STROBE_INT;
wire CLK_SR_int;

//*********** OUTPUTS ***********\\
// OBUF: Single-ended Output Buffer
// OBUF #(.DRIVE(12), .IOSTANDARD("DEFAULT"), .SLEW("SLOW")) OBUF_inst (.O(O), .I(I));
(* DONT_TOUCH = "TRUE" *)OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW"))OBUF_SR_OUT(SR_OUT, SR_OUT_INT);
(* DONT_TOUCH = "TRUE" *)OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW"))OBUF_STROBE(STROBE_OUT, STROBE_INT);
// CLOCK FORWARDING TO OUTPUT
(* DONT_TOUCH = "TRUE" *)
ODDR #(.DDR_CLK_EDGE("OPPOSITE_EDGE"),.INIT(1'b0),.SRTYPE("SYNC")) 
ODDR_SRclk(CLK_SR_int, CLK_IN, STROBE_INT, 1'b0, 1'b1, 1'b0, 1'b0);
(* DONT_TOUCH = "TRUE" *)OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW"))OBUF_SCK(CLK_SR , CLK_SR_int);

reg [4:0] bitcount = 16;
always @(posedge CLK_IN) begin
    //******** OUTPUT FROM FPGA TO SHIFT-REGISTER ********\\
    case (bitcount)
        default: SR_OUT_INT <= 1'b0;
        0:  SR_OUT_INT  <= out0;
        1:  SR_OUT_INT  <= out1;
        2:  SR_OUT_INT  <= out2;
        3:  SR_OUT_INT  <= out3;
        4:  SR_OUT_INT  <= out4;
        5:  SR_OUT_INT  <= out5;
        6:  SR_OUT_INT  <= out6;
        7:  SR_OUT_INT  <= out7;
        8:  SR_OUT_INT  <= out8;
        9:  SR_OUT_INT  <= out9;
        10: SR_OUT_INT  <= out10;
        11: SR_OUT_INT  <= out11;
        12: SR_OUT_INT  <= out12;
        13: SR_OUT_INT  <= out13;
        14: SR_OUT_INT  <= out14;
        15: SR_OUT_INT  <= out15;
    endcase
    // Count and reset bitcount
    if (bitcount == 16) bitcount <= 0;
    else                bitcount <= bitcount + 1;  
    // Strobe for one clock cycle when bitcount gets to one
    if (bitcount == 16) STROBE_INT <= 0;
    else                STROBE_INT <= 1;
end

endmodule