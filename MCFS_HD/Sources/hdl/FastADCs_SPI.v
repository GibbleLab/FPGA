`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module that implements an SPI for the Fast ADC's. The conversion data transfer and clocks are managed by FastADCsDDR.v.
//
// This module initializes the fast ADC's conversion data format (2's complement), transfer mode (transfer conversion data over 2 LVDS pairs), and an optional training pattern for debugging with the SPI bus. It also controls the sleep mode.
//
// The CS's for all ADC's are connected to a single logic signal so all are programmed simultaneously and identically; the baseboard has a CS for each ADC to allow independent programming.
//
// The module delays sending the ADC sleep mode command for 30s after ADCOFF goes HIGH, to avoid unintended shutdowns. 
// Wake-up commands are sent with no delay when ADCOFF goes LOW.
// 
// Based on NIST digital servo LTC2195 SPI firmware.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////   
    
module FastADCs_SPI(
    input  wire clk,
    input  wire rst,
    input  wire ADCOFF,
    // SPI wires
    output wire CS0_out,
    output wire CS1_out,
    output wire CS2_out,
    output wire CS3_out,
    output wire CS4_out,
    output wire SCK_out,
    output wire SDI_out,
    input  wire SDO_in
);

wire SDO, CS, CS0, CS1, CS2, CS3, CS4, SCK, SDI;

assign CS0 = CS;
assign CS1 = CS;
assign CS2 = CS;
assign CS3 = CS;
assign CS4 = CS;

////////// Input and output buffers \\\\\\\\\\

//*********** INPUTS ***********\\
// IBUF: Single-ended Input Buffer
IBUF#(.IBUF_LOW_PWR("FALSE"), .IOSTANDARD("LVCMOS25"))IBUF_SDO(SDO, SDO_in);

//*********** OUTPUTS ***********\\
// OBUF: Single-ended Output Buffer
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS25"), .SLEW("SLOW"))OBUF_CS0(CS0_out, CS0);
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS25"), .SLEW("SLOW"))OBUF_CS1(CS1_out, CS1);
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS25"), .SLEW("SLOW"))OBUF_CD2(CS2_out, CS2);
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS25"), .SLEW("SLOW"))OBUF_CS3(CS3_out, CS3);
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS25"), .SLEW("SLOW"))OBUF_CS4(CS4_out, CS4);
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS25"), .SLEW("SLOW"))OBUF_SDI(SDI_out, SDI);
// Output clock.
// We use the recommended clock forwarding architecture: ODDR + OBUF primitives. 
// CScond is an enable signal for the ODDR, only outputting a clock signal when at least 1 CS goes low.
wire CScond1;
assign CScond1 = !(CS0&CS1&CS2&CS3&CS4);
reg CScond = 0;
reg [7:0] cnt;
parameter transfer_size = 16;
always @(posedge clk) begin
    if (CScond1 && cnt < transfer_size) begin
        CScond <= 1;
        cnt <= cnt + 1;
    end
    else if (cnt == transfer_size) begin
        CScond <= 0;
        cnt <= cnt + 1;
    end
    else begin
        CScond <= 0;
        cnt <= 0;
    end
end
wire SCK_int;
ODDR #(.DDR_CLK_EDGE("OPPOSITE_EDGE"), .INIT(1'b0), .SRTYPE("SYNC"))
ODDR_SCK(.Q(SCK_int), .C(clk), .CE(CScond), .D1(1'b0), .D2(1'b1), .R(1'b0), .S(1'b0));
OBUF#(.DRIVE(12), .IOSTANDARD("LVCMOS25"), .SLEW("SLOW"))OBUF_SCK(SCK_out, SCK_int);

///////////////////////////////////////////////////////////////////////////////
// SPI state machine
reg            spi_trigger;
reg  [15:0]    spi_data;
wire           spi_ready;
SPI #(
  .TRANSFER_SIZE(transfer_size)
)
LTC2194_SPI_inst(
  .clk_in(clk),
  .rst_in(rst),
  .trigger_in(spi_trigger),
  .data_in(spi_data),
  .data_out(),
  .ready_out(spi_ready),
  .spi_scs_out(CS),
  .spi_sdo_out(SDI),
  .spi_sdi_in(SDO)
);

///////////////////////////////////////////////////////////////////////////////
// State machine that initializes and controls the sleep-mode.
// State machine definitions
localparam IDLE  = 8'h0;
localparam RST1  = 8'h1;
localparam RST2A = 8'h2;
localparam RST2B = 8'h3;
localparam RST2C = 8'h4;
localparam RST3A = 8'h5;
localparam RST3B = 8'h6;
localparam RST3C = 8'h7;
localparam RST4A = 8'h8;
localparam RST4B = 8'h9;
localparam RST4C = 8'hA;
localparam RST5A = 8'hB;
localparam RST5B = 8'hC;
localparam RST5C = 8'hD;
localparam RST6A = 8'hE;
localparam RST6B = 8'hF;
localparam RST6C = 8'h10;
localparam OFFA  = 8'h11;
localparam OFFB  = 8'h12;
localparam OFFC  = 8'h13;
localparam OFFD  = 8'h14;
localparam ONA   = 8'h15;
localparam ONB   = 8'h16;
localparam ONC   = 8'h17;
// State
reg [7:0]  state_f;
reg [7:0]  counter_f;   // Reset counter.
reg [31:0] counter_off; // Counter to delay setting ADC's into sleep mode.
parameter [31:0] counter_off_max = 32'd3_000_000_000; // 30 seconds
// State machine - combinatorial part
function [7:0] next_state;
    input [7:0]  state;
    input [7:0]  counter;
    input [31:0] counter_OFF;
    input        rdone;
    input        AOFF;
    input        off_c;
    input        ready;
  
    begin
        case (state)
            IDLE: 
                if (rdone) begin
                     if (AOFF) begin
                        if (off_c) next_state = IDLE;
                        else       next_state = OFFA;
                     end
                     else begin
                        if (off_c) next_state = ONA;
                        else       next_state = IDLE;
                     end
                end
                else next_state = IDLE;
            RST1:
                if (counter == 8'b1)
                     next_state = RST2A;
                else next_state = RST1;
            RST2A:
                if (ready) next_state = RST2B;
                else       next_state = RST2A;
            RST2B: next_state = RST2C;
            RST2C: next_state = RST3A;
            RST3A:
                if (ready) next_state = RST3B;
                else       next_state = RST3A;
            RST3B: next_state = RST3C;
            RST3C: next_state = RST4A;
            RST4A:
                if (ready) next_state = RST4B;
                else       next_state = RST4A;
            RST4B: next_state = RST4C;
            RST4C: next_state = RST5A;
            RST5A:
                if (ready) next_state = RST5B;
                else       next_state = RST5A;
            RST5B: next_state = RST5C;
            RST5C: next_state = RST6A;
            RST6A:
                if (ready) next_state = RST6B;
                else       next_state = RST6A;
            RST6B: next_state = RST6C;
            RST6C: next_state = IDLE;
            OFFA:
                if (!AOFF) next_state = IDLE;
                else begin
                    if (counter_OFF == 30'b1)
                         next_state = OFFB;
                    else next_state = OFFA;
                end
            OFFB:
                if (ready) next_state = OFFC;
                else       next_state = OFFB;
            OFFC: next_state = OFFD;
            OFFD: next_state = IDLE;
            ONA:
                if (ready) next_state = ONB;
                else       next_state = ONA;
            ONB: next_state = ONC;
            ONC: next_state = IDLE;
            default: next_state = IDLE;
      endcase
  end
endfunction

// State machine - sequential part

// Test pattern on (1) or off (0). Used for calibrating fast ADC's.
wire TPon;
assign TPon = 0;
parameter [7:0] 
    TPm = 8'b1011_0011, // MSB's of test pattern
    TPl = 8'b0001_0111; // LSB's of test pattern
wire TC;
assign TC = 1'b1; // 1 for 2's complement output format, 0 for offset binary.
// rst_done goes HIGH when the reset data transfers are complete.
// off_cond is set HIGH when a sleep command sequence is initiated so that the command is sent only once.
reg rst_done, off_cond; 
always @(posedge clk) begin
    if (rst) begin
        state_f <= RST1;
        counter_f <= 8'hFF; // 255+1 clock cycle delay to reset ADC
        counter_off <= counter_off_max;
        spi_trigger <= 1'b0;
        rst_done <= 0;
        off_cond <= 0;
    end
    else begin
    state_f <= next_state(state_f, counter_f, counter_off, rst_done, ADCOFF, off_cond, spi_ready);
    case (state_f)
        IDLE: begin
            spi_trigger <= 1'b0;
            counter_off <= counter_off_max;
        end
        // reset the ADC after 256 clock cycles
        RST1: counter_f <= counter_f - 8'b1;
        // The 16-bit SPI words are a read-write (R/W) bit, followed by the 7-bit register address, and
        // then the 8 bits of register data. 
        // If R/W is low, the register data is written to the register address.
        // Reset all programming registers to 0.
        RST2A: spi_data <= {1'b0, 7'h0, 8'h80}; // b'1000_0000 resets all registers
        RST2B: spi_trigger <= 1'b1;
        RST2C: spi_trigger <= 1'b0;
        // Set the ADC's data format to 2's complement.
        RST3A: spi_data <= {1'b0, 7'h1, 2'b00, TC, 5'b00000};
        RST3B: spi_trigger <= 1'b1;
        RST3C: spi_trigger <= 1'b0;
        // Turn the test pattern on or off and set the ADC's to transfer conversion data in 2-lane mode. 
        // A lane is an LVDS pair. In 2-lane mode one lane sends the even bits and the other the odd bits. 
        RST4A: spi_data <= {1'b0, 7'h2, 5'b00000, TPon, 2'b00};
        RST4B: spi_trigger <= 1'b1;
        RST4C: spi_trigger <= 1'b0;
        // Set the test pattern bits 15:8
        RST5A: spi_data <= {1'b0, 7'h3, TPm};
        RST5B: spi_trigger <= 1'b1;
        RST5C: spi_trigger <= 1'b0;
        // Set the test pattern bits 7:0.
        RST6A: spi_data <= {1'b0, 7'h4, TPl};
        RST6B: spi_trigger <= 1'b1;
        RST6C: begin
          spi_trigger <= 1'b0;
          rst_done <= 1;
        end
        // Program ADC's to go into sleep mode 30 seconds after ADCOFF goes HIGH, to avoid unintended shutdowns. 
        OFFA: counter_off <= counter_off - 32'd1;
        OFFB: spi_data <= {1'b0, 7'h1, 2'b00, TC, 1'b1 /*This bit 1 for sleep*/, 4'b0000};
        OFFC: begin
            spi_trigger <= 1'b1;
            off_cond <= 1;
        end
        OFFD: spi_trigger <= 1'b0;
        // The wake-up command is sent with no delay after ADCOFF goes LOW.
        ONA: spi_data <= {1'b0, 7'h1, 2'b00, TC, 1'b0 /*This bit 1 for sleep*/, 4'b0000};
        ONB: begin
            spi_trigger <= 1'b1;
            off_cond <= 0;
        end
        ONC: spi_trigger <= 1'b0;
        endcase
    end
end

endmodule