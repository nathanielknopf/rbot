`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MIT
// Engineer: jeswiezy with much help from jodalyst
// 
// Create Date: 10/12/2016 05:11:46 AM
// Design Name: 
// Module Name: i2c_master
// Project Name: first version i2c master with MPU9250 9axis IMU
// Target Devices: Artix 7
// Tool Versions: 
// Description: Simple, state machine reading x acceleration of MPU9250 on loop
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module i2c_poll #(parameter NUM_DATA_BYTES=2)
    (input clock,
    input scl_clock,
    input reset,
    output reg [(NUM_DATA_BYTES*8)-1:0] reading,
    inout sda,
    inout scl,
    output [4:0] state_out,
    input [7:0] register_address,
    input [6:0] device_address);
    
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
    localparam START2A = 6'd14; //SCL -> HI
    localparam START2B = 6'd15; //SDA -> HI
    localparam START2C = 6'd16; //SDA -> LOW (restarts)
    localparam ADDRESS2A = 6'd17; //Address again (7'h68)
    localparam ADDRESS2B = 6'd18; //Address again
    localparam READWRITE2A = 6'd19; //readwrite bit...this time read (1)
    localparam READWRITE2B = 6'd20; //readwrite bit...this time read (1)
    localparam ACKNACK3A = 6'd21; //like other acknacks...wait for MPU to respond
    localparam ACKNACK3B = 6'd22; //else go back to IDLE
    localparam ACKNACK3C = 6'd23; //"""""
    localparam READ1A = 6'd24; //start reading in data from device
    localparam READ1B = 6'd25; //this data is 8MSB of x accelerometer reading
    localparam ACKNACK4A = 6'd26; //Master (FPGA) assets acknowledgement to Slave
    localparam ACKNACK4B = 6'd27; //Effectively asking for more data
    localparam NACK = 6'd28; //Fail to acknowledge Slave this time (way to say "I'm done so slave doesn't send more data)
    localparam STOP1A = 6'd29; //Stop/Release line
    localparam STOP1B = 6'd30; //FPGA master does this by pulling SCL HI while SDA LOW
    localparam STOP1C = 6'd31; //Then pulling SDA HI while SCL remains HI
    
    
    //reg [6:0] device_address = 7'h68;
    //reg [7:0] register_address = 8'h75;
    reg [7:0] count;
    reg [3:0] data_count;
    
    reg [5:0] state = IDLE;
    assign state_out = state;
    
    reg [(NUM_DATA_BYTES*8)-1:0] incoming_data = 0;
    
    reg sda_val=1; //from the fsm perspective, where SDA output data is placed.
    assign sda =  sda_val ? 1'bz: 1'b0;  //if sda_data  = 1, make hiZ, else 0...rely on external pullup resistors
    
    reg scl_val=1;
    assign scl = scl_val ? 1'bz : 1'b0; //if scl_val = 1, make hiZ, else 0...do this for clock stretching.
    
    always @(posedge scl_clock)begin //update only on rising/fall edges of i2c clock
        if (reset &&(state !=IDLE))begin
            state <= IDLE;
            count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (reset)begin
                        state <= IDLE;
                        reading <= 48'h0;
                    end
                    else if (count == 60)begin
                        state <= START1;
                        count <= 0;
                    end
                    count <= count + 1;
                    sda_val <=1;
                    scl_val <=1;
                    data_count <= 0;
                end
                START1: begin
                    sda_val <= 0; //pull SDA low
                    scl_val <=1;
                    state <=ADDRESS1A;
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
                        count <= count -1;
                        state <= ADDRESS1A;
                    end else begin
                        state <= READWRITE1A;
                    end
                end
                READWRITE1A: begin
                    scl_val <=0;
                    sda_val <=0;//write address
                    state <= READWRITE1B;
                end
                READWRITE1B: begin
                    scl_val <=1;
                    state <= ACKNACK1A;
                end
                ACKNACK1A: begin
                    scl_val <=0;
                    sda_val <=1; //float sda for listening next time
                    state <= ACKNACK1B;
                end
                ACKNACK1B: begin
                    scl_val <=1;
                    state <=ACKNACK1C;
                    count <=7;
                end
                ACKNACK1C: begin
                    scl_val <=0;
                    //acknowledge <= sda;  //what do we have?
                    if (sda ==1'b1)begin //no acknowledgement
                        count <=0;
                        state <= IDLE;
                    end else begin
                        state <= REGISTER1B;
                        sda_val <= register_address[count];              
                    end 
                end
                REGISTER1A: begin
                    scl_val <=0;
                    sda_val <= register_address[count];
                    state <= REGISTER1B;
                end
                REGISTER1B: begin
                    scl_val <=1;
                    if (count>0) begin
                        count <= count -1;
                        state <= REGISTER1A;
                    end else begin
                        state <= ACKNACK2A;
                    end
                end
                ACKNACK2A: begin
                    scl_val <=0;
                    sda_val <=1; //float sda for listening next time
                    state <= ACKNACK2B;
                end
                ACKNACK2B: begin
                    scl_val <=1;
                    state <=ACKNACK2C;
                end
                ACKNACK2C: begin
                    scl_val <=0;
                    //acknowledge <= sda;  //what do we have?
                    if (sda ==1'b1)begin //no acknowledgement
                        state <= IDLE;
                        count <=0;
                    end else begin
                        state <= START2A;
                        sda_val<=0;
                        count <=15;
                    end 
                end
                START2A: begin
                    scl_val <=1;
                    state <= START2B;
                end
                START2B: begin
                    sda_val <= 1;
                    state <= START2C;
                end
                START2C: begin
                    sda_val <= 0; //pull down while SCL is high
                    state <= ADDRESS2A;
                    count <=6; 
                end
                ADDRESS2A: begin
                    scl_val<=0;
                    sda_val <= device_address[count];
                    state <= ADDRESS2B;
                end
                ADDRESS2B: begin
                    scl_val <=1;
                    if (count >= 1) begin
                        count <= count -1;
                        state <= ADDRESS2A;
                    end else begin
                        state <= READWRITE2A;
                    end
                end
                READWRITE2A: begin
                    scl_val <=0;
                    sda_val <=1;//read address
                    state <= READWRITE2B;
                end
                READWRITE2B: begin
                    scl_val <=1;
                    state <= ACKNACK3A;
                end
                ACKNACK3A: begin
                    scl_val <=0;
                    sda_val <=1; //float sda for listening next time
                    state <= ACKNACK3B;
                end
                ACKNACK3B: begin
                    scl_val <=1;
                    state <=ACKNACK3C;
                    count <=7;
                end
                ACKNACK3C: begin
                    scl_val <=0;
                    //acknowledge <= sda;  //what do we have?
                    if (sda ==1'b1)begin //no acknowledgement
                        count <=0;
                        state <= IDLE;
                    end else begin
                        state <= READ1A;
                        sda_val <= 1;            
                    end 
                end
                READ1A: begin
                    scl_val <=1;
                    state <= READ1B;
                end
                READ1B: begin
                    scl_val <=0;
                    incoming_data[count+(data_count<<3)] <= sda;
                    if (count > 0)begin
                        count <= count -1;
                        state <= READ1A;
                    end else if(data_count >= (NUM_DATA_BYTES-1)) begin
                        state <= NACK;
                        sda_val <= 1;
                    end else begin
                        state <= ACKNACK4A;
                        sda_val <= 0;
                        data_count <= data_count + 1;
                    end
                end
                ACKNACK4A: begin
                    scl_val <=1;
                    state <=ACKNACK4B;
                    count <=7;
                end
                ACKNACK4B: begin
                    scl_val <=0;
                    state <= READ1A;
                    sda_val <= 1;
                end
                NACK: begin
                    scl_val <=1;
                    count <=0;
                    reading <= incoming_data;
                    state <= STOP1A;
                end
                STOP1A: begin
                    scl_val <=0;
                    sda_val <=0;
                    state <= STOP1B;
                end
                STOP1B: begin
                    scl_val <= 1;
                    sda_val <=0;
                    state <=STOP1C;
                end
                STOP1C: begin
                    sda_val <=1;
                    state <= IDLE;
                end
    
            endcase
        end             
    end
    
    
endmodule
