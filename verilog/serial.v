`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2017 12:56:35 AM
// Design Name: 
// Module Name: serial
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


module serial(
    input clock,
    input reset,
    input send_data,
    input [161:0] data,
    output reg tx_pin,
    output reg data_sent,
    output reg [2:0] state=0
    );
    
    localparam IDLE = 3'd0;
    localparam START = 3'd1;
    localparam SEND = 3'd2;
    localparam STOP = 3'd3;
    
    localparam NUM_BYTES_TO_SEND = 5'd21;

    reg [2:0] count = 0;
    reg [4:0] byte_count = 0;
    
    reg [161:0] data_to_send = 0;
    
    wire baud;
    wire clock_reset;
    assign clock_reset = reset;
    baudrate_generator slow_stuff(.reset(clock_reset), .clock(clock), .slow_clock(baud));
    
    always @(posedge baud)begin
        if(reset)begin
            state <= IDLE;
        end else begin
            case(state)
                IDLE:begin
                    data_sent <= 1;
                    state <= IDLE;
                    tx_pin <= 1;
                    if(send_data)begin
                        state <= START;
                        byte_count <= 0;
                        count <= 0;
                        data_to_send <= data;
                    end
                end
                START:begin
                    data_sent <= 0;
                    tx_pin <= (byte_count == NUM_BYTES_TO_SEND) ? 1:0;
                    state <= (byte_count == NUM_BYTES_TO_SEND) ? IDLE:SEND;
                end
                SEND:begin
                    tx_pin <= data_to_send[0];
                    data_to_send <= data_to_send >> 1;
                    count <= count + 1;
                    if(count == 7)begin
                        state <= STOP;
                    end
                end
                STOP:begin
                    tx_pin <= 1;
                    byte_count <= byte_count + 1;
                    state <= START;
                end
            endcase
        end
    end
    
endmodule
