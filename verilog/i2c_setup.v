`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MIT
// Engineer: jeswiezy with substantial help from jodalyst
// 
// Create Date: 10/12/2016 05:11:46 AM
// Design Name: 
// Module Name: i2c_write
// Project Name: rbot
// Target Devices: Artix 7
// Tool Versions: 
// Description: Sequential write of registers on I2C device
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//i2c_master module:
//clock comes in at 25MHz...locally generates one at 100kHz to 400kHz (potentially up to 3.8 MHz, I believe, but won't hold breath

module i2c_setup #(parameter NUM_WRITE_BYTES=1)
    (input clock,
    input scl_clock,
    input reset,
    inout sda,
    inout scl,
    output [4:0] state_out,
    input [7:0] register_address,
    input [6:0] device_address,
    input [(NUM_WRITE_BYTES*8)-1:0] data_in,
    input start,
    output reg done=1);
    
    localparam IDLE = 6'd0; //Idle/initial state (SDA= 1, SCL=1)
    localparam START1 = 6'd1; //FPGA claims bus by pulling SDA LOW while SCL is HI
    localparam ADDRESS1A = 6'd2; //send 7 bits of device address (7'h68)
    localparam ADDRESS1B = 6'd3; //send 7 bits of device address
    localparam READWRITE1A = 6'd4; //set read/write bit (write here) (a 0)
    localparam READWRITE1B = 6'd5; //set read/write bit (write here)
    localparam ACKNACK1A = 6'd6; //pull SDA HI while SCL ->LOW
    localparam ACKNACK1B = 6'd7; //pull SCL back HI
    localparam ACKNACK1C = 6'd8; //Is SDA LOW (slave Acknowledge)? if so, move on, else go back to IDLE
    localparam REGISTER1A = 6'd9; //write MPU9250 register we want to read from (8'h3b)
    localparam REGISTER1B = 6'd10; //write MPU9250 register we want to read from
    localparam ACKNACK2A = 6'd11; //pull SDA HI while SCL -> LOW
    localparam ACKNACK2B = 6'd12; //pull SCL back HI
    localparam ACKNACK2C = 6'd13; //Is SDA LOW (slave Ack?) If so move one, else go to idle
    localparam WRITE1A = 6'd14; //SCL -> HI
    localparam WRITE1B = 6'd15; //SDA -> HI
    localparam ACKNACK3A = 6'd16; //like other acknacks...wait for MPU to respond
    localparam ACKNACK3B = 6'd17; //else go back to IDLE
    localparam ACKNACK3C = 6'd18; //"""""
    localparam STOP1A = 6'd19; //Stop/Release line
    localparam STOP1B = 6'd20; //FPGA master does this by pulling SCL HI while SDA LOW
    
    
    //reg [6:0] device_address = 7'h68;
    //reg [7:0] register_address = 8'h75;
    reg [7:0] count;
    reg [3:0] bytes_rem;
    
    reg [5:0] state = IDLE;
    assign state_out = state;
    
    reg [15:0] incoming_data = 16'h0000;
    
    reg sda_val=1; //from the fsm perspective, where SDA output data is placed.
    assign sda =  sda_val ? 1'bz: 1'b0;  //if sda_data  = 1, make hiZ, else 0...rely on external pullup resistors
    
    reg scl_val=1;
    assign scl = scl_val ? 1'bz : 1'b0; //if scl_val = 1, make hiZ, else 0...do this for clock stretching.
    
    always @(posedge scl_clock)begin //update only on rising/fall edges of i2c clock
        if (reset)begin
            state <= IDLE;
            count <= 0;
			sda_val <= 1;
            scl_val <= 1;
        end else begin
            case (state)
                IDLE: begin
                    if (start)begin
                        state <= START1;
                        bytes_rem <= NUM_WRITE_BYTES;
                        count <= 0;
                        done <= 0;
                    end else begin
                        done <= 1;
                    end
                    sda_val <= 1;
                    scl_val <= 1;
                end
                START1: begin
                    sda_val <= 0; //pull SDA low
                    scl_val <= 1;
                    state <= ADDRESS1A;
                    count <= 6;
                end
                ADDRESS1A: begin
                    scl_val<=0;
                    sda_val <= device_address[count];
                    state <= ADDRESS1B;
                end
                ADDRESS1B: begin
                    scl_val <=1;
                    if (count >= 1) begin
                        count <= count - 1;
                        state <= ADDRESS1A;
                    end else begin
                        state <= READWRITE1A;
                    end
                end
                READWRITE1A: begin
                    scl_val <= 0;
                    sda_val <= 0;//write address
                    state <= READWRITE1B;
                end
                READWRITE1B: begin
                    scl_val <= 1;
                    state <= ACKNACK1A;
                end
                ACKNACK1A: begin
                    scl_val <= 0;
                    sda_val <= 1; //float sda for listening next time
                    state <= ACKNACK1B;
                end
                ACKNACK1B: begin
                    scl_val <= 1;
                    state <= ACKNACK1C;
                    count <= 7;
                end
                ACKNACK1C: begin
                    scl_val <= 0;
                    if (sda == 1'b1)begin //no acknowledgement
                        count <= 0;
                        state <= IDLE;
                    end else begin
                        state <= REGISTER1B;
                        sda_val <= register_address[count];              
                    end 
                end
                REGISTER1A: begin
                    scl_val <= 0;
                    sda_val <= register_address[count];
                    state <= REGISTER1B;
                end
                REGISTER1B: begin
                    scl_val <= 1;
                    if (count > 0) begin
                        count <= count - 1;
                        state <= REGISTER1A;
                    end else begin
                        state <= ACKNACK2A;
                    end
                end
                ACKNACK2A: begin
                    scl_val <= 0;
                    sda_val <= 1; //float sda for listening next time
                    state <= ACKNACK2B;
                end
                ACKNACK2B: begin
                    scl_val <= 1;
                    count <= 7;
                    state <= ACKNACK2C;
                end
                ACKNACK2C: begin
                    scl_val <= 0;
                    if (sda == 1'b1)begin //no acknowledgement
                        state <= IDLE;
                        count <= 0;
                    end else if(bytes_rem != 0) begin
                        bytes_rem <= bytes_rem - 1;
                        state <= WRITE1B;
                        sda_val <= data_in[(bytes_rem<<3)-1];
                    end else begin
                        state <= STOP1A;
                        sda_val <= 0;
                    end
                end
                WRITE1A: begin
                    scl_val <= 0;
                    sda_val <= data_in[(bytes_rem<<3)+count];
                    state <= WRITE1B;
                end
                WRITE1B: begin
                    scl_val <= 1;
                    if (count > 0) begin
                        count <= count - 1;
                        state <= WRITE1A;
                    end else begin
                        state <= ACKNACK2A;
                    end
                end
                STOP1A: begin
                    scl_val <= 1;
                    sda_val <= 0;
                    state <= STOP1B;
                end
                STOP1B: begin
                    sda_val <= 1;
                    state <= IDLE;
                end
    
            endcase
        end             
    end
    
    
endmodule
