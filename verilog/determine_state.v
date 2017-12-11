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

module determine_state(input start, reset, [2:0] edge_color_sensor, [2:0] corner_color_sensor, color_sensor_stable, clock,
                        output reg send_setup_moves, reg [5:0] counter=0, reg[161:0] cubestate_output, reg cubestate_determined, reg [2:0] known_edge_color=3'd7);

    // the values used to represent colors in state register
    // colors are 3 bit numbers, explaining why state is 54*3 bit register
    parameter W = 3'd0;
    parameter O = 3'd1;
    parameter G = 3'd2;
    parameter Red = 3'd3;
    parameter Blue = 3'd4;
    parameter Y = 3'd5;
    parameter NULL = 3'd7;

    // cubestate is a 54*3=162 bit register
    // cubestate[71:0] is reserved for corners
    // cubestate[143:72] is reserved for edges
    // cubestate[161:144] are the centers - hardcoded below
    // see sticker-state-indices.png in ../supportingdocs for layout
    reg [161:0] cubestate = {144'd0, Y, Blue, Red, G, O, W};
    
    // states for the FSM
    // PREP: send setup moves to motor, go immediately to wait
    // IDLE: wait for the motors to finish - when they send done signal, go to observe
    // OBSERVE: store value under sensor in question in value in question
    parameter PREP = 4'd0;
    parameter IDLE = 4'd1;
    parameter OBSERVE = 4'd2;
    parameter DONE1 = 4'd3;
    parameter SETUP = 4'd4;
    parameter DONE2 = 4'd5;
    parameter OBSERVE1 = 4'd6;
    parameter OBSERVE2 = 4'd7;
    parameter PREP1 = 4'd8;
    parameter IDLE1 = 4'd9;
    
    reg [5:0] counter_mem = 0;
    reg [2:0] color_acc [3:0];
    wire [4:0] corner_num;
    wire [7:0] ind;
    
    assign corner_num = counter - 24;
    
    lookup lt(.clock(clock), .corner_num(corner_num), .ind(ind));

    reg [3:0] state = SETUP;

    always @(posedge clock) begin
        if (reset) begin
            state <= SETUP;
            counter <= 0;
            cubestate_determined <= 0;
        end else begin
            case (state)
                SETUP: begin
                    // these should be true anyway, just making sure
                    counter <= 0;
                    // this is to make sure this shit ain't fucked
                    cubestate_determined <= 0;
                    // only start when we get the start signal...
                    cubestate <= {144'd0, Y, Blue, Red, G, O, W};
                    state <= (start) ? PREP : SETUP;
                    known_edge_color <= NULL;
                end
                PREP: begin
                    // we need to tell the spin_all module to send the appropriate moves
                    // to the motors. Then we go to IDLE
                    send_setup_moves <= 1;
                    // VERY NOT SURE ABOUT THIS FOLLOWING LINE - NEED TO FIGURE OUT WHAT VALUE OF COUNTER MATTERS...
                    state <= (counter < 47) ? IDLE : DONE1; // still need to do the moves associated with 44 on counter in spin_all...
                    cubestate <= cubestate << 3;
                    
                    case (counter)
                        // subtract 75 + 3 times the index here
                        24: known_edge_color <= cubestate[38:36]; // DFR - cubestate[71:69] (actually want 107:105)
                        25: known_edge_color <= cubestate[77:75];// DBR - cubestate[68:66] (actually want 143:141)
                        26: known_edge_color <= cubestate[38:36]; // DBL - cubestate[65:63] (actually want 101:99)
                        27: known_edge_color <= cubestate[77:75]; // DFL - cubestate[62:60] (actually want 137:135)
                        28: known_edge_color <= cubestate[50:48]; // BDL - cubestate[59:57] (actually want 107:105)
                        29: known_edge_color <= cubestate[74:72]; // BUR - cubestate[56:54] (actually want 128:126)
                        30: known_edge_color <= cubestate[50:48]; // BUL - cubestate[53:51] (actually want 101:99)
                        31: known_edge_color <= cubestate[74:72]; // BDL - cubestate[50:48] (actually want 122:120)
                        32: known_edge_color <= cubestate[53:51]; // RDB - cubestate[47:45] (actually want 98:96)
                        33: known_edge_color <= cubestate[74:72]; // RDF - cubestate[44:42] (actually want 116:114)
                        34: known_edge_color <= cubestate[65:63]; // RUF - cubestate[41:39] (actually want 104:102)
                        35: known_edge_color <= cubestate[74:72]; // RUB - cubestate[38:36] (actually want 110:108)
                        36: known_edge_color <= cubestate[74:72]; // FUR - cubestate[35:33] (actually want 107:105)
                        37: known_edge_color <= cubestate[68:66]; // FDR - cubestate[32:30] (actually want 98:96)
                        38: known_edge_color <= cubestate[74:72]; // FDL - cubestate[29:27] (actually want 101:99)
                        39: known_edge_color <= cubestate[80:78]; // FUL - cubestate[26:24] (actually want 104:102)
                        40: known_edge_color <= cubestate[83:81]; // LBU - cubestate[23:21] (actually want 104:102)
                        41: known_edge_color <= cubestate[74:72]; // LFU - cubestate[20:18] (actually want 92:90)
                        42: known_edge_color <= cubestate[83:81]; // LFD - cubestate[17:15] (actually want 98:96)
                        43: known_edge_color <= cubestate[74:72]; // LBD - cubestate[14:12] (actually want 86:84)
                        44: known_edge_color <= cubestate[98:96]; // UBR - cubestate[11:9] (actually want 107:105)
                        45: known_edge_color <= cubestate[77:75]; // UFR - cubestate[8:6] (actually want 83:81)
                        46: known_edge_color <= cubestate[98:96]; // UFL - cubestate[5:3] (actually want 101:99)
                        47: known_edge_color <= cubestate[77:75]; // UBL - cubestate[2:0] (actually want 77:75)
                        default : known_edge_color <= NULL;
                    endcase
                end
                IDLE: begin
                    // make sure we aren't telling spin_all module to keep sending moves
                    send_setup_moves <= 0;
                    // sit here waiting until done turning happens
                    if (color_sensor_stable) state <= OBSERVE;
                end
                OBSERVE: begin
                    if(counter < 24) begin
                        state <= PREP1;
                        counter_mem <= counter + 1;
                        counter <= 49;
                        color_acc[0] <= edge_color_sensor;
                    end else begin
                        state <= PREP;
                        counter <= counter + 1;
                        cubestate <= cubestate | {159'h0, corner_color_sensor};
                    end
                end
                PREP1: begin
                    // we need to tell the spin_all module to send the appropriate moves
                    // to the motors. Then we go to IDLE
                    send_setup_moves <= 1;
                    state <= IDLE1;
                end
                IDLE1: begin
                    // make sure we aren't telling spin_all module to keep sending moves
                    send_setup_moves <= 0;
                    // sit here waiting until done turning happens
                    if (color_sensor_stable) state <= OBSERVE1;
                end
                OBSERVE1: begin
                    // when we get here, we can observe the color under the appropriate sensor
                    color_acc[counter-48] <= edge_color_sensor;
                    if(counter == 51) begin
                        state <= OBSERVE2;
                        counter <= counter_mem;
                    end else begin
                        counter <= counter + 1;
                        state <= PREP1;
                    end
                end
                OBSERVE2: begin
                    if(color_acc[0] == color_acc[1] | color_acc[0] == color_acc[2] | color_acc[0] == color_acc[3]) cubestate <= cubestate | {159'h0, color_acc[0]};
                    else if(color_acc[1] == color_acc[2] | color_acc[1] == color_acc[3]) cubestate <= cubestate | {159'h0, color_acc[1]};
                    else if(color_acc[2] == color_acc[3]) cubestate <= cubestate | {159'h0, color_acc[2]};
                    else cubestate <= cubestate | {159'h0, color_acc[3]};
                    state <= PREP;
                end
                DONE1: begin
                    // do the last moves
                    counter <= counter + 1;
                    send_setup_moves <= 1;
                    state <= DONE2;
                    known_edge_color <= NULL;
                end
                DONE2: begin
                    send_setup_moves <= 0;
                    state <= DONE2;
                    cubestate_output <= cubestate;
                    cubestate_determined <= 1;
                    send_setup_moves <= 0; // only send them for one bit...? i forget what this signal does.
                end
            endcase
        end
    end
endmodule


