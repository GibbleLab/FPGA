`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 1-time global reset at startup.
// This module can also be used to reset at other times using the EN input to reset the counter.
// 
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module reset(
    input   wire    clk_in, EN,
    output  wire    rst
);

parameter	max = 30'd20000; 		//20000 cycles (200 mu s)
parameter   rst_on = 30'd10000;   // turn reset on after 10000 cycles (100 mu s)
    
reg [29:0] counter = 30'b0;
reg        rst_in = 1'b0;
    
always @(posedge clk_in) begin
    if (EN) begin
        if (counter < rst_on)    begin
            counter <= counter + 30'b1;
            rst_in <= 1'b0;
        end
        else if ( (counter >= rst_on) && (counter < max-30'b1) ) begin
            counter <= counter + 30'b1;
            rst_in <= 1'b1;
        end
        else    begin
            rst_in <= 1'b0; // don't reset counter, so there is a single reset just after programming the FPGA
        end
    end
    else begin
        counter <= 0;
        rst_in <= 0;
    end
end
    
assign rst = rst_in;
    
endmodule