`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2017 07:47:53 PM
// Design Name: 
// Module Name: clock_100hz
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


module clock_100hz #(parameter CLOCK_PERIOD=124999)
    (input reset,
    input clock,
    output reg slow_clock
    );
    
    //assume incoming signal is 25 mhz, so we need to slow clock down by 250000
    //every 125000 posedges of clock we will toggle slow_clock state
    reg [16:0] count = 0;
    always @(posedge clock)begin
        if (reset) begin
            count <= 0;
            slow_clock <= 0;
        end else begin
            if (count == CLOCK_PERIOD)begin
                count <= 0;
                slow_clock <= !slow_clock;
            end else begin
                count <= count + 1;
            end
        end
    end
    
endmodule
