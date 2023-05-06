`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module assigns parameters for the FM_MOT states, selected from the touchscreen.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////


module FM_MOT_PARAM_ASSIGN#(parameter N_B = 16)(
    input wire clk,
    input wire [1:0] mode,
    // Input parameters (OFF, mode=0)
    input wire                  FMon_0,
    input wire        [N_B-1:0] FMdivFast_0, FMdivSlow_0, FMsc_0,
    input wire signed [N_B-1:0] FMmean_0,
    input wire        [N_B-1:0] dtD_0, dt1_0, dt2_0, dt3_0, dtUP_0, dtDOWN_0,
    input wire signed [23:0]    D1_0, D2_0, DUP_0, DDOWN_0,
    input wire signed [N_B-1:0] FMIntMax_0, dt4_0,
    input wire        [N_B-1:0] dt5_0, dt6_0,
    input wire signed [23:0]    D5_0, D6_0,
    input wire        [N_B-1:0] dt8_0, FMINTBS_0, FMDEMCBS_0, FMDEMSBS_0,
    input wire signed [N_B-1:0] cImin_0,
    input wire signed [23:0]    DcI_0,
    input wire        [3:0]     selFM0_0, selFM1_0, selFM2_0,
    // Input parameters (saturated absorption, mode=1)
    input wire                  FMon_1,
    input wire        [N_B-1:0] FMdivFast_1, FMdivSlow_1, FMsc_1,
    input wire signed [N_B-1:0] FMmean_1,
    input wire        [N_B-1:0] dtD_1, dt1_1, dt2_1, dt3_1, dtUP_1, dtDOWN_1,
    input wire signed [23:0]    D1_1, D2_1, DUP_1, DDOWN_1,
    input wire signed [N_B-1:0] FMIntMax_1, dt4_1,
    input wire        [N_B-1:0] dt5_1, dt6_1,
    input wire signed [23:0]    D5_1, D6_1,
    input wire        [N_B-1:0] dt8_1, FMINTBS_1, FMDEMCBS_1, FMDEMSBS_1,
    input wire signed [N_B-1:0] cImin_1,
    input wire signed [23:0]    DcI_1,
    input wire        [3:0]     selFM0_1, selFM1_1, selFM2_1,
    // Input parameters (326 FM MOT, mode=2)
    input wire                  FMon_2,
    input wire        [N_B-1:0] FMdivFast_2, FMdivSlow_2, FMsc_2,
    input wire signed [N_B-1:0] FMmean_2,
    input wire        [N_B-1:0] dtD_2, dt1_2, dt2_2, dt3_2, dtUP_2, dtDOWN_2,
    input wire signed [23:0]    D1_2, D2_2, DUP_2, DDOWN_2,
    input wire signed [N_B-1:0] FMIntMax_2, dt4_2,
    input wire        [N_B-1:0] dt5_2, dt6_2,
    input wire signed [23:0]    D5_2, D6_2,
    input wire        [N_B-1:0] dt8_2, FMINTBS_2, FMDEMCBS_2, FMDEMSBS_2,
    input wire signed [N_B-1:0] cImin_2,
    input wire signed [23:0]    DcI_2,
    input wire        [3:0]     selFM0_2, selFM1_2, selFM2_2,
    // Input parameters (361 MOT, mode=2)
    input wire                  FMon_3,
    input wire        [N_B-1:0] FMdivFast_3, FMdivSlow_3, FMsc_3,
    input wire signed [N_B-1:0] FMmean_3,
    input wire        [N_B-1:0] dtD_3, dt1_3, dt2_3, dt3_3, dtUP_3, dtDOWN_3,
    input wire signed [23:0]    D1_3, D2_3, DUP_3, DDOWN_3,
    input wire signed [N_B-1:0] FMIntMax_3, dt4_3,
    input wire        [N_B-1:0] dt5_3, dt6_3,
    input wire signed [23:0]    D5_3, D6_3,
    input wire        [N_B-1:0] dt8_3, FMINTBS_3, FMDEMCBS_3, FMDEMSBS_3,
    input wire signed [N_B-1:0] cImin_3,
    input wire signed [23:0]    DcI_3,
    input wire        [3:0]     selFM0_3, selFM1_3, selFM2_3,
    // Output parameters (to FM_MOT module)
    output reg                  FMon,
    output reg        [N_B-1:0] FMdivFast, FMdivSlow, FMsc,
    output reg signed [N_B-1:0] FMmean,
    output reg        [N_B-1:0] dtD, dt1, dt2, dt3, dtUP, dtDOWN,
    output reg signed [23:0]    D1, D2, DUP, DDOWN,
    output reg signed [N_B-1:0] FMIntMax, dt4,
    output reg        [N_B-1:0] dt5, dt6,
    output reg signed [23:0]    D5, D6,
    output reg        [N_B-1:0] dt8, FMINTBS, FMDEMCBS, FMDEMSBS,
    output reg signed [N_B-1:0] cImin,
    output reg signed [23:0]    DcI,
    output reg        [3:0]     selFM0, selFM1, selFM2
);

always @(posedge clk) begin
case (mode)
// OFF mode
0: begin
    FMdivFast <= FMdivFast_0;
    FMdivSlow <= FMdivSlow_0; 
    FMmean    <= FMmean_0;
    FMsc      <= FMsc_0;
    dtD       <= dtD_0;
    dt1       <= dt1_0;
    D1        <= D1_0;
    dt2       <= dt2_0;
    D2        <= D2_0;
    dt3       <= dt3_0;
    dtUP      <= dtUP_0;
    DUP       <= DUP_0;
    dtDOWN    <= dtDOWN_0;
    DDOWN     <= DDOWN_0;
    FMIntMax  <= FMIntMax_0;
    dt4       <= dt4_0;
    dt5       <= dt5_0;
    D5        <= D5_0; 
    dt6       <= dt6_0; 
    D6        <= D6_0; 
    dt8       <= dt8_0; 
    FMINTBS   <= FMINTBS_0; 
    FMDEMCBS  <= FMDEMCBS_0;
    FMDEMSBS  <= FMDEMSBS_0;
    cImin     <= cImin_0;
    DcI       <= DcI_0;
    FMon      <= FMon_0; 
    selFM0    <= selFM0_0; 
    selFM1    <= selFM1_0; 
    selFM2    <= selFM2_0; 
end
// Saturated absorption mode
1: begin
    FMdivFast <= FMdivFast_1;
    FMdivSlow <= FMdivSlow_1; 
    FMmean    <= FMmean_1;
    FMsc      <= FMsc_1;
    dtD       <= dtD_1;
    dt1       <= dt1_1;
    D1        <= D1_1;
    dt2       <= dt2_1;
    D2        <= D2_1;
    dt3       <= dt3_1;
    dtUP      <= dtUP_1;
    DUP       <= DUP_1;
    dtDOWN    <= dtDOWN_1;
    DDOWN     <= DDOWN_1;
    FMIntMax  <= FMIntMax_1;
    dt4       <= dt4_1;
    dt5       <= dt5_1;
    D5        <= D5_1; 
    dt6       <= dt6_1; 
    D6        <= D6_1; 
    dt8       <= dt8_1; 
    FMINTBS   <= FMINTBS_1; 
    FMDEMCBS  <= FMDEMCBS_1;
    FMDEMSBS  <= FMDEMSBS_1;
    cImin     <= cImin_1;
    DcI       <= DcI_1;
    FMon      <= FMon_1; 
    selFM0    <= selFM0_1; 
    selFM1    <= selFM1_1;
    selFM2    <= selFM2_1; 
end
// FM_MOT mode
2: begin
    FMdivFast <= FMdivFast_2;
    FMdivSlow <= FMdivSlow_2; 
    FMmean    <= FMmean_2;
    FMsc      <= FMsc_2;
    dtD       <= dtD_2;
    dt1       <= dt1_2;
    D1        <= D1_2;
    dt2       <= dt2_2;
    D2        <= D2_2;
    dt3       <= dt3_2;
    dtUP      <= dtUP_2;
    DUP       <= DUP_2;
    dtDOWN    <= dtDOWN_2;
    DDOWN     <= DDOWN_2;
    FMIntMax  <= FMIntMax_2;
    dt4       <= dt4_2;
    dt5       <= dt5_2;
    D5        <= D5_2; 
    dt6       <= dt6_2; 
    D6        <= D6_2; 
    dt8       <= dt8_2; 
    FMINTBS   <= FMINTBS_2; 
    FMDEMCBS  <= FMDEMCBS_2;
    FMDEMSBS  <= FMDEMSBS_2;
    cImin     <= cImin_2;
    DcI       <= DcI_2;
    FMon      <= FMon_2; 
    selFM0    <= selFM0_2; 
    selFM1    <= selFM1_2;
    selFM2    <= selFM2_2; 
end
// 361 MOT mode 
3: begin
    FMdivFast <= FMdivFast_3;
    FMdivSlow <= FMdivSlow_3; 
    FMmean    <= FMmean_3;
    FMsc      <= FMsc_3;
    dtD       <= dtD_3;
    dt1       <= dt1_3;
    D1        <= D1_3;
    dt2       <= dt2_3;
    D2        <= D2_3;
    dt3       <= dt3_3;
    dtUP      <= dtUP_3;
    DUP       <= DUP_3;
    dtDOWN    <= dtDOWN_3;
    DDOWN     <= DDOWN_3;
    FMIntMax  <= FMIntMax_3;
    dt4       <= dt4_3;
    dt5       <= dt5_3;
    D5        <= D5_3; 
    dt6       <= dt6_3; 
    D6        <= D6_3; 
    dt8       <= dt8_3; 
    FMINTBS   <= FMINTBS_3; 
    FMDEMCBS  <= FMDEMCBS_3;
    FMDEMSBS  <= FMDEMSBS_3;
    cImin     <= cImin_3;
    DcI       <= DcI_3;
    FMon      <= FMon_3; 
    selFM0    <= selFM0_3; 
    selFM1    <= selFM1_3;
    selFM2    <= selFM2_3; 
end
endcase

end

endmodule