`timescale 1ns / 1ps

module ascii_decoder (
    input [7:0] ascii_data,
    input rx_done,
    input reset,
    output reg [7:0] decoder_out
);
    always @(*) begin
        if (rx_done) begin
            case (ascii_data)
                8'h52:   decoder_out = 8'b1000_0000;
                8'h53:   decoder_out = 8'b0100_0000;
                8'h43:   decoder_out = 8'b0010_0000;
                8'h4d:   decoder_out = 8'b0001_0000;
                8'h6c:   decoder_out = 8'b0000_1000;
                8'h72:   decoder_out = 8'b0000_0100;
                8'h75:   decoder_out = 8'b0000_0010;
                8'h64:   decoder_out = 8'b0000_0001;
                default: decoder_out = 8'b0000_0000;
            endcase
        end else begin
            decoder_out = 8'b0000_0000;
        end
    end
endmodule
// ascii_data 
// r = 0x72 -> run
// s = 0x73 -> stop
// c = 0x63 -> clear
// m  = 0x6d  mode
// L = 0x4c -> go Left digit (stopwatch mode)
// R = 0x52 -> go Right digit (stopwatch mode)
// U = 0x55 -> time digit up (watch mode)
// D = 0x44 -> time digit down (watch mode)
// decoder_out =  {run, stop, clear, mode, L, R, U, D}
