`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2017 07:44:41 PM
// Design Name: 
// Module Name: stepper_driver
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


module stepper_driver(
    input clock,
    input step_clock,
    input start,
    input [7:0] steps,
    output en_out,
    output reg done
    );
    
    reg [7:0] steps_left = 0;
    reg prev_step_clock = 0;
    
    assign en_out = done;
    
    always @(posedge clock)begin
        prev_step_clock <= step_clock;
        if (start)begin
            steps_left <= steps + 1; // add 1, so that last step completes
            done <= 0;
        end else if (steps_left == 0)begin
            done <= 1;
        end else if (step_clock & !prev_step_clock)begin
            steps_left <= steps_left - 1;
        end
    end
    
endmodule
