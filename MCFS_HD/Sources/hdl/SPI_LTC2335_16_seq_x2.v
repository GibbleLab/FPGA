`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module to read 2 LTC2335-16 ADC's over their SPI.
//
// Adapted from NIST Digital Servo SPI.v.
//
// Daniel Schussheim
//////////////////////////////////////////////////////////////////////////////////

module SPI_LTC2335_16_seq_x2#(parameter N_R = 128, N_B = 24, N_wait = 1)(
// N_R = # bits of reset output, currently unused
// N_B = # bits to capture from ADC, 
// N_wait = # clk cycles to wait after CS goes low before reading data
    input  wire clk,      // Clock to run state machine
                data_in_clk, // Delayed clock to capture input data from ADC
	            rst,      // Triggers state machine to reprogram sequencer on ADC
	            trigger,  // Trigger state machine to capture data
	input  wire	[N_B-1:0] data_in,  // Data to send to ADC each read cycle
	output wire	[N_B-1:0] data_out0,
	                      data_out1, // Data captured from ADC
	output reg  ready,       // high when data transfer complete
	            SCK_en,      // Enables ODDR buffer for output clock to ADC
	output wire data_clk_en, // Delayed SCK_en to capture input data from ADC
	output reg  CS0,
	            CS1,         // Chip select, active low
	output wire SCK,         // Debug signal to check if the output clock is enabled at the correct time.
	output reg  SDO,         // Output to chip
	input  wire SDI0, 
	            SDI1,         // Input from chip
    output wire [2:0] state_out
);
// SCK should be constant, HIGH or LOW, when CS is HIGH.
assign SCK = SCK_en & clk;

// State machine definitions
localparam IDLE = 3'h0;
localparam TRIG	= 3'h1;
localparam RST  = 3'h2;
localparam SPI1	= 3'h3;
localparam SPI2	= 3'h4;
localparam SPI3 = 3'h5;

// State machine - combinatorial part
function [2:0] next_state;
    input [2:0]  state;
    input [11:0] counter;
    input [3:0]  CS_counter;

    begin
        case (state)
            IDLE: 
                next_state = IDLE;
            TRIG:
                next_state = SPI1;
            RST :
                next_state = SPI1;
            SPI1:
                if ( CS_counter < (N_wait-4'd1) )
                    next_state = SPI1;
                else
                    next_state = SPI2;
            SPI2:
                if (counter == 12'b1)
                    next_state = SPI3;
                else
                    next_state = SPI2;            
            SPI3:   
                next_state = IDLE;
            default:
                    next_state = IDLE;
        endcase
        
    end
endfunction
// End State
reg [2:0]  state_f;
reg [11:0] counter_f;
reg [3:0] cnt_CS_wait = 4'd1;
reg [N_B-1:0] data_0, data_1;

// Enable output clock
always @(posedge clk) begin
    case (state_f)
        // IDLE, do nothing until trigger or reset
        IDLE: SCK_en <= 1'b0;
        // TRIG, begin new transfer
        TRIG: SCK_en <= 1'b0;
        // RST, reprogram sequencer
        RST:  SCK_en <= 1'b0;
        SPI1: SCK_en <= 1'b0;
        SPI2: SCK_en <= 1'b1;
        SPI3: SCK_en <= 1'b0;
    endcase
end

localparam [2:0] SS = 3'b111;
// Clock out data and CS
always @(posedge clk) begin // To adjust the phase of the ADC clock, use data_out_clk instead of clk. 
	if (rst) begin
//        state_f   <= RST; // Uncomment this line and comment out the line below if the channel sequencer is programmed after a reset
        state_f   <= TRIG;
        ready <= 1'b0;
    end
    // Trigger begins new transfer
    else if (trigger) begin
        state_f   <= TRIG;
        ready <= 1'b0;
    end
    else begin
    state_f <= next_state(state_f, counter_f, cnt_CS_wait);
        // Transfer data after a trigger, or stay in idle state
        case (state_f)
            // IDLE, do nothing until trigger or reset
            IDLE: begin
                ready <= 1'b1;
                CS0   <= 1'b1;
                CS1   <= 1'b1;
                SDO   <= 1'b0;
            end
            // TRIG, begin new transfer
            TRIG: begin
                ready     <= 1'b0;
                counter_f <= N_B;
                CS0       <= 1'b1;
                CS1       <= 1'b1;
                SDO       <= 1'b0;
                data_0    <= data_in;
            end
            // RST, program sequencer
            RST: begin
                ready     <= 1'b0;
                counter_f <= N_R;
                CS0       <= 1'b1;
                CS1       <= 1'b1;
                SDO       <= 1'b0;
            end
            SPI1: begin
                ready       <= 1'b0;
                CS0         <= 1'b0;
                CS1         <= 1'b0;
                SDO         <= 1'b0;
                cnt_CS_wait <= cnt_CS_wait + 4'd1;
            end
            SPI2: begin
                ready       <= 1'b0;
                CS0         <= 1'b0;
                CS1         <= 1'b0;
                // SDO         <= 0; // Uncomment this line and comment out the line below if the channel sequencer is programmed after a reset. SDO is only used to program the sequencer after a reset.
                SDO         <= data_0[N_B-1];
                data_0      <= {data_0[N_B-2:0], SDI0};
                counter_f   <= counter_f - 12'b1;
                cnt_CS_wait <= 4'd0;
            end
            SPI3: begin
                ready <= 1'b0;
                CS0   <= 1'b1;
                CS1   <= 1'b1;
                SDO   <= 1'b0;
            end
        endcase
    end
end


// The conversion data output from the ADC is delayed relative to the ADC's input clock, clk.
// The ADC data capture below is synchronous with data_in_clk, which has an adjustable phase relative to clk.
// To read the data the synchronized data read enables data_clk_en1 and data_clk_en2 are HIGH for 24 data_in_clk cycles. 
// data_clk_en2 is delayed by one data_in_clk cycle relative to data_clk_en1 and the appropriate one is selected for timing closure.
reg data_clk_en1, data_clk_en2;
always @(posedge data_in_clk) begin
    if      (rst)     data_clk_en1 <= 1'b0;
    else if (trigger) data_clk_en1 <= 1'b0;
    else begin
        case (state_f)
            IDLE: data_clk_en1 <= 1'b0;
            TRIG: data_clk_en1 <= 1'b0;
            RST : data_clk_en1 <= 1'b0;
            SPI1: data_clk_en1 <= 1'b0;
            SPI2: data_clk_en1 <= 1'b1;
            SPI3: data_clk_en1 <= 1'b0;
        endcase
    end
    data_clk_en2 <= data_clk_en1; // Delay data_clk_en2 by 1 cycle.
end
assign data_clk_en = data_clk_en1; // Select data_clk_en1, comment to select data_clk_en2
// assign data_clk_en = data_clk_en2; // Uncomment to select data_clk_en2 

reg [23:0] data_out_r0, data_out_r1, data_out_f0, data_out_f1;
localparam [4:0] bitcount_max = 5'd24;
reg [4:0] bitcount = bitcount_max;
reg data_rec_bit;
always @(posedge data_in_clk) begin
    if (data_clk_en && (bitcount == bitcount_max) ) begin
        data_out_r0 <= {data_out_r0[22:0], SDI0};
        data_out_r1 <= {data_out_r1[22:0], SDI1};
        bitcount <= bitcount - 5'd1;
        data_rec_bit <= 1'b0;
    end
    else if ( (bitcount < bitcount_max) && (bitcount > 5'd0) ) begin
        data_out_r0 <= {data_out_r0[22:0], SDI0};
        data_out_r1 <= {data_out_r1[22:0], SDI1};
        bitcount <= bitcount - 5'd1;
        data_rec_bit <= 1'b0;
    end
    else begin
        data_out_f0 <= data_out_r0;
        data_out_f1 <= data_out_r1;
        bitcount <= bitcount_max;
        data_rec_bit <= 1'b1;
    end
end

assign data_out0 = data_out_f0;
assign data_out1 = data_out_f1;

assign state_out = state_f;

endmodule