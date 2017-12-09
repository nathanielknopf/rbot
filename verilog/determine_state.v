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

module determine_state(input start, edge_color_sensor, corner_color_sensor, color_sensor_stable, clock,
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
    parameter PREP = 0;
    parameter IDLE = 1;
    parameter OBSERVE = 2;
    parameter DONE = 3;
    parameter SETUP = 4;

    reg [2:0] state = 0;

    // index in s to which we are going to write (write to s[index:index+2])
    reg [7:0] index = 0; // this increments by 3 for each sticker we observe

    always @(posedge clock) begin
        case (state)
            SETUP: begin
                // these should be true anyway, just making sure
                counter <= 0;
                index <= 0;
                // this is to make sure this shit ain't fucked
                cubestate_determined <= 0;
                state <= PREP;
            end
            PREP: begin
                // we need to tell the spin_all module to send the appropriate moves
                // to the motors. Then we go to IDLE
                send_setup_moves <= 1;
                // VERY NOT SURE ABOUT THIS FOLLOWING LINE - NEED TO FIGURE OUT WHAT VALUE OF COUNTER MATTERS...
                state <= (counter < 44) ? IDLE : DONE;
                cubestate <= cubestate << 3;
                index <= index + 3;
            end
            IDLE: begin
                // make sure we aren't telling spin_all module to keep sending moves
                send_setup_moves <= 0;
                // sit here waiting until done turning happens
                if (color_sensor_stable) state <= OBSERVE;
            end
            OBSERVE: begin
                // when we get here, we can observe the color under the appropriate sensor
                cubestate <= cubestate | (index < 72) ? corner_color_sensor : edge_color_sensor;
                state <= PREP;
                // increment counter
                counter <= counter + 1;
            end
            DONE: begin
                state <= DONE;
                cubestate_output <= cubestate;
                cubestate_determined <= 1;
            end
        endcase
    end
endmodule


