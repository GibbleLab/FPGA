`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Firmware to drive an LTC2194 fast ADC, deserializing both ADC channels at 400 MHz DDR. 
// The ADC's are clocked at 100 MHz. Five LVDS pairs, a Frame and even and odd bits for both channels 
// are deserialized by ISERDESE2 primitives. IDELAYE2 primitives perform the fine delays (delay0-delay5), 
// and the Bitslip submodule of the ISERDESE2's correctly orders the bits.
//
// Adapted from firmware in NIST Digital Servo, here using IDELAYE2 and ISERDESE2 instantiations based on the primitive instantiation templates in the Xilinx HDL Libraries Guide (UG953), version 2012.2.
//
// Daniel Schussheim
//////////////////////////////////////////////////////////////////////////////////

module LTC2194DDR#(
  parameter N00 = 3'b0, N01 = 3'b0, N10 = 3'b0, N11 = 3'b0, // Static bit-slips
            delay0 = 0, delay1 = 0, delay2 = 0, delay3 = 0, delay4 = 0 // IDELAYE2 taps for ch0 pair 0, ch0 pair 1, ch1 pair 0, ch1 pair 1, and Frame
)(
  // Clock and reset inputs
  input  wire clk100,
  input  wire clk200,
  input  wire clk400, clk400B,
  input  wire rst,
  // Frame inputs (p/n are the positive and negative wires of the differential pairs)
  input  wire FR_p,
  input  wire FR_n,
  // Data inputs
  input  wire [1:0] D0_p,
  input  wire [1:0] D0_n,
  input  wire [1:0] D1_p,
  input  wire [1:0] D1_n,
  // Deserialized outputs
  output wire signed [15:0] ADC0_out, // Channel 0 sample
  output wire signed [15:0] ADC1_out, // Channel 1 sample
  output wire signed [7:0]  FR_out    // Deserialized Frame (nominally 8'b11110000)
);

// Parameterize the 5 input data pairs for the GENERATE loop below.
localparam N_LVDS = 5;   // Number of LVDS channels
localparam N_SERIAL = 8; // Number of bits that are transfer on each pair
wire   [N_LVDS-1:0] data_in_p, data_in_n; // Input from FPGA pins
wire [N_LVDS*N_SERIAL-1:0] data_out; // Output from ISERDESE2's
// Assign the conversion data and frame to data_in.
assign data_in_p = {FR_p, D1_p, D0_p};
assign data_in_n = {FR_n, D1_n, D0_n};

// Assemble the deserialized data from the ISERDESE2's.
assign ADC0_out = {
  data_out[0], data_out[8],  data_out[1], data_out[9],  data_out[2], data_out[10], data_out[3], data_out[11],
  data_out[4], data_out[12], data_out[5], data_out[13], data_out[6], data_out[14], data_out[7], data_out[15]
};
assign ADC1_out = {
    data_out[16 + 0], data_out[16 + 8],  data_out[16 + 1], data_out[16 + 9],  data_out[16 + 2], data_out[16 + 10], data_out[16 + 3], data_out[16 + 11],
    data_out[16 + 4], data_out[16 + 12], data_out[16 + 5], data_out[16 + 13], data_out[16 + 6], data_out[16 + 14], data_out[16 + 7], data_out[16 + 15]
};       
assign FR_out = data_out[39:32]; // Training pattern for bit-slip state machine

wire BSiF, BSi00, BSi01, BSi10, BSi11; // 1-bit bit-slip inputs to ISERDESE2's. The ISERDESE2 bit-slips the deserialized data on the positive edges of the bit-slip inputs. The static bit-slips are only applied right after FPGA programming and the dynamic bit-slip BSiF normally only after the ADC's start up.
wire EN00, EN01, EN10, EN11; // Enable outputs from BitslipStatic that delay dynamic bit-slips to be after the statics. All 4 enables are AND'ed.
// The 4 data pairs each get their own static bit-slips.
BitslipStatic#(100_000, N00)BitslipStatic00(clk100, EN00, BSi00);
BitslipStatic#(100_000, N01)BitslipStatic01(clk100, EN01, BSi01);
BitslipStatic#(100_000, N10)BitslipStatic10(clk100, EN10, BSi10);
BitslipStatic#(100_000, N11)BitslipStatic11(clk100, EN11, BSi11);
// AND the enable outputs from each BitslipStatic instance and use the result to enable BitslipDynamic. 
wire EN;
assign EN = EN00 && EN01 && EN10 && EN11;
// BitslipDynamic bit-slips all data, including the frame FR_p/n so that it is 11110000.
wire FR_test_out;
BitslipDynamic#(8'b11110000)BitslipF(clk100, EN, FR_out, FR_test_out, BSiF);
// OR the bit-slip inputs for the frame and each data pair.
wire [N_LVDS-1:0] BS;
assign BS = {BSiF, BSiF || BSi11, BSiF || BSi10, BSiF || BSi01, BSiF || BSi00};

// Function for delay values in GENERATE loop, below.
function integer delay_value;
  input integer num;
  begin
      case(num) 
          0: delay_value  = delay0;  
          1: delay_value  = delay1; 
          2: delay_value  = delay2;                      
          3: delay_value  = delay3; 
          4: delay_value  = delay4;
          default:
              delay_value = 0;
      endcase
  end                               
endfunction

// LTC2194's simultaneously sample 2 analog input channels.
// Each input channel's data is output on 2 LVDS pairs, one carrying the odd bits and the other the even bits, all aligned with the Frame.
// The DDR output data is at 4x the input clock, 400 MHz for a 100 MHz clock. 
// The Frame uses a single LVDS input pair, so N_LVDS = 5 input pairs are deserialized. 
// A GENERATE block instantiates the required elements to capture the 5 LVDS signals:
// first, input differential buffers, IBUFDS, then IDELAYE2 primitives for precise alignment of the DDR input data, 
// and finally, ISERDESE2 primitives to deserialize the DDR output into 16-bit conversion samples.
// The Bitslip submodule of ISERDESE2 does the coarse alignment of the 16-bit words.
wire [N_LVDS-1:0] data_in_from_pins, data_in_from_pins_dly; // Input buffer data and delayed output from IDELAYE2
genvar pin_count;
generate for (pin_count = 0; pin_count < N_LVDS; pin_count = pin_count + 1) begin: pins    
    // IBUFDS IDELAYE2 and ISERDESE2 instantiations are based on the primitive instantiation templates in the Xilinx HDL Libraries Guide (UG953), version 2012.2.
    // IBUFDS: Differential Input Buffer, from Xilinx template
    (* DONT_TOUCH = "TRUE" *)
    IBUFDS #(
        .DIFF_TERM("TRUE"),         // Differential Termination
        .IBUF_LOW_PWR("FALSE"),     // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD("LVDS_25"))     // Specify the input I/O standard
    IBUFDS_inst (
        .O(data_in_from_pins[pin_count]),     // Buffer output
        .I(data_in_p[pin_count]),             // Diff_p buffer input (connect directly to top-level port)
        .IB(data_in_n[pin_count]));           // Diff_n buffer input (connect directly to top-level port)        
    // IDELAYE2: Input Fixed or Variable Delay Element, from Xilinx template
    (* DONT_TOUCH = "TRUE" *)
    IDELAYE2 #(
        .CINVCTRL_SEL("FALSE"),         // Enable dynamic clock inversion (FALSE, TRUE)
        .DELAY_SRC("IDATAIN"),          // Delay input (IDATAIN, DATAIN)
        .HIGH_PERFORMANCE_MODE("TRUE"), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
        .IDELAY_TYPE("FIXED"),          // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
        .IDELAY_VALUE(delay_value(pin_count)), // Input delay tap setting (0-31). Each increment corresponds to a delay of about 78 ps.
        .PIPE_SEL("FALSE"),             // Select pipelined mode, FALSE, TRUE
        .REFCLK_FREQUENCY(200.0),       // IDELAYCTRL clock input frequency in MHz (190.0-210.0).
        .SIGNAL_PATTERN("DATA"))        // DATA, CLOCK input signal
    IDELAYE2_inst (
        .CNTVALUEOUT(),                             // 5-bit output: Counter value output
        .DATAOUT(data_in_from_pins_dly[pin_count]), // 1-bit output: Delayed data output
        .C(),                                       // 1-bit input: Clock input
        .CE(),                                      // 1-bit input: Active high enable increment/decrement input
        .CINVCTRL(),                                // 1-bit input: Dynamic clock inversion input
        .CNTVALUEIN(),                              // 5-bit input: Counter value input
        .DATAIN(),                                  // 1-bit input: Internal delay data input
        .IDATAIN(data_in_from_pins[pin_count]),     // 1-bit input: Data input from the I/O
        .INC(),                                     // 1-bit input: Increment / Decrement tap delay input
        .LD(),                                      // 1-bit input: Load IDELAY_VALUE input
        .LDPIPEEN(),                                // 1-bit input: Enable PIPELINE register to load data input
        .REGRST(rst));                             // 1-bit input: Active-high reset tap-delay input
    // ISERDESE2: Input SERial/DESerializer with Bitslip, from Xilinx template
    (* DONT_TOUCH = "TRUE" *)
    ISERDESE2 #(
        .DATA_RATE("DDR"),              // DDR, SDR
        .DATA_WIDTH(8),                 // Parallel data width (2-8,10,14)
        .DYN_CLKDIV_INV_EN("FALSE"),    // Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
        .DYN_CLK_INV_EN("FALSE"),       // Enable DYNCLKINVSEL inversion (FALSE, TRUE)
        // INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
        .INIT_Q1(1'b0),
        .INIT_Q2(1'b0),
        .INIT_Q3(1'b0),
        .INIT_Q4(1'b0),
        .INTERFACE_TYPE("NETWORKING"),    // MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
        .IOBDELAY("IFD"),                 // NONE, BOTH, IBUF, IFD
        .NUM_CE(2),                       // Number of clock enables (1,2)
        .OFB_USED("FALSE"),               // Select OFB path (FALSE, TRUE)
        .SERDES_MODE("MASTER"),           // MASTER, SLAVE
        // SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
        .SRVAL_Q1(1'b0),
        .SRVAL_Q2(1'b0),
        .SRVAL_Q3(1'b0),
        .SRVAL_Q4(1'b0))
    ISERDESE2_inst (
        .O(), // 1-bit output: Combinatorial output
        // Q1 - Q8: 1-bit (each) output: Registered data outputs
        .Q1(data_out[N_SERIAL*pin_count+7]),
        .Q2(data_out[N_SERIAL*pin_count+6]),
        .Q3(data_out[N_SERIAL*pin_count+5]),
        .Q4(data_out[N_SERIAL*pin_count+4]),
        .Q5(data_out[N_SERIAL*pin_count+3]),
        .Q6(data_out[N_SERIAL*pin_count+2]),
        .Q7(data_out[N_SERIAL*pin_count+1]),
        .Q8(data_out[N_SERIAL*pin_count+0]),
        // SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
        .SHIFTOUT1(),
        .SHIFTOUT2(),
        .BITSLIP(BS[pin_count]),
        // 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
        // CLKDIV when asserted (active High). Subsequently, the data on the Q1
        // to Q8 output ports will shift, as in a barrel-shifter operation, one
        // position every time Bitslip is invoked (DDR is different than
        // SDR).
        // CE1, CE2: 1-bit (each) input: Data register clock enable inputs
        .CE1(1'b1),
        .CE2(1'b1),
        .CLKDIVP(1'b0),        // 1-bit input: TBD
        // Clocks: 1-bit (each) input: ISERDESE2 clock input ports
        .CLK(clk400),          // 1-bit input: High-speed clock
        .CLKB(clk400B),        // 1-bit input: High-speed secondary clock
        .CLKDIV(clk100),       // 1-bit input: Divided clock
        .OCLK(),               // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY"
        // Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
        .DYNCLKDIVSEL(1'b0),   // 1-bit input: Dynamic CLKDIV inversion
        .DYNCLKSEL(1'b0),      // 1-bit input: Dynamic CLK/CLKB inversion
        // Input Data: 1-bit (each) input: ISERDESE2 data input ports
        .D(data_in_from_pins[pin_count]), // 1-bit input: Data input
        .DDLY(data_in_from_pins_dly[pin_count]),             // 1-bit input: Serial data from IDELAYE2
        .OFB(),                // 1-bit input: Data feedback from OSERDESE2
        .OCLKB(),              // 1-bit input: High speed negative edge output clock
        .RST(rst),
        // SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
        .SHIFTIN1(1'b0),
        .SHIFTIN2(1'b0));        
end
endgenerate
  
endmodule