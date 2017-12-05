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
     
//    reg [15:0] led_state = 16'd0;
    
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
    
//    assign data = {value[31:0]};

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
    
    reg prev_butt;
    reg start_stepper;
    
    always @(posedge clock_25mhz)begin
        prev_butt <= debounce_BTNC;
        start_stepper <= debounce_BTNC & !prev_butt;
    end
    
    wire stepper_dir_pin;
    wire stepper_step_pin;
    wire [5:0] stepper_en_pins;
    
    assign JB[2] = stepper_dir_pin;
    assign JB[6] = stepper_step_pin;
    
    assign JB[3] = stepper_en_pins[0];
    assign JB[1] = stepper_en_pins[1];
    assign JB[0] = stepper_en_pins[2];
    assign JB[5] = stepper_en_pins[3];
    assign JB[4] = stepper_en_pins[4];
    assign JB[7] = stepper_en_pins[5];
    
    assign LED[3:0] = SW[3:0];
    
    move_to_step steppers(.clock(clock_25mhz), .next_move(SW[3:0]), .move_start(start_stepper), .move_done(LED[4]), .dir_pin(stepper_dir_pin), .step_pin(stepper_step_pin), .en_pins(stepper_en_pins));
    
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
