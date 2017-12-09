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
    input reset,
    input disable_steppers,
    input [3:0] next_move,
    input move_start,
    output move_done,
    output dir_pin,
    output step_pin,
    output [5:0] en_pins
    );
    
    localparam QUARTER_TURN = 51;
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
    
    localparam CLOCK_100HZ = 124999;
    localparam CLOCK_200HZ = 62499;
    localparam CLOCK_400HZ = 31249;
    localparam CLOCK_450HZ = 27777;
    localparam CLOCK_500HZ = 24999;
    localparam CLOCK_600HZ = 20832;
    localparam CLOCK_800HZ = 15624;
    
    localparam BETWEEN_STEP_DELAY = 400;
    
    wire step_clock;
    clock_100hz #(.CLOCK_PERIOD(CLOCK_400HZ)) local_clock(.reset(move_start), .clock(clock), .slow_clock(step_clock));
    assign step_pin = step_clock;
    
    wire dir;
    assign dir_pin = !next_move[0];
    
    wire [5:0] start;
    assign start[RIGHT] = (next_move[3:1] == R[3:1]) & move_start & !reset & !disable_steppers;
    assign start[UP] = (next_move[3:1] == U[3:1]) & move_start & !reset & !disable_steppers;
    assign start[FRONT] = (next_move[3:1] == F[3:1]) & move_start & !reset & !disable_steppers;
    assign start[LEFT] = (next_move[3:1] == L[3:1]) & move_start & !reset & !disable_steppers;
    assign start[BACK] = (next_move[3:1] == B[3:1]) & move_start & !reset & !disable_steppers;
    assign start[DOWN] = (next_move[3:1] == D[3:1]) & move_start & !reset & !disable_steppers;

    wire [5:0] done;
    assign move_done = &done;  
    
    stepper_driver #(.END_MOVE_DELAY(BETWEEN_STEP_DELAY)) up_stepper(.clock(clock), .step_clock(step_clock), .start(start[UP]), .steps(QUARTER_TURN), .en_out(en_pins[UP]), .done(done[UP]));
    stepper_driver #(.END_MOVE_DELAY(BETWEEN_STEP_DELAY)) down_stepper(.clock(clock), .step_clock(step_clock), .start(start[DOWN]), .steps(QUARTER_TURN), .en_out(en_pins[DOWN]), .done(done[DOWN]));
    stepper_driver #(.END_MOVE_DELAY(BETWEEN_STEP_DELAY)) right_stepper(.clock(clock), .step_clock(step_clock), .start(start[RIGHT]), .steps(QUARTER_TURN), .en_out(en_pins[RIGHT]), .done(done[RIGHT]));
    stepper_driver #(.END_MOVE_DELAY(BETWEEN_STEP_DELAY)) left_stepper(.clock(clock), .step_clock(step_clock), .start(start[LEFT]), .steps(QUARTER_TURN), .en_out(en_pins[LEFT]), .done(done[LEFT]));
    stepper_driver #(.END_MOVE_DELAY(BETWEEN_STEP_DELAY)) front_stepper(.clock(clock), .step_clock(step_clock), .start(start[FRONT]), .steps(QUARTER_TURN), .en_out(en_pins[FRONT]), .done(done[FRONT]));
    stepper_driver #(.END_MOVE_DELAY(BETWEEN_STEP_DELAY)) back_stepper(.clock(clock), .step_clock(step_clock), .start(start[BACK]), .steps(QUARTER_TURN), .en_out(en_pins[BACK]), .done(done[BACK]));
    
endmodule
