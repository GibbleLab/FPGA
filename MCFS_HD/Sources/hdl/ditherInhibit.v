`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Module that gates a dither and outputs a signal to hold the integrator of the dither lock. 
// When the FM_MOT cycle begins, EN goes HIGH, the dither starts on an inhtrig transition to HIGH, the dither integrator hold, inthld, goes LOW after a delay of NIhld+1 dither cycles, which are counted by Ncyc. 
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////
module ditherInhibit#(parameter N_B = 16, NIhld = 2)(
    input  wire clk,
                EN,                       // enable signal (from FM_MOT module)
                inhtrig,                   // trigger (from ditherLock module)
    input  wire signed [N_B-1:0] dith_in, // input dither signal
    output reg                   inthld,
    output reg  signed [N_B-1:0] dith_out // gated dither output
);
    
reg signed [N_B-1:0] dith_old;
reg                  dithStop = 0;
reg [31:0] Ncyc = 0; 
always @(posedge clk) begin
    dith_old <= dith_in;
    if (!EN) begin
        if (!dithStop) begin
            dith_out <= dith_old;
            if (inhtrig) dithStop <= 1;
            else        dithStop <= 0;
        end
        else begin
            dith_out <= 0;
            dithStop <= 1;
        end
    end
    else begin
        if (dithStop) begin
            dith_out <= 0;
            if (inhtrig) dithStop <= 0;
            else        dithStop <= 1;
        end
        else begin
            dith_out <= dith_old;
            dithStop <= 0;
        end
    end
    // A HIGH inthld output pauses the dither lock integrator.
    // When EN is LOW, inthld is set to HIGH and Ncyc resets to 0, so there is a delay before enabling the dither integrator 
    if (!EN) begin
        inthld <= 1;
        Ncyc <= 0;
    end
    else begin
        // Ncyc counts to delay the enable for the dither integrator.
        if (Ncyc < NIhld+1) begin 
            // Dither cycles, Ncyc, are incremented on rising edges of inhtrig.
  	        if (inhtrig) Ncyc <= Ncyc + 1;
            else Ncyc <= Ncyc;
            inthld <= 1;
        end 
        else begin
            Ncyc <= Ncyc;
            inthld <= 0;
        end
    end
end

endmodule