module tb_rv32i_cpu;
    logic clk = 1'b0, rst_n = 1'b0;
    always #5 clk = ~clk;
    rv32i_top dut(.*);
    initial begin
        $fsdbDumpfile("./build/wave.fsdb");
        $fsdbDumpvars(0, tb_rv32i_cpu);
        $fsdbDumpMDA(0, tb_rv32i_cpu);
    end
    initial begin
        rst_n = 1'b0;
        @(negedge clk);
        rst_n = 1'b1;
        #200;
        $finish;
    end

endmodule
