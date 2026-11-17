`timescale 1ns / 1ps

module uart_decoder (
    input        clk,
    input        reset,
    input        i_done,
    input  [7:0] i_command,
    output [7:0] o_decoded
);

    parameter STOP = 1, RUN = 2, CLEAR = 3, MODE = 4;
    parameter HUP = 5, MUP = 6, SUP = 7, EDIT = 8;

    reg [7:0] decoded;
    assign o_decoded = decoded;

    always @(*) begin
        decoded = 8'b0;
    if (i_done) begin
        case (i_command)
            8'h72:   decoded = RUN;  // r
            8'h73:   decoded = STOP; // s
            8'h63:   decoded = CLEAR;// c
            8'h6d:   decoded = MODE; // m
            8'h48:   decoded = HUP;  // H
            8'h4d:   decoded = MUP;  // M
            8'h53:   decoded = SUP;  // S
            8'h45:   decoded = EDIT; // E
        endcase
    end
    end
endmodule

