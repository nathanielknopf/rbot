`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2017 03:12:40 PM
// Design Name: 
// Module Name: color_reader
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


module color_reader(
    input clock,
    input [7:0] red,
    input [7:0] green,
    input [7:0] blue,
    output reg [2:0] color
    );
    
    parameter W = 0;
    parameter O = 1;
    parameter G = 2;
    parameter R = 3;
    parameter B = 4;
    parameter Y = 5;
    
    always @(posedge clock)begin
        
    end
    
endmodule
