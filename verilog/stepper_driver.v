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
    input dir_in,
    input [7:0] steps,
    output reg dir_out,
    output step_out,
    output reg done
    );
    
    reg [7:0] steps_left = 0;
    reg prev_step_clock = 0;
    
    assign step_out = (|steps_left[7:0]) & step_clock;
    
    always @(posedge step_clock)begin
        
    end
    
    always @(posedge clock)begin
        prev_step_clock <= step_clock;
        if (start)begin
            steps_left <= steps;
            dir_out <= dir_in;
            done <= 0;
        end else if (steps_left == 0)begin
            done <= 1;
        end else if (step_clock & !prev_step_clock)begin
            steps_left <= steps_left - 1;
        end
    end
    
endmodule
