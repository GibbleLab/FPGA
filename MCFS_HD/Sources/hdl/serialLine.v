`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Implements a serial input, triggered by external source, with 16-bit handshakes at the beginning and end.
// The input is partitioned as a series of 35-bit numbers
// 
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////


module serialLine(
    input   wire            clk_in,
    input   wire            in,
    input   wire            trig_in,
    output  reg     [15:0]  handshake_i,
    output  reg     [15:0]  handshake_f,
    output  reg     [34:0]  num0,  num1,  num2,  num3,  num4,  num5,  num6,  num7,  num8,  
                            num9,  num10, num11, num12, num13, num14, num15, num16, num17, 
                            num18, num19, num20, num21, num22, num23, num24, num25, num26
);

// Max number of points expected
localparam N = 14'd977+14'd2; // 2*16+27*35 = 977, add 2 extra cycles to "wait" at the end
// Regs to record serial values
reg [N-1:0] all_new, all_old;
// States for counters to record serial values
localparam IDLE = 2'd0;
localparam CNT1 = 2'd1;
localparam CNT0 = 2'd2;
// Combinatorial part of state machine, generates counters to synchronize the data capture initiated by trig.
function [25:0] serial_next_state;
    input [1:0]  state;
    input        trig;
    input [9:0]  cFast;
    input [13:0] cSlow;
    input [9:0]  Nf;
    input [13:0] Ns;
    
    reg [9:0] cFast_new;
    reg [13:0] cSlow_new;
    
    begin 
        case (state)
            IDLE: begin
                if (trig) begin
                    cFast_new = 10'd0;
                    cSlow_new = N - 14'd1;
                    serial_next_state = {cFast_new, cSlow_new, CNT1};
                end
                else begin
                    cFast_new = 10'd0;
                    cSlow_new = N-1;
                    serial_next_state = {cFast_new, cSlow_new, IDLE};            
                end
            end
            CNT1: begin
                if ( (cFast < (Nf-10'd1)) && (cSlow != 14'd0) ) begin
                    cFast_new = cFast + 10'd1;
                    cSlow_new = cSlow;
                    serial_next_state = {cFast_new, cSlow_new, CNT1};            
                end
                else if ( (cFast == (Nf-10'd1)) && (cSlow != 14'd0) ) begin
                    cFast_new = 10'd0;
                    cSlow_new = cSlow - 14'd1;
                    serial_next_state = {cFast_new, cSlow_new, CNT1};            
                end
                else if ( (cFast == (Nf-10'd1)) && (cSlow == 14'd0) ) begin
                    cFast_new = cFast + 10'd1;
                    cSlow_new = cSlow;
                    serial_next_state = {cFast_new, cSlow_new, CNT1};            
                end
                else begin
                   cFast_new = 10'd0;
                   cSlow_new = cSlow;
                   serial_next_state = {cFast_new, cSlow_new, CNT0};            
                end
            end
            CNT0: begin
                if ( cFast < (Nf-10'd1)) begin
                    cFast_new = cFast + 10'd1;
                    cSlow_new = cSlow;
                    serial_next_state = {cFast_new, cSlow_new, CNT0};  
                end
                else begin
                    cFast_new = 10'd0;
                    cSlow_new = N;
                    serial_next_state = {cFast_new, cSlow_new, IDLE};
                end
            end            
        endcase
    end
endfunction
// Sequential part of state machine. Store serial input sequentially in all_new 
reg [25:0] serialF;
reg [9:0]  c1000 = 10;
reg [13:0] ind;
reg [1:0] serialState=IDLE;
always @(posedge clk_in) begin
    serialF     = serial_next_state(serialState, trig_in, c1000, ind, 10'd1000, N);
    c1000       = serialF[25:16];
    ind         = serialF[15:2];
    serialState = serialF[1:0];
    begin
        case (serialState)
            CNT1: begin
                if (c1000 == 10'd500) begin
                    all_new[ind] <= in;
                end
            end
            CNT0: begin
                if (c1000 == 10'd500) begin
                    all_new[ind] <= in;
                end
            end
        endcase
    end
end
// Output values from serial stream
wire trig_rec;
assign trig_rec = (ind == N);
always @(posedge clk_in) begin
    if (trig_rec) all_old  <= all_new;
    else          all_old  <= all_old;
    handshake_i = all_old[N-1:N-16];
    num0        = all_old[N-17:N-51];
    num1        = all_old[N-52:N-86];
    num2        = all_old[N-87:N-121];
    num3        = all_old[N-122:N-156];
    num4        = all_old[N-157:N-191];
    num5        = all_old[N-192:N-226];
    num6        = all_old[N-227:N-261];
    num7        = all_old[N-262:N-296];
    num8        = all_old[N-297:N-331];
    num9        = all_old[N-332:N-366];
    num10       = all_old[N-367:N-401];
    num11       = all_old[N-402:N-436];
    num12       = all_old[N-437:N-471];
    num13       = all_old[N-472:N-506];
    num14       = all_old[N-507:N-541];
    num15       = all_old[N-542:N-576];
    num16       = all_old[N-577:N-611];
    num17       = all_old[N-612:N-646];
    num18       = all_old[N-647:N-681];
    num19       = all_old[N-682:N-716];
    num20       = all_old[N-717:N-751];
    num21       = all_old[N-752:N-786];
    num22       = all_old[N-787:N-821];
    num23       = all_old[N-822:N-856];
    num24       = all_old[N-857:N-891];
    num25       = all_old[N-892:N-926];
    num26       = all_old[N-927:N-961];
    handshake_f = all_old[N-962:N-977];
end

endmodule