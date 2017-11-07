// c is the color sensor at the ULB corner
// e is the color sensor at the UB edge

// each sticker takes 3 bits to represent (2^3 = 8, need 6)

parameter W = 0;
parameter O = 1;
parameter G = 2;
parameter R = 3;
parameter B = 4;
parameter Y = 5;

// state is a 54*3=162 bit register
reg [161:0] s;

// center values never change
s[12:14] = W;
s[39:41] = O;
s[66:68] = G;
s[93:95] = R;
s[120:122] = B;
s[147:149] = Y;

// probably can implement with FSM

// flow:
    // determine all corners
        // go face by face ULFRBD
        // go ULB, ULF, URF, URB
        // {ULB, ULF, URF, URB}
        // F B' {LDB, LDF, LUF, LUB} B F'
        // L' R {FUL, FDL, FDR, FUR} R' L
        // F' B {RUB, RUF, RDF, RDB} B' F
        // L R' {BDL, BUL, BUR, BDR} R L'
        // L2 R2 {DLF, DLB, DRB, DRF} L2 R2
    // determine all edges
        // go face by face ULFRBD
        // go UB, UL, UF, UR
        // for brackets, perform a U move between each piece
        // {UB, UL, UF, UR}
        // F B' L U F B' {LD, LF, LU, LB} B F' U' L' B F'
        // L' R F U' L' R {FR, FD, FL, FB} R' L U F' R' L
        // F' B R U F' B {RU, RL, RD, RB} B' F U' R' B' F
        // L R' B' U L R' {BL, BD, BR, BU} R L' U' B R L'
        // R2 L2 F2 B2 {DB, DL, DF, DR} B2 F2 L2 R2
    // for each piece, need following states:
        // begin: send setup moves to motor, go immediately to wait
        // wait: wait for the motors to finish - when they send done signal, go to observe
        // observe: store value under sensor in question in value in question
    // 14 states: for each piece, 3 states


