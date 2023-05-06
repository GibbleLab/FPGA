`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module to read 2 LTC2335-16 multiplexed SPI ADC's.
// They can read 1 to 8 channels with an arbitrary sequence. 
// Both ADC's have the same sequence because they are programmed simultaneously over a shared SDI wire on the baseboard.
// By alternating their CS's, which are separate wires on the baseboard (here connected to the same logic signal), they could be programmed independently.
// Alternatively, each ADC channel sequencer could be programmed after a rst.
//
// Daniel Schussheim
//////////////////////////////////////////////////////////////////////////////////


module LTC2335_16#(parameter [6:0] N = 100, N_CNV = 5, N_CH = 24)(// N = Number of clock cycles between conversions (1 us minimum)
    // Clocks and reset                                           // N_CNV = number of clock cycles to hold CNV high (40-60 ns)
    input  wire clk,
    input  wire data_in_clk, // adjustable phase relative to clk
    input  wire rst,
    // SPI IO wires
    input  wire SDO0, SDO1,   // Converter output data
    input  wire BUSY,         // Transitions low to high at start of conversion, stays high until end of conversion
    input  wire SCKO0, SCKO1, // Unused output clocks from ADC's, which are synchronous with their SDO's
    output reg  CNV,      // A rising edge triggers a conversion
    output wire CS0, CS1, // Chip selects
    output wire SCKI,     // ADC clock input
    output wire SDI,      // ADC input data
    // Channel sequence
    input  wire [2:0] SEQ [0:N_CH-1],
    // Input signals
    output  wire [15:0] s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15,
    // Signals for debugging this module
    output  wire        SCK_en,
    output  wire [23:0] data_out0, data_out1,
    output  wire        ready_out,
                        CNVtog_out,
    output wire [2:0]   state_out
);
    
// SPI module control signals: trigger initiates a conversion, ready goes HIGH when the SPI is idle.
wire spi_trigger, spi_ready;
// Collect conversion data for all channels
reg [15:0] data0 [0:7];
reg [15:0] data1 [0:7];
// Assign outputs
assign s0  = data0[0];
assign s1  = data0[1];
assign s2  = data0[2];
assign s3  = data0[3];
assign s4  = data0[4];
assign s5  = data0[5];
assign s6  = data0[6];
assign s7  = data0[7];
assign s8  = data1[0];
assign s9  = data1[1];
assign s10 = data1[2];
assign s11 = data1[3];
assign s12 = data1[4];
assign s13 = data1[5];
assign s14 = data1[6];
assign s15 = data1[7];
wire [2:0] CH_IN0, CH_IN1;
assign CH_IN0 = data_out0[5:3];
assign CH_IN1 = data_out1[5:3];
reg [31:0] CHcnt = 0;
reg [23:0] data_in;

reg [7:0] CNVcnt = 8'd0; // Counts N cycles between successive conversions.
reg rst_trig; // HIGH for 256 clk cycles when this module is reset 

always @(posedge clk) begin
    if (CNVcnt == 0) begin
        data0[CH_IN0] <= data_out0[23:8]; // record the conversion data for the selected channel of ADC0
        data1[CH_IN1] <= data_out1[23:8]; // record the conversion data for the selected channel of ADC1
        // New output data. The 2 MSB's must be 10 to be considered a valid word by the ADC's, 
        // the next 3 bits are the channel to sample on the next conversion cycle,
        // the next 3 bits specify the range (+/- 10V for this baseboard) and format (2's complement), 
        // and the 16 LSB's are 0 and not used by the ADC's.
        data_in <= {2'b10,SEQ[CHcnt],3'b111,16'h00};
        if (CHcnt < N_CH-1) CHcnt <= CHcnt+1; // Next channel in SEQ
        else                CHcnt <= 0;
    end
    else begin
        data0[CH_IN0] <= data0[CH_IN0];
        data1[CH_IN1] <= data1[CH_IN1];
        data_in       <=  data_in;
        CHcnt         <= CHcnt;
    end
end

// This loop controls the CNV output. There are N clk cycles between conversions; CNV is HIGH for N_CNV clk cycles and LOW otherwise.
always @(posedge clk) begin
    if (rst) begin
        rst_trig <= 1'b1;
        CNVcnt<= 8'd0;
        CNV <= 1'b0;
    end
    else if (rst_trig && (CNVcnt < 8'd255)) begin
        rst_trig <= 1'b1;
        CNVcnt<= CNVcnt + 8'd1;
        CNV <= 1'b0;
    end
    else if (rst_trig && (CNVcnt == 8'd255) ) begin
        rst_trig <= 1'b0;
        CNVcnt<= 8'd0;
        CNV <= 1'b0;
    end
    else begin
        // Count number of cycles between conversions (N)
        if ( CNVcnt < (N-1) ) CNVcnt <= CNVcnt + 7'd1;
        else                  CNVcnt <= 8'd0;
        // Keep CNV high for 160 ns
        if (CNVcnt < N_CNV) CNV <= 1'b1;
        else                CNV <= 1'b0;
    end
end

// CS_cnt_trig is used below to ensure that the SPI submodule is triggered only once per conversion cycle.
// Triggering the next SPI transfer before CNV would initiate another conversion cycle.
reg CS_tog, CS_cnt_trig;
reg [3:0] CS_cnt = 4'd0;
localparam [3:0] CS_cnt_max = 4'd1; // Number of data transfers per conversion cycle
always @(posedge clk) begin
    CS_tog <= CS0;
    if (CNV) CS_cnt <= 'd0;
    else if (!CNV && !CS0 && CS_tog && CS_cnt < CS_cnt_max)
             CS_cnt <= CS_cnt + 'd1;
    else     CS_cnt <= CS_cnt;
    
    if (CS_cnt == CS_cnt_max) CS_cnt_trig <= 1'b0;
    else                      CS_cnt_trig <= 1'b1;
        
end

// SPI controller
// Trigger data transfer when conversion is over (not BUSY) 
// and old transfer is finished.
assign spi_trigger = !BUSY && spi_ready && CS_cnt_trig;
wire data_clk_en;
SPI_LTC2335_16_seq_x2#(128, 24, 1)
LTC2335_16_SPI_inst(
    clk, data_in_clk, rst, spi_trigger, 
    data_in, data_out0, data_out1, 
    spi_ready, SCK_en, data_clk_en, 
    CS0, CS1, SCKI, SDI, SDO0, SDO1,
    state_out
);

assign ready_out = spi_ready;
assign CNVtog_out = data_clk_en;

endmodule