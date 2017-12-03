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
   output LED16_B, LED16_G, LED16_R,
   output LED17_B, LED17_G, LED17_R,
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
    wire debounce_SW7;
    wire reset;
    
    debounce btnc_deb(.reset(reset), .clock(clock_25mhz), .noisy(BTNC), .clean(debounce_BTNC));
    
    assign reset = SW[15];
     
    reg [15:0] led_state = 16'd0;
    
    localparam TCS_ADDRESS = 7'h68;
    localparam TCS_ENABLE = 8'h3F;
    
    reg setup_done = 1;
     
    reg [7:0] tcs_reg_addr = TCS_ENABLE;
    
    //assign data = {3'b000,SW[15],2'b00,SW[7],debounce_SW7, 8'h00, curr_state,time_left, 2'b00,SW[5:4], SW[3:0]};
    wire [5:0] state_display;
    wire [15:0] value;
    wire poll_stop;
    assign poll_stop = reset | !setup_done;
    
//    i2c_poll poll(.clock(clock_25mhz), .reset(poll_stop), .reading(value), .scl(JA[3]), .sda(JA[2]), .state_out(state_display), .sys_clock(JA[1]), .register_address(TCS_ENABLE), .device_address(TCS_ADDRESS));
//    i2c_setup setup(.clock(clock_25mhz), .reset(reset), .scl(JA[3]), .sda(JA[2]), .sys_clock(JA[1]), .register_address(tcs_reg_addr), .device_address(TCS_ADDRESS));
    
    assign data = {4'h0, tcs_reg_addr,4'h0,value[15:0]};

    assign LED[0] = (state_display==6'd0) ? 1'b1:1'b0;
    assign LED[1] = led_state[1] & !reset | (state_display==6'd8) ? 1'b1:1'b0;
    assign LED[2] = led_state[2] & !reset | (state_display==6'd10) ? 1'b1:1'b0;
    assign LED[3] = led_state[3] & !reset | (state_display==6'd32) ? 1'b1:1'b0;
    
    reg prev_butt;
    reg start_stepper;
    
    always @(posedge clock_25mhz)begin
        prev_butt <= debounce_BTNC;
        start_stepper <= debounce_BTNC & !prev_butt;
    end
    
    wire [5:0] stepper_dir_pins;
    wire [5:0] stepper_step_pins;
    
    assign JB[3] = stepper_step_pins[0];
    assign JB[2] = stepper_dir_pins[0];
    
    move_to_step steppers(.clock(clock_25mhz), .next_move(0), .move_start(start_stepper), .move_done(LED[4]), .dir_pin(stepper_dir_pins), .step_pin(stepper_step_pins));
    
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
