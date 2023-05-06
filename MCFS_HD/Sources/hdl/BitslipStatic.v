`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Performs static bit-slip with ISERDESE2 primitive.
// EN enables the BitslipDynamic module to perform bit-slips until the fast ADC frame deserializes as 8'hf0
// BS enables a ISERDESE2 primitive to perform N bit-slips. These are the required bit-slips for the channels when frames are 8'hf0, and are applied before the frames are correctly deserialized. 
//
// Daniel Schussheim
//////////////////////////////////////////////////////////////////////////////////

module BitslipStatic#(parameter start_delay = 10000, parameter [2:0] N = 3'b000)(
    input  wire       clk,
    output reg        EN = 1'b0,
    output reg        BS);

// Number of clk cycles to wait between successive bitslips.  
localparam wait_time = 5;
// After the FPGA is programmed bit-slips are disabled until this counter reaches start_delay. This counter does not reset until the FPGA is reprogrammed.

reg [31:0] counter = 32'b0;

// count is the number of bit-slips after the startup delay
reg [2:0] count = N;
// step delays successive bit-slips by 5 clk cycles.
reg [3:0] step = 4'b0;

always @(posedge clk) begin
    if (counter < start_delay)
        counter <= counter + 32'b1;
        
    if (counter == start_delay) begin
        if (count > 0) begin
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
                count <= count - 3'b001;
            end
        end
        else begin
            BS <= 1'b0;
            step <= 4'b0;
            EN <= 1'b1;
        end
    end
    else begin
        BS <= 1'b0;
        step <= 4'b0;
        EN <= 1'b0;
    end
end

endmodule