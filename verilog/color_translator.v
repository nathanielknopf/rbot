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
    input [2:0] known_edge_color,
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
        case(known_edge_color)
            W:begin
                if(b_corner > r_corner) color_corner <= Blue;
                else if(r_corner > 7)begin
                    if(g_corner < 8) color_corner <= O;
                    else if(b_corner > 5) color_corner <= W;
                    else color_corner <= Y;
                end else if(g_corner > r_corner) color_corner <= G;
                else color_corner <= Red;
            end
            O:begin
                if(r_corner > 7)begin
                    if(g_corner < 7) color_corner <= O;
                    else if(b_corner > 4) color_corner <= W;
                    else color_corner <= Y;
                end else if(g_corner > 4) color_corner <= G;
                else if(r_corner > 3) color_corner <= Red;
                else color_corner <= Blue;
            end
            G:begin
                if(r_corner > 6)begin
                    if(g_corner < 8) color_corner <= O;
                    else if(b_corner > 5) color_corner <= W;
                    else color_corner <= Y;
                end else if(r_corner > 3) color_corner <= Red;
                else if(b_corner > r_corner) color_corner <= Blue;
                else color_corner <= G;
            end
            Red:begin
                if(r_corner > 6)begin
                    if(g_corner < 7) color_corner <= O;
                    else if(b_corner > 4) color_corner <= W;
                    else color_corner <= Y;
                end else if(r_corner > g_corner) color_corner <= Red;
                else if(corner_bright > 7) color_corner <= G;
                else color_corner <= Blue;
            end
            Blue:begin
                if(r_corner > 6)begin
                    if(g_corner < 6) color_corner <= O; //weak
                    else if(b_corner > 5) color_corner <= W;
                    else color_corner <= Y;
                end else if(r_corner < 3) color_corner <= Blue;
                else if(r_corner > g_corner) color_corner <= Red;
                else color_corner <= G;
            end
            Y:begin
                if(corner_bright > 16)begin
                    if(b_corner > 5) color_corner <= W;
                    else color_corner <= Y;
                end else if(corner_bright > 12) color_corner <= O;
                else if(corner_bright > 9) color_corner <= Red;
                else if(g_corner > b_corner & g_corner > r_corner) color_corner <= G;
                else color_corner <= Blue;
            end
            default:begin
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
            end
        endcase
        
        if(edge_bright > 15 || (edge_bright > 13 && corner_bright < 10))begin //W or Y or O
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
