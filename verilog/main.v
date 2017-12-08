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
    
    debounce btnc_deb(.reset(reset), .clock(clock_25mhz), .noisy(BTNC), .clean(debounce_BTNC));
    debounce btnu_deb(.reset(reset), .clock(clock_25mhz), .noisy(BTNU), .clean(debounce_BTNU));
    debounce btnl_deb(.reset(reset), .clock(clock_25mhz), .noisy(BTNL), .clean(debounce_BTNL));
    debounce btnr_deb(.reset(reset), .clock(clock_25mhz), .noisy(BTNR), .clean(debounce_BTNR));
    debounce btnd_deb(.reset(reset), .clock(clock_25mhz), .noisy(BTND), .clean(debounce_BTND));
    
    assign reset = SW[15];
     
    reg [15:0] led_state = 16'd0;
    
    // STEPPERS
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
    
//    assign JB[3] = stepper_en_pins[0];
//    assign JB[1] = stepper_en_pins[1];
//    assign JB[0] = stepper_en_pins[2];
//    assign JB[5] = stepper_en_pins[3];
//    assign JB[4] = stepper_en_pins[4];
//    assign JB[7] = stepper_en_pins[5];
    
    wire [3:0] next_move;
    wire move_start;
    wire move_done;
    
    move_to_step steppers(.clock(clock_25mhz), .reset(reset), .next_move(next_move), .move_start(move_start), .move_done(move_done), .dir_pin(stepper_dir_pin), .step_pin(stepper_step_pin), .en_pins(stepper_en_pins));

    
    // COLOR SENSORS
    wire [2:0] edge_color;
    wire [2:0] corner_color;
    wire i2c_clock;
    
    wire [7:0] red;
    wire [7:0] green;
    wire [7:0] blue;
    
    clock_200khz clock_for_i2c(.reset(reset), .clock(clock_25mhz), .slow_clock(i2c_clock));
    
    color_reader edge_reader(.state(LED[15]), .red(red), .green(green), .blue(blue), .sda(JA[3]), .scl(JA[2]), .clock(clock_25mhz), .scl_clock(i2c_clock), .reset(reset), .color(edge_color));
//    color_reader corner_reader(.sda(JA[1]), .scl(JA[0]), .clock(clock_25mhz), .scl_clock(i2c_clock), .reset(reset), .color(corner_color));

    //SEQUENCER
    reg seq_complete = 0;
    reg moves_avail_to_queue = 0;
    wire [199:0] new_moves_to_queue;
    wire [7:0] num_moves_loaded;
    wire [7:0] current_step;
    wire seq_done;

    // wire these things:
    // moves_avail_to_queue -- when a set of moves have been output that should be thrown on the queue
    // new_moves_to_queue -- the actual moves output by solving_algorithm
    // seq_complete - the solving_algorithm is done

    // the values used to represent colors in cubestate register
    parameter W = 0;
    parameter O = 1;
    parameter G = 2;
    parameter Red = 3;
    parameter Blue = 4;
    parameter Y = 5;    
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

    // use this scramble
    // U Bi Li F B R2 Li B Ui F D Fi L2 Fi U2 Li U2 D B2 L R2 F B L Bi Di
    // reg [161:0] cubestate_initial = {Y,Blue,Red,G,O,W,Y,Y,Y,Y,W,G,Blue,W,Red,Red,Blue,O,O,W,G,O,Blue,Red,G,O,W,G,Blue,Red,Blue,Y,Blue,Red,Blue,G,G,W,Red,Y,G,O,Y,O,W,W,Y,Blue,G,O,W,O,Red,Red};
    //                              |----centers-----|----edges----edges----edges----edges----edges----edges----edges----|----corners----corners----corners----corners----corners----corners-|
//    reg [161:0] cubestate_initial = {Y,Blue,Red,G,O,W,Y,Y,Y,Y,Red,Blue,Blue,Blue,Red,Red,Red,G,O,G,G,G,O,Blue,O,O,W,W,W,W,Y,Y,Y,Y,Blue,Red,Red,Blue,Red,Red,G,G,O,G,G,O,Blue,Blue,O,O,W,W,W,W};
    reg [161:0] cubestate_initial = {Y,Blue,Red,G,O,W,Y,Y,Y,Y,Blue,Blue,Blue,Blue,Red,Red,Red,Red,G,G,G,G,O,O,O,O,W,W,W,W,Y,Y,Y,Y,Blue,Blue,Blue,Blue,Red,Red,Red,Red,G,G,G,G,O,O,O,O,W,W,W,W};


    reg [161:0] cubestate_for_solving_algorithm;
    wire [161:0] cubestate_updated;
    wire cube_solution_finished;
    wire new_moves_ready;
    wire state_updated;
    reg start_finding_solution;
    wire [2:0] step_stuff;
    wire [1:0] state_stuff;

    solving_algorithm sa(.fucked(LED[1]),.step_stuff(step_stuff),.state_stuff(state_stuff),.start(start_finding_solution),.clock(clock_25mhz),.cubestate(cubestate_for_solving_algorithm),.state_updated(state_updated),.next_moves(new_moves_to_queue),.cube_solved(cube_solution_finished),.new_moves_ready(new_moves_ready));
    update_state us(.clock(clock_25mhz),.moves_input(new_moves_to_queue),.new_moves_ready(new_moves_ready),.cubestate_input(cubestate_for_solving_algorithm),.cubestate_updated(cubestate_updated),.state_updated(state_updated));

    assign LED[0] = cube_solution_finished;
    
    parameter LOAD_INIT_STATE = 0;
    parameter FIND_SOLUTION = 1;
    parameter DONE_PLANNING_SOLUTION = 2;
    parameter HOLY_SHIT_IS_IT_WORKING = 3;
    reg [2:0] state = 0;

    always @(posedge clock_25mhz) begin
        if (reset) begin
            seq_complete <= 0;
            state <= LOAD_INIT_STATE;
            cubestate_for_solving_algorithm <= cubestate_initial;
        end
        else begin
            case (state)
                LOAD_INIT_STATE: begin
                    cubestate_for_solving_algorithm <= cubestate_initial;
                    state <= FIND_SOLUTION;
                end
                FIND_SOLUTION: begin
                    // some bullshit here
                    // this should just go until it's done...? i have no idea what the fuck is going on here
                    cubestate_for_solving_algorithm <= cubestate_updated;
                    state <= (cube_solution_finished) ? DONE_PLANNING_SOLUTION : FIND_SOLUTION;
                end
                DONE_PLANNING_SOLUTION: begin
                    // tell sequence to go
                    seq_complete <= 1;
                    state <= HOLY_SHIT_IS_IT_WORKING;
                end
                HOLY_SHIT_IS_IT_WORKING: begin
                    seq_complete <= 0;
                    state <= HOLY_SHIT_IS_IT_WORKING;
                end
                default : state <= LOAD_INIT_STATE;
            endcase
        end
    end

    sequencer seq(.clock(clock_25mhz), .seq_complete(seq_complete), .new_moves(moves_avail_to_queue), .seq(new_moves_to_queue), .seq_done(seq_done), .next_move(next_move), .start_move(move_start), .num_moves(num_moves_loaded), .curr_step(current_step), .move_done(move_done));
    
    assign data = {1'h0, step_stuff, 2'h0, state_stuff, 4'h0, next_move, current_step, num_moves_loaded};


    
    // parameter send_moves = 0;
    // parameter tell_it_to_load = 1;
    // parameter tell_it_to_go = 2;
    // parameter idle = 3;
    
    // reg [1:0] state = 0;

    // always @(posedge clock_25mhz) begin
    //     if(reset) begin
    //         state <= send_moves;
    //         case (SW[3:0])
    //             0: solution <= 200'd0 | Ri;
    //             1: solution <= 200'd0 | {R,Ri};
    //             2: solution <= 200'd0 | {R,Ri,R,Ri};
    //             3: solution <= 200'd0 | {R,Ri,R,Ri,L,R,Ri,Li};
    //             4: solution <= 200'd0 | {R,Ri,R,Ri,L,R,Ri,Li,R,Ri};
    //             5: solution <= 200'd0 | {R,Ri,R,Ri,L,R,Ri,Li,R,Ri,R,Ri};
    //             6: solution <= 200'd0 | {R,U,Ri,Ui};
    //             7: solution <= 200'd0 | {U,R,Ui,Ri};
    //             8: solution <= 200'd0 | {R,U,L,F,D,B};
    //             9: solution <= 200'd0 | {Bi,Di,Fi,Li,Ui,Ri};
    //             10: solution <= 200'd0 | {R,U,L,F,D,B,Bi,Di,Fi,Li,Ui,Ri};
    //             11: solution <= 200'd0 | {U,D,B,R,R,Fi,B,B,U,U,L,D,L,L,D,D,R,R,Bi,U,U,L,L,Fi,B,B,R,R,Bi,R,R};
    //             12: solution <= 200'd0 | {R,Ri,R,Ri,R,Ri,R,Ri,L};
    //             13: solution <= 200'd0 | {R,Ri,R,Ri,R,Ri,R,Ri};
    //             default solution <= 200'd0 | Ri;
    //         endcase
    //     end else begin
    //         case (state)
    //             send_moves: begin
    //                 new_moves_to_queue <= solution;
    //                 state <= tell_it_to_load;
    //             end
    //             tell_it_to_load: begin
    //                 moves_avail_to_queue <= 1;
    //                 state <= tell_it_to_go;
    //             end
    //             tell_it_to_go: begin
    //                 moves_avail_to_queue <= 0;
    //                 seq_complete <= 1;
    //                 state <= idle;
    //             end
    //             idle: begin
    //                 state <= idle;
    //             end
    //             default : state <= idle;
    //         endcase
    //     end
    // end
    
// I2C TEST    
    
//    localparam CS_ADDRESS = 7'h44;
//    localparam CS_CONFIG_REG1 = 8'h01;
//    localparam CS_CONFIG_REG2 = 8'h02;
//    localparam CS_CONFIG_REG3 = 8'h03;
//    localparam CS_R_HIGH = 8'h0C;
//    localparam CS_R_LOW = 8'h0B;
//    localparam CS_G_HIGH = 8'h0A;
//    localparam CS_G_LOW = 8'h09;
//    localparam CS_B_HIGH = 8'h0E;
//    localparam CS_B_LOW = 8'h0D;
    
//    localparam CS_CONFIG_REG1_VALUE = 8'h05;
    
//    localparam CONFIG1 = 0;
//    localparam POLL_SENS = 1;
    
//    wire setup_done;
//    reg start_setup = 0;
//    reg setup_state = CONFIG1; 
//    reg [7:0] cs_setup_reg = CS_CONFIG_REG1;
    
//    //assign data = {3'b000,SW[15],2'b00,SW[7],debounce_SW7, 8'h00, curr_state,time_left, 2'b00,SW[5:4], SW[3:0]};
//    wire [5:0] state_display;
//    wire [47:0] value;
//    wire poll_stop;
//    assign poll_stop = reset | !setup_done;
    
//    wire i2c_clock;
    
//    clock_200khz clock_for_i2c(.reset(reset), .clock(clock_25mhz), .slow_clock(i2c_clock));
    
//    i2c_poll #(.NUM_DATA_BYTES(6)) poll(.clock(clock_25mhz), .scl_clock(i2c_clock), .reset(poll_stop), .reading(value), .scl(JA[3]), .sda(JA[2]), .state_out(state_display), .register_address(CS_G_LOW), .device_address(CS_ADDRESS));
//    i2c_setup setup(.clock(clock_25mhz), .scl_clock(i2c_clock), .reset(reset), .scl(JA[3]), .sda(JA[2]), .register_address(cs_setup_reg), .device_address(CS_ADDRESS), .data_in(CS_CONFIG_REG1_VALUE), .start(start_setup), .done(setup_done));
    
//    assign data = {8'h0, value[31:24], value[15:8], value[47:40]};

//    assign LED[0] = (state_display==6'd0) ? 1'b1:1'b0;
//    assign LED[1] = led_state[1] & !reset | (state_display==6'd8) ? 1'b1:1'b0;
//    assign LED[2] = led_state[2] & !reset | (state_display==6'd10) ? 1'b1:1'b0;
//    assign LED[3] = led_state[3] & !reset | (state_display==6'd32) ? 1'b1:1'b0;
//    assign LED[4] = setup_done;
    
//    always @(posedge clock_25mhz) begin
//        if(reset) begin
//            setup_state <= CONFIG1;
//        end else begin
//            case(setup_state)
//                CONFIG1: begin
//                    start_setup <= 1;
//                    if(!setup_done)begin
//                        setup_state <= POLL_SENS;
//                    end
//                end
//                POLL_SENS: begin
//                    start_setup <= 0;
//                end
//            endcase
//        end
//    end

// STEPPER TEST
    
//    reg prev_butt;
//    reg start_stepper;
    
//    always @(posedge clock_25mhz)begin
//        prev_butt <= debounce_BTNC;
//        start_stepper <= debounce_BTNC & !prev_butt;
//    end
    
//    wire stepper_dir_pin;
//    wire stepper_step_pin;
//    wire [5:0] stepper_en_pins;
    
//    assign JB[2] = stepper_dir_pin;
//    assign JB[6] = stepper_step_pin;
    
//    assign JB[3] = stepper_en_pins[0];
//    assign JB[1] = stepper_en_pins[1];
//    assign JB[0] = stepper_en_pins[2];
//    assign JB[5] = stepper_en_pins[3];
//    assign JB[4] = stepper_en_pins[4];
//    assign JB[7] = stepper_en_pins[5];
    
//    assign LED[3:0] = SW[3:0];
    
//    move_to_step steppers(.clock(clock_25mhz), .next_move(SW[3:0]), .move_start(start_stepper), .move_done(LED[4]), .dir_pin(stepper_dir_pin), .step_pin(stepper_step_pin), .en_pins(stepper_en_pins));

// OLD I2C TEST
    
//    localparam CONFIGA = 4'd0;
//    localparam CONFIGB = 4'd1;
//    localparam READA = 4'd2;
//    localparam READB = 4'd3;
    
//    always @(posedge clock_25mhz) begin
//        led_state <= LED;
//        if (reset && (tcs_setup_state != CONFIGA)) begin
//            tcs_setup_state <= CONFIGA;
//        end else begin
//            case (tcs_setup_state)
//                CONFIGA: begin
//                    if (reset) begin
//                        tcs_setup_state <= CONFIGA;
//                    end else begin
//                        tcs_rw <= 0;
//                        tcs_reg_addr <= 8'b10000000;
//                        tcs_data_in <= 8'b00000011;
//                        tcs_setup_state <= CONFIGB;
//                    end
//                end
//                CONFIGB: begin
//                    tcs_start <= 1;
//                    if (tcs_done) begin
//                        tcs_start <= 0;
//                        tcs_setup_state <= READA;
//                    end
//                end
//                READA: begin
//                    tcs_rw <= 1;
//                    tcs_reg_addr <= 8'b10010100;
//                    tcs_data_in <= 8'b00000000;
//                    tcs_setup_state <= READB;    
//                end
//                READB: begin
//                    tcs_start <= 1;
//                end
//            endcase
//        end
//    end

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
