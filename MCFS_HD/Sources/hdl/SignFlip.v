`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// Module to flip signs of slow inputs and outputs because their inverting 
// amplifiers produce a negative sign relative to the rest of the design.
//
// Daniel Schussheim and Kurt Gibble
///////////////////////////////////////////////////////////////////////////////

module SignFlip(
    input wire sADC_clk, sDAC_clk, 
	input wire signed [15:0]					
		s_in_0_int, s_in_1_int, s_in_2_int, s_in_3_int, s_in_4_int, s_in_5_int, s_in_6_int, s_in_7_int, s_in_8_int, s_in_9_int, s_in_10_int, s_in_11_int, s_in_12_int, s_in_13_int, s_in_14_int, s_in_15_int,	
		sout0_int,  sout1_int,  sout2_int,  sout3_int,  sout4_int,  sout5_int,  sout6_int,  sout7_int, sout8_int,  sout9_int,   sout10_int,  sout11_int,  sout12_int,  sout13_int,  sout14_int,  sout15_int,
	output reg signed [15:0]					
		s_in_0, s_in_1, s_in_2, s_in_3, s_in_4, s_in_5, s_in_6, s_in_7, s_in_8, s_in_9, s_in_10, s_in_11, s_in_12, s_in_13, s_in_14, s_in_15,
		sout0,  sout1,  sout2,  sout3,  sout4,  sout5,  sout6,  sout7,  sout8,  sout9,  sout10,  sout11,  sout12,  sout13,  sout14,  sout15
);
// Function that flips sign and offsets by 1, so the most negative 16-bit signed integer -32768 maps to the most positive, 32767.
function signed [15:0] sgnFlip;
    input signed [15:0] in;
    begin
        if (in < 0) sgnFlip = -(in+1);
        else        sgnFlip = -in-1;
    end
endfunction
// Flip signs with offset.
always @(posedge sADC_clk) begin 
    s_in_0  <= sgnFlip(s_in_0_int);
    s_in_1  <= sgnFlip(s_in_1_int);
    s_in_2  <= sgnFlip(s_in_2_int);
    s_in_3  <= sgnFlip(s_in_3_int);
    s_in_4  <= sgnFlip(s_in_4_int);
    s_in_5  <= sgnFlip(s_in_5_int);
    s_in_6  <= sgnFlip(s_in_6_int);
    s_in_7  <= sgnFlip(s_in_7_int);
    s_in_8  <= sgnFlip(s_in_8_int);
    s_in_9  <= sgnFlip(s_in_9_int);
    s_in_10 <= sgnFlip(s_in_10_int);
    s_in_11 <= sgnFlip(s_in_11_int);
    s_in_12 <= sgnFlip(s_in_12_int);
    s_in_13 <= sgnFlip(s_in_13_int);
    s_in_14 <= sgnFlip(s_in_14_int);
    s_in_15 <= sgnFlip(s_in_15_int);
end
always @(posedge sDAC_clk) begin 
	sout0  <= sgnFlip(sout0_int);
    sout1  <= sgnFlip(sout1_int);
    sout2  <= sgnFlip(sout2_int);
    sout3  <= sgnFlip(sout3_int);
    sout4  <= sgnFlip(sout4_int);
    sout5  <= sgnFlip(sout5_int);
    sout6  <= sgnFlip(sout6_int);
    sout7  <= sgnFlip(sout7_int);
    sout8  <= sgnFlip(sout8_int);
    sout9  <= sgnFlip(sout9_int);
    sout10 <= sgnFlip(sout10_int);
    sout11 <= sgnFlip(sout11_int);
    sout12 <= sgnFlip(sout12_int);
    sout13 <= sgnFlip(sout13_int);
    sout14 <= sgnFlip(sout14_int);
    sout15 <= sgnFlip(sout15_int);
end

endmodule