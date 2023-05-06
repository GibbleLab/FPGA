`timescale 1ns / 1ps // <simulation time step> / <simulation time step precision>
//////////////////////////////////////////////////////////////////////////////////
// Generates logic signals for being unlocked, or unlocked in the past 5 seconds
// Bit 0 is unlocked in last 5 seconds, bit 1 is unlocked (0 if locked)
//
// Daniel Schussheim and Kurt Gibble
//////////////////////////////////////////////////////////////////////////////////


module RelockLEDs(
    input wire clk_in,
    input wire relock_on,
    output reg [1:0] out
);
    
//State machine for relock LEDs
localparam [1:0] LOCKED       = 2'b00,
                 UNLOCKED     = 2'b01,
                 UNLOCKED1S   = 2'b10,
                 UNLOCKED1MIN = 2'b11; // currently unused.
//Combinatorial part
function [1:0] relock_next_state;
    input        relock_on;
    input [1:0]  state;
    input [32:0] counter;
    begin 
        case(state)
            LOCKED:
                if (relock_on)
                    relock_next_state = UNLOCKED; //If below threshold and previously locked, set to unlocked
                else
                    relock_next_state = LOCKED; //Otherwise still locked
            UNLOCKED:
                if (relock_on)
                    relock_next_state = UNLOCKED; // not locked
                else
                    relock_next_state = UNLOCKED1S; // Otherwise, locked and start 5s counter
            UNLOCKED1S:
                if (relock_on)
                    relock_next_state = UNLOCKED; // If lock is lost within 5s of locking, set to unlocked
                else if ( (~relock_on) && (counter < 33'd500_000_000) ) // 5 seconds
                    relock_next_state = UNLOCKED1S; //If locked and counting, stay in counter state
                else
                    relock_next_state = LOCKED; // If locked when counter finishes, set to locked 
//                    relock_next_state = UNLOCKED1MIN; // If locked when counter finishes, set to locked 
//            UNLOCKED1MIN:
//                if (relock_on)
//                    relock_next_state = UNLOCKED; // If lock is lost within 1 min of locking, set to unlocked
//                else if ( (~relock_on) && (counter < 33'd6_000_000_000) ) // 1 minute
//                    relock_next_state = UNLOCKED1MIN; // If locked and counting, stay in counter state 
//                else
//                    relock_next_state = LOCKED; // If locked when counter finishes, set to locked 
            default:
                relock_next_state = UNLOCKED;
        endcase
    end
endfunction
//Sequential part
reg [32:0] relock_counter = 33'b0; //Counter for led that stays on 5s after relocked
reg [1:0] relock_state;
always @(posedge clk_in) begin
    relock_state <= relock_next_state(relock_on, relock_state, relock_counter);
    out <= relock_state;
    if (relock_state == UNLOCKED1S)
        relock_counter <= relock_counter + 33'b1;
    else
        relock_counter <= 33'b0;
end
    
endmodule