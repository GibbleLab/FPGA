`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module to assign Cd oven temperature servo parameters depending on the FM_MOT state (from a display button).
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////


module Cd_Oven_PARAM_ASSIGN#(FILTER_IO_SIZE = 18)(
    input wire clk,
    input wire [1:0] mode,
    // Input parameters (99, mode=1)
    input wire               PI_on_Cd_1, is_neg_Cd_1,
    input wire signed [9:0]  NFI_Cd_1, NI_Cd_1, NFP_Cd_1, NP_Cd_1, ND_Cd_1, NFD_Cd_1, NGD_Cd_1,
    input wire signed [FILTER_IO_SIZE-1:0] sp_Cd_1, offset_Cd_1, SHDN_Cd_1,
    // Input parameters (119, mode=2)
    input wire               PI_on_Cd_2, is_neg_Cd_2,
    input wire signed [9:0]  NFI_Cd_2, NI_Cd_2, NFP_Cd_2, NP_Cd_2, ND_Cd_2, NFD_Cd_2, NGD_Cd_2,
    input wire signed [FILTER_IO_SIZE-1:0] sp_Cd_2, offset_Cd_2, SHDN_Cd_2,
    // Input parameters (Cd, mode=3)
    input wire               PI_on_Cd_3, is_neg_Cd_3,
    input wire signed [9:0]  NFI_Cd_3, NI_Cd_3, NFP_Cd_3, NP_Cd_3, ND_Cd_3, NFD_Cd_3, NGD_Cd_3,
    input wire signed [FILTER_IO_SIZE-1:0] sp_Cd_3, offset_Cd_3, SHDN_Cd_3,
    // Output parameters
    output reg               PI_on_Cd, is_neg_Cd,
    output reg signed [9:0]  NFI_Cd, NI_Cd, NFP_Cd, NP_Cd, ND_Cd, NFD_Cd, NGD_Cd,
    output reg signed [FILTER_IO_SIZE-1:0] sp_Cd, offset_Cd, SHDN_Cd
);

always @(posedge clk) begin
case (mode)
// OFF mode
0: begin
    sp_Cd     <= sp_Cd;
    offset_Cd <= offset_Cd;
    NFI_Cd    <= NFI_Cd;
    NI_Cd     <= NI_Cd;
    NFP_Cd    <= NFP_Cd;
    NP_Cd     <= NP_Cd;
    ND_Cd     <= ND_Cd;
    NFD_Cd    <= NFD_Cd;
    NGD_Cd    <= NGD_Cd;
    is_neg_Cd <= is_neg_Cd;
    PI_on_Cd  <= 0; // Turn off servo in off mode
    SHDN_Cd   <= SHDN_Cd;    
end
// 99C mode
1: begin
    sp_Cd     <= sp_Cd_1;
    offset_Cd <= offset_Cd_1;
    NFI_Cd    <= NFI_Cd_1;
    NI_Cd     <= NI_Cd_1;
    NFP_Cd    <= NFP_Cd_1;
    NP_Cd     <= NP_Cd_1;
    ND_Cd     <= ND_Cd_1;
    NFD_Cd    <= NFD_Cd_1;
    NGD_Cd    <= NGD_Cd_1;
    is_neg_Cd <= is_neg_Cd_1;
    PI_on_Cd  <= PI_on_Cd_1;
    SHDN_Cd   <= SHDN_Cd_1; 
end
// 119C mode 
2: begin
    sp_Cd     <= sp_Cd_2;
    offset_Cd <= offset_Cd_2;
    NFI_Cd    <= NFI_Cd_2;
    NI_Cd     <= NI_Cd_2;
    NFP_Cd    <= NFP_Cd_2;
    NP_Cd     <= NP_Cd_2;
    ND_Cd     <= ND_Cd_2;
    NFD_Cd    <= NFD_Cd_2;
    NGD_Cd    <= NGD_Cd_2;
    is_neg_Cd <= is_neg_Cd_2;
    PI_on_Cd  <= PI_on_Cd_2;
    SHDN_Cd   <= SHDN_Cd_2;   
end
// Programmable temperature mode 
3: begin
    sp_Cd     <= sp_Cd_3;
    offset_Cd <= offset_Cd_3;
    NFI_Cd    <= NFI_Cd_3;
    NI_Cd     <= NI_Cd_3;
    NFP_Cd    <= NFP_Cd_3;
    NP_Cd     <= NP_Cd_3;
    ND_Cd     <= ND_Cd_3;
    NFD_Cd    <= NFD_Cd_3;
    NGD_Cd    <= NGD_Cd_3;
    is_neg_Cd <= is_neg_Cd_3;
    PI_on_Cd  <= PI_on_Cd_3;
    SHDN_Cd   <= SHDN_Cd_3; 
end
endcase

end

endmodule