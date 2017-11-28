module solving_algorithm(input start, clock, cubestate,
                        output reg[HUGE:0] next_moves, reg solved);

    // the values used to represent colors in cubestate register
    parameter W = 0;
    parameter O = 1;
    parameter G = 2;
    parameter R = 3;
    parameter B = 4;
    parameter Y = 5;

    // moves
    parameter R = 0;
    parameter Ri = 1;
    parameter U = 2;
    parameter Ui = 3;
    parameter F = 4;
    parameter Fi = 5;
    parameter L = 6;
    parameter Li = 7;
    parameter B = 8;
    parameter Bi = 9;
    parameter D = 10;
    parameter Di = 11;

    // steps of the method
    parameter CROSS = 0;
    parameter BOTTOM_CORNERS = 1;
    parameter MIDDLE_LAYER = 2;
    parameter OLL = 3;
    parameter PLL = 4;

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
                                    next_moves <= {Li,Ui,L,U,Li,Ui,L};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in LDF and unsolved
                                else if (cubestate[15:17] == G && cubestate[27:29] == Y && cubestate[60:62] == O) begin
                                    next_moves <= {Li,U,L,Ui,Li,U,L};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // corner is in RDF
                                else if (cubestate[30:32] == G && cubestate[42:44] == Y && cubestate[69:71] == O) begin
                                    next_moves <= {R,Li,U,L,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in RDF
                                else if (cubestate[30:32] == O && cubestate[42:44] == G && cubestate[69:71] == Y) begin
                                    next_moves <= {R,U,Ri,Li,Ui,L};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in RDF
                                else if (cubestate[30:32] == Y && cubestate[42:44] == O && cubestate[69:71] == G) begin
                                    next_moves <= {Fi,Ui,F,F,U,U,Fi};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // corner is in LDB
                                else if (cubestate[12:14] == G && cubestate[48:50] == O && cubestate[63:65] == Y) begin
                                    next_moves <= {L,U,U,Li,U,Li,Ui,L};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in LDB
                                else if (cubestate[12:14] == Y && cubestate[48:50] == G && cubestate[63:65] == O) begin
                                    next_moves <= {L,U,U,Li,Li,U,L};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in LDB
                                else if (cubestate[12:14] == O && cubestate[48:50] == Y && cubestate[63:65] == G) begin
                                    next_moves <= {F,Bi,Ui,Fi,B};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // corner is in RDB
                                else if (cubestate[45:47] == G && cubestate[57:59] == Y && cubestate[66:68] == O) begin
                                    next_moves <= {B,Li,U,U,L,Bi};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in RDB
                                else if (cubestate[45:47] == O && cubestate[57:59] == G && cubestate[66:68] == Y) begin
                                    next_moves <= {Ri,Li,U,U,L,R};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in RDB
                                else if (cubestate[45:47] == Y && cubestate[57:59] == O && cubestate[66:68] == G) begin
                                    next_moves <= {Ri,F,U,U,Fi,R};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // corner is in ULF
                                else if (cubestate[3:5] == G && cubestate[24:26] == Y && cubestate[18:20] == O) begin
                                    next_moves <= {Ui,Li,U,L};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == O && cubestate[24:26] == G && cubestate[18:20] == Y) begin
                                    next_moves <= {Li,Ui,L};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == Y && cubestate[24:26] == O && cubestate[18:20] == G) begin
                                    next_moves <= {Li,U,U,L,U,Li,Ui,L};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // corner is in URF
                                else if (cubestate[6:8] == G && cubestate[39:41] == Y && cubestate[33:35] == O) begin
                                    next_moves <= {Li,U,L};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in URF
                                else if (cubestate[6:8] == O && cubestate[39:41] == G && cubestate[33:35] == Y) begin
                                    next_moves <= {U,Li,Ui,L};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in URF
                                else if (cubestate[6:8] == Y && cubestate[39:41] == O && cubestate[33:35] == G) begin
                                    next_moves <= {R,Li,U,U,Ri,L};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // corner is in URB
                                else if (cubestate[9:11] == G && cubestate[54:56] == Y && cubestate[36:38] == O) begin
                                    next_moves <= {Li,U,U,L};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in URB
                                else if (cubestate[9:11] == O && cubestate[54:56] == G && cubestate[36:38] == Y) begin
                                    next_moves <= {F,U,U,Fi};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in URB
                                else if (cubestate[9:11] == Y && cubestate[54:56] == O && cubestate[36:38] == G) begin
                                    next_moves <= {F,Ri,U,R,Fi};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end

                                // corner is in ULB
                                else if (cubestate[0:2] == G && cubestate[21:23] == Y && cubestate[51:53] == O) begin
                                    next_moves <= {U,Li,U,U,L};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in ULB
                                else if (cubestate[0:2] == O && cubestate[21:23] == G && cubestate[51:53] == Y) begin
                                    next_moves <= {F,Ui,Fi};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                                // corner is in ULB
                                else if (cubestate[0:2] == Y && cubestate[21:23] == O && cubestate[51:53] == G) begin
                                    next_moves <= {F,U,U,Fi,U,F,Ui,Fi};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 0;
                                end
                            end
                            1: begin
                                // YGR corner needs to go in RDF
                                // we've solved LDF so it won't be there!

                                // corner is in RDF and solved
                                if (cubestate[30:32] == G && cubestate[42:44] == R && cubestate[69:71] == Y) piece_counter <= 2;
                                // corner is in RDF
                                else if (cubestate[30:32] == Y && cubestate[42:44] == G && cubestate[69:71] == R) begin
                                    next_moves <= {R,Ui,Ri,U,R,Ui,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in RDF
                                else if (cubestate[30:32] == R && cubestate[42:44] == Y && cubestate[69:71] == G) begin
                                    next_moves <= {R,U,Ri,Ui,R,U,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end

                                // corner is in LDB
                                else if (cubestate[12:14] == G && cubestate[48:50] == Y && cubestate[63:65] == R) begin
                                    next_moves <= {Bi,R,U,U,Ri,B};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in LDB
                                else if (cubestate[12:14] == R && cubestate[48:50] == G && cubestate[63:65] == Y) begin
                                    next_moves <= {L,U,U,Li,U,R,Ui,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in LDB
                                else if (cubestate[12:14] == Y && cubestate[48:50] == R && cubestate[63:65] == G) begin
                                    next_moves <= {L,U,U,R,U,Ri,Li};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end

                                // corner is in RDB
                                else if (cubestate[45:47] == G && cubestate[57:59] == R && cubestate[66:68] == Y) begin
                                    next_moves <= {Ri,U,U,R,Ui,R,U,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in RDB
                                else if (cubestate[45:47] == Y && cubestate[57:59] == G && cubestate[66:68] == R) begin
                                    next_moves <= {Ri,U,U,R,R,Ui,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in RDB
                                else if (cubestate[45:47] == R && cubestate[57:59] == Y && cubestate[66:68] == G) begin
                                    next_moves <= {Fi,B,U,Bi,F};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end

                                // corner is in ULF
                                else if (cubestate[3:5] == G && cubestate[24:26] == R && cubestate[18:20] == Y) begin
                                    next_moves <= {R,Ui,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == Y && cubestate[24:26] == G && cubestate[18:20] == R) begin
                                    next_moves <= {R,U,U,Ri,U,R,Ui,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == R && cubestate[24:26] == Y && cubestate[18:20] == G) begin
                                    next_moves <= {Ui,R,U,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end

                                // corner is in URF
                                else if (cubestate[6:8] == G && cubestate[39:41] == R && cubestate[33:35] == Y) begin
                                    next_moves <= {U,R,Ui,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in URF
                                else if (cubestate[6:8] == Y && cubestate[39:41] == G && cubestate[33:35] == R) begin
                                    next_moves <= {R,U,U,Ri,Ui,R,U,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in URF
                                else if (cubestate[6:8] == R && cubestate[39:41] == Y && cubestate[33:35] == G) begin
                                    next_moves <= {R,U,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end

                                // corner is in URB
                                else if (cubestate[9:11] == G && cubestate[54:56] == R && cubestate[36:38] == Y) begin
                                    next_moves <= {U,U,R,Ui,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in URB
                                else if (cubestate[9:11] == Y && cubestate[54:56] == G && cubestate[36:38] == R) begin
                                    next_moves <= {Ui,R,U,Ri,U,R,Ui,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in URB
                                else if (cubestate[9:11] == R && cubestate[54:56] == Y && cubestate[36:38] == G) begin
                                    next_moves <= {U,R,U,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end

                                // corner is in ULB
                                else if (cubestate[0:2] == G && cubestate[21:23] == R && cubestate[51:53] == Y) begin
                                    next_moves <= {R,U,U,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in ULB
                                else if (cubestate[0:2] == Y && cubestate[21:23] == G && cubestate[51:53] == R) begin
                                    next_moves <= {R,U,Ri,U,R,Ui,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                                // corner is in ULB
                                else if (cubestate[0:2] == R && cubestate[21:23] == Y && cubestate[51:53] == G) begin
                                    next_moves <= {U,U,R,U,Ri};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 1;
                                end
                            end
                            2: begin
                                // YOB corner needs to go in LDB
                                // we've solved LDF so it won't be there!
                                // we've solved RDF so it won't be there!

                                // corner is in LDB and solved
                                if (cubestate[12:14] == O && cubestate[48:50] == B && cubestate[63:65] == Y) piece_counter <= 3;
                                // corner is in LDB
                                else if (cubestate[12:14] == Y && cubestate[48:50] == O && cubestate[63:65] == B) begin
                                    next_moves <= {L,U,Li,Ui,L,U,Li};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in LDB
                                else if (cubestate[12:14] == B && cubestate[48:50] == Y && cubestate[63:65] == O) begin
                                    next_moves <= {Bi,Ui,B,U,Bi,Ui,B};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end

                                // corner is in RDB
                                else if (cubestate[45:47] == B && cubestate[57:59] == O && cubestate[66:68] == Y) begin
                                    next_moves <= {Ri,U,U,R,Bi,U,B};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in RDB
                                else if (cubestate[45:47] == Y && cubestate[57:59] == B && cubestate[66:68] == O) begin
                                    next_moves <= {Ri,L,Ui,R,Li};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in RDB
                                else if (cubestate[45:47] == O && cubestate[57:59] == Y && cubestate[66:68] == B) begin
                                    next_moves <= {Bi,U,B,U,Bi,U,B};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end

                                // corner is in ULF
                                else if (cubestate[3:5] == B && cubestate[24:26] == O && cubestate[18:20] == Y) begin
                                    next_moves <= {U,U,L,Ui,Li};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == Y && cubestate[24:26] == B && cubestate[18:20] == O) begin
                                    next_moves <= {U,L,U,U,Li,Ui,Li,U,L};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == O && cubestate[24:26] == Y && cubestate[18:20] == B) begin
                                    next_moves <= {Bi,U,B};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end

                                // corner is in URF
                                else if (cubestate[6:8] == B && cubestate[39:41] == O && cubestate[33:35] == Y) begin
                                    next_moves <= {L,U,U,Li};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in URF
                                else if (cubestate[6:8] == Y && cubestate[39:41] == B && cubestate[33:35] == O) begin
                                    next_moves <= {L,U,Li,U,L,Ui,Li};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in URF
                                else if (cubestate[6:8] == O && cubestate[39:41] == Y && cubestate[33:35] == B) begin
                                    next_moves <= {Bi,U,U,B};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end

                                // corner is in URB
                                else if (cubestate[9:11] == B && cubestate[54:56] == O && cubestate[36:38] == Y) begin
                                    next_moves <= {L,Ui,Li};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in URB
                                else if (cubestate[9:11] == Y && cubestate[54:56] == B && cubestate[36:38] == O) begin
                                    next_moves <= {Ri,U,R,U,U,L,Ui,Li};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in URB
                                else if (cubestate[9:11] == O && cubestate[54:56] == Y && cubestate[36:38] == B) begin
                                    next_moves <= {Ui,L,U,Li};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end

                                // corner is in ULB
                                else if (cubestate[0:2] == B && cubestate[21:23] == O && cubestate[51:53] == Y) begin
                                    next_moves <= {U,L,Ui,Li};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in ULB
                                else if (cubestate[0:2] == Y && cubestate[21:23] == B && cubestate[51:53] == O) begin
                                    next_moves <= {L,U,U,Li,Ui,L,U,Li};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 2;
                                end
                                // corner is in ULB
                                else if (cubestate[0:2] == O && cubestate[21:23] == Y && cubestate[51:53] == B) begin
                                    next_moves <= {L,U,Li};
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
                                if (cubestate[45:47] == R && cubestate[57:59] == B && cubestate[66:68] == Y) begin
                                    piece_counter <= 0;
                                    step <= MIDDLE_LAYER;
                                end
                                else if (cubestate[45:47] == B && cubestate[57:59] == Y && cubestate[66:68] == R) begin
                                    next_moves <= {Ri,U,R,Ui,Ri,U,R};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                                // corner is in RDB
                                else if (cubestate[45:47] == Y && cubestate[57:59] == R && cubestate[66:68] == B) begin
                                    next_moves <= {Ri,Ui,R,U,Ri,Ui,R};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end

                                // corner is in ULF
                                else if (cubestate[3:5] == B && cubestate[24:26] == Y && cubestate[18:20] == R) begin
                                    next_moves <= {Ri,U,U,R};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == R && cubestate[24:26] == B && cubestate[18:20] == Y) begin
                                    next_moves <= {B,U,U,Bi};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                                // corner is in ULF
                                else if (cubestate[3:5] == Y && cubestate[24:26] == R && cubestate[18:20] == B) begin
                                    next_moves <= {Ri,Ui,R,Ui,Ri,U,R};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end

                                // corner is in URF
                                else if (cubestate[6:8] == B && cubestate[39:41] == Y && cubestate[33:35] == R) begin
                                    next_moves <= {U,U,Ri,U,R};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                                // corner is in URF
                                else if (cubestate[6:8] == R && cubestate[39:41] == B && cubestate[33:35] == Y) begin
                                    next_moves <= {Ui,Ri,Ui,R};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                                // corner is in URF
                                else if (cubestate[6:8] == Y && cubestate[39:41] == R && cubestate[33:35] == B) begin
                                    next_moves <= {U,Ri,Ui,R,Ui,Ri,U,R};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end

                                // corner is in URB
                                else if (cubestate[9:11] == B && cubestate[54:56] == O && cubestate[36:38] == Y) begin
                                    next_moves <= {};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                                // corner is in URB
                                else if (cubestate[9:11] == Y && cubestate[54:56] == B && cubestate[36:38] == O) begin
                                    next_moves <= {};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                                // corner is in URB
                                else if (cubestate[9:11] == O && cubestate[54:56] == Y && cubestate[36:38] == B) begin
                                    next_moves <= {};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end

                                // corner is in ULB
                                else if (cubestate[0:2] == B && cubestate[21:23] == Y && cubestate[51:53] == R) begin
                                    next_moves <= {Ri,U,R};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                                // corner is in ULB
                                else if (cubestate[0:2] == R && cubestate[21:23] == B && cubestate[51:53] == Y) begin
                                    next_moves <= {U,Ri,Ui,R};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                                // corner is in ULB
                                else if (cubestate[0:2] == Y && cubestate[21:23] == R && cubestate[51:53] == B) begin
                                    next_moves <= {Ri,U,U,R,Ui,Ri,U,R};
                                    state <= UPDATE_STATE;
                                    piece_counter <= 3;
                                end
                            end
                            default : piece_counter <= 0;
                        endcase
                    end

                    MIDDLE_LAYER: begin
                    end

                    OLL: begin
                    end

                    PLL: begin
                    end


                    default : /* default */;
                endcase
            end

            UPDATE_STATE:begin
                next_moves <= 0;
                // if we get the thing then go to the MOVE state
            end

            default : state <= UPDATE_STATE;
        endcase
    end


endmodule