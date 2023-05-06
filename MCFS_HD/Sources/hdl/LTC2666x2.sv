`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module to drive 2 LTC2666-16 multiplexed SPI DACs.
// These DACs are designed to update a channel at 50 kS/s.
// They can be overclocked, but have a nonlinearity at zero that 
// looks like a voltage offset for negative codes, which can be corrected with 
// the n input (currently commented out).
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

module LTC2666x2#(parameter N0 = 8, N1 = 8)
   (input  wire clk,
    input  wire rst,
    input  wire signed [15:0] 
        s_in0, s_in1, s_in2,  s_in3,  s_in4,  s_in5,  s_in6,  s_in7,
        s_in8, s_in9, s_in10, s_in11, s_in12, s_in13, s_in14, s_in15,
    input  wire [2:0] CH0 [0:N0-1], // sequence of channels, N is the number of elements in the sequence
    input  wire [2:0] CH1 [0:N1-1],
    // // Update-rate dependent offsets (due to overclocking) for each channel
    // // Offset is 32 LSB / MSPS, e.g. 2 MSPS needs offset of 64 LSB.
    // input  wire signed [15:0] n0 [0:7], 
    // input  wire signed [15:0] n1 [0:7], 
    output wire [23:0] data_out,
    // Serial lines
    input  wire SDO, // Output from DAC
    output wire CS0, CS1,
    output wire SCK,
    output wire SDI // Data into DAC
);

/*
// Incoming signals.    
wire signed [15:0] data_in0_temp0 [0:7]; 
wire signed [15:0] data_in1_temp0 [0:7]; 
wire signed [15:0] data_in0_temp1 [0:7]; 
wire signed [15:0] data_in1_temp1 [0:7]; 
wire [15:0] data_in0 [0:7];
wire [15:0] data_in1 [0:7]; 

// Subtract n from all negative input values. Removes bipolar-zero error from DAC outputs.
localparam signed [15:0] min = 16'h8000; // This is the most negative possible DAC code (if n is zero)
// This intermediate assignment prevents negative overflows when subtracting n from negative values.
// This excludes n[i] of 2^16 possible DAC codes. When the input is within n of min, the output is min+n.
// chip 0
assign data_in0_temp0[0] = (s_in0<(min+n0[0]))?(min+n1[0]):(s_in0);
assign data_in0_temp0[1] = (s_in1<(min+n0[1]))?(min+n1[1]):(s_in1);
assign data_in0_temp0[2] = (s_in2<(min+n0[2]))?(min+n1[2]):(s_in2);
assign data_in0_temp0[3] = (s_in3<(min+n0[3]))?(min+n1[3]):(s_in3);
assign data_in0_temp0[4] = (s_in4<(min+n0[4]))?(min+n1[4]):(s_in4);
assign data_in0_temp0[5] = (s_in5<(min+n0[5]))?(min+n1[5]):(s_in5);
assign data_in0_temp0[6] = (s_in6<(min+n0[6]))?(min+n1[6]):(s_in6);
assign data_in0_temp0[7] = (s_in7<(min+n0[7]))?(min+n1[7]):(s_in7);
// chip 1
assign data_in1_temp0[0] = (s_in8 <(min+n1[0]))?(min+n1[0]):(s_in8);
assign data_in1_temp0[1] = (s_in9 <(min+n1[1]))?(min+n1[1]):(s_in9);
assign data_in1_temp0[2] = (s_in10<(min+n1[2]))?(min+n1[2]):(s_in10);
assign data_in1_temp0[3] = (s_in11<(min+n1[3]))?(min+n1[3]):(s_in11);
assign data_in1_temp0[4] = (s_in12<(min+n1[4]))?(min+n1[4]):(s_in12);
assign data_in1_temp0[5] = (s_in13<(min+n1[5]))?(min+n1[5]):(s_in13);
assign data_in1_temp0[6] = (s_in14<(min+n1[6]))?(min+n1[6]):(s_in14);
assign data_in1_temp0[7] = (s_in15<(min+n1[7]))?(min+n1[7]):(s_in15);
// Subtract n from all negative inputs to remove BPZ error.
// chip 0
assign data_in0_temp1[0] = (s_in0<0)?(data_in0_temp0[0]-n0[0]):(data_in0_temp0[0]);
assign data_in0_temp1[1] = (s_in1<0)?(data_in0_temp0[1]-n0[1]):(data_in0_temp0[1]);
assign data_in0_temp1[2] = (s_in2<0)?(data_in0_temp0[2]-n0[2]):(data_in0_temp0[2]);
assign data_in0_temp1[3] = (s_in3<0)?(data_in0_temp0[3]-n0[3]):(data_in0_temp0[3]);
assign data_in0_temp1[4] = (s_in4<0)?(data_in0_temp0[4]-n0[4]):(data_in0_temp0[4]);
assign data_in0_temp1[5] = (s_in5<0)?(data_in0_temp0[5]-n0[5]):(data_in0_temp0[5]);
assign data_in0_temp1[6] = (s_in6<0)?(data_in0_temp0[6]-n0[6]):(data_in0_temp0[6]);
assign data_in0_temp1[7] = (s_in7<0)?(data_in0_temp0[7]-n0[7]):(data_in0_temp0[7]);
// chip 1
assign data_in1_temp1[0] = (s_in8 <0)?(data_in1_temp0[0]-n1[0]):(data_in1_temp0[0]);
assign data_in1_temp1[1] = (s_in9 <0)?(data_in1_temp0[1]-n1[1]):(data_in1_temp0[1]);
assign data_in1_temp1[2] = (s_in10<0)?(data_in1_temp0[2]-n1[2]):(data_in1_temp0[2]);
assign data_in1_temp1[3] = (s_in11<0)?(data_in1_temp0[3]-n1[3]):(data_in1_temp0[3]);
assign data_in1_temp1[4] = (s_in12<0)?(data_in1_temp0[4]-n1[4]):(data_in1_temp0[4]);
assign data_in1_temp1[5] = (s_in13<0)?(data_in1_temp0[5]-n1[5]):(data_in1_temp0[5]);
assign data_in1_temp1[6] = (s_in14<0)?(data_in1_temp0[6]-n1[6]):(data_in1_temp0[6]);
assign data_in1_temp1[7] = (s_in15<0)?(data_in1_temp0[7]-n1[7]):(data_in1_temp0[7]);
*/

// This DAC uses straight binary codes (0x0000 is the most negative number, 0x8000 is the midpoint, 0xFFFF is the most positive number.)
// To convert from 2's complement to straight binary flip, the MSB.
wire [15:0] data_in0 [0:7];
wire [15:0] data_in1 [0:7]; 
assign data_in0[0] = {!s_in0[15] , s_in0[14:0]};
assign data_in0[1] = {!s_in1[15] , s_in1[14:0]};
assign data_in0[2] = {!s_in2[15] , s_in2[14:0]};
assign data_in0[3] = {!s_in3[15] , s_in3[14:0]};
assign data_in0[4] = {!s_in4[15] , s_in4[14:0]};
assign data_in0[5] = {!s_in5[15] , s_in5[14:0]};
assign data_in0[6] = {!s_in6[15] , s_in6[14:0]};
assign data_in0[7] = {!s_in7[15] , s_in7[14:0]};
assign data_in1[0] = {!s_in8[15] , s_in8[14:0]};
assign data_in1[1] = {!s_in9[15] , s_in9[14:0]};
assign data_in1[2] = {!s_in10[15], s_in10[14:0]};
assign data_in1[3] = {!s_in11[15], s_in11[14:0]};
assign data_in1[4] = {!s_in12[15], s_in12[14:0]};
assign data_in1[5] = {!s_in13[15], s_in13[14:0]};
assign data_in1[6] = {!s_in14[15], s_in14[14:0]};
assign data_in1[7] = {!s_in15[15], s_in15[14:0]};

// Trigger a new data transfer when SPI module finishes the previous transfer.
wire spi_trigger, spi_ready;
assign spi_trigger = spi_ready;

// Multiplex input signals
reg  [23:0] spi_data0, spi_data1;
localparam [3:0] cmd = 4'b0011; // Write and update DAC register addr
reg [3:0] addr0 = 4'b0000, addr1 = 4'b0000; // Addresses
// Change address once every 25 cycles (the time it takes to transfer the 3 byte DAC code).
reg [4:0] cnt = 5'd0;
reg [7:0] ch_cnt0 = 8'd0, ch_cnt1 = 8'd0;
wire state; // The DAC chip that will be active on the next transfer.
always @(posedge clk) begin
    if (spi_trigger) begin
        cnt <= 0;
        // Update the DAC channels sequentially to sample all channels
        if (state) begin
            if (ch_cnt1 < (N1-1)) ch_cnt1 <= ch_cnt1 + 1;
            else                  ch_cnt1 <= 0;
        end
        else begin
            if (ch_cnt0 < (N0-1)) ch_cnt0 <= ch_cnt0 + 1;
            else                  ch_cnt0 <= 0;
        end
        addr0 <= {1'b0,CH0[ch_cnt0]};
        addr1 <= {1'b0,CH1[ch_cnt1]};
    end
    else if (!spi_trigger && cnt < 5'd14) cnt <= cnt + 5'd1;
    else begin
        cnt <= cnt;
        spi_data0 = {cmd, addr0, data_in0[addr0]};
        spi_data1 = {cmd, addr1, data_in1[addr1]};
    end
end

// Transfer size is 24 bits
SPI_LTC2666x2#(24)LTC2666_SPI_inst(clk, rst, spi_data0, spi_data1, data_out, spi_ready, CS0, CS1, SCK, SDI, SDO, state);
endmodule