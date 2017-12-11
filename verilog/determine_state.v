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
                        output reg send_setup_moves, reg [5:0] counter=0, reg[161:0] cubestate_output, reg cubestate_determined);

    // the values used to represent colors in state register
    // colors are 3 bit numbers, explaining why state is 54*3 bit register
    parameter W = 3'd0;
    parameter O = 3'd1;
    parameter G = 3'd2;
    parameter Red = 3'd3;
    parameter Blue = 3'd4;
    parameter Y = 3'd5;

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
    parameter PREP = 3'd0;
    parameter IDLE = 3'd1;
    parameter OBSERVE = 3'd2;
    parameter DONE1 = 3'd3;
    parameter SETUP = 3'd4;
    parameter DONE2 = 3'd5;

    reg [2:0] state = SETUP;

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
                end
                PREP: begin
                    // we need to tell the spin_all module to send the appropriate moves
                    // to the motors. Then we go to IDLE
                    send_setup_moves <= 1;
                    // VERY NOT SURE ABOUT THIS FOLLOWING LINE - NEED TO FIGURE OUT WHAT VALUE OF COUNTER MATTERS...
                    state <= (counter < 47) ? IDLE : DONE1; // still need to do the moves associated with 44 on counter in spin_all...
                    cubestate <= cubestate << 3;
                end
                IDLE: begin
                    // make sure we aren't telling spin_all module to keep sending moves
                    send_setup_moves <= 0;
                    // sit here waiting until done turning happens
                    if (color_sensor_stable) state <= OBSERVE;
                end
                OBSERVE: begin
                    // when we get here, we can observe the color under the appropriate sensor
                    cubestate <= cubestate | ((counter < 24) ? {159'h0, edge_color_sensor} : {159'h0, corner_color_sensor});
//                    cubestate <= cubestate | {159'h0, edge_color_sensor};
                    state <= PREP;
                    // increment counter
                    counter <= counter + 1;
                end
                DONE1: begin
                    // do the last moves
                    counter <= counter + 1;
                    send_setup_moves <= 1;
                    state <= DONE2;
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


