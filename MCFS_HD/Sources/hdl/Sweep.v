`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Sweep module modified from NIST Digital Servo, by David Leibrandt
// 6/30/11
// Generates a triangle wave sweep.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module Sweep#(
	parameter SIGNAL_OUT_SIZE = 16, resetmode = "max" // reset to maxval in "max" mode, 0 otherwise.
)(
    input   wire								clk,
	input   wire						   		on,
	input   wire                                hold,
	input   wire signed	[15:0]					minval,
	input	wire signed	[15:0]					maxval,
	input	wire		[31:0]					stepsize,
	output  wire                                state_out,
    output  reg  signed	[SIGNAL_OUT_SIZE-1:0]	signal_out
);

// State machine definitions
localparam  GOINGUP   = 1'b0;
localparam  GOINGDOWN = 1'b1;

// State
reg					state_f;
reg signed	[33:0]	current_val_f = 34'd0, next_val_f = 34'd0;

// State machine
always @(posedge clk) begin
	if (on && !hold) begin
		if (state_f == GOINGUP)
			next_val_f <= next_val_f + stepsize;
		else
			next_val_f <= next_val_f - stepsize;
		
		if (next_val_f > $signed({maxval[15], maxval[15], maxval, 16'b0})) begin
			current_val_f <= {maxval[15], maxval[15], maxval, 16'b0};
			state_f <= GOINGDOWN;
		end else	if (next_val_f < $signed({minval[15], minval[15], minval, 16'b0})) begin
			current_val_f <= {minval[15], minval[15], minval, 16'b0};
			state_f <= GOINGUP;
		end else
			current_val_f <= next_val_f;
	end 
	else if (on && hold) begin
	    current_val_f <= current_val_f;
	end 
	else begin
        if (resetmode == "max") begin // Start sweep at maximum, negative slope
            current_val_f <= maxval <<< SIGNAL_OUT_SIZE;
            next_val_f    <= maxval <<< SIGNAL_OUT_SIZE;
            state_f <= GOINGDOWN;
        end
        else begin
            current_val_f <= 34'b0; // start at 0, positive slope
            next_val_f <= 34'b0;
            state_f <= GOINGUP;
        end
	end
	signal_out <= current_val_f[33:32-SIGNAL_OUT_SIZE];
end

assign state_out = state_f;

endmodule