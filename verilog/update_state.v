module update_state (
    input clock, [199:0] moves, new_moves_ready, [161:0] cubestate,
    output reg[161:0] cubestate_updated, 
);
    // moves
    parameter R = 4'd2;
    parameter Ri = 4'd3;
    parameter U = 4'd4;
    parameter Ui = 4'd5;
    parameter F = 4'd6;
    parameter Fi = 4'd7;
    parameter L = 4'd8;
    parameter Li = 4'd9;
    parameter B = 4'd10;
    parameter Bi = 4'd11;
    parameter D = 4'd12;
    parameter Di = 4'd13;

    
    parameter IDLE = 0;
    parameter MOVING = 1;

    always @(posedge clock) begin
    end

endmodule