 // basically need an internal variable that tracks what block of moves to spit out
// some dumb nerd shit

// determine all corners
    // go face by face ULFRBD
    // go ULB, ULF, URF, URB, LDB, LDF, LUF, LUB, FUL, FDL, FDR, FUR, 
    // RUB, RUF, RDF, RDB, BDL, BUL, BUR, BDR, DLF, DLB, DRB, DRF
    // notation {a,b,c,d} means observe a, b, c, d in order and execute U move after each observation
    // actual batches 
        // {ULB, ULF, URF, URB}
        // F B' {LDB, LDF, LUF, LUB} B F'
        // L' R {FUL, FDL, FDR, FUR} R' L
        // F' B {RUB, RUF, RDF, RDB} B' F
        // L R' {BDL, BUL, BUR, BDR} R L'
        // L2 R2 {DLF, DLB, DRB, DRF} L2 R2

// determine all edges
    // go face by face ULFRBD
    // go UB, UL, UF, UR, LD, LF, LU, LB, FR, FD, FL, FU, RU, RL, RD, RB, BL, BD, BR, BU, DB, DL, DF, DR
    // for brackets, perform a U move between each piece
    // notation {a,b,c,d} means observe a, b, c, d in order and execute U move after each observation
    // actual batches 
        // {UB, UL, UF, UR}
        // F B' L U F B' {LD, LF, LU, LB} B F' U' L' B F'
        // L' R F U' L' R {FR, FD, FL, FU} R' L U F' R' L
        // F' B R U F' B {RU, RL, RD, RB} B' F U' R' B' F
        // L R' B' U L R' {BL, BD, BR, BU} R L' U' B R L'
        // R2 L2 F2 B2 {DB, DL, DF, DR} B2 F2 L2 R2

module spin_all(input send_setup_moves, clock, [5:0] counter,
                output reg [199:0] moves, reg new_moves=0);    

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

    parameter SEND_MOVES = 0;
    parameter IDLE = 1; 

    // FSM state - either sending moves or waiting for a signal from determine_state module to spit out new moves
    reg state = 0;

    always @(posedge clock) begin
        case (state)
            SEND_MOVES: begin
                case (counter)
                    // for real though...
                    // {DR, DF, DL, DB}
                    0: moves <= moves | {R,Li,Di,F,R,Li,U,Ui}; // DR
                    1: moves <= moves | {Fi,R,Ri}; // DF
                    2: moves <= moves | {Fi,U,Ui}; // DL
                    3: moves <= moves | {Fi,R,Ri}; // DB
                    // {BU, BR, BD, BL}              |            (lck)
                    4: moves <= moves | {Fi,L,Ri,Fi,D,Li,R,B,F,L,L,U,Ui,Ri,Ri,Fi,U,Ui}; // BU
                    5: moves <= moves | {F,R,Ri}; // BR
                    6: moves <= moves | {F,U,Ui}; // BD
                    7: moves <= moves | {F,R,Ri}; // BL
                    // {RB, RD, RF, RU}                   (solved)v
                    8: moves <= moves | {F,F,L,L,R,R,Fi,Bi,L,L,R,R,U,Di,R,F,U,Di,R,Ri}; // RB
                    9: moves <= moves | {Fi,U,Ui}; // RD
                    10: moves <= moves | {Fi,R,Ri}; // RF
                    11: moves <= moves | {Fi,U,Ui}; // RU
                    // {FU, FL, FD, FR}             (solved)v
                    12: moves <= moves | {Fi,D,Ui,Fi,Ri,D,Ui,F,F,R,Ri}; // FU
                    13: moves <= moves | {F,U,Ui}; // FL
                    14: moves <= moves | {F,R,Ri}; // FD
                    15: moves <= moves | {F,U,Ui}; // FR
                    // {LB, LU, LF, LD}
                    16: moves <= moves | {Fi,Ui,D,L,F,Ui,D,F,F,R,Ri}; // LB
                    17: moves <= moves | {Fi,U,Ui}; // LU
                    18: moves <= moves | {Fi,R,Ri}; // LF
                    19: moves <= moves | {Fi,U,Ui}; // LD
                    // {UR, UF, UL, UB}            (solved)v
                    20: moves <= moves | {F,Di,U,Fi,Li,Di,U,L,Ri,U,F,L,Ri}; // UR
                    21: moves <= moves | {Fi,R,Ri}; // UF
                    22: moves <= moves | {Fi,U,Ui}; // UL
                    23: moves <= moves | {Fi,R,Ri}; // UB
                    // {DFR, DBR, DBL, DFL}         (solved)v
                    24: moves <= moves | {Fi,R,Li,Fi,Ui,R,Li,R,Li,F,F,R,Ri}; // DFR
                    25: moves <= moves | {Fi,U,Ui}; // DBR
                    26: moves <= moves | {Fi,R,Ri}; // DBL
                    27: moves <= moves | {Fi,U,Ui}; // DFL
                    // {BDL, BUR, BUL,BDL}
                    28: moves <= moves | {F,R,Li,F,F,R,Ri}; // BDL
                    29: moves <= moves | {Fi,U,Ui}; // BUR
                    30: moves <= moves | {Fi,R,Ri}; // BUL
                    31: moves <= moves | {Fi,U,Ui}; // BDL
                    // {RDB, RDF, RUF, RUB}
                    32: moves <= moves | {F,R,R,L,L,U,Di,F,R,Ri}; // RDB
                    33: moves <= moves | {Fi,U,Ui}; // RDF
                    34: moves <= moves | {Fi,R,Ri}; // RUF
                    35: moves <= moves | {Fi,U,Ui}; // RUB
                    // {FUR, FDR, FDL, FUL}
                    36: moves <= moves | {F,F,D,Ui,F,F,R,Ri}; // FUR
                    37: moves <= moves | {Fi,U,Ui}; // FDR
                    38: moves <= moves | {Fi,R,Ri}; // FDL
                    39: moves <= moves | {Fi,U,Ui}; // FUL
                    // {LBU, LFU, LFD, LBD}
                    40: moves <= moves | {F,Ui,D,Fi,R,Ri}; // LBU
                    41: moves <= moves | {Fi,U,Ui}; // LFU
                    42: moves <= moves | {Fi,R,Ri}; // LFD
                    43: moves <= moves | {Fi,U,Ui}; // LBD
                    // {UBR, UFR, UFL, UBL}
                    44: moves <= moves | {U,Di,L,Ri,F,F,R,Ri}; // UBR
                    45: moves <= moves | {Fi,R,Ri}; // UFR
                    46: moves <= moves | {Fi,U,Ui}; // UFL
                    47: moves <= moves | {Fi,R,Ri}; // UBL
                    // unfuck it
                    48: moves <= moves | {F,R,Li};
                endcase
                state <= IDLE;
                new_moves <= 1;
            end
            IDLE: begin
                if (send_setup_moves) state <= SEND_MOVES;
                moves <= 0;
                new_moves <= 0;
            end
            default : state <= IDLE;
        endcase
    end
endmodule


// old broken stuff from when i was not smart
                    // // {ULB, ULF, URF, URB}
                    // 0: moves <= moves | {L,Ri,Fi,U,Ui}; // ULB
                    // 1: moves <= moves | {F,R,Ri}; // ULF
                    // 2: moves <= moves | {F,U,Ui}; // URF
                    // 3: moves <= moves | {F,R,Ri}; // URB
                    // // {LDB, LDF, LUF, LUB}
                    // 4: moves <= moves | {F,F,Li,R,Ui,D,R,Ri}; // LDB
                    // 5: moves <= moves | {F,U,Ui}; // LDF
                    // 6: moves <= moves | {F,R,Ri}; // LUF
                    // 7: moves <= moves | {F,U,Ui}; // LUB
                    // // {FUL, FDL, FDR, FUR}
                    // 8: moves <= moves | {F,U,Di,Fi,R,Ri}; // FUL
                    // 9: moves <= moves | {F,U,Ui}; // FDL
                    // 10: moves <= moves | {F,R,Ri}; // FDR
                    // 11: moves <= moves | {F,U,Ui}; // FUR
                    // // {RUB, RUF, RDF, RDB}
                    // 12: moves <= moves | {F,F,U,Di,F,F,R,Ri}; // RUB
                    // 13: moves <= moves | {F,U,Ui}; // RUF
                    // 14: moves <= moves | {F,R,Ri}; // RDF
                    // 15: moves <= moves | {F,U,Ui}; // RDB
                    // // {BDL, BUL, BUR, BDR}
                    // 16: moves <= moves | {Fi,U,Di,R,Ri}; // BDL
                    // 17: moves <= moves | {Fi,U,Ui}; // BUL
                    // 18: moves <= moves | {Fi,R,Ri}; // BUR
                    // 19: moves <= moves | {Fi,U,Ui}; // BDR
                    // // {DLF, DLB, DRB, DRF}
                    // 20: moves <= moves | {Fi,U,U,D,D,Li,R,Fi,U,Ui}; // DLF
                    // 21: moves <= moves | {F,R,Ri}; // DLB
                    // 22: moves <= moves | {F,U,Ui}; // DRB
                    // 23: moves <= moves | {F,R,Ri}; // DRF
                    // // {UB, UL, UF, UR}   (solved)v
                    // 24: moves <= moves | {F,F,L,Ri,Ui,L,Ri,U,F,L,Ri,F,F,U,Ui}; // UB
                    // 25: moves <= moves | {F,R,Ri}; // UL
                    // 26: moves <= moves | {F,U,Ui}; // UF
                    // 27: moves <= moves | {F,R,Ri}; // UR
                    // // {LD, LF, LU, LB}               (solved)v // skips here... first two
                    // 28: moves <= moves | {Fi,R,Li,Fi,Ui,R,Li,U,Ui,D,Li,Fi,Ui,D,F,U,Ui};
                    // 29: moves <= moves | {F,R,Ri}; // LF
                    // 30: moves <= moves | {F,U,Ui}; // LU
                    // 31: moves <= moves | {F,R,Ri}; // LB
                    // // {FR, FD, FL, FU}        (solved)v
                    // 32: moves <= moves | {Di,U,F,L,Di,U,F,R,Ri}; // FR
                    // 33: moves <= moves | {Fi,U,Ui}; // FD
                    // 34: moves <= moves | {Fi,R,Ri}; // FL
                    // 35: moves <= moves | {Fi,U,Ui}; // FU
                    // // {RU, RL, RD, RB}(slvd)v
                    // 36: moves <= moves | {F,F,U,Di,Ri,Fi,Di,U,Fi,R,Ri}; // RU
                    // 37: moves <= moves | {F,U,Ui}; // RL
                    // 38: moves <= moves | {F,R,Ri}; // RD
                    // 39: moves <= moves | {F,U,Ui}; // RB
                    // // {BL, BD, BR, BU}            (solved)v 
                    // 40: moves <= moves | {F,F,Ui,D,F,R,D,Ui,D,D,U,U,F,B,U,U,D,D,F,F,R,Ri}; // BL
                    // 41: moves <= moves | {F,U,Ui}; // BD
                    // 42: moves <= moves | {F,R,Ri}; // BR
                    // 43: moves <= moves | {F,U,Ui}; // BU
                    // // {DB, DL, DF, DR}                   (solved)v
                    // 44: moves <= moves | {Fi,D,D,U,U,Bi,Fi,U,U,D,D,R,Li,Di,F,R,Li,F,U,Ui}; // DB
                    // 45: moves <= moves | {F,R,Ri}; // DL
                    // 46: moves <= moves | {F,U,Ui}; // DF
                    // 47: moves <= moves | {F,R,Ri}; // DR
                    // // done, gotta make sure we do these moves....
                    // 48: moves <= moves | {L,Ri,Fi,D,L,Ri}; // solved...?