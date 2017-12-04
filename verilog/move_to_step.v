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
    output dir_pin,
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
    
    // moves
    localparam R = 4'd2;
    localparam Ri = 4'd3;
    localparam U = 4'd4;
    localparam Ui = 4'd5;
    localparam F = 4'd6;
    localparam Fi = 4'd7;
    localparam L = 4'd8;
    localparam Li = 4'd9;
    localparam B = 4'd10;
    localparam Bi = 4'd11;
    localparam D = 4'd12;
    localparam Di = 4'd13;
    localparam NULL = 4'd15;
    
    wire step_clock;
    clock_100hz local_clock(.reset(move_start), .clock(clock), .slow_clock(step_clock));
    
    wire dir;
    assign dir_pin = next_move[0];
    
    wire [5:0] start;
    assign start[RIGHT] = (next_move[3:1] == R[3:1]) & move_start;
    assign start[UP] = (next_move[3:1] == U[3:1]) & move_start;
    assign start[FRONT] = (next_move[3:1] == F[3:1]) & move_start;
    assign start[LEFT] = (next_move[3:1] == L[3:1]) & move_start;
    assign start[BACK] = (next_move[3:1] == B[3:1]) & move_start;
    assign start[DOWN] = (next_move[3:1] == D[3:1]) & move_start;

    wire [5:0] done;
    assign move_done = &done;  
    
    stepper_driver up_stepper(.clock(clock), .step_clock(step_clock), .start(start[UP]), .steps(QUARTER_TURN), .step_out(step_pin[UP]), .done(done[UP]));
    stepper_driver down_stepper(.clock(clock), .step_clock(step_clock), .start(start[DOWN]), .steps(QUARTER_TURN), .step_out(step_pin[DOWN]), .done(done[DOWN]));
    stepper_driver right_stepper(.clock(clock), .step_clock(step_clock), .start(start[RIGHT]), .steps(QUARTER_TURN), .step_out(step_pin[RIGHT]), .done(done[RIGHT]));
    stepper_driver left_stepper(.clock(clock), .step_clock(step_clock), .start(start[LEFT]), .steps(QUARTER_TURN), .step_out(step_pin[LEFT]), .done(done[LEFT]));
    stepper_driver front_stepper(.clock(clock), .step_clock(step_clock), .start(start[FRONT]), .steps(QUARTER_TURN), .step_out(step_pin[FRONT]), .done(done[FRONT]));
    stepper_driver back_stepper(.clock(clock), .step_clock(step_clock), .start(start[BACK]), .steps(QUARTER_TURN), .step_out(step_pin[BACK]), .done(done[BACK]));
    
endmodule
