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
    
    parameter W = 3'd0;
    parameter O = 3'd1;
    parameter G = 3'd2;
    parameter Red = 3'd3;
    parameter Blue = 3'd4;
    parameter Y = 3'd5;
    
    always @(posedge clock)begin
        if(red >= 8'h7)begin // W,O,Y
            if(blue >= 8'h4)begin
                color <= W;
            end else if(green >= 8'h6)begin
                color <= Y;
            end else begin
                color <= O;
            end
        end else begin // R,G,B
            if(red >= 8'h5)begin
                color <= Red;
            end else if((blue > green) && (green < 8'h5))begin
                color <= Blue;
            end else begin
                color <= G;
            end
        end
    end
    
endmodule
