`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module to store the difference and the difference of difference signals from the FM-MOT module.
// 
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////
module fmMOTmem#(parameter MEMSIZE = 1024, SIGSIZE = 16, ADDRWIDTH = 10)(
    input  wire clk, we,
    input  wire [SIGSIZE-1:0] in0, in1,
    output wire [SIGSIZE-1:0] out0, out1,
    output wire [31:0] ao
);
// Current memory address.
reg [ADDRWIDTH-1:0] addr_in = 0;
// Counter to output stored data to fast outputs or ILA debug probes.
reg [ADDRWIDTH-1:0] addr_out = 0;
always @(posedge clk) begin
    // Store new sample when an experiment cycle is complete, when the trigger from the FM_MOT module goes high.
    if (we) begin
        if (addr_in < (MEMSIZE-1)) addr_in <= addr_in+1;
        else                       addr_in <= 0;
    end
    else addr_in <= addr_in;
    // Output stored samples at clk rate.
    if (addr_out < (MEMSIZE-1)) addr_out <= addr_out + 1;
    else                        addr_out <= 0;
end
// RAM modules.
ram_dual#(MEMSIZE, SIGSIZE, ADDRWIDTH)ram_dual_0(clk, we, addr_in, addr_out, in0, out0);
ram_dual#(MEMSIZE, SIGSIZE, ADDRWIDTH)ram_dual_1(clk, we, addr_in, addr_out, in1, out1);
// Output current read address.
assign ao = addr_out;
endmodule