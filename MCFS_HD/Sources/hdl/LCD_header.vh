//////////////////////////////////////////////////////////////////////////////////
// Verilog header file with the signal declarations, tasks, and functions
// Needed to drive LCD display.
//
// Lam Tran, Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////

//GLOBAL VARIABLES FOR DISPLAYLIST
reg [11:0] currentoffset = 0;

//START: general COLORS 
parameter [23:0] black = 24'h000000;
parameter [23:0] white = 24'hffffff;
parameter [23:0] red = 24'hff0000;
parameter [23:0] green = 24'h00ff00;
parameter [23:0] blue = 24'h0000ff;
parameter [23:0] yellow = 24'hffff00;
parameter [23:0] purple = 24'h800080;
parameter [23:0] redpurple = 24'h630141;
parameter [23:0] bluepurple = 24'h530080;
parameter [23:0] orange = 24'hff8c00;
parameter [23:0] navy = 24'h000027; //24'h093162;
parameter [23:0] darkred = 24'haf0000;
parameter [23:0] darkerred = 24'h630000;
parameter [23:0] darkgreen = 24'h008b00;
parameter [23:0] darkergreen = 24'h2b3808;
parameter [23:0] lightgreen = 24'h62d2a2;
//END: general COLORS 

//start: colors of buttons
parameter [23:0] 
    // Colors for if these servos are locked
    greenlbo     = darkred,
    green542     = darkgreen,
    green820     = orange,
    green1083    = redpurple,
    green326     = purple,
    green361     = bluepurple,
    green332     = purple,
    greense8     = red,
    scancolor    = darkergreen, // Color for servo in scan mode
    adjcolor     = darkerred,   // Outdated name (believed to be unused)
    unlock       = red,         // Out of lock color
    unlock1s     = yellow,      // Color when out of lock within the past few seconds (see RelockLEDs.v)
    // Colors for MOT buttons
    motclr1      = green,
    motclr2      = darkgreen,
    motclr3      = darkergreen;
    // So far unused colors for an intermediate indicator if a servo was unlocked in the last minute 
//    unlock1Mlbo  = greenlbo + 24'h006464,
//    unlock1M542  = green542 + 24'h640064,
//    unlock1M820  = 24'hffb450 ,
//    unlock1M1083 = 24'hb2577c;
//end: colors of buttons

// signals for  heater servo indicators
parameter signed [15:0] tin0r = 16'd33; // +- 1mV (1 degree C).
parameter signed [15:0] tin1r = 16'd33; // +- 1mV (1 degree C).
parameter signed [15:0] tin2r = 16'd33; // +- 1mV (1 degree C).
parameter signed [15:0] tin3r = 16'd33; // +- 1mV (1 degree C).
parameter signed [15:0] tin4r = 16'd33; // +- 1mV (1 degree C).
parameter signed [15:0] tin5r = 16'd33; // +- 1mV (1 degree C).
parameter signed [15:0] tin6r = 16'd33; // +- 1mV (1 degree C).
parameter signed [15:0] tin7r = 16'd33; // +- 1mV (1 degree C).
parameter signed [15:0] tin8r = 16'd33; // +- 1mV (1 degree C).
parameter signed [15:0] tin9r = 16'd33; // +- 1mV (1 degree C).
parameter signed [15:0] tin10r = 16'd33; // +- 1mV (1 degree C).

//START OF LCD DISPLAY PARAMETERS
parameter HSIZE = 320;
parameter VSIZE = 240;
parameter HCYCLE = 408;
parameter HOFFSET = 70;
parameter HSYNC0 = 0;
parameter HSYNC1 = 10;
parameter VCYCLE = 263;
parameter VOFFSET = 13;
parameter VSYNC0 = 0;
parameter VSYNC1 = 2;
parameter SWIZZLE = 0; //0
parameter PCLK_POL = 1;
parameter CSPREAD  = 1; //1
parameter PCLK = 5;
//END OF LCD DISPLAY PARAMETERS

////////////////////MEMORY MAP////////////////////////
//changed Write32, read32;
//changed MemWrite32, MemRead32;
parameter RAM_DL = 22'h300000;
parameter RAM_REG = 22'h302000;
parameter RAM_CMD = 22'h308000;
parameter RAM_G = 22'h0;

parameter REG_ID        = RAM_REG;
parameter REG_CPURESET  = RAM_REG + 22'h20;
parameter REG_HCYCLE    = RAM_REG + 22'h2c;
parameter REG_HOFFSET   = RAM_REG + 22'h30;
parameter REG_HSYNC0    = RAM_REG + 22'h38;
parameter REG_HSYNC1    = RAM_REG + 22'h3c;
parameter REG_VCYCLE    = RAM_REG + 22'h40;
parameter REG_VOFFSET   = RAM_REG + 22'h44;
parameter REG_VSYNC0    = RAM_REG + 22'h4c;
parameter REG_VSYNC1    = RAM_REG + 22'h50;
parameter REG_SWIZZLE   = RAM_REG + 22'h64;
parameter REG_PCLK_POL  = RAM_REG + 22'h6c;
parameter REG_CSPREAD   = RAM_REG + 22'h68;
parameter REG_HSIZE     = RAM_REG + 22'h34;
parameter REG_VSIZE     = RAM_REG + 22'h48;
parameter REG_GPIO_DIR  = RAM_REG + 22'h90;
parameter REG_GPIO      = RAM_REG + 22'h94;
parameter REG_DLSWAP    = RAM_REG + 22'h54;
parameter REG_PCLK      = RAM_REG + 22'h70;
parameter REG_TOUCH_TAG = RAM_REG + 22'h12c;

parameter REG_CMD_WRITE = RAM_REG + 22'hfc;
parameter REG_CMD_READ  = RAM_REG + 22'hf8;

parameter CMD_DLSTART   = 32'hffffff00;
parameter CMD_BUTTON    = 32'hffffff0d;
parameter CMD_TEXT      = 32'hffffff0c;
parameter CMD_CALIBRATE = 32'hffffff15;
parameter CMD_SWAP      = 32'hffffff01;
parameter CMD_FGCOLOR   = 32'hffffff0a;
  
// Functions, some of which are used below to make the display list. All are based on the FT81x_series_programmer_guide
function automatic [56:0] CmdWrite32;
	input [21:0] addedoffset;
	input [31:0] cmd;
	begin
		CmdWrite32 = {AddrForWr(RAM_CMD + IncCMDOffset(currentoffset, addedoffset)), Write32(cmd)};
	end
endfunction

function automatic [31:0] be;
	input [31:0] data;
	begin
		be = {data[7:0], data[15:8], data[23:16], data[31:24]};
	end
endfunction

function automatic [56:0] MemWrite32;
    input [21:0] hexadd;
    input [31:0] data;
    begin
        MemWrite32 = {AddrForWr(hexadd), Write32(data)};
    end
endfunction

function automatic [56:0] MemWrite32be;
    input [21:0] hexadd;
    input [31:0] data;
    begin
        MemWrite32be = {AddrForWr(hexadd), data[31:0], 1'b0};
    end
endfunction

function automatic [15:0] IncCMDOffset;
    input [15:0] currentoffset;
    input [15:0] cmdsize; //in bytes
    begin
            IncCMDOffset = currentoffset + cmdsize;
            if (IncCMDOffset > 4095)
                IncCMDOffset = IncCMDOffset - 4096;          
    end
endfunction

function automatic [31:0] XYPOS;
    input [15:0] x;
    input [15:0] y;
    begin
        XYPOS = {y[15:8], y[7:0], x[15:8], x[7:0]};
    end
endfunction

function automatic [31:0] WILE;
    input [15:0] width;
    input [15:0] length;
    begin
        WILE = {length[15:8], length[7:0], width[15:8], width[7:0]};
    end
endfunction

function automatic [31:0] SCISSOR_SIZE;
    input [11:0] width;
    input [11:0] height;
    begin
        SCISSOR_SIZE = {8'h1c, width[11:0], height[11:0]};
    end
endfunction

// TAG_MASK(1) indicates the following graphics object is updated with the value given in this TAG command.
function automatic [31:0] TAG_MASK;
    input mask; //0 or 1
    begin
        TAG_MASK = {8'h14, 23'b0, mask};
    end
endfunction

function automatic [31:0] TAG;
    input [7:0] tag; //from 1 to 255
    begin
        TAG = {8'h3, 16'b0, tag};
    end
endfunction
 
function automatic [31:0] CLEAR_COLOR_RGB;
    input [7:0] Red;
    input [7:0] Green;
    input [7:0] Blue;
    begin
        CLEAR_COLOR_RGB = {8'h02, Blue[7:0], Green[7:0], Red[7:0]};
    end
endfunction

function automatic [31:0] CLEAR_COLOR_RGBc;
    input [23:0] color;
    begin
        CLEAR_COLOR_RGBc = {8'h02, color[7:0], color[15:8], color[23:16]};
    end
endfunction

function automatic [31:0] COLOR_RGB;
    input [7:0] Red;
    input [7:0] Green;
    input [7:0] Blue;
    begin
        COLOR_RGB = {8'h04, Blue[7:0], Green[7:0], Red[7:0]};
    end
endfunction

function automatic [31:0] DISPLAY;
    input dummy;
    begin
        DISPLAY = 0;
    end
endfunction

function automatic [31:0] END;
    input dummy;
    begin
        END = {8'h21, 24'b0};
    end
endfunction

function automatic [31:0] VERTEX2II;
    input [8:0] x;
    input [8:0] y;
    input [4:0] handle;
    input [6:0] char;
    begin
        VERTEX2II = {2'h2, x[8:0], y[8:0], handle[4:0], char[6:0]};
    end
endfunction

function automatic [31:0] CLEAR;
    input color;
    input stencil;
    input tag;
    begin
        CLEAR = {8'h26, 21'b0, color, stencil, tag};
    end
endfunction

function automatic [31:0] BEGIN;
    input [3:0] prim;
    begin
        BEGIN = {8'h1f, 20'b0, prim[3:0]};
    end
endfunction

function automatic [32:0] Write32;
    input [31:0] data;
    begin
        Write32 = {data[7:0], data[15:8], data[23:16], data[31:24], 1'b0};
    end
endfunction

function automatic [31:0] W31;
    input [31:0] data;
    begin
        W31 = {data[7:0], data[15:8], data[23:16], data[31:24]};
    end
endfunction

function automatic [15:0] Write16;
    input [31:0] data;
    begin
        Write16 = {data[7:0], data[15:8]};
    end
endfunction

function automatic [7:0] Write8;
    input [31:0] data;
    begin
        Write8 = {data[7:0]};
    end
endfunction

function automatic [23:0] AddrForWr;
    input [21:0] hexadd;
    begin
        AddrForWr = {2'b10, hexadd[21:0]};
    end
endfunction

function automatic [23:0] AddrForRd;
    input [21:0] hexadd;
    begin
        AddrForRd = {2'b00, hexadd[21:0]};
    end
endfunction

function automatic [32:0] Read32;
    input dummy;
    begin
        Read32 = 0;
    end
endfunction

function automatic [15:0] Read16;
    input dummy;
    begin
        Read16 = 0;
    end
endfunction

function automatic [7:0] Read8;
    input dummy;
    begin
        Read8 = 0;
    end
endfunction

function automatic [39:0] MemWrite16;
    input [21:0] hexadd;
    input [31:0] data;
    begin
        MemWrite16 = {AddrForWr(hexadd), Write16(data)};
    end
endfunction

function automatic [31:0] MemWrite8;
    input [21:0] hexadd;
    input [31:0] data;
    begin
        MemWrite8 = {AddrForWr(hexadd), Write8(data)};
    end
endfunction

function automatic [56:0] MemRead32;
    input [21:0] hexadd;
    input dummy;
    begin
        MemRead32 = {AddrForRd(hexadd), Read32(dummy)};
    end
endfunction

function automatic [47:0] MemRead16;
    input [21:0] hexadd;
    input dummy;
    begin
        MemRead16 = {AddrForRd(hexadd), 8'b0, Read16(dummy)};
    end
endfunction

function automatic [39:0] MemRead8;
    input [21:0] hexadd;
    input dummy;
    begin
        MemRead8 = {AddrForRd(hexadd), 8'b0, Read8(dummy)};
    end
endfunction

function automatic [23:0] CmdWrite;
    input [7:0] cmd;
    input [7:0] param;
    begin
        CmdWrite = {cmd[7:0], param[7:0], 8'b0};
    end
endfunction

//START: DECLARE for INITIALIZATIONS
//reg [5:0] cnt_rst = 0; // counter to delay the reg active after reset
reg clockout = 0;
reg spiclock = 0; //clock for display
reg [5:0] poscount = 0; //position count in the 56-bit series (WR + address + command)
reg active = 0;
reg data_active = 0;
reg [5:0] poscount_active = 0;
reg CS = 1;
reg PD = 0;
reg [19:0] wait_count = 0;
reg [23:0] wait_count0 = 0; // 5ms reset PD down pulse
reg [23:0] wait_count1 = 0; // 20ms wait after reset, PD pulled up
parameter [23:0] bootuptime = 630000; //504 ms
parameter [23:0] resetpulse = 38000; //30.4 ms
parameter [23:0] PDuptime = 3; //60.8 ms
reg [23:0] color = 24'hffffff;
reg [56:0] iniarr [22:0];
//parameter [7:0] countMAX = 110;
parameter [7:0] countMAX = 181;
(* DONT_TOUCH *) // Without this, synthesis could trim the 7-byte words at the end of messages, which results in a nonfunctioning display.
reg [56:0] cmdarr [countMAX:0];
parameter [25:0] hostcmd = 26'b0; // During ACTIVE, send 0's to SDO. Includes two dummy bits (MSB and LSB)
reg iniorcmd = 0;
//END: DECLARE for INITIALIZATIONS    

reg [7:0] count = 0;
//START: DECLARE for DISPLAYLIST
reg [5:0] readbitcount = 0;
reg [5:0] readposcount = 22;
reg [15:0] readtemp = 0;

reg [23:0] wait_count5 = 0; //debounce time

// Arrays to hold: 
// # of touches of a button
reg [1:0]  touch_countarr [10:0];
reg [1:0]  touch_countarr_old [10:0];
// states and colors of buttons
reg [31:0] statearr [10:0];
reg [23:0] colorarr [10:0];
wire [23:0] htrclr [10:0];
// relock state (unlocked, unlock5s/1minute, locked)
wire [1:0] out_relockledsarr [8:0];
reg [23:0] greenarr [8:0];
//    reg [23:0] unlock1minarr [3:0];
// text to display
reg [31:0] textarr[8:0];
// "Tag" (label) of button that was touched
reg [7:0] touchtagarr[10:0];
// Scan and stop status of buttons
reg scanarr [8:0];
reg stoparr [8:0];

// reg touch_count9 = 1;    // stop all servos button
reg touch_count9 = 0;    // start all servos button
reg [2:0] tcnt_cdclr = 0;// cadmium oven mode
reg [2:0] tcnt_mot = 0;  // FM_MOT mode
reg [2:0] tcnt_gain = 0; // gain to adjust

reg [23:0] colorbg = 24'h0;

// Overall stop button state/string
reg [31:0] startorstop = "STRT";
// Starting state of button to select which servo to adjust
reg [31:0] cdclr = "OFF";
reg [31:0] mottxt = "OFF";
// Counter for debouncing 
parameter [23:0] debouncer = 20; //about 34ms
// Variables to record which addresses have been written to/read from this cycle, and which button was touched
reg [15:0] regcmdwrite;
reg [15:0] regcmdread;
reg [7:0] regtouchtag;
reg [7:0] regtouchtag_temp;
//// State variables for gain adjustment buttons, counters, ....
//// ASCII code for N_CNT_1 that is sent to the display.
//wire [23:0] CNT_STR;
//// Counter for net gain adjustment. 
//reg signed [4:0] N_CNT_1 [5:0];
//// Reg to reset the gain increment counter (N_CNT_1) after the gain is programmed from the serial input.
//reg cntrst1_temp; 
//// Control for up/down trigger
//reg gctrl0;

//END: DECLARATIONS for DISPLAYLIST

integer i;
// After a reset, initialize and turn on the display. Commands are from the datasheet.
task assign_initial_values;
begin
    poscount_active <= 25;
    clockout <= 0;
    count <= 0;
    poscount <= 56;
    data_active <= 0;
    active <= 1;
    CS <= 1;
    PD <= 0;
    wait_count <= 0;
    wait_count0 <= 0;
    wait_count1 <= 0;
    wait_count5 <= debouncer;
    spiclock <= 0;
           
    touch_countarr[1]  <= 0;
    touch_countarr[2]  <= 0;
    touch_countarr[3]  <= 0;
    touch_countarr[4]  <= 0;
    touch_countarr[5]  <= 0;
    touch_countarr[6]  <= 0;
    touch_countarr[7]  <= 0;
    touch_countarr[8]  <= 0;
    touch_countarr[9]  <= 0;
    touch_countarr[10] <= 0;
    
    touchtagarr[1]  <= 1;
    touchtagarr[2]  <= 2;
    touchtagarr[3]  <= 3;
    touchtagarr[4]  <= 4;
    touchtagarr[5]  <= 5;
    touchtagarr[6]  <= 6;
    touchtagarr[7]  <= 7;
    touchtagarr[8]  <= 8;
    touchtagarr[9]  <= 9;
    touchtagarr[10] <= 10;
    
    greenarr[1]  <= greenlbo;
    greenarr[2]  <= green542;
    greenarr[3]  <= green820;
    greenarr[4]  <= green1083;
    greenarr[5]  <= green326;
    greenarr[6]  <= green542;
    greenarr[7]  <= green1083;
    greenarr[8]  <= green332;
    
//    htrclr[0] <= red;
//    htrclr[1] <= orange;
//    htrclr[2] <= yellow;
//    htrclr[3] <= green;
//    htrclr[4] <= blue;
//    htrclr[5] <= bluepurple;
//    htrclr[6] <= purple;
//    htrclr[7] <= black;
        
    textarr[1] <= "LBO"; // LBO servo button
    textarr[2] <= "542"; // 542_326 servo button
    textarr[3] <= "820"; // 820 servo button
    textarr[4] <= "1083";// 1083 reference cavity servo button
//    textarr[5] <= "LBO ";// button to select the servo to adjust
//    textarr[6] <= "LCK"; // button to select the gain to adjust
//    textarr[7] <= " + "; // Increment button
//    textarr[8] <= " - "; // Decrement button
    textarr[5] <= "OFF";// Cd Temperature servo button
    textarr[6] <= "542"; // 361 542 button
    textarr[7] <= "1083"; // 361 1083 button
    textarr[8] <= "332"; // 332 button
    // Initializing gain counter for first servo
//    N_CNT_1[0] = 5'd0;
//    N_CNT_1[1] = 5'd0;
//    N_CNT_1[2] = 5'd0;
//    N_CNT_1[3] = 5'd0;
//    N_CNT_1[4] = 5'd0;
//    N_CNT_1[5] = 5'd0;
      
    iniorcmd <= 0;
    color <= 24'hffffff;
    currentoffset <= 0;
    regtouchtag_temp <= 0;
    colorbg <= navy;
    
    iniarr[0]  <= MemWrite32(REG_HCYCLE, HCYCLE);
    iniarr[1]  <= MemWrite32(REG_HOFFSET, HOFFSET);
    iniarr[2]  <= MemWrite32(REG_HSYNC0, HSYNC0);
    iniarr[3]  <= MemWrite32(REG_HSYNC1, HSYNC1);
    iniarr[4]  <= MemWrite32(REG_VCYCLE, VCYCLE);
    iniarr[5]  <= MemWrite32(REG_VOFFSET, VOFFSET);
    iniarr[6]  <= MemWrite32(REG_VSYNC0, VSYNC0);
    iniarr[7]  <= MemWrite32(REG_VSYNC1, VSYNC1);
    iniarr[8]  <= MemWrite32(REG_SWIZZLE, SWIZZLE);
    iniarr[9]  <= MemWrite32(REG_PCLK_POL, PCLK_POL);
    iniarr[10] <= MemWrite32(REG_CSPREAD, CSPREAD);
    iniarr[11] <= MemWrite32(REG_HSIZE, HSIZE);
    iniarr[12] <= MemWrite32(REG_VSIZE, VSIZE);
    
    iniarr[13] <= MemWrite32(RAM_CMD + 0, CMD_DLSTART);
    iniarr[14] <= MemWrite32(RAM_CMD + 4, CLEAR_COLOR_RGBc(color));
    iniarr[15] <= MemWrite32(RAM_CMD + 4*2, CLEAR(1, 1, 1));
    iniarr[16] <= MemWrite32(RAM_CMD + 4*3, CMD_CALIBRATE);
    iniarr[17] <= MemWrite32(RAM_CMD + 4*4, DISPLAY(0));
    iniarr[18] <= MemWrite32(RAM_CMD + 4*5, CMD_SWAP);
    iniarr[19] <= MemWrite32(REG_CMD_WRITE, 24);
    iniarr[20] <= MemWrite32(REG_GPIO_DIR, 32'h80);
    iniarr[21] <= MemWrite32(REG_GPIO, 32'h80);
    iniarr[22] <= MemWrite32(REG_PCLK, PCLK);
       
    cmdarr[0]  <= MemRead32(REG_CMD_WRITE, 0);
    cmdarr[1]  <= MemRead32(REG_CMD_READ, 0);
    cmdarr[2]  <= MemRead32(REG_TOUCH_TAG, 0);
end
endtask

//start: tasks for displaylist

// This task makes a button on the screen.
// Each button takes at least 8 commands in cmdarr.
// The button task has a number of specific cases to make
// the code cleaner, since many of our buttons are the same size and arranged in a line.
// The commands go as:
//  cmdarr[index + 0] = CmdWrite32((4*(index - 3)), CMD_FGCOLOR);
//  cmdarr[index + 1] = CmdWrite32((4*(index - 2)), be({color, 8'b0})); 
//  cmdarr[index + 2] = CmdWrite32((4*(index - 1)), TAG(tag));
//  cmdarr[index + 3] = CmdWrite32((4*index), CMD_BUTTON);
//  cmdarr[index + 4] = CmdWrite32((4*(index + 1)), XYPOS(17*(tag - 11), 56));
//  cmdarr[index + 5] = CmdWrite32((4*(index + 2)), WILE(16, 16));
//  cmdarr[index + 6] = CmdWrite32((4*(index + 3)), font1);
//  cmdarr[index + 7] = CmdWrite32((4*(index + 4)), be(4-byte ASCII text string 0)); // AT LEAST THESE 8 COMMANDS ARE NEEDED TO MAKE A BUTTON
//  cmdarr[index + 8] = CmdWrite32((4*(index + 5)), be(4-byte ASCII text string 1)); // EXTRA TEXT STRINGS
//  cmdarr[index + 9] = CmdWrite32((4*(index + 6)), be(4-byte ASCII text string 2)); // THE LAST STRING MUST END WITH A NULL CHARACTER, 8'h00.
// See the FT81x programmer's guide (v1.2, page 176) for information about button objects.
task button;
    input [7:0] index; // location in cmd memory
    input [7:0] tag;
    
    //buttonsize. 1: servo button, 2: reset/hold button
    parameter [15:0] w1 = 65;
    parameter [15:0] l1 = 55;
    parameter [15:0] w2 = 65;
    parameter [15:0] l2 = 40;
    parameter [31:0] font1 = 32'h100001a; //26
    parameter [31:0] font2 = 32'h1000014; //20
    
    begin
        // Commands to "make" a button in memory, common to all the buttons used
        cmdarr[index] = CmdWrite32((4*(index - 3)), CMD_FGCOLOR);
        cmdarr[index + 2] = CmdWrite32((4*(index - 1)), TAG(tag));
        cmdarr[index + 3] = CmdWrite32((4*index), CMD_BUTTON);
        // This specifies the location and size of the buttons.
        // Each case allows differences of the buttons.
        if (tag < 5)
            cmdarr[index + 4] = CmdWrite32((4*(index + 1)), XYPOS(66*(tag - 1), 0));
        if ((tag >= 5) && (tag <= 8))
            cmdarr[index + 4] = CmdWrite32((4*(index + 1)), XYPOS(66*(tag - 5), 185));
        if ((tag == 9) || (tag == 10))
            cmdarr[index + 4] = CmdWrite32((4*(index + 1)), XYPOS(255, 80 + 41*(tag - 9)));
        if (tag < 9) begin
            cmdarr[index + 5] = CmdWrite32((4*(index + 2)), WILE(w1, l1));
            cmdarr[index + 6] = CmdWrite32((4*(index + 3)), font1);
            cmdarr[index + 1] = CmdWrite32((4*(index - 2)), be({colorarr[tag], 8'b0}));
        end
        if ((tag > 8) && (tag < 11)) begin
            cmdarr[index + 5] = CmdWrite32((4*(index + 2)), WILE(w2, l2));
            cmdarr[index + 6] = CmdWrite32((4*(index + 3)), font2);
            if (tag == 9) begin
                if (startorstop=="STOP")
                     cmdarr[index + 1] = CmdWrite32((4*(index - 2)), be({lightgreen, 8'b0}));
                else cmdarr[index + 1] = CmdWrite32((4*(index - 2)), be({darkerred, 8'b0}));
            end
            if (tag == 10)
                cmdarr[index + 1] = CmdWrite32((4*(index - 2)), be({colorarr[tag], 8'b0})); // end with a byte of zeros
        end
        // Text for these buttons can be 3 byte strings.
        if ((tag < 9) && ((tag != 4) || (tag != 7)))
            cmdarr[index + 7] = CmdWrite32((4*(index + 4)), be({statearr[tag][23:0], 8'b0}));
        if (tag == 10)
            cmdarr[index + 7] = CmdWrite32((4*(index + 4)), be({statearr[tag][23:0], 8'b0}));          
        // These buttons need 4-byte strings to fit all letters (1083 has 4 characters = 4 bytes)
        if ((tag == 4) || (tag == 7)) begin
            cmdarr[index + 7] = CmdWrite32((4*(index + 4)), be(statearr[tag]));
            cmdarr[index + 8] = CmdWrite32((4*(index + 5)), be({" ", 24'b0}));
        end
        // A 12 byte string works for this button. 
//        if (tag == 10) begin
//            cmdarr[index + 7] = CmdWrite32((4*(index + 4)), be(" N ="));
//            cmdarr[index + 8] = CmdWrite32((4*(index + 5)), be({8'h20, CNT_STR}));
//            cmdarr[index + 9] = CmdWrite32((4*(index + 6)), be({" ", 24'b0}));
//        end 
        // if (tag == 10) begin
        //     cmdarr[index + 7] = CmdWrite32((4*(index + 4)), be("ADJ "));
        //     cmdarr[index + 8] = CmdWrite32((4*(index + 5)), be("NONE"));
        //     cmdarr[index + 9] = CmdWrite32((4*(index + 6)), be({" ", 24'b0}));
        // end      

        // This button starts or stops many servos 
        if (tag == 9) begin
            cmdarr[index + 7] = CmdWrite32((4*(index + 4)), be(startorstop));
            cmdarr[index + 8] = CmdWrite32((4*(index + 5)), be(" SER"));
            cmdarr[index + 9] = CmdWrite32((4*(index + 6)), be({"VO", 16'b0}));
        end
        // Small buttons to indicate temperature servo error signals
        if (tag>10) begin
            cmdarr[index + 1] = CmdWrite32((4*(index - 2)), be({htrclr[tag - 10], 8'b0}));
            cmdarr[index + 4] = CmdWrite32((4*(index + 1)), XYPOS(17*(tag - 11), 56));
            cmdarr[index + 5] = CmdWrite32((4*(index + 2)), WILE(16, 16));
            cmdarr[index + 6] = CmdWrite32((4*(index + 3)), font1);
            cmdarr[index + 7] = CmdWrite32((4*(index + 4)), be(32'b0));     
        end           
    end
endtask
//end: tasks for displaylist

// This executes after initialization, and whenever a change (button touch) is detected by the display.
// Starting and ending commands are from the display manual. 
// cmdarr is an array of length countMAX where each element contains a 56-bit command for the display.
// 5 commands set the appearance and behavior of a display button, and an additional command for each character label of that button.
// So a 3 character button uses 8 cmdarr elements, and a 4 character button uses 9 element. 
// Thus, to add a new button, countMAX must be increased by at least 8.
// Therefore, the first argument of successive button tasks below increases by at least 8. 
task assign_displaylist;
    begin
        cmdarr[3] <= CmdWrite32((4*0), CMD_DLSTART);
        cmdarr[4] <= CmdWrite32((4*1), CLEAR_COLOR_RGBc(colorbg));
        cmdarr[5] <= CmdWrite32((4*2), CLEAR(1, 1, 1));
        cmdarr[6] <= CmdWrite32((4*3), TAG_MASK(1));
        // LBO button
        button(7, 1);
        // BBO 542 button
        button(15, 2);
        // 820 button
        button(23, 3);
        // 1083 reference cavity button
        button(31, 4);
        // Cd oven button
        button(40, 5);
        // 542 361
        button(48, 6);
        // 1083 361
        button(56, 7);
        // 332 button
        button(65, 8);
        // Start/stop servo button
        button(73, 9);
        // FM MOT button
        button(83, 10);
        
        // Temperature servo status lights
        button(91 , 11);//Cd oven
        button(99 , 12);
        button(107, 13);
        button(115, 14);
        button(123, 15);
        button(131, 16);
        button(139, 17);
        button(147, 18);
        button(155, 19);
        button(163, 20);
//        button(172, 21);
//        button(180, 22);
//        button(188, 23);
//        button(196, 24);
//        button(204, 25);
//        button(212, 26);
           
        cmdarr[countMAX-10] <= CmdWrite32((4*(countMAX-13)), CMD_TEXT);
        cmdarr[countMAX-9] <= CmdWrite32((4*(countMAX-12)), XYPOS(10, 100));
        cmdarr[countMAX-8] <= CmdWrite32((4*(countMAX-11)), 32'h100001f);
        // Large Display Text
        cmdarr[countMAX-7] <= CmdWrite32((4*(countMAX-10)), be("PSU "));
        cmdarr[countMAX-6] <= CmdWrite32((4*(countMAX-9)), be({"Cd", 16'b0}));
        cmdarr[countMAX-5] <= CmdWrite32((4*(countMAX-8)), DISPLAY(0));
        cmdarr[countMAX-4] <= CmdWrite32((4*(countMAX-7)), CMD_SWAP);
        cmdarr[countMAX-3] <= MemWrite32(REG_CMD_WRITE, IncCMDOffset(currentoffset, 4*(countMAX-6)));
        cmdarr[countMAX-2] <= MemRead32(REG_CMD_WRITE, 0);
        cmdarr[countMAX-1] <= MemRead32(REG_CMD_READ, 0);
        cmdarr[countMAX] <= MemRead32(REG_TOUCH_TAG, 0); 
        
    end
endtask