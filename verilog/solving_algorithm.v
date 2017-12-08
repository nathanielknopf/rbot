module solving_algorithm(input start, clock, reset, [161:0] cubestate, state_updated,
                        output reg[199:0] next_moves, reg cube_solved=0, reg new_moves_ready, [2:0]step_stuff, [1:0]state_stuff, reg fucked=0);

    // the values used to represent colors in cubestate register
    parameter W = 3'd0;
    parameter O = 3'd1;
    parameter G = 3'd2;
    parameter Red = 3'd3;
    parameter Blue = 3'd4;
    parameter Y = 3'd5;


    // in the event that we want to test this, we should use a dummy cubestate, provided below
    // this is a known scramble - this can be reached by applying the following moves to a solved Rubik's Cube:
    // R2 B R2 B2 F L2 U2 B R2 D2 L2 Di Li U2 B2 F R2 Bi Di Ui 
    // reg [161:0] cubestate = {Y,Blue,Red,G,O,W,W,G,Red,Blue,Blue,Blue,Red,Red,W,Blue,O,Y,Red,O,O,Y,O,G,W,G,G,Y,W,Y,G,Y,Blue,G,O,O,O,Y,Blue,Y,Red,G,W,Red,Red,O,W,W,W,Red,Y,Blue,G,Blue};
    //                      |----centers-----|----------edges----------edges----------edges----------edges-------|---------corners---------corners---------corners---------corners---|
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
    parameter WAIT = 2;
    parameter SETUP = 3;

    // FSM: step starts at cross
    reg[2:0] step = PLL_CORNERS;
    assign step_stuff = step;

    // state is either MOVE or UPDATE_STATE
    reg [1:0] state = SETUP;
    assign state_stuff = state;

    reg [5:0] counter = 0;

    // piece counter counts the sub-step of the step of the method (0th corner, 1st corner, ...)
    reg[1:0] piece_counter = 0;

    always @(posedge clock) begin
        if(reset)begin
            state <= SETUP;
        end else begin
            case (state)
                SETUP:begin
                    if(start)begin
                        state <= MOVE;
                    end
                end
                MOVE:begin
                    case (step)
                        // closed for renovations
                        // this is FUCKED!
                        // CROSS: begin
                        //     case (piece_counter)
                        //         0: begin
                        //             // YG needs to go in DF
                        //             // solved: move on
                        //             if (cubestate[101:99] == G && cubestate[140:138] == Y) piece_counter <= 1;
                        //             // DF flipped
                        //             else if (cubestate[101:99] == Y && cubestate[140:138] == Y) begin
                        //                 next_moves <= next_moves | {Fi,Ri,Di};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 0;
                        //             end
                        //             // DL
                        //             else if (cubestate[137:135] == Y && cubestate[86:84] == G) begin
                        //                 next_moves <= next_moves | {D};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 0;
                        //             end
                        //             else if (cubestate[137:135] == G && cubestate[86:84] == Y) begin
                        //                 next_moves <= next_moves | {Li,Fi};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 0;
                        //             end
                        //             // DB
                        //             else if (cubestate[134:132] == Y && cubestate[125:123] == G) begin
                        //                 next_moves <= next_moves | {D,D};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 0;
                        //             end
                        //             else if (cubestate[134:132] == G && cubestate[125:123] == Y) begin
                        //                 next_moves <= next_moves | {B,R,Di};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 0;
                        //             end
                        //             // DR
                        //             else if (cubestate[143:141] == Y && cubestate[116:114] == G) begin
                        //                 next_moves <= next_moves | {Di};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 0;
                        //             end
                        //             else if (cubestate[143:141] == G && cubestate[116:114] == Y) begin
                        //                 next_moves <= next_moves | {R,F};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 0;
                        //             end
    
                        //             // RF
                        //             else if (cubestate[98:96] == Y && cubestate[113:111] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[98:96] == OTHER && cubestate[113:111] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             // LF
                        //             else if (cubestate[104:102] == Y && cubestate[89:87] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[104:102] == OTHER && cubestate[89:87] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             // RB
                        //             else if (cubestate[128:126] == Y && cubestate[119:117] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[128:126] == OTHER && cubestate[119:117] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             // LB
                        //             else if (cubestate[122:120] == Y && cubestate[95:93] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[122:120] == OTHER && cubestate[95:93] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //         end
                        //         1: begin
                        //             // YO needs to go in DL
                        //             // can't be in DF because that's already solved
                        //             // solved: move on           
                        //             if ([137:135] == Y && cubestate[86:84] == O) piece_counter <= 2;       
                        //             // DL
                        //             else if (cubestate[137:135] == O && cubestate[86:84] == Y) begin
                        //                 next_moves <= next_moves | {Li,D,Fi,Di};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 1;
                        //             end
                        //             // DB
                        //             else if (cubestate[134:132] == Y && cubestate[125:123] == O) begin
                        //                 next_moves <= next_moves | {F,D,Fi};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 1;
                        //             end
                        //             else if (cubestate[134:132] == O && cubestate[125:123] == Y) begin
                        //                 next_moves <= next_moves | {Bi,Li};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 1;
                        //             end
                        //             // DR
                        //             else if (cubestate[143:141] == Y && cubestate[116:114] == O) begin
                        //                 next_moves <= next_moves | {R,D,D,Ri,D,D};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 1;
                        //             end
                        //             else if (cubestate[143:141] == O && cubestate[116:114] == Y) begin
                        //                 next_moves <= next_moves | {Ri,Di,Bi,D};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 1;
                        //             end
    
                        //             // RF
                        //             else if (cubestate[98:96] == Y && cubestate[113:111] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[98:96] == OTHER && cubestate[113:111] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             // LF
                        //             else if (cubestate[104:102] == Y && cubestate[89:87] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[104:102] == OTHER && cubestate[89:87] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             // RB
                        //             else if (cubestate[128:126] == Y && cubestate[119:117] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[128:126] == OTHER && cubestate[119:117] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             // LB
                        //             else if (cubestate[122:120] == Y && cubestate[95:93] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[122:120] == OTHER && cubestate[95:93] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end              
                        //         end
                        //         2: begin
                        //             // YBlue needs to go in DB
                        //             // can't be in DF because that's already solved
                        //             // can't be in DL because that's already solved
                        //             // solved: move on
                        //             if (cubestate[134:132] == Y && cubestate[125:123] == Blue) piece_counter <= 3;
                        //             // DB
                        //             else if (cubestate[134:132] == Blue && cubestate[125:123] == Y) begin
                        //                 next_moves <= next_moves | {B,Di,R,D};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 2;
                        //             end
                        //             // DR
                        //             else if (cubestate[143:141] == Y && cubestate[116:114] == Blue) begin
                        //                 next_moves <= next_moves | {R,Di,Ri};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 2;
                        //             end
                        //             else if (cubestate[143:141] == Blue && cubestate[116:114] == Y) begin
                        //                 next_moves <= next_moves | {Ri,Bi};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 2;
                        //             end 
    
                        //             // RF
                        //             else if (cubestate[98:96] == Y && cubestate[113:111] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[98:96] == OTHER && cubestate[113:111] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             // LF
                        //             else if (cubestate[104:102] == Y && cubestate[89:87] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[104:102] == OTHER && cubestate[89:87] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             // RB
                        //             else if (cubestate[128:126] == Y && cubestate[119:117] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[128:126] == OTHER && cubestate[119:117] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             // LB
                        //             else if (cubestate[122:120] == Y && cubestate[95:93] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[122:120] == OTHER && cubestate[95:93] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end             
                        //         end
                        //         3: begin
                        //             // YRed needs to go in DR
                        //             // can't be in DF because that's already solved
                        //             // can't be in DL because that's already solved
                        //             // can't be in DB because that's already solved
                        //             // solved: move on
                        //             if (cubestate[116:114] == Red && cubestate[143:141] == Y) begin
                        //                 piece_counter <= 0;
                        //                 step <= BOTTOM_CORNERS;
                        //             end
                        //             else if (cubestate[116:114] == Y && cubestate[143:141] == Red) begin
                        //                 next_moves <= next_moves | {R,Di,F,D};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= 3;
                        //             end
    
                        //             // RF
                        //             else if (cubestate[98:96] == Y && cubestate[113:111] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[98:96] == OTHER && cubestate[113:111] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             // LF
                        //             else if (cubestate[104:102] == Y && cubestate[89:87] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[104:102] == OTHER && cubestate[89:87] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             // RB
                        //             else if (cubestate[128:126] == Y && cubestate[119:117] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[128:126] == OTHER && cubestate[119:117] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             // LB
                        //             else if (cubestate[122:120] == Y && cubestate[95:93] == OTHER) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //             else if (cubestate[122:120] == OTHER && cubestate[95:93] == Y) begin
                        //                 next_moves <= next_moves | {};
                        //                 new_moves_ready <= 1;
                        //                 state <= UPDATE_STATE;
                        //                 piece_counter <= COUNT;
                        //             end
                        //         end
                            
                        //         default : /* default */;
                        //     endcase
                        // end
    
                        // only works if the cross is already solved lol...
                        CROSS: begin
                            step <= BOTTOM_CORNERS;
                            piece_counter <= 0;
                        end
    
                        BOTTOM_CORNERS: begin
                            case (piece_counter)
                                0: begin
                                    // YGO corner needs to go in LDF
                                    // corner is in LDF and solved
                                    if (cubestate[17:15] == O && cubestate[29:27] == G && cubestate[62:60] == Y) piece_counter <= 1;
                                    // corner is in LDF and unsolved
                                    else if (cubestate[17:15] == Y && cubestate[29:27] == O && cubestate[62:60] == G) begin
                                        next_moves <= next_moves | {Li,Ui,L,U,Li,Ui,L};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
                                    // corner is in LDF and unsolved
                                    else if (cubestate[17:15] == G && cubestate[29:27] == Y && cubestate[62:60] == O) begin
                                        next_moves <= next_moves | {Li,U,L,Ui,Li,U,L};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
    
                                    // corner is in RDF
                                    else if (cubestate[32:30] == G && cubestate[44:42] == Y && cubestate[71:69] == O) begin
                                        next_moves <= next_moves | {R,Li,U,L,Ri};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
                                    // corner is in RDF
                                    else if (cubestate[32:30] == O && cubestate[44:42] == G && cubestate[71:69] == Y) begin
                                        next_moves <= next_moves | {R,U,Ri,Li,Ui,L};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
                                    // corner is in RDF
                                    else if (cubestate[32:30] == Y && cubestate[44:42] == O && cubestate[71:69] == G) begin
                                        next_moves <= next_moves | {Fi,Ui,F,F,U,U,Fi};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
    
                                    // corner is in LDB
                                    else if (cubestate[14:12] == G && cubestate[50:48] == O && cubestate[65:63] == Y) begin
                                        next_moves <= next_moves | {L,U,U,Li,U,Li,Ui,L};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
                                    // corner is in LDB
                                    else if (cubestate[14:12] == Y && cubestate[50:48] == G && cubestate[65:63] == O) begin
                                        next_moves <= next_moves | {L,U,U,Li,Li,U,L};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
                                    // corner is in LDB
                                    else if (cubestate[14:12] == O && cubestate[50:48] == Y && cubestate[65:63] == G) begin
                                        next_moves <= next_moves | {F,Bi,Ui,Fi,B};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
    
                                    // corner is in RDB
                                    else if (cubestate[47:45] == G && cubestate[59:57] == Y && cubestate[68:66] == O) begin
                                        next_moves <= next_moves | {B,Li,U,U,L,Bi};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
                                    // corner is in RDB
                                    else if (cubestate[47:45] == O && cubestate[59:57] == G && cubestate[68:66] == Y) begin
                                        next_moves <= next_moves | {Ri,Li,U,U,L,R};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
                                    // corner is in RDB
                                    else if (cubestate[47:45] == Y && cubestate[59:57] == O && cubestate[68:66] == G) begin
                                        next_moves <= next_moves | {Ri,F,U,U,Fi,R};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
    
                                    // corner is in ULF
                                    else if (cubestate[5:3] == G && cubestate[26:24] == Y && cubestate[20:18] == O) begin
                                        next_moves <= next_moves | {Ui,Li,U,L};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
                                    // corner is in ULF
                                    else if (cubestate[5:3] == O && cubestate[26:24] == G && cubestate[20:18] == Y) begin
                                        next_moves <= next_moves | {Li,Ui,L};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
                                    // corner is in ULF
                                    else if (cubestate[5:3] == Y && cubestate[26:24] == O && cubestate[20:18] == G) begin
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
                                    if (cubestate[32:30] == G && cubestate[44:42] == Red && cubestate[71:69] == Y) piece_counter <= 2;
                                    // corner is in RDF
                                    else if (cubestate[32:30] == Y && cubestate[44:42] == G && cubestate[71:69] == Red) begin
                                        next_moves <= next_moves | {R,Ui,Ri,U,R,Ui,Ri};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
                                    // corner is in RDF
                                    else if (cubestate[32:30] == Red && cubestate[44:42] == Y && cubestate[71:69] == G) begin
                                        next_moves <= next_moves | {R,U,Ri,Ui,R,U,Ri};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
    
                                    // corner is in LDB
                                    else if (cubestate[14:12] == G && cubestate[50:48] == Y && cubestate[65:63] == Red) begin
                                        next_moves <= next_moves | {Bi,R,U,U,Ri,B};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
                                    // corner is in LDB
                                    else if (cubestate[14:12] == Red && cubestate[50:48] == G && cubestate[65:63] == Y) begin
                                        next_moves <= next_moves | {L,U,U,Li,U,R,Ui,Ri};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
                                    // corner is in LDB
                                    else if (cubestate[14:12] == Y && cubestate[50:48] == Red && cubestate[65:63] == G) begin
                                        next_moves <= next_moves | {L,U,U,R,U,Ri,Li};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
    
                                    // corner is in RDB
                                    else if (cubestate[47:45] == G && cubestate[59:57] == Red && cubestate[68:66] == Y) begin
                                        next_moves <= next_moves | {Ri,U,U,R,Ui,R,U,Ri};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
                                    // corner is in RDB
                                    else if (cubestate[47:45] == Y && cubestate[59:57] == G && cubestate[68:66] == Red) begin
                                        next_moves <= next_moves | {Ri,U,U,R,R,Ui,Ri};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
                                    // corner is in RDB
                                    else if (cubestate[47:45] == Red && cubestate[59:57] == Y && cubestate[68:66] == G) begin
                                        next_moves <= next_moves | {Fi,B,U,Bi,F};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
    
                                    // corner is in ULF
                                    else if (cubestate[5:3] == G && cubestate[26:24] == Red && cubestate[20:18] == Y) begin
                                        next_moves <= next_moves | {R,Ui,Ri};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
                                    // corner is in ULF
                                    else if (cubestate[5:3] == Y && cubestate[26:24] == G && cubestate[20:18] == Red) begin
                                        next_moves <= next_moves | {R,U,U,Ri,U,R,Ui,Ri};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
                                    // corner is in ULF
                                    else if (cubestate[5:3] == Red && cubestate[26:24] == Y && cubestate[20:18] == G) begin
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
                                    if (cubestate[14:12] == O && cubestate[50:48] == Blue && cubestate[65:63] == Y) piece_counter <= 3;
                                    // corner is in LDB
                                    else if (cubestate[14:12] == Y && cubestate[50:48] == O && cubestate[65:63] == Blue) begin
                                        next_moves <= next_moves | {L,U,Li,Ui,L,U,Li};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 2;
                                    end
                                    // corner is in LDB
                                    else if (cubestate[14:12] == Blue && cubestate[50:48] == Y && cubestate[65:63] == O) begin
                                        next_moves <= next_moves | {Bi,Ui,B,U,Bi,Ui,B};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 2;
                                    end
    
                                    // corner is in RDB
                                    else if (cubestate[47:45] == Blue && cubestate[59:57] == O && cubestate[68:66] == Y) begin
                                        next_moves <= next_moves | {Ri,U,U,R,Bi,U,B};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 2;
                                    end
                                    // corner is in RDB
                                    else if (cubestate[47:45] == Y && cubestate[59:57] == Blue && cubestate[68:66] == O) begin
                                        next_moves <= next_moves | {Ri,L,Ui,R,Li};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 2;
                                    end
                                    // corner is in RDB
                                    else if (cubestate[47:45] == O && cubestate[59:57] == Y && cubestate[68:66] == Blue) begin
                                        next_moves <= next_moves | {Bi,U,B,U,Bi,U,B};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 2;
                                    end
    
                                    // corner is in ULF
                                    else if (cubestate[5:3] == Blue && cubestate[26:24] == O && cubestate[20:18] == Y) begin
                                        next_moves <= next_moves | {U,U,L,Ui,Li};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 2;
                                    end
                                    // corner is in ULF
                                    else if (cubestate[5:3] == Y && cubestate[26:24] == Blue && cubestate[20:18] == O) begin
                                        next_moves <= next_moves | {U,L,U,U,Li,Ui,Li,U,L};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 2;
                                    end
                                    // corner is in ULF
                                    else if (cubestate[5:3] == O && cubestate[26:24] == Y && cubestate[20:18] == Blue) begin
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
                                    if (cubestate[47:45] == Red && cubestate[59:57] == Blue && cubestate[68:66] == Y) begin
                                        piece_counter <= 0;
                                        step <= MIDDLE_LAYER;
                                    end
                                    else if (cubestate[47:45] == Blue && cubestate[59:57] == Y && cubestate[68:66] == Red) begin
                                        next_moves <= next_moves | {Ri,U,R,Ui,Ri,U,R};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 3;
                                    end
                                    // corner is in RDB
                                    else if (cubestate[47:45] == Y && cubestate[59:57] == Red && cubestate[68:66] == Blue) begin
                                        next_moves <= next_moves | {Ri,Ui,R,U,Ri,Ui,R};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 3;
                                    end
    
                                    // corner is in ULF
                                    else if (cubestate[5:3] == Blue && cubestate[26:24] == Y && cubestate[20:18] == Red) begin
                                        next_moves <= next_moves | {Ri,U,U,R};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 3;
                                    end
                                    // corner is in ULF
                                    else if (cubestate[5:3] == Red && cubestate[26:24] == Blue && cubestate[20:18] == Y) begin
                                        next_moves <= next_moves | {B,U,U,Bi};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 3;
                                    end
                                    // corner is in ULF
                                    else if (cubestate[5:3] == Y && cubestate[26:24] == Red && cubestate[20:18] == Blue) begin
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
                                    if (cubestate[89:87] == O && cubestate[104:102] == G) piece_counter <= 1;
                                    // edge is in LF and flipped
                                    else if (cubestate[89:87] == G && cubestate[104:102] == O) begin
                                        next_moves <= next_moves | {Li,U,L,Ui,F,U,U,Fi,U,U,F,Ui,Fi};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
    
                                    // edge is in RF
                                    else if (cubestate[98:96] == G && cubestate[113:111] == O) begin
                                        next_moves <= next_moves | {B,B,D,D,F,F,D,D,B,B};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
                                    else if( cubestate[98:96] == O && cubestate[113:111] == G) begin
                                        next_moves <= next_moves | {D,R,U,Ri,Di,U,F,Ui,Fi};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
    
                                    // edge is in RB
                                    else if (cubestate[128:126] == G && cubestate[119:117] == O) begin
                                        next_moves <= next_moves | {D,D,Ri,U,R,D,D,U,U,Li,U,L};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
                                    else if( cubestate[128:126] == O && cubestate[119:117] == G) begin
                                        next_moves <= next_moves | {Ri,U,R,Ui,Li,U,L,U,F,Ui,Fi,U,Ri,Ui,R};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
                                    // edge is in LB
                                    else if (cubestate[95:93] == G && cubestate[122:120] == O) begin
                                        next_moves <= next_moves | {Di,L,U,Li,D,Ui,F,Ui,Fi};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
                                    else if( cubestate[95:93] == O && cubestate[122:120] == G) begin
                                        next_moves <= next_moves | {R,R,D,D,L,L,D,D,R,R};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
    
                                    // edge is in UF
                                    else if (cubestate[80:78] == G && cubestate[107:105] == O) begin
                                        next_moves <= next_moves | {U,U,F,Ui,Fi,Ui,Li,U,L};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 0;
                                    end
                                    else if(cubestate[80:78] == O && cubestate[107:105] == G) begin
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
                                    if (cubestate[98:96] == G && cubestate[113:111] == Red) piece_counter <= 2;
                                    // edge is in RF and flipped
                                    else if (cubestate[98:96] == Red && cubestate[113:111] == G) begin
                                        next_moves <= next_moves | {R,Ui,Ri,U,Fi,U,U,F,U,U,Fi,U,F};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
    
                                    // edge is in RB
                                    else if (cubestate[128:126] == G && cubestate[119:117] == Red) begin
                                        next_moves <= next_moves | {L,L,D,D,R,R,D,D,L,L};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
                                    else if (cubestate[128:126] == Red && cubestate[119:117] == G) begin
                                        next_moves <= next_moves | {D,Ri,Ui,R,Di,Fi,U,U,F};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
    
                                    // edge is in LB
                                    else if (cubestate[122:120] == G && cubestate[95:93] == Red) begin
                                        next_moves <= next_moves | {D,D,L,U,Li,D,D,U,U,R,Ui,Ri};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
                                    else if (cubestate[122:120] == Red && cubestate[95:93] == G) begin
                                        next_moves <= next_moves | {L,U,Li,Ui,Bi,Ui,B,U,R,Ui,Ri,Ui,Fi,U,F};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
    
                                    // edge is in UF
                                    else if (cubestate[80:78] == G && cubestate[107:105] == Red) begin
                                        next_moves <= next_moves | {U,U,Fi,U,F,U,R,Ui,Ri};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 1;
                                    end
                                    else if (cubestate[80:78] == Red && cubestate[107:105] == G) begin
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
                                    if (cubestate[119:117] == Red && cubestate[128:126] == Blue) piece_counter <= 3;
                                    // edge is in RB and flipped
                                    else if (cubestate[119:117] == Blue && cubestate[128:126] == Red) begin
                                        next_moves <= next_moves | {Ri,U,R,Ui,B,U,U,Bi,U,U,B,Ui,Bi};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 2;
                                    end
    
                                    // edge is in LB
                                    else if (cubestate[95:93] == Blue && cubestate[122:120] == Red) begin
                                        next_moves <= next_moves | {D,L,U,Li,Di,U,B,Ui,Bi};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 2;
                                    end
                                    else if (cubestate[95:93] == Red && cubestate[122:120] == Blue) begin
                                        next_moves <= next_moves | {F,F,D,D,B,B,D,D,F,F};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 2;
                                    end
    
                                    // edge is in UF
                                    else if (cubestate[80:78] == Blue && cubestate[107:105] == Red) begin
                                        next_moves <= next_moves | {B,Ui,Bi,Ui,Ri,U,R};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 2;
                                    end
                                    else if (cubestate[80:78] == Red && cubestate[107:105] == Blue) begin
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
                                    if (cubestate[95:93] == O && cubestate[122:120] == Blue) begin
                                        piece_counter <= 0;
                                        step <= OLL_EDGES;
                                    end
                                    else if (cubestate[95:93] == Blue && cubestate[122:120] == O) begin
                                        next_moves <= next_moves | {L,Ui,Li,U,Bi,U,U,B,U,U,Bi,U,B};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 3;
                                    end
    
                                    // edge is in UF
                                    else if (cubestate[80:78] == Blue && cubestate[107:105] == O) begin
                                        next_moves <= next_moves | {Bi,U,B,U,L,Ui,Li};
                                        new_moves_ready <= 1;
                                        state <= UPDATE_STATE;
                                        piece_counter <= 3;
                                    end
                                    else if (cubestate[80:78] == O && cubestate[107:105] == Blue) begin
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
                            // dot - 92:90, 107:105, 110:108, 131:129 are all white
                            if(cubestate[92:90] == W && cubestate[107:105] == W && cubestate[110:108] == W && cubestate[131:129] == W) begin
                                next_moves <= next_moves | {F,U,R,Ui,Ri,Fi,U,F,R,U,Ri,Ui,Fi};
                                new_moves_ready <= 1;
                                step <= OLL_CORNERS;
                                state <= UPDATE_STATE;
                            end
                            // L - 77:75 and 74:72 are white
                            else if(cubestate[77:75] == W && cubestate[74:72] == W) begin
                                next_moves <= next_moves | {F,U,R,Ui,Ri,Fi};
                                new_moves_ready <= 1;
                                step <= OLL_CORNERS;
                                state <= UPDATE_STATE;
                            end
                            // Line - 77:75 and 83:81 are white
                            else if(cubestate[77:75] == W && cubestate[83:81] == W) begin
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
                            // sune: 35:33, 38:36, 53:51 W
                            if (cubestate[35:33] == W && cubestate[38:36] == W && cubestate[53:51] == W) begin
                                next_moves <= next_moves | {R,U,Ri,U,R,U,U,Ri};
                                new_moves_ready <= 1;
                                step <= PLL_EDGES;
                                state <= UPDATE_STATE;
                            end
                            // antisune: 41:39, 26:24, 23:21 W
                            if (cubestate[41:39] == W && cubestate[26:24] == W && cubestate[23:21] == W) begin
                                next_moves <= next_moves | {R,U,U,Ri,Ui,R,Ui,Ri};
                                new_moves_ready <= 1;
                                step <= PLL_EDGES;
                                state <= UPDATE_STATE;
                            end
                            // doublesune: 41:39, 38:36, 20:18, 23:21 W
                            if (cubestate[41:39] == W && cubestate[38:36] == W && cubestate[20:18] == W && cubestate[23:21] == W) begin
                                next_moves <= next_moves | {R,U,Ri,U,R,Ui,Ri,U,R,U,U,Ri};
                                new_moves_ready <= 1;
                                step <= PLL_EDGES;
                                state <= UPDATE_STATE;
                            end
                            // headlights: 26:24, 35:33 W
                            if (cubestate[26:24] == W && cubestate[35:33] == W) begin
                                next_moves <= next_moves | {R,R,D,Ri,U,U,R,Di,Ri,U,U,Ri};
                                new_moves_ready <= 1;
                                step <= PLL_EDGES;
                                state <= UPDATE_STATE;
                            end
                            // weird bullfrog looking one: 26:24, 53:51 W
                            if (cubestate[26:24] == W && cubestate[53:51] == W) begin
                                next_moves <= next_moves | {L,F,Ri,Fi,Li,F,R,Fi};
                                new_moves_ready <= 1;
                                step <= PLL_EDGES;
                                state <= UPDATE_STATE;
                            end
                            // bowtie/butterfly: 41:39, 53:51 W
                            if (cubestate[41:39] == W && cubestate[53:51] == W) begin
                                next_moves <= next_moves | {R,U,Ri,Ui,Ri,F,R,U,R,Ui,Ri,Fi};
                                new_moves_ready <= 1;
                                step <= PLL_EDGES;
                                state <= UPDATE_STATE;
                            end
                            // superman: 35:33, 53:51, 20:18, 23:21 W
                            if (cubestate[35:33] == W && cubestate[53:51] == W && cubestate[20:18] == W && cubestate[23:21] == W) begin
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
                        end
    
                        PLL_EDGES: begin
                            // 8 different U perms, 2 Z perms...
                            // solved
                            if (cubestate[92:90] == O && cubestate[107:105] == G && cubestate[110:108] == Red && cubestate[131:129] == Blue) step <= PLL_CORNERS;
                            // U: solved edge in back
                            else if (cubestate[92:90] == Red && cubestate[107:105] == O && cubestate[110:108] == G) begin
                                next_moves <= next_moves | {R,R,U,R,U,Ri,Ui,Ri,Ui,Ri,U,Ri};
                                new_moves_ready <= 1;
                                step <= PLL_CORNERS;
                                state <= UPDATE_STATE;
                            end
                            else if (cubestate[92:90] == G && cubestate[107:105] == Red && cubestate[110:108] == O) begin
                                next_moves <= next_moves | {R,Ui,R,U,R,U,R,Ui,Ri,Ui,R,R};
                                new_moves_ready <= 1;
                                step <= PLL_CORNERS;
                                state <= UPDATE_STATE;
                            end
                            // U: solved edge on left
                            else if (cubestate[131:129] == G && cubestate[107:105] == Red && cubestate[110:108] == Blue) begin
                                next_moves <= next_moves | {U,R,Ui,R,U,R,U,R,Ui,Ri,Ui,R,R,Ui};
                                new_moves_ready <= 1;
                                step <= PLL_CORNERS;
                                state <= UPDATE_STATE;
                            end
                            else if (cubestate[131:129] == Red && cubestate[107:105] == Blue && cubestate[110:108] == G) begin
                                next_moves <= next_moves | {U,R,R,U,R,U,Ri,Ui,Ri,Ui,Ri,U,Ri,Ui};
                                new_moves_ready <= 1;
                                step <= PLL_CORNERS;
                                state <= UPDATE_STATE;
                            end
                            // U: solved edge in front
                            else if (cubestate[131:129] == Red && cubestate[92:90] == Blue && cubestate[110:108] == O) begin
                                next_moves <= next_moves | {U,U,R,R,U,R,U,Ri,Ui,Ri,Ui,Ri,U,Ri,U,U};
                                new_moves_ready <= 1;
                                step <= PLL_CORNERS;
                                state <= UPDATE_STATE;
                            end
                            else if (cubestate[131:129] == O && cubestate[92:90] == Red && cubestate[110:108] == Blue) begin
                                next_moves <= next_moves | {U,U,R,Ui,R,U,R,U,R,Ui,Ri,Ui,R,R,U,U};
                                new_moves_ready <= 1;
                                step <= PLL_CORNERS;
                                state <= UPDATE_STATE;
                            end
                            // U: solved edge on right
                            else if (cubestate[131:129] == G && cubestate[107:105] == O && cubestate[92:90] == Blue) begin
                                next_moves <= next_moves | {Ui,R,R,U,R,U,Ri,Ui,Ri,Ui,Ri,U,Ri,U};
                                new_moves_ready <= 1;
                                step <= PLL_CORNERS;
                                state <= UPDATE_STATE;
                            end
                            else if (cubestate[131:129] == O && cubestate[107:105] == Blue && cubestate[92:90] == G) begin
                                next_moves <= next_moves | {Ui,R,Ui,R,U,R,U,R,Ui,Ri,Ui,R,R,U};
                                new_moves_ready <= 1;
                                step <= PLL_CORNERS;
                                state <= UPDATE_STATE;
                            end
                            // Z perms - reduce to U perm
                            else if (cubestate[107:105] == Red && cubestate[110:108] == G && cubestate[92:90] == Blue && cubestate[131:129] == O) begin
                                next_moves <= next_moves | {R,R,U,R,U,Ri,Ui,Ri,Ui,Ri,U,Ri};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                            else if (cubestate[107:105] == O && cubestate[110:108] == Blue && cubestate[92:90] == G && cubestate[131:129] == Red) begin
                                next_moves <= next_moves | {R,R,U,R,U,Ri,Ui,Ri,Ui,Ri,U,Ri};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                            // only 2 are solved
                            else if (cubestate[92:90] == O && cubestate[110:108] == Red && cubestate[107:105] == Blue && cubestate[131:129] == G) begin
                                next_moves <= next_moves | {Ui,R,U,Ri,Ui,Ri,F,R,R,Ui,Ri,Ui,R,U,Ri,Fi,U};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                            else if (cubestate[92:90] == Red && cubestate[110:108] == O && cubestate[107:105] == G && cubestate[131:129] == Blue) begin
                                next_moves <= next_moves | {Ui,R,U,Ri,Ui,Ri,F,R,R,Ui,Ri,Ui,R,U,Ri,Fi,U};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                            // otherwise, turn U until we recognize something (probably we have an H perm/edges are solved
                            else begin
                                next_moves <= next_moves | {U};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                        end
    
                        // testing purposes - we're gonna begin here...
                        // this is step number 6 (parameter wise)
                        PLL_CORNERS: begin
                            // solved
                            if (cubestate[26:24] == G && cubestate[35:33] == G && cubestate[56:54] == Blue && cubestate[53:51] == Blue) step <= SOLVED;
                            // a perm - two per each corner ==> 8 a perms
                            // a perm - URF
                            else if (cubestate[35:33] == Blue && cubestate[38:36] == G && cubestate[53:51] == Red) begin
                                next_moves <= next_moves | {Ri,F,Ri,B,B,R,Fi,Ri,B,B,R,R};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                            else if (cubestate[35:33] == Red && cubestate[38:36] == Blue && cubestate[53:51] == G) begin
                                next_moves <= next_moves | {R,R,B,B,R,F,Ri,B,B,R,Fi,R};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                            // a perm - URB
                            else if (cubestate[38:36] == O && cubestate[53:51] == Red && cubestate[20:18] == Blue) begin
                                next_moves <= next_moves | {U,Ri,F,Ri,B,B,R,Fi,Ri,B,B,R,R,Ui};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                            else if (cubestate[38:36] == Blue && cubestate[53:51] == O && cubestate[20:18] == Red) begin
                                next_moves <= next_moves | {U,R,R,B,B,R,F,Ri,B,B,R,Fi,R,Ui};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                            // a perm - ULB
                            else if (cubestate[35:33] == Blue && cubestate[53:51] == O && cubestate[20:18] == G) begin
                                next_moves <= next_moves | {U,U,R,R,B,B,R,F,Ri,B,B,R,Fi,R,Ui,Ui};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                            else if (cubestate[35:33] == O && cubestate[53:51] == G && cubestate[20:18] == Blue) begin
                                next_moves <= next_moves | {U,U,Ri,F,Ri,B,B,R,Fi,Ri,B,B,R,R,Ui,Ui};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                            // a perm - ULF
                            else if (cubestate[35:33] == Red && cubestate[38:36] == O && cubestate[20:18] == G) begin
                                next_moves <= next_moves | {Ui,R,R,B,B,R,F,Ri,B,B,R,Fi,R,U};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                            else if (cubestate[35:33] == O && cubestate[38:36] == G && cubestate[20:18] == Red) begin
                                next_moves <= next_moves | {Ui,Ri,F,Ri,B,B,R,Fi,Ri,B,B,R,R,U};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                            // e perm - two orientations
                            else if (cubestate[26:24] == O && cubestate[35:33] == Red && cubestate[23:21] == G && cubestate[38:36] == G) begin
                                next_moves <= next_moves | {R,Bi,Ri,F,R,B,Ri,Fi,R,B,Ri,F,R,Bi,Ri,Fi};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                            else if (cubestate[26:24] == Red && cubestate[35:33] == O && cubestate[23:21] == Blue && cubestate[38:36] == Blue) begin
                                next_moves <= next_moves | {U,R,Bi,Ri,F,R,B,Ri,Fi,R,B,Ri,F,R,Bi,Ri,Fi,Ui};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                            // h perm - only one orientation
                            else if (cubestate[26:24] == Blue && cubestate[35:33] == Blue && cubestate[56:54] == G && cubestate[53:51] == G) begin
                                next_moves <= next_moves | {R,R,U,U,R,R,U,U,R,R,U,R,R,U,U,R,R,U,U,R,R,U};
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                            end
                            // otherwise just turn U till we figure out what the shit is happening here
                            else begin
                                next_moves <= next_moves | U;
                                new_moves_ready <= 1;
                                state <= UPDATE_STATE;
                                fucked <= 1;
                            end
                        end
    
                        SOLVED: cube_solved <= 1;
    
                        // another hack for things...
                        default : step <= PLL_CORNERS;
                    endcase
                end
    
                WAIT: begin
                    counter <= counter + 1;
                    state <= (counter == 60) ? MOVE : WAIT;
                end
    
                UPDATE_STATE:begin
                    next_moves <= 0;
                    new_moves_ready <= 0;
                    counter <= 0;
                    // if we get the thing then go to the MOVE state
                    if (state_updated) begin
                        state <= WAIT;
                        // probably some other kinda shit i need to do here huh...
                    end
                end
    
                default : state <= UPDATE_STATE; // uhh.....
            endcase
        end
    end
endmodule