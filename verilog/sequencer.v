`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jacob Swiezy
// 
// Create Date: 12/01/2017 02:42:22 PM
// Design Name: 
// Module Name: sequencer
// Project Name: rbot
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sequencer
    (input clock,
    input reset,
    input seq_complete,
    input new_moves,
    input [199:0] seq,
    output reg seq_done,
    output reg [3:0] next_move,
    output reg start_move,
    output reg [7:0] num_moves = 0,
    output reg [7:0] curr_step = 0,
    output reg finished_queue,
    input move_done
    );
    
    localparam IDLE = 3'd0;
    localparam ADD_TO_QUEUE = 3'd1;
    localparam LOAD_MOVE = 3'd2;
    localparam WAIT_FOR_MOVE_1 = 3'd3;
    localparam WAIT_FOR_MOVE_2 = 3'd4;
    localparam SEQ_FINISHED = 3'd5;
    localparam FINISHED_DATA_QUEUE = 3'd6;
    
    reg [2:0] state = IDLE;
    reg [199:0] part_seq;
    reg [3:0] moves [199:0];
    
    always @(posedge clock)begin
        if(reset)begin
            state <= IDLE;
            curr_step <= 0;
            num_moves <= 0;
            start_move <= 0;
        end else begin
            case(state)
                IDLE: begin
                    finished_queue <= 0;
                    seq_done <= 0;
                    if(new_moves) begin
                        part_seq[199:0] <= seq[199:0];
                        state <= ADD_TO_QUEUE;
                    end else if(seq_complete & |(num_moves)) begin
                        state <= LOAD_MOVE;
                    end else if(seq_complete) begin //if no moves loaded just go to SEQ_FINISHED
                        state <= SEQ_FINISHED;
                    end
                end
                ADD_TO_QUEUE: begin
                    moves[num_moves] <= part_seq[199:196];
                    num_moves <= (|part_seq[199:196]) ? num_moves + 1 : num_moves;
                    part_seq <= part_seq << 4;
                    state <= (|(part_seq[195:0])) ? ADD_TO_QUEUE : FINISHED_DATA_QUEUE;
                end
                FINISHED_DATA_QUEUE: begin
                    finished_queue <= 1;
                    state <= IDLE;
                end
                LOAD_MOVE: begin
                    next_move <= moves[curr_step];
                    curr_step <= curr_step + 1;
                    start_move <= 1;
                    state <= WAIT_FOR_MOVE_1;
                end
                WAIT_FOR_MOVE_1: begin
                    start_move <= 0;
                    state <= WAIT_FOR_MOVE_2;
                end
                WAIT_FOR_MOVE_2: begin
                    if(move_done) begin
                        state <= (curr_step < num_moves) ? LOAD_MOVE : SEQ_FINISHED;
                    end
                end
                SEQ_FINISHED: begin
                    seq_done <= 1;
                    curr_step <= 0;
                    num_moves <= 0;
                    next_move <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end
    
endmodule
