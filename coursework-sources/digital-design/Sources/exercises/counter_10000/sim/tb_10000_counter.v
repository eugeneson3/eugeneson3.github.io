`timescale 1ns / 1ps

module tb_10000_counter();
    reg clk;
    reg reset;
    wire tick;

    tick_gen dut(
    .clk(clk),
    .reset(reset),
    .tick(tick)
    );
    always #5 clk = ~clk;
    initial begin
        clk = 0;
        reset = 1;
        #10;

        reset = 0;
        #(1_000_000*10*2);
        $stop;
    end
endmodule
