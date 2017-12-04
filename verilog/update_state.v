module update_state (
    input clock, [199:0] moves, new_moves_ready, [161:0] cubestate,
    output reg[161:0] cubestate_updated, reg state_updated
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

    reg state = IDLE;

    reg [5:0] counter = 0;

    always @(posedge clock) begin
        case (state)
            MOVING: begin
                case (next_move):
                    R: begin
                    end
                    Ri: begin
                    end
                    U: begin
                    end
                    Ui: begin
                    end
                    F: begin
                    end
                    Fi: begin
                    end
                    L: begin
                    end
                    Li: begin
                    end
                    B: begin
                    end
                    Bi: begin
                    end
                    D: begin
                    end
                    Di: begin
                    end
                endcase
                counter <= counter + 1;
                moves <= moves << 4
                next_move <= moves[195:192]
                // if we've just done our 50th move (counter == 49) then go to IDLE
                state <= (counter < 49) ? MOVING : IDLE
                state_updated <= (counter == 49) ? 1 : 0
            end
            IDLE: begin
                counter <= 0; // always be ready...
                state_updated <= 0;
                if (new_moves_ready) begin
                    next_move <= moves[199:196];
                    state <= MOVING;
                end
            end
            default : state <= IDLE;
        endcase
    end

endmodule