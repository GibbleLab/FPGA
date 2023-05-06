`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module to read and write the serial shift-register I/O lines.
// There are 24-bits in/out, latched by STROBE, some of which are used by display.v.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////


module SR_CTRL(
    // Clocks, as for display module
    input  wire RST,
    input  wire CLK_IN,
    output wire CLK_SR,
    // Controls for display module
    output reg [5:0] cnt_rst,
    output reg [4:0] bitcount,
    // active/data_active are inputs from the display that indicate if the display is initializing, 
    // or operating normally.     
    // Below only (active OR data_active) is used, which seems to always be TRUE, so these inputs can likely be eliminated without loss.   
    input  wire active,
    input  wire data_active,
    // OUTPUTS FOR EACH SHIFT-REGISTER BIT
    input  wire out0,  out1,  out2,  out3,  out4,  out5,  out6,  out7, 
                out8,  out9,  out10, out11, out12, out13, out14, out15,
                out16, out17, out18, out19, out20, out21, out22, out23,
    // INPUTS FROM SHIFT-REGISTER BITS
    output reg in0,  in1,  in2,  in3,  in4,  in5,  in6,  in7, 
               in8,  in9,  in10, in11, in12, in13, in14, in15,
               in16, in17, in18, in19, in20, in21, in22, in23,
    // SERIAL OUTPUT TO SHIFT-REGISTER
    output wire SR_OUT,
    output wire STROBE_OUT,
    // SERIAL INPUT FROM SHIFT-REGISTER
    input  wire SR_IN_INT
);

reg SR_OUT_INT, STROBE_INT;
wire SR_IN, CLK_SR_int;

//*********** INPUTS ***********\\
// IBUF: Single-ended Input Buffer
// IBUF #(.IBUF_LOW_PWR("TRUE"), .IOSTANDARD("DEFAULT")) IBUF_inst (.O(buffer output), .I(buffer input));
// High-power mode (has shorter buffer delay)
(* DONT_TOUCH = "TRUE" *)IBUF#(.IBUF_LOW_PWR("FALSE"), .IOSTANDARD("LVCMOS33"))IBUF_SR_IN(SR_IN, SR_IN_INT);

//*********** OUTPUTS ***********\\
// OBUF: Single-ended Output Buffer
// OBUF #(.DRIVE(12), .IOSTANDARD("DEFAULT"), .SLEW("SLOW")) OBUF_inst (.O(O), .I(I));
// Default drive strength 12, slow slew rate, could also try high.
(* DONT_TOUCH = "TRUE" *)OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW"))OBUF_SR_OUT(SR_OUT, SR_OUT_INT);
(* DONT_TOUCH = "TRUE" *)OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW"))OBUF_STROBE(STROBE_OUT, STROBE_INT);
// CLOCK FORWARDING TO OUTPUT
ODDR #(.DDR_CLK_EDGE("OPPOSITE_EDGE"),.INIT(1'b0),.SRTYPE("SYNC")) 
ODDR_SRclk(CLK_SR_int, CLK_IN, STROBE_INT, 1'b0, 1'b1, 1'b0, 1'b0);
(* DONT_TOUCH = "TRUE" *)OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS33"), .SLEW("SLOW"))OBUF_SCK(CLK_SR , CLK_SR_int);

always @(posedge CLK_IN) begin
    
//******** OUTPUT FROM FPGA TO SHIFT-REGISTER ********\\
case (bitcount)
    default: SR_OUT_INT <= 1'b0; 
    0:  SR_OUT_INT  <= out0; // Clock to display
    1:  SR_OUT_INT  <= out1; // Output data to display
    2:  SR_OUT_INT  <= out2; // Power-down for display
    3:  SR_OUT_INT  <= out3; // Chip-select 0 for display 
    4:  SR_OUT_INT  <= out4; // Chip-select 1 for display
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
    16: SR_OUT_INT  <= out16;
    17: SR_OUT_INT  <= out17;
    18: SR_OUT_INT  <= out18;
    19: SR_OUT_INT  <= out19;
    20: SR_OUT_INT  <= out20;
    21: SR_OUT_INT  <= out21;
    22: SR_OUT_INT  <= out22;
    23: SR_OUT_INT  <= out23;
endcase
    
//******** INPUT TOP FPGA FROM SHIFT-REGISTER ********\\
case (bitcount)
    1:  in0  <= SR_IN; // INPUT DATA FROM DISPLAY
    2:  in1  <= SR_IN; // INTERRUPT FROM DISPLAY
    3:  in2  <= SR_IN;
    4:  in3  <= SR_IN;
    5:  in4  <= SR_IN;
    6:  in5  <= SR_IN;
    7:  in6  <= SR_IN;
    8:  in7  <= SR_IN;
    9:  in8  <= SR_IN;
    10:  in9  <= SR_IN;
    11: in10 <= SR_IN;
    12: in11 <= SR_IN;
    13: in12 <= SR_IN;
    14: in13 <= SR_IN;
    15: in14 <= SR_IN;
    16: in15 <= SR_IN;
    17: in16 <= SR_IN;
    18: in17 <= SR_IN;
    19: in18 <= SR_IN;
    20: in19 <= SR_IN;
    21: in20 <= SR_IN;
    22: in21 <= SR_IN;
    23: in22 <= SR_IN;
    24: in23 <= SR_IN;
endcase
    
    //******** RESET AND ENABLES ********\\
    // Control reset counter
    if (RST == 1) begin
        if (cnt_rst < 5) cnt_rst <= cnt_rst + 1;
        else             cnt_rst <= 4;
    end
    else                 cnt_rst <= 0;
    
    // Set STROBE high for one clock cycle after reset 
    if (cnt_rst == 1) begin
        bitcount <= 0;
        STROBE_INT <= 1;
    end
    
    // It seems (active OR data_active) is always TRUE, so these can likely be eliminated without loss. 
    if ((cnt_rst != 1)&&(active || data_active)) begin
        // Count and reset bitcount
        if (bitcount == 24) bitcount <= 0;
        else                bitcount <= bitcount + 1;  
        // Strobe for one clock cycle when bitcount gets to one
        if (bitcount == 24) STROBE_INT <= 0;
        else                STROBE_INT <= 1;
    end
end

endmodule