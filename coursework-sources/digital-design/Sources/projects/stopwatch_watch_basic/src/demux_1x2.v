`timescale 1ns / 1ps
module demux_1x2 #(
    parameter BIT_NUM = 4
) (
    input [BIT_NUM -1 : 0] i_in,
    input i_sel,
    output reg [BIT_NUM-1:0] o_out0,
    output reg [BIT_NUM-1:0] o_out1
);
    // Combinational Logic
    always @(*) begin
        if (!i_sel) begin
            o_out0 = i_in;
            o_out1 = 0;
        end else begin
            o_out0 = 0;
            o_out1 = i_in;
        end
    end

endmodule
