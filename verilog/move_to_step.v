`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2017 09:08:47 PM
// Design Name: 
// Module Name: move_to_step
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


module move_to_step(
    input clock,
    input [3:0] next_move,
    input move_start,
    output move_done,
    output [5:0] dir_pin,
    output [5:0] step_pin
    );
    
    localparam QUARTER_TURN = 50;
    localparam HALF_TURN = 100;
    localparam FULL_TURN = 200;
    
    localparam RIGHT = 0;
    localparam UP = 1;
    localparam FRONT = 2;
    localparam LEFT = 3;
    localparam BACK = 4;
    localparam DOWN = 5;
    
    localparam R = 0;
    localparam RI = 1;
    localparam U = 2;
    localparam UI = 3;
    localparam F = 4;
    localparam FI = 5;
    localparam L = 6;
    localparam LI = 7;
    localparam B = 8;
    localparam BI = 9;
    localparam D = 10;
    localparam DI = 11;
    
    wire step_clock;
    clock_100hz local_clock(.reset(move_start), .clock(clock), .slow_clock(step_clock));
    
    wire dir;
    assign dir = next_move[0];
    
    wire [5:0] start;
    assign start[UP] = (next_move==U | next_move==UI) & move_start;
    assign start[DOWN] = (next_move==D | next_move==DI) & move_start;
    assign start[RIGHT] = (next_move==R | next_move==RI) & move_start;
    assign start[LEFT] = (next_move==L | next_move==LI) & move_start;
    assign start[FRONT] = (next_move==F | next_move==FI) & move_start;
    assign start[BACK] = (next_move==B | next_move==BI) & move_start;

    wire [5:0] done;  
    assign move_done = &done;  
    
    stepper_driver up_stepper(.clock(clock), .step_clock(step_clock), .start(start[UP]), .dir_in(dir), .steps(QUARTER_TURN), .dir_out(dir_pin[UP]), .step_out(step_pin[UP]), .done(done[UP]));
    stepper_driver down_stepper(.clock(clock), .step_clock(step_clock), .start(start[DOWN]), .dir_in(dir), .steps(QUARTER_TURN), .dir_out(dir_pin[DOWN]), .step_out(step_pin[DOWN]), .done(done[DOWN]));
    stepper_driver right_stepper(.clock(clock), .step_clock(step_clock), .start(start[RIGHT]), .dir_in(dir), .steps(QUARTER_TURN), .dir_out(dir_pin[RIGHT]), .step_out(step_pin[RIGHT]), .done(done[RIGHT]));
    stepper_driver left_stepper(.clock(clock), .step_clock(step_clock), .start(start[LEFT]), .dir_in(dir), .steps(QUARTER_TURN), .dir_out(dir_pin[LEFT]), .step_out(step_pin[LEFT]), .done(done[LEFT]));
    stepper_driver front_stepper(.clock(clock), .step_clock(step_clock), .start(start[FRONT]), .dir_in(dir), .steps(QUARTER_TURN), .dir_out(dir_pin[FRONT]), .step_out(step_pin[FRONT]), .done(done[FRONT]));
    stepper_driver back_stepper(.clock(clock), .step_clock(step_clock), .start(start[BACK]), .dir_in(dir), .steps(QUARTER_TURN), .dir_out(dir_pin[BACK]), .step_out(step_pin[BACK]), .done(done[BACK]));
    
endmodule
