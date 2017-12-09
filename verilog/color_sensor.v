`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2017 09:58:51 PM
// Design Name: 
// Module Name: color_sensor
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


module color_sensor(
    inout sda,
    inout scl,
    input clock,
    input scl_clock,
    input reset,
	output [47:0] value,
    output [2:0] color,
    output [5:0] state_display
    );
    
    localparam CS_ADDRESS = 7'h44;
    localparam CS_CONFIG_REG1 = 8'h01;
    localparam CS_CONFIG_REG2 = 8'h02;
    localparam CS_CONFIG_REG3 = 8'h03;
    localparam CS_R_HIGH = 8'h0C;
    localparam CS_R_LOW = 8'h0B;
    localparam CS_G_HIGH = 8'h0A;
    localparam CS_G_LOW = 8'h09;
    localparam CS_B_HIGH = 8'h0E;
    localparam CS_B_LOW = 8'h0D;
    
    localparam CS_CONFIG_REG1_VALUE = 8'b00001101;
    localparam CS_CONFIG_REG2_VALUE = 8'b00111111;
    
    localparam CONFIG1 = 1'd0;
    localparam POLL_SENS = 1'd1;
    
    wire setup_done;
    reg start_setup = 0;
    reg setup_state = CONFIG1;
    
    wire poll_stop;
    assign poll_stop = reset | !setup_done;
    
    wire [7:0] red;
    wire [7:0] green;
    wire [7:0] blue;
	
	assign red = value[31:24];
	assign green = value[15:8];
	assign blue = value[47:40];
    
    i2c_poll #(.NUM_DATA_BYTES(6)) poll(.clock(clock), .scl_clock(scl_clock), .reset(poll_stop), .reading(value), .scl(scl), .sda(sda), .state_out(state_display), .register_address(CS_G_LOW), .device_address(CS_ADDRESS));
    i2c_setup #(.NUM_WRITE_BYTES(2)) setup(.clock(clock), .scl_clock(scl_clock), .reset(reset), .scl(scl), .sda(sda), .register_address(CS_CONFIG_REG1), .device_address(CS_ADDRESS), .data_in({CS_CONFIG_REG1_VALUE, CS_CONFIG_REG2_VALUE}), .start(start_setup), .done(setup_done));
    
//    color_reader identifier(.clock(clock), .red(red), .green(green), .blue(blue), .color(color));
    
    always @(posedge clock) begin
        if(reset) begin
            setup_state <= CONFIG1;
        end else begin
            case(setup_state)
                CONFIG1: begin
                    start_setup <= 1;
                    if(!setup_done)begin
                        setup_state <= POLL_SENS;
                    end
                end
                POLL_SENS: begin
                    start_setup <= 0;
                end
            endcase
        end
    end
    
endmodule
