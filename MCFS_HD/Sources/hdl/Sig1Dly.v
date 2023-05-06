`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// After trig goes low, the module sets a logical signal, out to high 
// after cntMax cycles of clk until the trig goes high.
//
// Daniel Schussheim
//////////////////////////////////////////////////////////////////////////////////

module Sig1Dly(
    input wire clk, trig,
    input wire [25:0] cntMAX,
    output reg out
);

reg [25:0] cnt = 'b0;
always @(posedge clk) begin
    if (trig) begin
        cnt <= 'b0;
        out <= 1'b0;
    end
    else begin
        if (cnt < cntMAX) begin
            cnt <= cnt + 'b1;
            out <= 1'b0;
        end
        else begin
            cnt <= cnt;
            out <= 1'b1;
        end
    end
end

endmodule