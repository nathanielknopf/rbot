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
                output reg [59:0] moves, reg new_moves=0);    

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
                    // {ULB, ULF, URF, URB}
                    0: moves <= moves | {L,Ri,Fi}; // ULB
                    1: moves <= moves | {F}; // ULF
                    2: moves <= moves | {F}; // URF
                    3: moves <= moves | {F}; // URB
                    // {LDB, LDF, LUF, LUB}
                    4: moves <= moves | {F,F,Li,R,Ui,D}; // LDB
                    5: moves <= moves | {F}; // LDF
                    6: moves <= moves | {F}; // LUF
                    7: moves <= moves | {F}; // LUB
                    // {FUL, FDL, FDR, FUR}
                    8: moves <= moves | {F,U,Di,Fi}; // FUL
                    9: moves <= moves | {F}; // FDL
                    10: moves <= moves | {F}; // FDR
                    11: moves <= moves | {F}; // FUR
                    // {RUB, RUF, RDF, RDB}
                    12: moves <= moves | {F,F,U,Di,F,F}; // RUB
                    13: moves <= moves | {F}; // RUF
                    14: moves <= moves | {F}; // RDF
                    15: moves <= moves | {F}; // RDB
                    // {BDL, BUL, BUR, BDR}
                    16: moves <= moves | {Fi,U,Di}; // BDL
                    17: moves <= moves | {Fi}; // BUL
                    18: moves <= moves | {Fi}; // BUR
                    19: moves <= moves | {Fi}; // BDR
                    // {DLF, DLB, DRB, DRF}
                    20: moves <= moves | {Fi,U,U,D,D,Li,R,Fi}; // DLF
                    21: moves <= moves | {F}; // DLB
                    22: moves <= moves | {F}; // DRB
                    23: moves <= moves | {F}; // DRF
                    // {UB, UL, UF, UR}   (solved)v
                    24: moves <= moves | {F,F,L,Ri,Ui,L,Ri,U,F,L,Ri,F,F}; // UB
                    25: moves <= moves | {F}; // UL
                    26: moves <= moves | {F}; // UF
                    27: moves <= moves | {F}; // UR
                    // {LD, LF, LU, LB}               (solved)v
                    28: moves <= moves | {Fi,R,Li,Fi,Ui,R,Li,U,Ui,D,Li,Fi,Ui,D,F};
                    29: moves <= moves | {F}; // LF
                    30: moves <= moves | {F}; // LU
                    31: moves <= moves | {F}; // LB
                    // {FR, FD, FL, FU}        (solved)v
                    32: moves <= moves | {Di,U,F,L,Di,U,F}; // FR
                    33: moves <= moves | {Fi}; // FD
                    34: moves <= moves | {Fi}; // FL
                    35: moves <= moves | {Fi}; // FU
                    // {RU, RL, RD, RB}(slvd)v
                    36: moves <= moves | {F,F,U,Di,Ri,Fi,Di,U,Fi}; // RU
                    37: moves <= moves | {F}; // RL
                    38: moves <= moves | {F}; // RD
                    39: moves <= moves | {F}; // RB
                    // {BL, BD, BR, BU}            (solved)v
                    40: moves <= moves | {F,F,Ui,D,F,R,D,Ui,D,D,U,U,F,B,U,U,D,D,F,F}; // BL
                    41: moves <= moves | {F}; // BD
                    42: moves <= moves | {F}; // BR
                    43: moves <= moves | {F}; // BU
                    // {DB, DL, DF, DR}                   (solved)v
                    44: moves <= moves | {Fi,D,D,U,U,Bi,Fi,U,U,D,D,R,Li,Di,F,R,Li,F}; // DB
                    45: moves <= moves | {F}; // DL
                    46: moves <= moves | {F}; // DF
                    47: moves <= moves | {F}; // DR
                    // done, gotta make sure we do these moves....
                    48: moves <= moves | {L,Ri,Fi,D,L,Ri}; // solved...?
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