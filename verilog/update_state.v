module update_state (
    input clock, [199:0] moves_input, new_moves_ready, [161:0] cubestate_input,
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
    parameter DONE = 2;

    reg [1:0] state = IDLE;

    reg [5:0] counter = 0;

    reg [161:0] cubestate = 0;
    reg [199:0] moves = 0;
    reg [3:0] next_move;

    always @(posedge clock) begin
        case (state)
            MOVING: begin
                case (next_move)
                    R: begin
                        // corners not on R face
                        cubestate[8:6] <= cubestate[32:30];
                        cubestate[11:9] <= cubestate[35:33];
                        cubestate[56:54] <= cubestate[8:6];
                        cubestate[59:57] <= cubestate[11:9];
                        cubestate[68:66] <= cubestate[56:54];
                        cubestate[71:69] <= cubestate[59:57];
                        cubestate[32:30] <= cubestate[68:66];
                        cubestate[35:33] <= cubestate[71:69];
                        // edges not on R face
                        cubestate[83:81] <= cubestate[98:96];
                        cubestate[128:126] <= cubestate[83:81];
                        cubestate[143:141] <= cubestate[128:126];
                        cubestate[98:96] <= cubestate[143:141];
                        // stickers on R face
                        cubestate[38:36] <= cubestate[41:39];
                        cubestate[47:45] <= cubestate[38:36];
                        cubestate[44:42] <= cubestate[47:45]; 
                        cubestate[41:39] <= cubestate[44:42]; 
                        cubestate[110:108] <= cubestate[113:111];
                        cubestate[119:117] <= cubestate[110:108];
                        cubestate[116:114] <= cubestate[119:117];
                        cubestate[113:111] <= cubestate[116:114];
                    end
                    Ri: begin
                        // corners not on R face
                        cubestate[32:30] <= cubestate[8:6];
                        cubestate[35:33] <= cubestate[11:9];
                        cubestate[8:6] <= cubestate[56:54];
                        cubestate[11:9] <= cubestate[59:57];
                        cubestate[56:54] <= cubestate[68:66];
                        cubestate[59:57] <= cubestate[71:69];
                        cubestate[68:66] <= cubestate[32:30];
                        cubestate[71:69] <= cubestate[35:33];
                        // edges not on R face
                        cubestate[98:96] <= cubestate[83:81];
                        cubestate[83:81] <= cubestate[128:126];
                        cubestate[128:126] <= cubestate[143:141];
                        cubestate[143:141] <= cubestate[98:96];
                        // stickers on R face
                        cubestate[41:39] <= cubestate[38:36];
                        cubestate[38:36] <= cubestate[47:45];
                        cubestate[47:45] <= cubestate[44:42];
                        cubestate[44:42] <= cubestate[41:39];
                        cubestate[113:111] <= cubestate[110:108];
                        cubestate[110:108] <= cubestate[119:117];
                        cubestate[119:117] <= cubestate[116:114];
                        cubestate[116:114] <= cubestate[113:111];
                    end
                    U: begin
                        // corners not on U face
                        cubestate[26:24] <= cubestate[41:39];
                        cubestate[41:39] <= cubestate[56:54];
                        cubestate[56:54] <= cubestate[23:21];
                        cubestate[23:21] <= cubestate[26:24];
                        cubestate[35:33] <= cubestate[38:36];
                        cubestate[38:36] <= cubestate[53:51];
                        cubestate[53:51] <= cubestate[20:18];
                        cubestate[20:18] <= cubestate[35:33];
                        // edges not on U face
                        cubestate[107:105] <= cubestate[110:108];
                        cubestate[110:108] <= cubestate[131:129];
                        cubestate[131:129] <= cubestate[92:90];
                        cubestate[92:90] <= cubestate[107:105];
                        // stickers on U face
                        cubestate[2:0] <= cubestate[5:3];
                        cubestate[5:3] <= cubestate[8:6];
                        cubestate[8:6] <= cubestate[11:9];
                        cubestate[11:9] <= cubestate[2:0];
                        cubestate[77:75] <= cubestate[80:78];
                        cubestate[80:78] <= cubestate[83:81];
                        cubestate[83:81] <= cubestate[74:72];
                        cubestate[74:72] <= cubestate[77:75];
                    end
                    Ui: begin
                        // corners not on U face
                        cubestate[41:39] <= cubestate[26:24];
                        cubestate[56:54] <= cubestate[41:39];
                        cubestate[23:21] <= cubestate[56:54];
                        cubestate[26:24] <= cubestate[23:21];
                        cubestate[38:36] <= cubestate[35:33];
                        cubestate[53:51] <= cubestate[38:36];
                        cubestate[20:18] <= cubestate[53:51];
                        cubestate[35:33] <= cubestate[20:18];
                        // edges not on U face
                        cubestate[110:108] <= cubestate[107:105];
                        cubestate[131:129] <= cubestate[110:108];
                        cubestate[92:90] <= cubestate[131:129];
                        cubestate[107:105] <= cubestate[92:90];
                        // stickers on U face
                        cubestate[5:3] <= cubestate[2:0];
                        cubestate[8:6] <= cubestate[5:3];
                        cubestate[11:9] <= cubestate[8:6];
                        cubestate[2:0] <= cubestate[11:9];
                        cubestate[80:78] <= cubestate[77:75];
                        cubestate[83:81] <= cubestate[80:78];
                        cubestate[74:72] <= cubestate[83:81];
                        cubestate[77:75] <= cubestate[74:72];
                    end
                    F: begin
                        // corners not on F face
                        cubestate[41:39] <= cubestate[5:3];
                        cubestate[71:69] <= cubestate[41:39];
                        cubestate[17:15] <= cubestate[71:69];
                        cubestate[5:3] <= cubestate[17:15]; 
                        cubestate[44:42] <= cubestate[8:6];
                        cubestate[62:60] <= cubestate[44:42];
                        cubestate[20:18] <= cubestate[62:60];
                        cubestate[8:6] <= cubestate[20:18];
                        // edges not on F face 
                        cubestate[80:78] <= cubestate[89:87];
                        cubestate[113:111] <= cubestate[80:78];
                        cubestate[140:138] <= cubestate[113:111];
                        cubestate[89:87] <= cubestate[140:138];
                        // F face
                        cubestate[35:33] <= cubestate[26:24];
                        cubestate[32:30] <= cubestate[35:33];
                        cubestate[29:27] <= cubestate[32:30];
                        cubestate[26:24] <= cubestate[29:27];
                        cubestate[107:105] <= cubestate[104:102];
                        cubestate[98:96] <= cubestate[107:105];
                        cubestate[101:99] <= cubestate[98:96];
                        cubestate[104:102] <= cubestate[101:99];
                    end
                    Fi: begin
                        // corners not on F face
                        cubestate[5:3] <= cubestate[41:39];
                        cubestate[41:39] <= cubestate[71:69];
                        cubestate[71:69] <= cubestate[17:15];
                        cubestate[17:15] <= cubestate[5:3];
                        cubestate[8:6] <= cubestate[44:42];
                        cubestate[44:42] <= cubestate[62:60];
                        cubestate[62:60] <= cubestate[20:18];
                        cubestate[20:18] <= cubestate[8:6];
                        // edges not on F face
                        cubestate[89:87] <= cubestate[80:78];
                        cubestate[80:78] <= cubestate[113:111];
                        cubestate[113:111] <= cubestate[140:138];
                        cubestate[140:138] <= cubestate[89:87];
                        // F face
                        cubestate[26:24] <= cubestate[35:33];
                        cubestate[35:33] <= cubestate[32:30];
                        cubestate[32:30] <= cubestate[29:27];
                        cubestate[29:27] <= cubestate[26:24];
                        cubestate[104:102] <= cubestate[107:105];
                        cubestate[107:105] <= cubestate[98:96];
                        cubestate[98:96] <= cubestate[101:99];
                        cubestate[101:99] <= cubestate[104:102];
                    end
                    L: begin
                        // corners not on L face
                        cubestate[2:0] <= cubestate[50:48];
                        cubestate[50:48] <= cubestate[62:60];
                        cubestate[62:60] <= cubestate[26:24];
                        cubestate[26:24] <= cubestate[2:0];
                        cubestate[5:3] <= cubestate[53:51];
                        cubestate[53:51] <= cubestate[65:63];
                        cubestate[65:63] <= cubestate[29:27];
                        cubestate[29:27] <= cubestate[5:3];
                        // edges not on L face
                        cubestate[104:102] <= cubestate[77:75];
                        cubestate[77:75] <= cubestate[122:120];
                        cubestate[122:120] <= cubestate[137:135];
                        cubestate[137:135] <= cubestate[104:102];
                        // L face
                        cubestate[23:21] <= cubestate[14:12];
                        cubestate[14:12] <= cubestate[17:15];
                        cubestate[17:15] <= cubestate[20:18];
                        cubestate[20:18] <= cubestate[23:21];
                        cubestate[95:93] <= cubestate[86:84];
                        cubestate[86:84] <= cubestate[89:87];
                        cubestate[89:87] <= cubestate[92:90];
                        cubestate[92:90] <= cubestate[95:93];
                    end
                    Li: begin
                        // corners not on L face
                        cubestate[50:48] <= cubestate[2:0];
                        cubestate[62:60] <= cubestate[50:48];
                        cubestate[26:24] <= cubestate[62:60];
                        cubestate[2:0] <= cubestate[26:24];
                        cubestate[53:51] <= cubestate[5:3];
                        cubestate[65:63] <= cubestate[53:51];
                        cubestate[29:27] <= cubestate[65:63];
                        cubestate[5:3] <= cubestate[29:27];
                        // edges not on L face
                        cubestate[77:75] <= cubestate[104:102];
                        cubestate[122:120] <= cubestate[77:75];
                        cubestate[137:135] <= cubestate[122:120];
                        cubestate[104:102] <= cubestate[137:135];
                        // L face
                        cubestate[14:12] <= cubestate[23:21];
                        cubestate[17:15] <= cubestate[14:12];
                        cubestate[20:18] <= cubestate[17:15];
                        cubestate[23:21] <= cubestate[20:18];
                        cubestate[86:84] <= cubestate[95:93];
                        cubestate[89:87] <= cubestate[86:84];
                        cubestate[92:90] <= cubestate[89:87];
                        cubestate[95:93] <= cubestate[92:90];
                    end
                    B: begin
                        // corners not on B face
                        cubestate[2:0] <= cubestate[38:36];
                        cubestate[38:36] <= cubestate[68:66];
                        cubestate[68:66] <= cubestate[14:12];
                        cubestate[14:12] <= cubestate[2:0];
                        cubestate[11:9] <= cubestate[47:45];
                        cubestate[47:45] <= cubestate[65:63];
                        cubestate[65:63] <= cubestate[23:21];
                        cubestate[23:21] <= cubestate[11:9];
                        // edges not on B face
                        cubestate[74:72] <= cubestate[119:117];
                        cubestate[119:117] <= cubestate[134:132];
                        cubestate[134:132] <= cubestate[95:93];
                        cubestate[95:93] <= cubestate[74:72];
                        // B face
                        cubestate[56:54] <= cubestate[59:57];
                        cubestate[59:57] <= cubestate[50:48];
                        cubestate[50:48] <= cubestate[53:51];
                        cubestate[53:51] <= cubestate[56:54];
                        cubestate[128:126] <= cubestate[125:123];
                        cubestate[125:123] <= cubestate[122:120];
                        cubestate[122:120] <= cubestate[131:129];
                        cubestate[131:129] <= cubestate[122:120];
                    end
                    Bi: begin
                        // corners not on B face
                        cubestate[38:36] <= cubestate[2:0];
                        cubestate[68:66] <= cubestate[38:36];
                        cubestate[14:12] <= cubestate[68:66];
                        cubestate[2:0] <= cubestate[14:12];
                        cubestate[47:45] <= cubestate[11:9];
                        cubestate[65:63] <= cubestate[47:45];
                        cubestate[23:21] <= cubestate[65:63];
                        cubestate[11:9] <= cubestate[23:21];
                        // edges not on B face
                        cubestate[119:117] <= cubestate[74:72];
                        cubestate[134:132] <= cubestate[119:117];
                        cubestate[95:93] <= cubestate[134:132];
                        cubestate[74:72] <= cubestate[95:93];
                        // B face
                        cubestate[59:57] <= cubestate[56:54];
                        cubestate[50:48] <= cubestate[59:57];
                        cubestate[53:51] <= cubestate[50:48];
                        cubestate[56:54] <= cubestate[53:51];
                        cubestate[125:123] <= cubestate[128:126];
                        cubestate[122:120] <= cubestate[125:123];
                        cubestate[131:129] <= cubestate[122:120];
                        cubestate[122:120] <= cubestate[131:129];
                    end
                    D: begin
                        // corners not on D face
                        cubestate[29:27] <= cubestate[14:12];
                        cubestate[14:12] <= cubestate[59:57];
                        cubestate[59:57] <= cubestate[44:42];
                        cubestate[44:42] <= cubestate[29:27];
                        cubestate[32:30] <= cubestate[17:15];
                        cubestate[17:15] <= cubestate[50:48];
                        cubestate[50:48] <= cubestate[47:45];
                        cubestate[47:45] <= cubestate[32:30];
                        // edges not on D face
                        cubestate[101:99] <= cubestate[86:84];
                        cubestate[86:84] <= cubestate[125:123];
                        cubestate[125:123] <= cubestate[116:114];
                        cubestate[116:114] <= cubestate[101:99];
                        // D face
                        cubestate[62:60] <= cubestate[65:63];
                        cubestate[65:63] <= cubestate[68:66];
                        cubestate[68:66] <= cubestate[71:69];
                        cubestate[71:69] <= cubestate[62:60];
                        cubestate[140:138] <= cubestate[137:135];
                        cubestate[137:135] <= cubestate[134:132];
                        cubestate[134:132] <= cubestate[143:141];
                        cubestate[143:141] <= cubestate[140:138];
                    end
                    Di: begin
                        // corners not on D face
                        cubestate[14:12] <= cubestate[29:27];
                        cubestate[59:57] <= cubestate[14:12];
                        cubestate[44:42] <= cubestate[59:57];
                        cubestate[29:27] <= cubestate[44:42];
                        cubestate[17:15] <= cubestate[32:30];
                        cubestate[50:48] <= cubestate[17:15];
                        cubestate[47:45] <= cubestate[50:48];
                        cubestate[32:30] <= cubestate[47:45];
                        // edges not on D face
                        cubestate[101:99] <= cubestate[86:84];
                        cubestate[86:84] <= cubestate[125:123];
                        cubestate[125:123] <= cubestate[116:114];
                        cubestate[116:114] <= cubestate[101:99];
                        // D face
                        cubestate[65:63] <= cubestate[62:60];
                        cubestate[68:66] <= cubestate[65:63];
                        cubestate[71:69] <= cubestate[68:66];
                        cubestate[62:60] <= cubestate[71:69];
                        cubestate[137:135] <= cubestate[140:138];
                        cubestate[134:132] <= cubestate[137:135];
                        cubestate[143:141] <= cubestate[134:132];
                        cubestate[140:138] <= cubestate[143:141];
                    end
                endcase
                counter <= counter + 1;
                moves <= moves << 4;
                next_move <= moves[195:192];
                // if we've just done our 50th move (counter == 49) then go to DONE
                state <= (counter < 49) ? MOVING : DONE;
            end
            DONE: begin
                state_updated <= 1;
                cubestate_updated <= cubestate;
                state <= IDLE;
            end
            IDLE: begin
                counter <= 0; // always be ready...
                state_updated <= 0;
                if (new_moves_ready) begin
                    cubestate <= cubestate_input;
                    moves <= moves_input;
                    next_move <= moves_input[199:196];
                    state <= MOVING;
                end
            end
            default : state <= IDLE;
        endcase
    end

endmodule