`timescale 1ns / 1ps

module tb_detector_0101();
    reg clk;
    reg reset;
    reg tb_i_num;
    wire tb_o_num;
    parameter testcase = 32'b1010_1010_0010_1010_1011_0101_0101_0101;

    detector_0101 dut(
        .clk(clk),
        .reset(reset),
        .i_num(tb_i_num),
        .o_num(tb_o_num)
    );
    integer i;
    always #5 clk = ~clk;
    initial begin
        
        clk = 0;
        reset = 1;
        tb_i_num = 0;
        #10;

        reset = 0;

        for (i = 0; i < 32 ; i = i + 1) begin
            tb_i_num = testcase[i];
            #10;
        end
        #200;
        $finish;
    end
endmodule
