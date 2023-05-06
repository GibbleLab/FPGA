`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module to make a 4-bit sequence to average a variable duty cycle output. 
// This sequence flips the MSB every cycle and the LSB at the lowest frequency. 
// It averages to 16 times higher precision.
// 
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////


module FastAVG4(
    input wire clk, on, 
    input [31:0] cnt_max,
    output reg [3:0] out
);

reg [31:0] cnta = 0;
reg [3:0] cntb = 0;
always @(posedge clk) begin
    if (on) begin
        case (cntb)
            0:  out <= 4'b1111; // 15
            1:  out <= 4'b0001; // 1
            2:  out <= 4'b1101; // 13
            3:  out <= 4'b0011; // 3
            4:  out <= 4'b1011; // 11
            5:  out <= 4'b0101; // 5
            6:  out <= 4'b1001; // 9
            7:  out <= 4'b0111; // 7
            8:  out <= 4'b1000; // 8
            9:  out <= 4'b0110; // 6
            10: out <= 4'b1010; // 10
            11: out <= 4'b0100; // 4
            12: out <= 4'b1100; // 12
            13: out <= 4'b0010; // 2
            14: out <= 4'b1110; // 14
            15: out <= 4'b0000; // 0
        endcase
        if (cnta == cnt_max-1) begin
            cnta <= 0;
            cntb <= cntb + 1;
        end
        else begin
            cnta <= cnta + 1;
            cntb <= cntb;
        end
    end
    else begin
        cnta <= 0;
        cntb <= 0;
        out <= 4'b0000;
    end
end
    
endmodule