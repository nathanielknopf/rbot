module determine_state(input start, edge_color_sensor, corner_color_sensor, done_turning, clock,
                        output reg send_setup_moves);

    // the values used to represent colors in state register
    // colors are 3 bit numbers, explaining why state is 54*3 bit register
    parameter W = 0;
    parameter O = 1;
    parameter G = 2;
    parameter R = 3;
    parameter B = 4;
    parameter Y = 5;

    // cubestate is a 54*3=162 bit register
    // cubestate[0:71] is reserved for corners
    // cubestate[72:143] is reserved for edges
    // cubestate[144:161] are the centers - hardcoded below
    // see sticker-state-indices.png in ../supportingdocs for layout
    reg [161:0] cubestate;
    cubestate[144:146] = W;
    cubestate[147:149] = O;
    cubestate[150:152] = G;
    cubestate[153:155] = R;
    cubestate[156:158] = B;
    cubestate[159:161] = Y;

    // states for the FSM
    // PREP: send setup moves to motor, go immediately to wait
    // IDLE: wait for the motors to finish - when they send done signal, go to observe
    // OBSERVE: store value under sensor in question in value in question
    parameter PREP = 0;
    parameter IDLE = 1;
    parameter OBSERVE = 2;

    reg [1:0] state = 0;

    // index in s to which we are going to write (write to s[index:index+2])
    reg [7:0] index = 0; // this increments by 3 for each sticker we observe

    always @(posedge clock) begin
        case (state)
            PREP: begin
                // we need to tell the spin_all module to send the appropriate moves
                // to the motors. Then we go to IDLE
                send_setup_moves <= 1;
                state <= IDLE;
            end
            IDLE: begin
                // make sure we aren't telling spin_all module to keep sending moves
                send_setup_moves <= 0;
                // sit here waiting until done turning happens
                if (done_turning) state <= OBSERVE;
            end
            OBSERVE: begin
                // when we get here, we can observe the color under the appropriate sensor
                cubestate[index:index+2] <= (index < 72) ? corner_color_sensor : edge_color_sensor;
                index <= index + 3;
                state <= PREP;
            end
        endcase
    end
    // :)
endmodule

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


