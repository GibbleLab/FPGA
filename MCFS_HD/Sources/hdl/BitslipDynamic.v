`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module to perform bitslips until a training pattern is obtained. Pair with ISERDESE2 primitive.
//
// Daniel Schussheim
//////////////////////////////////////////////////////////////////////////////////

module BitslipDynamic#(parameter [7:0] training_pattern = 11110000)
    (
    input  wire       clk,
    input  wire       EN,
    input  wire [7:0] test_in,
    output wire       test_out,
    output reg        BS
    );
// Number of clk cycles to wait between successive bitslips.
localparam wait_time = 5;
// Counters to start bitslips.
reg [3:0] step = 4'b0;
// Logic signal is high if bitshift is incorrect.
assign test_out = (test_in != training_pattern);
//  Logic to perform BITSLIP. It adds a 5 clk cycle delay between successive bit-slips.
always @(posedge clk) begin
    if (EN) begin  
        if (test_out) begin
            if (step == 4'b0) begin
                BS <= 1'b1;
                step <= step + 4'b1;
            end
            else if (step != 4'b0 && step < wait_time) begin
                BS <= 1'b0;
                step <= step + 4'b1;
            end
            else begin
                BS <= 1'b0;
                step <= 4'b0;
            end
        end
        else begin
            BS <= 1'b0;
            step <= 4'b0;
        end
    end
    else begin
        BS <= 1'b0;
        step <= 4'b0000;
    end
end

endmodule