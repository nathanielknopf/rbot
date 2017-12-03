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

module spin_all(input send_setup_moves, clock, [5:0] counter
                output reg [59:0] moves, reg new_moves);    

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
    // goes high when moves register has actual moves in it, and we want them to be executed by the robot
    reg new_moves = 0;

    always @(posedge clock) begin
        case (state)
            SEND_MOVES: begin
                case (counter)
                    // {ULB, ULF, URF, URB}
                    0: moves <= moves | 0;
                    1: moves <= moves | {U};
                    2: moves <= moves | {U};
                    3: moves <= moves | {U};
                    // F B' {LDB, LDF, LUF, LUB} B F'
                    4: moves <= moves | {U,F,Bi};
                    5: moves <= moves | {U};
                    6: moves <= moves | {U};
                    7: moves <= moves | {U};
                    // L' R {FUL, FDL, FDR, FUR} R' L
                    8: moves <= moves | {U,B,Fi,Li,R};
                    9: moves <= moves | {U};
                    10: moves <= moves | {U};
                    11: moves <= moves | {U};
                    // F' B {RUB, RUF, RDF, RDB} B' F
                    12: moves <= moves | {U,Ri,L,Fi,B};
                    13: moves <= moves | {U};
                    14: moves <= moves | {U};
                    15: moves <= moves | {U};
                    // L R' {BDL, BUL, BUR, BDR} R L'
                    16: moves <= moves | {U,Bi,F,L,Ri};
                    17: moves <= moves | {U};
                    18: moves <= moves | {U};
                    19: moves <= moves | {U};
                    // L2 R2 {DLF, DLB, DRB, DRF} L2 R2
                    20: moves <= moves | {U,Ri,L};
                    21: moves <= moves | {U};
                    22: moves <= moves | {U};
                    23: moves <= moves | {U};
                    // {UB, UL, UF, UR}
                    24: moves <= moves | {Li,R};
                    25: moves <= moves | {U};
                    26: moves <= moves | {U};
                    27: moves <= moves | {U};
                    // F B' L U F B' {LD, LF, LU, LB} B F' U' L' B F'
                    28: moves <= moves | {U,F,Bi,L,U,F,Bi};
                    29: moves <= moves | {U};
                    30: moves <= moves | {U};
                    31: moves <= moves | {U};
                    // L' R F U' L' R {FR, FD, FL, FU} R' L U F' R' L
                    32: moves <= moves | {U,B,Fi,Ui,Li,B,Fi,Li,R,F,Ui,Li,R};
                    33: moves <= moves | {U};
                    34: moves <= moves | {U};
                    35: moves <= moves | {U};
                    // F' B R U F' B {RU, RL, RD, RB} B' F U' R' B' F
                    36: moves <= moves | {U,Ri,L,U,Fi,Ri,L,Fi,B,R,U,Fi,B};
                    37: moves <= moves | {U};
                    38: moves <= moves | {U};
                    39: moves <= moves | {U};
                    // L R' B' U L R' {BL, BD, BR, BU} R L' U' B R L'
                    40: moves <= moves | {U,Bi,F,Ui,Ri,Bi,F,L,Ri,Bi,U,L,Ri};
                    41: moves <= moves | {U};
                    42: moves <= moves | {U};
                    43: moves <= moves | {U};
                    // R2 L2 F2 B2 {DB, DL, DF, DR} B2 F2 L2 R2
                    40: moves <= moves | {U,R,Li,Ui,B,R,Li,R,R,L,L,F,F,B,B};
                    41: moves <= moves | {U};
                    42: moves <= moves | {U};
                    43: moves <= moves | {U};
                    // done, gotta make sure we do these moves....
                    44: moves <= moves | {B,B,F,F,L,L,R,R};
                    default : moves <= {NULL};
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
    end
endmodule