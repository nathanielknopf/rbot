`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2017 02:51:05 PM
// Design Name: 
// Module Name: color_translator
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


module color_translator(
    input clock,
    input [7:0] r_edge,
    input [7:0] g_edge,
    input [7:0] b_edge,
    input [7:0] r_corner,
    input [7:0] g_corner,
    input [7:0] b_corner,
    output reg [2:0] color_edge,
    output reg [2:0] color_corner
    );
    
    parameter W = 3'd0;
    parameter O = 3'd1;
    parameter G = 3'd2;
    parameter Red = 3'd3;
    parameter Blue = 3'd4;
    parameter Y = 3'd5;
    
    wire [7:0] edge_bright;
    wire [7:0] corner_bright;
    assign edge_bright = r_edge + g_edge;
    assign corner_bright = r_corner + g_corner;
    
    
    always @(posedge clock)begin
        if(r_corner > 7)begin //W or Y or O
            if(b_corner > 5)begin
                color_corner <= W;
            end else if(g_corner > 7 || (g_corner > 6 && edge_bright < 8))begin
                color_corner <= Y;
            end else begin
                color_corner <= O;
            end
        end else if(r_corner > 4 || (r_corner > 3 && edge_bright < 8))begin
            color_corner <= Red;
        end else if(g_corner > 3 && edge_bright < 10)begin
            color_corner <= G;
        end else if(b_corner > r_corner || corner_bright < 6 || r_corner >= g_corner)begin
            color_corner <= Blue;
        end else begin
            color_corner <= G;
        end
        
        if(edge_bright > 15)begin //W or Y or O
            if(b_edge > 5 || (b_edge > 4 && edge_bright < 19))begin
                color_edge <= W;
            end else if(r_edge > 9 && g_edge < 9)begin
                color_edge <= O;
            end else begin
                color_edge <= Y;
            end
        end else if((edge_bright > 11 && corner_bright < 10) || (edge_bright > 10 && corner_bright < 5))begin
            color_edge <= O;
        end else if(r_edge > g_edge || (r_edge == g_edge && edge_bright > 7))begin
            color_edge <= Red;
        end else if(g_edge > 5 || (g_edge > 4 && corner_bright < 10))begin
            color_edge <= G;
        end else begin
            color_edge <= Blue;
        end
    end

endmodule
