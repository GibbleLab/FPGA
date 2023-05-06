`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module to increment or decrement gains.
// The mode input indicates the gain or cutoff frequency that is being changed.
// in_x is the "number of clicks", up or down of button x.
// The module outputs, inc_x, are 01, 00 or 10 for increments of +1, 0 or -1 of a gain or cutoff frequency.
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////
module gain_inc_trig#(parameter N_B = 5)(
    input  wire           clk,
    input  wire [2:0]     mode, // LOCK, overall, fH, fL, P, I
    input  wire signed [N_B-1:0] in_OVR,
    input  wire signed [N_B-1:0] in_I,
    input  wire signed [N_B-1:0] in_P,
    input  wire signed [N_B-1:0] in_fH,
    input  wire signed [N_B-1:0] in_fL,
    output reg         [1:0]     inc_I,
    output reg         [1:0]     inc_P,
    output reg         [1:0]     inc_fH,
    output reg         [1:0]     inc_fL
);
reg signed [N_B-1:0] in_OVR_old, in_I_old, in_P_old, in_fH_old, in_fL_old;
// Input upper and lower limits
wire OOR_OVR, OOR_I, OOR_P, OOR_fH, OOR_fL;
// Lower bound and upper bound. 
localparam signed [N_B-1:0] LB = -5'd9, UB = 5'd9;
// Logic variables when the #'s of clicks is out of range. 
// The range of -9 to 9 will change a gain by a factor of ~40.
// Reprogramming gains with the serial input will reset the center of the adjustable range to 0.
assign OOR_OVR = (in_OVR < LB) || (in_OVR > UB);
assign OOR_I   = (in_I   < LB) || (in_I   > UB);
assign OOR_P   = (in_P   < LB) || (in_P   > UB);
assign OOR_fH  = (in_fH  < LB) || (in_fH  > UB);
assign OOR_fL  = (in_fL  < LB) || (in_fL  > UB);
always @(posedge clk) begin
    case (mode)
        // Default case does nothing
        default: begin
            inc_I  <= 2'b00;
            inc_P  <= 2'b00;
            inc_fH <= 2'b00;
            inc_fL <= 2'b00;
        end
        // If in mode "1", change the overall gain, changing I and P by the same amount
        1: begin // OVERALL, change I, P, D
            // If not out of range, and the button to increase the value was pushed, send 01
            if ((in_OVR > in_OVR_old) && !OOR_OVR) begin
                inc_I  <= 2'b01;
                inc_P  <= 2'b01;
            end
            // Otherwise send 10 (to go decrement)
            else if ((in_OVR < in_OVR_old) && !OOR_OVR) begin
                inc_I <= 2'b10;
                inc_P <= 2'b10;
            end
            // Otherwise no change.
            else begin
                inc_I <= 2'b00;
                inc_P <= 2'b00;
            end
            inc_fH <= 2'b00;
            inc_fL <= 2'b00;
        end
        // Similar cases for other modes....
        2: begin //I, change I
            if      ((in_I > in_I_old) && !OOR_I) inc_I <= 2'b01;
            else if ((in_I < in_I_old) && !OOR_I) inc_I <= 2'b10;
            else                                  inc_I <= 2'b00;
            inc_P  <= 2'b00;
            inc_fH <= 2'b00;
            inc_fL <= 2'b00;
        end
        3: begin //P, change P
            inc_I <= 2'b00;
            if      ((in_P > in_P_old) && !OOR_P) inc_P <= 2'b01;
            else if ((in_P < in_P_old) && !OOR_P) inc_P <= 2'b10;
            else                                  inc_P <= 2'b00;
            inc_fH <= 2'b00;
            inc_fL <= 2'b00;
        end
        4: begin //fH, change fH
            inc_I <= 2'b00;
            inc_P <= 2'b00;
            if      ((in_fH > in_fH_old) && !OOR_fH) inc_fH <= 2'b01;
            else if ((in_fH < in_fH_old) && !OOR_fH) inc_fH <= 2'b10;
            else                                     inc_fH <= 2'b00;
            inc_fL <= 2'b00;
        end
        5: begin //fL, change fL
            inc_I  <= 2'b00;
            inc_P  <= 2'b00;
            inc_fH <= 2'b00;
            if      ((in_fL > in_fL_old) && !OOR_fL) inc_fL <= 2'b01;
            else if ((in_fL < in_fL_old) && !OOR_fL) inc_fL <= 2'b10;
            else                                     inc_fL <= 2'b00;
        end
    endcase
    // Store previous values so changes can be probed 
    // + or - 9 is the maximum change – limit changes to this range.
    if (!OOR_OVR) in_OVR_old <= in_OVR;
    else          in_OVR_old <= in_OVR_old;
    if (!OOR_I  ) in_I_old   <= in_I;
    else          in_I_old   <= in_I_old;
    if (!OOR_P  ) in_P_old   <= in_P;
    else          in_P_old   <= in_P_old;
    if (!OOR_fH ) in_fH_old  <= in_fH;
    else          in_fH_old  <= in_fH_old;
    if (!OOR_fL ) in_fL_old  <= in_fL;
    else          in_fL_old  <= in_fL_old;
end
endmodule