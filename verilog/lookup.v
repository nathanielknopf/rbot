// corner_num is an int from 0 to 23, in the order in which we learn the corners
// this outputs some bullshit

module lookup (
    input clock,    // Clock
    input [4:0] corner_num,
    output reg [7:0] ind
);
    case (corner_num)
        0: ind <= 7'd105; // DFR
        1: ind <= 7'd141; // DBR
        2: ind <= 7'd99; // DBL
        3: ind <= 7'd135; // DFL
        4: ind <= 7'd105; // BDL
        5: ind <= 7'd126; // BUR
        6: ind <= 7'd99; // BUL
        7: ind <= 7'd120; // BDL
        8: ind <= 7'd96; // RDB
        9: ind <= 7'd114; // RDF
        10: ind <= 7'd102; // RUF
        11: ind <= 7'd108; // RUB
        12: ind <= 7'd105; // FUR
        13: ind <= 7'd96; // FDR
        14: ind <= 7'd99; // FDL
        15: ind <= 7'd102; // FUL
        16: ind <= 7'd102; // LBU
        17: ind <= 7'd90; // LFU
        18: ind <= 7'd96; // LFD
        19: ind <= 7'd84; // LBD
        20: ind <= 7'd105; // UBR
        21: ind <= 7'd81; // UFR
        22: ind <= 7'd99; // UFL
        23: ind <= 7'd75; // UBL
        default : ind <= 3'd0;
    endcase
endmodule
