`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2017 02:42:22 PM
// Design Name: 
// Module Name: sequencer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sequencer #(parameter NUM_STEPS=0)
    (input clock,
    input start_seq,
    input [(NUM_STEPS*3)-1:0] sequence,
    output seq_done,
    output [3:0] next_move,
    output start_move,
    input move_done
    );
    
    
    
endmodule
