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
    
    always @(posedge clock)begin
        if(start)begin
            ms_counter <= 249999;
            counter <= DURATION - 1;
            done <= 0;
        end else if(ms_counter == 0)begin
            if(counter == 0)begin
                done <= 1;
            end else begin
                counter <= counter - 1;
                ms_counter <= 249999;
            end
        end else begin
            ms_counter <= counter - 1;
        end
        if(done)begin   //only keep done = 1 for 1 clk cycle
            done <= 0;
        end
    end
    
endmodule
