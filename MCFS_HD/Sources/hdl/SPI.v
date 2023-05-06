`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// SPI module from NIST, original code by David Leibrandt 
// This module programs the fast ADC's.
//
// Parameter notes
// Transfer size <= 4096
// SDO is clocked into the receiving device on the rising edge of SCK
//
// Daniel Schussheim
///////////////////////////////////////////////////////////////////////////////

module SPI#(parameter TRANSFER_SIZE = 16)
   (input wire clk_in,
	input wire rst_in,
	input  wire trigger_in,
	input  wire	[TRANSFER_SIZE-1:0] data_in,
	output reg	[TRANSFER_SIZE-1:0] data_out,
	output reg ready_out,
	output reg spi_scs_out,
	output reg spi_sdo_out,
	input  wire spi_sdi_in);

// State machine definitions
localparam IDLE = 3'h0;
localparam TRIG	= 3'h1;
localparam SPI1	= 3'h2;
localparam SPI2	= 3'h3;
localparam SPI3	= 3'h4;

// State
// The next line makes synthesis happy
// synthesis attribute INIT of state_f is "R"
reg [2:0]  state_f;
reg [11:0] counter_f;

// State machine - combinatorial part
function [2:0] next_state;
	input [2:0]  state;
	input [11:0] counter;
	
	begin
		case (state)
			IDLE: 
				next_state = IDLE;
			TRIG:
					next_state = SPI1;
			SPI1:
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

// State machine - sequential part
always @(posedge clk_in) begin
	if (rst_in) begin
		state_f   <= IDLE;
		counter_f <= 12'b0;
		data_out  <= 8'b0;
		ready_out <= 1'b0;
	end
	else if (trigger_in) begin
		state_f   <= TRIG;
		data_out  <= data_in;
		ready_out <= 1'b0;
	end
	else begin
		state_f <= next_state(state_f, counter_f);
		case (state_f)
			IDLE: begin
				ready_out   <= 1'b1;
				spi_scs_out <= 1'b1;
				spi_sdo_out <= 1'b1;
			end
			TRIG: begin
				counter_f <= TRANSFER_SIZE;
			end
			SPI1: begin
				spi_scs_out <= 1'b0;
			end
			SPI2: begin
				spi_sdo_out <= data_out[TRANSFER_SIZE-1];
				data_out <= {data_out[TRANSFER_SIZE-2:0], spi_sdi_in};
				counter_f <= counter_f - 12'b1;
			end
			SPI3: begin
				spi_scs_out <= 1'b1;
				spi_sdo_out <= 1'b1;
			end
			default: begin
				spi_scs_out <= 1'b1;
				spi_sdo_out <= 1'b1;
			end
		endcase
	end
end

endmodule