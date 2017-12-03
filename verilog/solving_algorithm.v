module solving_algorithm(input start, clock, cubestate,
                        output reg[255:0] next_moves, reg solved);

    // the values used to represent colors in cubestate register
    parameter W = 0;
    parameter O = 1;
    parameter G = 2;
    parameter Red = 3;
    parameter Blue = 4;
    parameter Y = 5;

    // moves
    parameter R = 4'd0;
    parameter Ri = 4'd1;
    parameter U = 4'd2;
    parameter Ui = 4'd3;
    parameter F = 4'd4;
    parameter Fi = 4'd5;
    parameter L = 4'd6;
    parameter Li = 4'd7;
    parameter B = 4'd8;
    parameter Bi = 4'd9;
    parameter D = 4'd10;
    parameter Di = 4'd11;

    // steps of the method
    parameter CROSS = 0;
    parameter BOTTOM_CORNERS = 1;
    parameter MIDDLE_LAYER = 2;
    parameter OLL_EDGES = 3;
    parameter OLL_CORNERS = 4;
    parameter PLL_EDGES = 5;
    parameter PLL_CORNERS = 6;
    parameter SOLVED = 7;

    // states are either find a move, or wait for state to update
    parameter MOVE = 0; // should figure out the next set of moves
    parameter UPDATE_STATE = 1; // waiting for the turn_state module to return updated state

    // FSM: step starts at cross
    reg[2:0] step = CROSS;

    // state is either MOVE or UPDATE_STATE
    reg state = MOVE;

    // piece counter counts the sub-step of the step of the method (0th corner, 1st corner, ...)
    reg[1:0] piece_counter = 0;

    always @(posedge clock) begin
        case (state)
            MOVE:begin
                case (step)
                    CROSS: begin
                    end

                    BOTTOM_CORNERS: begin
                        case (piece_counter)
                            0: begin
                                // YGO corner needs to go in LDF
                                // corner is in LDF and solved
                                if (cubestate[15:17] == O && cubestate[27:29] == G && cubestate[60:62] == Y) piece_counter <= 1;
                                // corner is in LDF and unsolved
                                else if (cubestate[15:17] == Y && cubestate[27:29] == O && cubestate[60:62] == G) begin
                                    next_moves <= next_moves | {Li,Ui,L,U,Li,Ui,L};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in LDF and unsolved
                                else if (cubestate[15:17] == G && cubestate[27:29] == Y && cubestate[60:62] == O) begin
                                    next_moves <= next_moves | {Li,U,L,Ui,Li,U,L};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // corner is in RDF
                                else if (cubestate[30:32] == G && cubestate[42:44] == Y && cubestate[69:71] == O) begin
                                    next_moves <= next_moves | {R,Li,U,L,Ri};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in RDF
                                else if (cubestate[30:32] == O && cubestate[42:44] == G && cubestate[69:71] == Y) begin
                                    next_moves <= next_moves | {R,U,Ri,Li,Ui,L};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in RDF
                                else if (cubestate[30:32] == Y && cubestate[42:44] == O && cubestate[69:71] == G) begin
                                    next_moves <= next_moves | {Fi,Ui,F,F,U,U,Fi};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // corner is in LDB
                                else if (cubestate[12:14] == G && cubestate[48:50] == O && cubestate[63:65] == Y) begin
                                    next_moves <= next_moves | {L,U,U,Li,U,Li,Ui,L};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in LDB
                                else if (cubestate[12:14] == Y && cubestate[48:50] == G && cubestate[63:65] == O) begin
                                    next_moves <= next_moves | {L,U,U,Li,Li,U,L};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in LDB
                                else if (cubestate[12:14] == O && cubestate[48:50] == Y && cubestate[63:65] == G) begin
                                    next_moves <= next_moves | {F,Bi,Ui,Fi,B};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // corner is in RDB
                                else if (cubestate[45:47] == G && cubestate[57:59] == Y && cubestate[66:68] == O) begin
                                    next_moves <= next_moves | {B,Li,U,U,L,Bi};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in RDB
                                else if (cubestate[45:47] == O && cubestate[57:59] == G && cubestate[66:68] == Y) begin
                                    next_moves <= next_moves | {Ri,Li,U,U,L,R};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in RDB
                                else if (cubestate[45:47] == Y && cubestate[57:59] == O && cubestate[66:68] == G) begin
                                    next_moves <= next_moves | {Ri,F,U,U,Fi,R};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // corner is in ULF
                                else if (cubestate[3:5] == G && cubestate[24:26] == Y && cubestate[18:20] == O) begin
                                    next_moves <= next_moves | {Ui,Li,U,L};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == O && cubestate[24:26] == G && cubestate[18:20] == Y) begin
                                    next_moves <= next_moves | {Li,Ui,L};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == Y && cubestate[24:26] == O && cubestate[18:20] == G) begin
                                    next_moves <= next_moves | {Li,U,U,L,U,Li,Ui,L};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // otherwise, it's somewhere on the top face so let's spin U until we get it into ULF
                                else begin
                                    next_moves <= next_moves | {U};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                            end
                            1: begin
                                // YGR corner needs to go in RDF
                                // we've solved LDF so it won't be there!

                                // corner is in RDF and solved
                                if (cubestate[30:32] == G && cubestate[42:44] == Red && cubestate[69:71] == Y) piece_counter <= 2;
                                // corner is in RDF
                                else if (cubestate[30:32] == Y && cubestate[42:44] == G && cubestate[69:71] == Red) begin
                                    next_moves <= next_moves | {R,Ui,Ri,U,R,Ui,Ri};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in RDF
                                else if (cubestate[30:32] == Red && cubestate[42:44] == Y && cubestate[69:71] == G) begin
                                    next_moves <= next_moves | {R,U,Ri,Ui,R,U,Ri};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end

                                // corner is in LDB
                                else if (cubestate[12:14] == G && cubestate[48:50] == Y && cubestate[63:65] == Red) begin
                                    next_moves <= next_moves | {Bi,R,U,U,Ri,B};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in LDB
                                else if (cubestate[12:14] == Red && cubestate[48:50] == G && cubestate[63:65] == Y) begin
                                    next_moves <= next_moves | {L,U,U,Li,U,R,Ui,Ri};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in LDB
                                else if (cubestate[12:14] == Y && cubestate[48:50] == Red && cubestate[63:65] == G) begin
                                    next_moves <= next_moves | {L,U,U,R,U,Ri,Li};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end

                                // corner is in RDB
                                else if (cubestate[45:47] == G && cubestate[57:59] == Red && cubestate[66:68] == Y) begin
                                    next_moves <= next_moves | {Ri,U,U,R,Ui,R,U,Ri};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in RDB
                                else if (cubestate[45:47] == Y && cubestate[57:59] == G && cubestate[66:68] == Red) begin
                                    next_moves <= next_moves | {Ri,U,U,R,R,Ui,Ri};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in RDB
                                else if (cubestate[45:47] == Red && cubestate[57:59] == Y && cubestate[66:68] == G) begin
                                    next_moves <= next_moves | {Fi,B,U,Bi,F};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end

                                // corner is in ULF
                                else if (cubestate[3:5] == G && cubestate[24:26] == Red && cubestate[18:20] == Y) begin
                                    next_moves <= next_moves | {R,Ui,Ri};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == Y && cubestate[24:26] == G && cubestate[18:20] == Red) begin
                                    next_moves <= next_moves | {R,U,U,Ri,U,R,Ui,Ri};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == Red && cubestate[24:26] == Y && cubestate[18:20] == G) begin
                                    next_moves <= next_moves | {Ui,R,U,Ri};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end

                                // otherwise, it's somewhere on the top face so let's spin U until we get it into ULF
                                else begin
                                    next_moves <= next_moves | {U};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                            end
                            2: begin
                                // YOB corner needs to go in LDB
                                // we've solved LDF so it won't be there!
                                // we've solved RDF so it won't be there!

                                // corner is in LDB and solved
                                if (cubestate[12:14] == O && cubestate[48:50] == Blue && cubestate[63:65] == Y) piece_counter <= 3;
                                // corner is in LDB
                                else if (cubestate[12:14] == Y && cubestate[48:50] == O && cubestate[63:65] == Blue) begin
                                    next_moves <= next_moves | {L,U,Li,Ui,L,U,Li};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in LDB
                                else if (cubestate[12:14] == Blue && cubestate[48:50] == Y && cubestate[63:65] == O) begin
                                    next_moves <= next_moves | {Bi,Ui,B,U,Bi,Ui,B};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end

                                // corner is in RDB
                                else if (cubestate[45:47] == Blue && cubestate[57:59] == O && cubestate[66:68] == Y) begin
                                    next_moves <= next_moves | {Ri,U,U,R,Bi,U,B};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in RDB
                                else if (cubestate[45:47] == Y && cubestate[57:59] == Blue && cubestate[66:68] == O) begin
                                    next_moves <= next_moves | {Ri,L,Ui,R,Li};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in RDB
                                else if (cubestate[45:47] == O && cubestate[57:59] == Y && cubestate[66:68] == Blue) begin
                                    next_moves <= next_moves | {Bi,U,B,U,Bi,U,B};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end

                                // corner is in ULF
                                else if (cubestate[3:5] == Blue && cubestate[24:26] == O && cubestate[18:20] == Y) begin
                                    next_moves <= next_moves | {U,U,L,Ui,Li};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == Y && cubestate[24:26] == Blue && cubestate[18:20] == O) begin
                                    next_moves <= next_moves | {U,L,U,U,Li,Ui,Li,U,L};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == O && cubestate[24:26] == Y && cubestate[18:20] == Blue) begin
                                    next_moves <= next_moves | {Bi,U,B};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end

                                // otherwise, it's somewhere on the top face so let's spin U until we get it into ULF
                                else begin
                                    next_moves <= next_moves | {U};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                            end
                            3: begin
                                // YRB corner needs to go in RDB
                                // we've solved LDF so it won't be there!
                                // we've solved RDF so it won't be there!
                                // we've solved RDB so it won't be there!

                                // corner is in RDB and solved
                                if (cubestate[45:47] == Red && cubestate[57:59] == Blue && cubestate[66:68] == Y) begin
                                    piece_counter <= 0;
                                    step <= MIDDLE_LAYER;
                                end
                                else if (cubestate[45:47] == Blue && cubestate[57:59] == Y && cubestate[66:68] == Red) begin
                                    next_moves <= next_moves | {Ri,U,R,Ui,Ri,U,R};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                                // corner is in RDB
                                else if (cubestate[45:47] == Y && cubestate[57:59] == Red && cubestate[66:68] == Blue) begin
                                    next_moves <= next_moves | {Ri,Ui,R,U,Ri,Ui,R};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end

                                // corner is in ULF
                                else if (cubestate[3:5] == Blue && cubestate[24:26] == Y && cubestate[18:20] == Red) begin
                                    next_moves <= next_moves | {Ri,U,U,R};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == Red && cubestate[24:26] == Blue && cubestate[18:20] == Y) begin
                                    next_moves <= next_moves | {B,U,U,Bi};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == Y && cubestate[24:26] == Red && cubestate[18:20] == Blue) begin
                                    next_moves <= next_moves | {Ri,Ui,R,Ui,Ri,U,R};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end

                                // otherwise, it's somewhere on the top face so let's spin U until we get it into ULF
                                else begin
                                    next_moves <= next_moves | {U};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                            end
                            default : piece_counter <= 0;
                        endcase
                    end

                    MIDDLE_LAYER: begin
                        case (piece_counter)
                            0: begin
                                // OG edge needs to go in LF
                                // edge is in LF and solved
                                if (cubestate[87:89] == O && cubestate[102:104] == G) piece_counter <= 1;
                                // edge is in LF and flipped
                                else if (cubestate[87:89] == G && cubestate[102:104] == O) begin
                                    next_moves <= next_moves | {Li,U,L,Ui,F,U,U,Fi,U,U,F,Ui,Fi};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // edge is in RF
                                else if (cubestate[96:98] == G && cubestate[111:113] == O) begin
                                    next_moves <= next_moves | {B,B,D,D,F,F,D,D,B,B};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                else if( cubestate[96:98] == O && cubestate[111:113] == G) begin
                                    next_moves <= next_moves | {D,R,U,Ri,Di,U,F,Ui,Fi};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // edge is in RB
                                else if (cubestate[126:128] == G && cubestate[117:119] == O) begin
                                    next_moves <= next_moves | {D,D,Ri,U,R,D,D,U,U,Li,U,L};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                else if( cubestate[126:128] == O && cubestate[117:119] == G) begin
                                    next_moves <= next_moves | {Ri,U,R,Ui,Li,U,L,U,F,Ui,Fi,U,Ri,Ui,R};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                
                                // edge is in LB
                                else if (cubestate[93:95] == G && cubestate[120:122] == O) begin
                                    next_moves <= next_moves | {Di,L,U,Li,D,Ui,F,Ui,Fi};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                else if( cubestate[93:95] == O && cubestate[120:122] == G) begin
                                    next_moves <= next_moves | {R,R,D,D,L,L,D,D,R,R};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // edge is in UF
                                else if (cubestate[78:80] == G && cubestate[105:107] == O) begin
                                    next_moves <= next_moves | {U,U,F,Ui,Fi,Ui,Li,U,L};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                else if(cubestate[78:80] == O && cubestate[105:107] == G) begin
                                    next_moves <= next_moves | {Ui,Li,U,L,U,F,Ui,Fi};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // otherwise, it's on the top face somewhere so just do a U move and 
                                // check if it's in UF yet (yay efficiency)
                                else begin
                                    next_moves <= next_moves | {U};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                            end
                            1: begin
                                // RG edge needs to go in RF
                                // edge can't be in LF because that piece is already solved
                                // edge is in RF and solved
                                if (cubestate[96:98] == G && cubestate[111:113] == Red) piece_counter <= 2;
                                // edge is in RF and flipped
                                else if (cubestate[96:98] == Red && cubestate[111:113] == G) begin
                                    next_moves <= next_moves | {R,Ui,Ri,U,Fi,U,U,F,U,U,Fi,U,F};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end

                                // edge is in RB
                                else if (cubestate[126:128] == G && cubestate[117:119] == Red) begin
                                    next_moves <= next_moves | {L,L,D,D,R,R,D,D,L,L};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                else if (cubestate[126:128] == Red && cubestate[117:119] == G) begin
                                    next_moves <= next_moves | {D,Ri,Ui,R,Di,Fi,U,U,F};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end

                                // edge is in LB
                                else if (cubestate[120:122] == G && cubestate[93:95] == Red) begin
                                    next_moves <= next_moves | {D,D,L,U,Li,D,D,U,U,R,Ui,Ri};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                else if (cubestate[120:122] == Red && cubestate[93:95] == G) begin
                                    next_moves <= next_moves | {L,U,Li,Ui,Bi,Ui,B,U,R,Ui,Ri,Ui,Fi,U,F};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end

                                // edge is in UF
                                else if (cubestate[78:80] == G && cubestate[105:107] == Red) begin
                                    next_moves <= next_moves | {U,U,Fi,U,F,U,R,Ui,Ri};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                else if (cubestate[78:80] == Red && cubestate[105:107] == G) begin
                                    next_moves <= next_moves | {U,R,Ui,Ri,Ui,Fi,U,F};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end

                                // otherwise, it's on the top face somewhere so just do a U move and 
                                // check if it's in UF yet (yay efficiency)
                                else begin
                                    next_moves <= next_moves | {U};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                            end
                            2: begin
                                // RB (color) edge needs to go in RB (position)
                                // edge can't be in LF because that piece is already solved
                                // edge can't be in RF because that piece is already solved
                                // edge is in RB and solved
                                if (cubestate[117:119] == Red && cubestate[126:128] == Blue) piece_counter <= 3;
                                // edge is in RB and flipped
                                else if (cubestate[117:119] == Blue && cubestate[126:128] == Red) begin
                                    next_moves <= next_moves | {Ri,U,R,Ui,B,U,U,Bi,U,U,B,Ui,Bi};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end

                                // edge is in LB
                                else if (cubestate[93:95] == Blue && cubestate[120:122] == Red) begin
                                    next_moves <= next_moves | {D,L,U,Li,Di,U,B,Ui,Bi};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                else if (cubestate[93:95] == Red && cubestate[120:122] == Blue) begin
                                    next_moves <= next_moves | {F,F,D,D,B,B,D,D,F,F};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end

                                // edge is in UF
                                else if (cubestate[78:80] == Blue && cubestate[105:107] == Red) begin
                                    next_moves <= next_moves | {B,Ui,Bi,Ui,Ri,U,R};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                else if (cubestate[78:80] == Red && cubestate[105:107] == Blue) begin
                                    next_moves <= next_moves | {U,Ri,U,R,U,B,Ui,Bi};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end

                                // otherwise, it's on the top face somewhere so just do a U move and 
                                // check if it's in UF yet (yay efficiency)
                                else begin
                                    next_moves <= next_moves | {U};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                            end
                            3: begin
                                // OB edge needs to go in LB
                                // edge can't be in LF because that piece is already solved
                                // edge can't be in RF because that piece is already solved
                                // edge can't be in RB because that piece is already solved
                                // edge is in LB and solved
                                if (cubestate[93:95] == O && cubestate[120:122] == Blue) begin
                                    piece_counter <= 0;
                                    step <= OLL_EDGES;
                                end
                                else if (cubestate[93:95] == Blue && cubestate[120:122] == O) begin
                                    next_moves <= next_moves | {L,Ui,Li,U,Bi,U,U,B,U,U,Bi,U,B};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end

                                // edge is in UF
                                else if (cubestate[78:80] == Blue && cubestate[105:107] == O) begin
                                    next_moves <= next_moves | {Bi,U,B,U,L,Ui,Li};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                                else if (cubestate[78:80] == O && cubestate[105:107] == Blue) begin
                                    next_moves <= next_moves | {Ui,L,Ui,Li,Ui,Bi,U,B};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end

                                // otherwise, it's on the top face somewhere so just do a U move and 
                                // check if it's in UF yet (yay efficiency)
                                else begin
                                    next_moves <= next_moves | {U};
                                    new_moves_ready <= 1;
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                            end
                            default: piece_counter <= 0;
                        endcase
                    end

                    OLL_EDGES: begin
                        // either dot, L in back, or line left to right. otherwise, do a U until recognize
                        // dot - 90:92, 105:107, 108:110, 129:131 are all white
                        if(cubestate[90:92] == W && cubestate[105:107] == W && cubestate[108:110] == W && cubestate[129:131] == W) begin
                            next_moves <= next_moves | {F,U,R,Ui,Ri,Fi,U,F,R,U,Ri,Ui,Fi};
                            new_moves_ready <= 1;
                            step <= OLL_CORNERS;
                            state <= UPDATE_STATE;
                        end
                        // L - 75:77 and 72:74 are white
                        else if(cubestate[75:77] == W && cubestate[72:74] == W) begin
                            next_moves <= next_moves | {F,U,R,Ui,Ri,Fi};
                            new_moves_ready <= 1;
                            step <= OLL_CORNERS;
                            state <= UPDATE_STATE;
                        end
                        // Line - 75:77 and 81:83 are white
                        else if(cubestate[75:77] == W && cubestate[81:83] == W) begin
                            next_moves <= next_moves | {F,R,U,Ri,Ui,Fi};
                            new_moves_ready <= 1;
                            step <= OLL_CORNERS;
                            state <= UPDATE_STATE;
                        end
                        // otherwise it's either L or Line, but oriented incorrectly so do a U move and check again
                        else begin
                            next_moves <= next_moves | {U};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                            // step remains OLL_EDGES...
                        end
                    end

                    OLL_CORNERS: begin
                        // 7 cases. If we don't see one of them, oriented incorrectly, so do a U and check again 
                        // sune: 33:35, 36:38, 51:53 W
                        if (cubestate[33:35] == W && cubestate[36:38] == W && cubestate[51:53] == W) begin
                            next_moves <= next_moves | {R,U,Ri,U,R,U,U,Ri};
                            new_moves_ready <= 1;
                            step <= PLL_EDGES;
                            state <= UPDATE_STATE;
                        end
                        // antisune: 39:41, 24:26, 21:23 W
                        if (cubestate[39:41] == W && cubestate[24:26] == W && cubestate[21:23] == W) begin
                            next_moves <= next_moves | {R,U,U,Ri,Ui,R,Ui,Ri};
                            new_moves_ready <= 1;
                            step <= PLL_EDGES;
                            state <= UPDATE_STATE;
                        end
                        // doublesune: 39:41, 36:38, 18:20, 21:23 W
                        if (cubestate[39:41] == W && cubestate[36:38] == W && cubestate[18:20] == W && cubestate[21:23] == W) begin
                            next_moves <= next_moves | {R,U,Ri,U,R,Ui,Ri,U,R,U,U,Ri};
                            new_moves_ready <= 1;
                            step <= PLL_EDGES;
                            state <= UPDATE_STATE;
                        end
                        // headlights: 24:26, 33:35 W
                        if (cubestate[24:26] == W && cubestate[33:35] == W) begin
                            next_moves <= next_moves | {R,R,D,Ri,U,U,R,Di,Ri,U,U,Ri};
                            new_moves_ready <= 1;
                            step <= PLL_EDGES;
                            state <= UPDATE_STATE;
                        end
                        // weird bullfrog looking one: 24:26, 51:53 W
                        if (cubestate[24:26] == W && cubestate[51:53] == W) begin
                            next_moves <= next_moves | {L,F,Ri,Fi,Li,F,R,Fi};
                            new_moves_ready <= 1;
                            step <= PLL_EDGES;
                            state <= UPDATE_STATE;
                        end
                        // bowtie/butterfly: 39:41, 51:53 W
                        if (cubestate[39:41] == W && cubestate[51:53] == W) begin
                            next_moves <= next_moves | {R,U,Ri,Ui,Ri,F,R,U,R,Ui,Ri,Fi};
                            new_moves_ready <= 1;
                            step <= PLL_EDGES;
                            state <= UPDATE_STATE;
                        end
                        // superman: 33:35, 51:53, 18:20, 21:23 W
                        if (cubestate[33:35] == W && cubestate[51:53] == W && cubestate[18:20] == W && cubestate[21:23] == W) begin
                            next_moves <= next_moves | {R,U,U,R,R,Ui,R,R,Ui,R,R,U,U,R};
                            new_moves_ready <= 1;
                            step <= PLL_EDGES;
                            state <= UPDATE_STATE;
                        end
                        // otherwise we do a U and check again
                        else begin
                            next_moves <= next_moves | {U};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                        end

                    PLL_EDGES: begin
                        // 8 different U perms, 2 Z perms...
                        // solved
                        if (cubestate[90:92] == O && cubestate[105:107] == G && cubestate[108:110] == Red && cubestate[129:131] == Blue) step <= PLL_CORNERS;
                        // U: solved edge in back
                        else if (cubestate[90:92] == Red && cubestate[105:107] == O && cubestate[108:110] == G) begin
                            next_moves <= next_moves | {R,R,U,R,U,Ri,Ui,Ri,Ui,Ri,U,Ri};
                            new_moves_ready <= 1;
                            step <= PLL_CORNERS;
                            state <= UPDATE_STATE;
                        end
                        else if (cubestate[90:92] == G && cubestate[105:107] == Red && cubestate[108:110] == O) begin
                            next_moves <= next_moves | {R,Ui,R,U,R,U,R,Ui,Ri,Ui,R,R};
                            new_moves_ready <= 1;
                            step <= PLL_CORNERS;
                            state <= UPDATE_STATE;
                        end
                        // U: solved edge on left
                        else if (cubestate[129:131] == G && cubestate[105:107] == Red && cubestate[108:110] == Blue) begin
                            next_moves <= next_moves | {U,R,Ui,R,U,R,U,R,Ui,Ri,Ui,R,R,Ui};
                            new_moves_ready <= 1;
                            step <= PLL_CORNERS;
                            state <= UPDATE_STATE;
                        end
                        else if (cubestate[129:131] == Red && cubestate[105:107] == Blue && cubestate[108:110] == G) begin
                            next_moves <= next_moves | {U,R,R,U,R,U,Ri,Ui,Ri,Ui,Ri,U,Ri,Ui};
                            new_moves_ready <= 1;
                            step <= PLL_CORNERS;
                            state <= UPDATE_STATE;
                        end
                        // U: solved edge in front
                        else if (cubestate[129:131] == Red && cubestate[90:92] == Blue && cubestate[108:110] == O) begin
                            next_moves <= next_moves | {U,U,R,R,U,R,U,Ri,Ui,Ri,Ui,Ri,U,Ri,U,U};
                            new_moves_ready <= 1;
                            step <= PLL_CORNERS;
                            state <= UPDATE_STATE;
                        end
                        else if (cubestate[129:131] == O && cubestate[90:92] == Red && cubestate[108:110] == Blue) begin
                            next_moves <= next_moves | {U,U,R,Ui,R,U,R,U,R,Ui,Ri,Ui,R,R,U,U};
                            new_moves_ready <= 1;
                            step <= PLL_CORNERS;
                            state <= UPDATE_STATE;
                        end
                        // U: solved edge on right
                        else if (cubestate[129:131] == G && cubestate[105:107] == O && cubestate[90:92] == Blue) begin
                            next_moves <= next_moves | {Ui,R,R,U,R,U,Ri,Ui,Ri,Ui,Ri,U,Ri,U};
                            new_moves_ready <= 1;
                            step <= PLL_CORNERS;
                            state <= UPDATE_STATE;
                        end
                        else if (cubestate[129:131] == O && cubestate[105:107] == Blue && cubestate[90:92] == G) begin
                            next_moves <= next_moves | {Ui,R,Ui,R,U,R,U,R,Ui,Ri,Ui,R,R,U};
                            new_moves_ready <= 1;
                            step <= PLL_CORNERS;
                            state <= UPDATE_STATE;
                        end
                        // Z perms - reduce to U perm
                        else if (cubestate[105:107] == Red && cubestate[108:110] == G && cubestate[90:92] == Blue && cubestate[129:131] == O) begin
                            next_moves <= next_moves | {R,R,U,R,U,Ri,Ui,Ri,Ui,Ri,U,Ri};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                        end
                        else if (cubestate[105:107] == O && cubestate[108:110] == Blue && cubestate[90:92] == G && cubestate[129:131] == Red) begin
                            next_moves <= next_moves | {R,R,U,R,U,Ri,Ui,Ri,Ui,Ri,U,Ri};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                        end
                        // only 2 are solved
                        else if (cubestate[90:92] == O && cubestate[108:110] == Red && cubestate[105:107] == Blue && cubestate[129:131] == G) begin
                            next_moves <= next_moves | {Ui,R,U,Ri,Ui,Ri,F,R,R,Ui,Ri,Ui,R,U,Ri,Fi,U};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                        end
                        else if (cubestate[90:92] == Red && cubestate[108:110] == O && cubestate[105:107] == G && cubestate[129:131] == Blue) begin
                            next_moves <= next_moves | {Ui,R,U,Ri,Ui,Ri,F,R,R,Ui,Ri,Ui,R,U,Ri,Fi,U};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                        end
                        // otherwise, turn U until we recognize something (probably we have an H perm/edges are solved
                        else begin
                            next_moves <= next_moves | {U};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE
                        end
                    end

                    PLL_CORNERS: begin
                        // solved
                        if (cubestate[24:26] == G && cubestate[33:35] == G && cubestate[54:56] == Blue && cubestate[51:53] == Blue) step <= SOLVED;
                        // a perm - two per each corner ==> 8 a perms
                        // a perm - URF
                        else if (cubestate[33:35] == Blue && cubestate[36:38] == G && cubestate[51:53] == Red) begin
                            next_moves <= next_moves | {Ri,F,Ri,B,B,R,Fi,Ri,B,B,R,R};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                        end
                        else if (cubestate[33:35] == Red && cubestate[36:38] == Blue && cubestate[51:53] == G) begin
                            next_moves <= next_moves | {R,R,B,B,R,F,Ri,B,B,R,Fi,R};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                        end
                        // a perm - URB
                        else if (cubestate[36:38] == O && cubestate[51:53] == Red && cubestate[18:20] == Blue) begin
                            next_moves <= next_moves | {U,Ri,F,Ri,B,B,R,Fi,Ri,B,B,R,R,Ui};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                        end
                        else if (cubestate[36:38] == Blue && cubestate[51:53] == O && cubestate[18:20] == Red) begin
                            next_moves <= next_moves | {U,R,R,B,B,R,F,Ri,B,B,R,Fi,R,Ui};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                        end
                        // a perm - ULB
                        else if (cubestate[33:35] == Blue && cubestate[51:53] == O && cubestate[18:20] == G) begin
                            next_moves <= next_moves | {U,U,R,R,B,B,R,F,Ri,B,B,R,Fi,R,Ui,Ui};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                        end
                        else if (cubestate[33:35] == O && cubestate[51:53] == G && cubestate[18:20] == Blue) begin
                            next_moves <= next_moves | {U,U,Ri,F,Ri,B,B,R,Fi,Ri,B,B,R,R,Ui,Ui};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                        end
                        // a perm - ULF
                        else if (cubestate[33:35] == Red && cubestate[36:38] == O && cubestate[18:20] == G) begin
                            next_moves <= next_moves | {Ui,R,R,B,B,R,F,Ri,B,B,R,Fi,R,U};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                        end
                        else if (cubestate[33:35] == O && cubestate[36:38] == G && cubestate[18:20] == Red) begin
                            next_moves <= next_moves | {Ui,Ri,F,Ri,B,B,R,Fi,Ri,B,B,R,R,U};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                        end
                        // e perm - two orientations
                        else if (cubestate[24:26] == O && cubestate[33:35] == Red && cubestate[21:23] == G && cubestate[36:38] == G) begin
                            next_moves <= next_moves | {R,Bi,Ri,F,R,B,Ri,Fi,R,B,Ri,F,R,Bi,Ri,Fi};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                        end
                        else if (cubestate[24:26] == Red && cubestate[33:35] == O && cubestate[21:23] == Blue && cubestate[36:38] == Blue) begin
                            next_moves <= next_moves | {U,R,Bi,Ri,F,R,B,Ri,Fi,R,B,Ri,F,R,Bi,Ri,Fi,Ui};
                            new_moves_ready <= 1;
                            state <= UPDATE_STATE;
                        end
                        // h perm - only one orientation
                        else if (cubestate[24:26] == Blue && cubestate[33:35] == Blue && cubestate[54:56] == G && cubestate[51:53] == G) begin
                            next_moves <= next_moves | {R,R,U,U,R,R,U,U,R,R,U,R,R,U,U,R,R,U,U,R,R,U};
                        end
                    end

                    default : step <= CROSS;
                endcase
            end

            UPDATE_STATE:begin
                next_moves <= 0;
                new_moves_ready <= 0;
                // if we get the thing then go to the MOVE state
                if (state_updated) begin
                    state <= MOVE;
                    // probably some other kinda shit i need to do here huh...
                end
            end

            default : state <= UPDATE_STATE; // uhh.....
        endcase
    end


endmodule