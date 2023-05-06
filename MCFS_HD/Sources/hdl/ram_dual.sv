`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Implements dual RAM to store data with write-enable (we) and output on clk edges.
// 
// Daniel Schussheim
//////////////////////////////////////////////////////////////////////////////////
module ram_dual#(parameter MEMSIZE = 1024, SIGSIZE = 16, ADDRWIDTH = 10)(
    input wire clk, we,
    input wire [ADDRWIDTH-1:0] addr_in, addr_out,
    input wire [SIGSIZE-1:0] in,
    output reg [SIGSIZE-1:0] out
);
// Declaration of memory array.
(* ram_style = "block" *)reg [SIGSIZE-1:0] mem [0:MEMSIZE-1];
// Initialize all entries to 0.
integer k;
initial
    begin
    for (k = 0; k < MEMSIZE - 1; k = k + 1)
    begin
        mem[k] = 16'h0000;
    end
end
// Write data when we is HIGH, and output data every clock cycle.
reg [ADDRWIDTH-1:0] addr_out_r;
always @(posedge clk) begin
    if (we) mem[addr_in] <= in;
    out <= mem[addr_out_r];
    addr_out_r <= addr_out;
end
endmodule