`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: JoeCorp, a Joe Corporation
// 
// Create Date: 10/1/2015 V1.0
// Design Name: verilog_i2c
// Module Name: labkit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: real simple i2c implementation to get accelerations from mpu9250
// 
// Dependencies: 
//  swiezy being dumb 
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module main(
   input CLK100MHZ,
   input[15:0] SW, 
   input BTNC, BTNU, BTNL, BTNR, BTND,
   inout[7:0] JA, 
   inout[7:0] JB,
   inout[7:0] JC,
   output[15:0] LED,
   output[7:0] SEG,  // segments A-G (0-6), DP (7)
   output[7:0] AN    // Display 0-7
   );
   

// create 25mhz system clock
    wire clock_25mhz;
    clock_quarter_divider clockgen(.clk100_mhz(CLK100MHZ), .clock_25mhz(clock_25mhz));

//  instantiate 7-segment display;  
    wire [31:0] data;
    wire [6:0] segments;
    display_8hex display(.clk(clock_25mhz),.data(data), .seg(segments), .strobe(AN));    
    assign SEG[6:0] = segments;
    assign SEG[7] = 1'b1;
    
    wire debounce_BTNC;
    wire debounce_BTNU;
    wire debounce_BTNL;
    wire debounce_BTNR;
    wire debounce_BTND;
    wire reset;
    
//    debounce btnc_deb(.reset(reset), .clock(clock_25mhz), .noisy(BTNC), .clean(debounce_BTNC));
//    debounce btnu_deb(.reset(reset), .clock(clock_25mhz), .noisy(BTNU), .clean(debounce_BTNU));
//    debounce btnl_deb(.reset(reset), .clock(clock_25mhz), .noisy(BTNL), .clean(debounce_BTNL));
//    debounce btnr_deb(.reset(reset), .clock(clock_25mhz), .noisy(BTNR), .clean(debounce_BTNR));
//    debounce btnd_deb(.reset(reset), .clock(clock_25mhz), .noisy(BTND), .clean(debounce_BTND));
    
    assign reset = SW[15];
     
    reg [15:0] led_state = 16'd0;
    
    // STEPPERS
    wire disable_steppers;
    assign disable_steppers = SW[1];
    
    wire stepper_dir_pin;
    wire stepper_step_pin;
    wire [5:0] stepper_en_pins;
    
    assign JB[2] = stepper_dir_pin;
    assign JB[6] = stepper_step_pin;
    
    localparam RIGHT = 0;
    localparam UP = 1;
    localparam FRONT = 2;
    localparam LEFT = 3;
    localparam BACK = 4;
    localparam DOWN = 5;
    
    assign JB[3] = stepper_en_pins[FRONT];
    assign JB[1] = stepper_en_pins[RIGHT];
    assign JB[0] = stepper_en_pins[BACK];
    assign JB[5] = stepper_en_pins[LEFT];
    assign JB[4] = stepper_en_pins[DOWN];
    assign JB[7] = stepper_en_pins[UP];
    
    wire [3:0] next_move;
    wire move_start;
    wire move_done;
    
    move_to_step steppers(.disable_steppers(disable_steppers),  .clock(clock_25mhz), .reset(reset), .next_move(next_move), .move_start(move_start), .move_done(move_done), .dir_pin(stepper_dir_pin), .step_pin(stepper_step_pin), .en_pins(stepper_en_pins));

    // COLOR SENSORS
    wire [2:0] edge_color;
    wire [2:0] corner_color;
    wire i2c_clock;
    
    wire [7:0] r_edge;
    wire [7:0] g_edge;
    wire [7:0] b_edge;
    wire [7:0] r_corner;
    wire [7:0] g_corner;
    wire [7:0] b_corner;
    
    wire [47:0] corner_val;
    wire [47:0] edge_val;
    
    assign r_edge = edge_val[31:24];
    assign g_edge = edge_val[15:8];
    assign b_edge = edge_val[47:40];
    assign r_corner = corner_val[31:24];
    assign g_corner = corner_val[15:8];
    assign b_corner = corner_val[47:40];
    
    clock_200khz clock_for_i2c(.reset(reset), .clock(clock_25mhz), .slow_clock(i2c_clock));
    
    color_sensor edge_reader(.value(edge_val), .scl(JA[3]), .sda(JA[2]), .clock(clock_25mhz), .scl_clock(i2c_clock), .reset(reset));
    color_sensor corner_reader(.value(corner_val), .scl(JA[1]), .sda(JA[0]), .clock(clock_25mhz), .scl_clock(i2c_clock), .reset(reset));
    
    color_translator(.clock(clock_25mhz), .r_edge(r_edge), .g_edge(g_edge), .b_edge(b_edge), .r_corner(r_corner), .g_corner(g_corner), .b_corner(b_corner), .color_edge(edge_color), .color_corner(corner_color));
    
    //CONSTANTS
    // the values used to represent colors in cubestate register
    parameter W = 3'd0;
    parameter O = 3'd1;
    parameter G = 3'd2;
    parameter Red = 3'd3;
    parameter Blue = 3'd4;
    parameter Y = 3'd5;    
    // moves
    parameter R = 4'd2;     //0010 2
    parameter Ri = 4'd3;    //0011 3
    parameter U = 4'd4;     //0100 4
    parameter Ui = 4'd5;    //0101 5
    parameter F = 4'd6;     //0110 6
    parameter Fi = 4'd7;    //0111 7
    parameter L = 4'd8;     //1000 8
    parameter Li = 4'd9;    //1001 9
    parameter B = 4'd10;    //1010 a
    parameter Bi = 4'd11;   //1011 b
    parameter D = 4'd12;    //1100 c
    parameter Di = 4'd13;   //1101 d
    
    //TEST CASES    
    reg [161:0] cubestate_initial [7:0];

    initial begin        
        // B2 U2 D R B' L U' L' D' F B2 U' D2 L2 D B2 D' F2 D2 R2 (fuck)
        cubestate_initial[0] = {Y,Blue,Red,G,O,W,O,G,Y,W,O,G,Red,Red,W,G,Blue,Blue,Red,Y,Y,O,Blue,W,Red,Blue,W,G,O,Y,Y,W,Blue,O,Red,Red,Y,W,Blue,Blue,G,G,Red,Red,Blue,O,G,W,Y,O,W,Y,G,O};
        // scramble: U F L' U' R F' D L D2 F R B2 L B2 R' F2 R2 B2 U2 R B2    
        //                     |----centers-----|----edges----edges----edges----edges----edges----edges----edges----|----corners----corners----corners----corners----corners----corners-|
        cubestate_initial[1] = {Y,Blue,Red,G,O,W,Y,O,Red,Red,Blue,W,G,Red,G,Blue,Y,G,O,Y,W,O,W,G,Red,Blue,O,Blue,Y,W,W,Blue,Y,W,W,G,Blue,Blue,Red,G,Blue,Red,W,Red,O,G,Red,Y,G,O,Y,O,O,Y};
        
        // scramble: F' U2 F2 D2 B' R2 F' D2 F' L2 F2 R' U B' L R B F2 D' U
        //                     |----centers-----|----edges----edges----edges----edges----edges----edges----edges----|----corners----corners----corners----corners----corners----corners-|
        cubestate_initial[2] = {Y,Blue,Red,G,O,W,Red,O,G,Blue,Y,Y,Red,G,Red,W,G,O,O,Blue,W,O,Red,Blue,W,W,Blue,Y,Y,G,O,Blue,Red,G,Red,O,W,W,Y,W,G,G,O,Blue,Y,Y,G,Blue,Red,Blue,Y,W,O,Red};
        
        // scramble: U' F2 R2 L F2 B L2 U2 R F' U' B2 R2 L2 D F2 U' L2 B2 U' L2
        //                     |----centers-----|----edges----edges----edges----edges----edges----edges----edges----|----corners----corners----corners----corners----corners----corners-|
        cubestate_initial[3] = {Y,Blue,Red,G,O,W,W,Y,G,Blue,O,Blue,Y,G,Red,Red,Red,O,Blue,G,Red,G,O,Y,Y,W,Blue,W,O,W,O,Blue,W,Y,Red,Blue,Blue,Red,Y,G,Red,O,W,W,G,Red,O,Y,O,G,Y,Blue,G,W};
        // solved cube
        cubestate_initial[4] = {Y,Blue,Red,G,O,W,Y,Y,Y,Y,Blue,Blue,Blue,Blue,Red,Red,Red,Red,G,G,G,G,O,O,O,O,W,W,W,W,Y,Y,Y,Y,Blue,Blue,Blue,Blue,Red,Red,Red,Red,G,G,G,G,O,O,O,O,W,W,W,W};
        // g perm
        cubestate_initial[5] = {Y,Blue,Red,G,O,W,Y,Y,Y,Y,Blue,Blue,Blue,Blue,Red,Red,Red,G,O,G,G,G,O,Red,O,O,W,W,W,W,Y,Y,Y,Y,Blue,G,Blue,Blue,Red,Red,Blue,O,Red,G,G,Red,O,G,O,O,W,W,W,W};

    end
    
    //SOLVING ALGORITHM, SEQUENCER, AND STATE DETERMINATION
    reg seq_complete = 0;
    wire [199:0] new_moves_to_queue;
    wire [7:0] num_moves_loaded;
    wire [7:0] current_step;
    wire seq_done;

    reg [161:0] cubestate_for_solving_algorithm;
    wire [161:0] cubestate_updated;
    wire cube_solution_finished;
    wire new_moves_ready;
    wire state_updated;
    reg start_finding_solution=0;
    wire find_next_set_of_moves; //use this to pasue solving alg while doing other calculations
    wire [2:0] step_stuff;
    wire [1:0] state_stuff;
    wire [1:0] pcs;
    
    reg send_ser_data = 0;
    wire sent_ser_data;
    wire [2:0] ser_state;
    
    wire sensor_stable;
    reg ready_to_observe = 0;
    reg start_finding_state = 0;
    wire send_setup_moves;
    wire [5:0] setup_counter;
    wire [161:0] initial_cubestate;
    wire queue_fin;
    reg start_sens_stability_timer = 0;
    wire initial_state_found;
    
    reg determining_state = 1;
    //TODO: use this to decide what is inputted into sequencer
    wire [199:0] new_moves_to_queue_state;
    wire [199:0] new_moves_to_queue_solve;
    wire new_moves_ready_state;
    wire new_moves_ready_solve;
    
    assign new_moves_to_queue = (determining_state) ? new_moves_to_queue_state:new_moves_to_queue_solve;
    assign new_moves_ready = (determining_state) ? new_moves_ready_state:new_moves_ready_solve;

    solving_algorithm sa(.reset(reset),.step_stuff(step_stuff),.state_stuff(state_stuff),.start(start_finding_solution),.clock(clock_25mhz),.cubestate(cubestate_for_solving_algorithm),.state_updated(state_updated),.next_moves(new_moves_to_queue_solve),.cube_solved(cube_solution_finished),.new_moves_ready(new_moves_ready_solve),.piece_counter_stuff(pcs));
    update_state us(.clock(clock_25mhz),.moves_input(new_moves_to_queue_solve),.new_moves_ready(new_moves_ready_solve),.cubestate_input(cubestate_for_solving_algorithm),.cubestate_updated(cubestate_updated),.state_updated(state_updated));
    
    determine_state ds(.reset(reset), .start(start_finding_state), .edge_color_sensor(edge_color), .corner_color_sensor(corner_color), .color_sensor_stable(ready_to_observe), .clock(clock_25mhz), .send_setup_moves(send_setup_moves), .counter(setup_counter), .cubestate_output(initial_cubestate), .cubestate_determined(initial_state_found));
    spin_all spin_it(.send_setup_moves(send_setup_moves), .clock(clock_25mhz), .counter(setup_counter), .moves(new_moves_to_queue_state), .new_moves(new_moves_ready_state));
    delay_timer #(.DURATION(1000)) dt(.clock(clock_25mhz), .reset(reset), .start(start_sens_stability_timer), .done(sensor_stable));
    
    sequencer seq(.finished_queue(queue_fin), .reset(reset), .clock(clock_25mhz), .seq_complete(seq_complete), .new_moves(new_moves_ready), .seq(new_moves_to_queue), .seq_done(seq_done), .next_move(next_move), .start_move(move_start), .num_moves(num_moves_loaded), .curr_step(current_step), .move_done(move_done));
        
    
    //STATE MACHINE
    parameter LOAD_INIT_STATE = 5'd0;
    parameter FIND_SOLUTION = 5'd1;
    parameter DONE_PLANNING_SOLUTION = 5'd2;
    parameter CALCULATE_NEW_STATE = 5'd3;
    parameter SEND_STATE1 = 5'd4;
    parameter SEND_STATE2 = 5'd5;
    parameter FIND_INIT_STATE = 5'd6;
    parameter WAIT_FOR_QUEUE = 5'd7;
    parameter WAIT_FOR_MOVE1 = 5'd8;
    parameter WAIT_FOR_MOVE2 = 5'd9;
    parameter WAIT_FOR_SENSOR1 = 5'd10;
    parameter WAIT_FOR_SENSOR2 = 5'd11;
    parameter SEND_INIT_STATE1 = 5'd12;
    parameter SEND_INIT_STATE2 = 5'd13;
    parameter OBSERVE_SENSORS = 5'd14;
    
    reg [4:0] state = 0;

    always @(posedge clock_25mhz) begin
        if (reset) begin
            seq_complete <= 0;
            state <= (SW[3]) ? LOAD_INIT_STATE:FIND_INIT_STATE;
            determining_state <= 1;
            start_finding_solution <= 0;
        end else if(SW[14])begin
            state <= DONE_PLANNING_SOLUTION;
        end else begin
            case (state)
                FIND_INIT_STATE: begin
                    determining_state <= 1;
                    start_finding_state <= 1;
                    state <= WAIT_FOR_QUEUE;
                end
                WAIT_FOR_QUEUE: begin
                    ready_to_observe <= 0;
                    start_finding_state <= 0;
                    if(!initial_state_found)begin
                        state <= (queue_fin) ? WAIT_FOR_MOVE1:WAIT_FOR_QUEUE;
                    end else begin
                        state <= LOAD_INIT_STATE;
                    end
                end
                WAIT_FOR_MOVE1: begin
                    seq_complete <= 1;
                    state <= WAIT_FOR_MOVE2;
                end
                WAIT_FOR_MOVE2: begin
                    seq_complete <= 0;
                    state <= (seq_done) ? WAIT_FOR_SENSOR1:WAIT_FOR_MOVE2;
                end
                WAIT_FOR_SENSOR1: begin
                    start_sens_stability_timer <= 1;
                    state <= WAIT_FOR_SENSOR2;
                end
                WAIT_FOR_SENSOR2: begin
                    start_sens_stability_timer <= 0;
                    state <= (sensor_stable) ? OBSERVE_SENSORS:WAIT_FOR_SENSOR2;
                end
                OBSERVE_SENSORS: begin
                    ready_to_observe <= 1;
                    state <= WAIT_FOR_QUEUE;
                end
                
                SEND_INIT_STATE1: begin
                    send_ser_data <= 1;
                    state <= (sent_ser_data) ? SEND_INIT_STATE1:SEND_INIT_STATE2;
                end
                SEND_INIT_STATE2: begin
                    send_ser_data <= 0;
                    state <= (sent_ser_data) ? FIND_SOLUTION:SEND_INIT_STATE2;
                end
                
                LOAD_INIT_STATE: begin
                    cubestate_for_solving_algorithm <= (SW[3]) ? cubestate_initial[SW[13:11]]:initial_cubestate;
                    determining_state <= 0;
                    state <= SEND_INIT_STATE1;
                end

                FIND_SOLUTION: begin
                    // we don't want to fuck with the input cubestate here
                    start_finding_solution <= 1;
                    if (cube_solution_finished) state <= DONE_PLANNING_SOLUTION;
                    else if (num_moves_loaded >= 200) state <= DONE_PLANNING_SOLUTION;
                    else if (new_moves_ready) state <= CALCULATE_NEW_STATE;
                    else state <= FIND_SOLUTION;
                end

                CALCULATE_NEW_STATE: begin
                    // the first time we enter this state, we want to change the input cubestate to solving_algorithm from
                    // cubestate_initial to cubestate_updated, which is produced by update_state.v module
                    cubestate_for_solving_algorithm <= cubestate_updated;
                    state <= (state_updated) ? ((SW[2]) ? SEND_STATE1:FIND_SOLUTION) : CALCULATE_NEW_STATE;
                end
                SEND_STATE1: begin
                    send_ser_data <= 1;
                    state <= (sent_ser_data) ? SEND_STATE1:SEND_STATE2;
                end
                SEND_STATE2: begin
                    send_ser_data <= 0;
                    state <= (sent_ser_data) ? FIND_SOLUTION:SEND_STATE2;
                end

                DONE_PLANNING_SOLUTION: begin
                    seq_complete <= 1;
                    state <= DONE_PLANNING_SOLUTION;
                end
            
                default : state <= LOAD_INIT_STATE;
            endcase
        end
    end
    
    //USER DEBUG OUTPUT
    assign data = (SW[0]) ? {1'h0, step_stuff, 2'h0, pcs, state, next_move, 2'h0, setup_counter, num_moves_loaded} : {r_edge[3:0], g_edge[3:0], b_edge[3:0], 1'h0, edge_color, r_corner[3:0], g_corner[3:0], b_corner[3:0], 1'h0, corner_color};
    assign LED[0] = cube_solution_finished;
    assign LED[1] = !disable_steppers;
    assign LED[2] = determining_state;
    assign LED[13:11] = SW[13:11];
    assign LED[3] = sent_ser_data;
    
    serial ser(.state(ser_state), .reset(reset), .clock(clock_25mhz), .send_data(send_ser_data), .data(cubestate_for_solving_algorithm), .tx_pin(JC[3]), .data_sent(sent_ser_data));
        
endmodule

module clock_quarter_divider(input clk100_mhz, output reg clock_25mhz = 0);
    reg counter = 0;
    
    always @(posedge clk100_mhz) begin
        counter <= counter + 1;
        if (counter == 0) begin
            clock_25mhz <= ~clock_25mhz;
        end
    end
endmodule
