`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module to generate low clock frequencies, e.g., 1 MHz or 125 kHz.
// Uses the BUFGCE primitive.
// 
// Daniel Schussheim
//////////////////////////////////////////////////////////////////////////////////

module gated_clk#(parameter [9:0] cntMAX= 100)(
    input  wire clk_in, 
    output wire clk_out
);
    
reg [9:0] cnt = 0;
reg CE;
// BUFGCE: Global Clock Buffer with Clock Enable
//         7 Series
// Xilinx HDL Language Template, version 2019.1
BUFGCE BUFGCE_inst (   
        .O(clk_out), // 1-bit output: Clock output   
        .CE(CE),     // 1-bit input: Clock enable input for I0   
        .I(clk_in)   // 1-bit input: Primary clock
);// End of BUFGCE_inst instantiation
    
always @(posedge clk_in) begin
    // Counter resets when it reaches cntMAX
    if (cnt == cntMAX-1) cnt <= 0;
    else                 cnt <= cnt + 1;
    // CE high only when 
    if (cnt == 0) CE <= 1;
    else          CE <= 0; 
end
    
endmodule