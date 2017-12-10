`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2017 03:14:07 PM
// Design Name: 
// Module Name: delay_timer
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


module delay_timer #(parameter DURATION = 250)
    (input clock,
    input start,
    input reset,
    output reg done
    );
    
    reg [14:0] ms_counter = 0;
    reg [10:0] counter = 0;
    
    localparam IDLE = 3'd0;
    localparam COUNTING = 3'd1;
    localparam TRIGGERED = 3'd2;
    
    reg [2:0] state = IDLE;
    
    always @(posedge clock)begin
        if(reset)begin
            state <= IDLE;
        end else begin
            case(state)
                IDLE:begin
                    done <= 0;
                    if(start)begin
                       ms_counter <= 0;
                       counter <= DURATION;
                       state <= COUNTING;
                    end
                end
                COUNTING:begin
                    if(ms_counter == 0)begin
                        if(counter == 0)begin
                            state <= TRIGGERED;
                        end else begin
                            counter <= counter - 1;
                            ms_counter <= 24999;
                        end
                    end else begin
                        ms_counter <= ms_counter - 1;
                    end
                end
                TRIGGERED:begin
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end    
endmodule
