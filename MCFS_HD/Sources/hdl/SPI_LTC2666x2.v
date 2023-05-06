`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// SPI module with no extra clock cycle delays.
// Drives 2 LTC2666 DAC's that share a common SDI by alternating CS.
//
// Adapted from NIST Digital Servo SPI.v.
//
// Daniel Schussheim
//////////////////////////////////////////////////////////////////////////////////


module SPI_LTC2666x2#(parameter N_B = 24)(
    input  wire           clk,
	input  wire           rst,
	input  wire	[N_B-1:0] data_in0, data_in1,
	output reg	[N_B-1:0] data_out2,
	output reg            ready, // goes HIGH after sending a data sample
	output reg            CS0, CS1,
	output wire           SCK,
	output reg            SDO,
	input  wire           SDI,
	output reg            state=0
);

// SCK should only be on when CS is low.
// Using BUFGCE to enable the SPI clock may have more timing margin.
assign SCK = !(CS0 && CS1) & clk;

// Bit counter
reg [11:0] counter_f;

reg [N_B-1:0] data_out;

// Send data samples and hold CS high for one cycle between samples. 
// This chip's SPI interface requires CS to be high for no less than one clock cycle.
always @(posedge clk) begin
    if (counter_f > 0) begin
        ready <= 0;
        // Set CS to chip0 or chip1
        if (state) begin
            CS0 <= 1'b1;
            CS1 <= 1'b0;
        end
        else begin
            CS0 <= 1'b0;
            CS1 <= 1'b1;
        end
        SDO <= data_out[N_B-1];
        data_out  <= {data_out[N_B-2:0],  SDI};
        data_out2 <= {data_out2[N_B-2:0], SDI};
        counter_f <= counter_f - 12'b1;
    end
    else begin
        ready <= 1;
        CS0   <= 1;
        CS1   <= 1;
        SDO   <= 1;
        // Load data for other chip
        if (state) data_out <= data_in0;
        else       data_out <= data_in1;
        counter_f <= N_B;
        state     <= !state; // change state to read other chip
    end
end

endmodule