// corner_num is an int from 0 to 23, in the order in which we learn the corners
// this outputs some bullshit

module lookup (
    input clock,    // Clock
    input [4:0] corner_num,
    output reg [7:0] ind
);
    case (corner_num)
        // subtract 75 + 3 times the index here
        0: ind <= 7'd36; // DFR - cubestate[71:69] (actually want 107:105)
        1: ind <= 7'd75; // DBR - cubestate[68:66] (actually want 143:141)
        2: ind <= 7'd36; // DBL - cubestate[65:63] (actually want 101:99)
        3: ind <= 7'd75; // DFL - cubestate[62:60] (actually want 137:135)
        4: ind <= 7'd48; // BDL - cubestate[59:57] (actually want 107:105)
        5: ind <= 7'd72; // BUR - cubestate[56:54] (actually want 128:126)
        6: ind <= 7'd48; // BUL - cubestate[53:51] (actually want 101:99)
        7: ind <= 7'd72; // BDL - cubestate[50:48] (actually want 122:120)
        8: ind <= 7'd51; // RDB - cubestate[47:45] (actually want 98:96)
        9: ind <= 7'd72; // RDF - cubestate[44:42] (actually want 116:114)
        10: ind <= 7'd63; // RUF - cubestate[41:39] (actually want 104:102)
        11: ind <= 7'd72; // RUB - cubestate[38:36] (actually want 110:108)
        12: ind <= 7'd72; // FUR - cubestate[35:33] (actually want 107:105)
        13: ind <= 7'd66; // FDR - cubestate[32:30] (actually want 98:96)
        14: ind <= 7'd72; // FDL - cubestate[29:27] (actually want 101:99)
        15: ind <= 7'd78; // FUL - cubestate[26:24] (actually want 104:102)
        16: ind <= 7'd81; // LBU - cubestate[23:21] (actually want 104:102)
        17: ind <= 7'd72; // LFU - cubestate[20:18] (actually want 92:90)
        18: ind <= 7'd81; // LFD - cubestate[17:15] (actually want 98:96)
        19: ind <= 7'd72; // LBD - cubestate[14:12] (actually want 86:84)
        20: ind <= 7'd96; // UBR - cubestate[11:9] (actually want 107:105)
        21: ind <= 7'd75; // UFR - cubestate[8:6] (actually want 83:81)
        22: ind <= 7'd96; // UFL - cubestate[5:3] (actually want 101:99)
        23: ind <= 7'd75; // UBL - cubestate[2:0] (actually want 77:75)
        default : ind <= 7'd0;
    endcase
endmodule
