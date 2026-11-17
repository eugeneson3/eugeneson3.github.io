module tb_rv32i_cpu;
    logic clk = 1'b0, rst_n = 1'b0;
    integer errors = 0;
    always #5 clk = ~clk;
    rv32i_top dut(.*);
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_rv32i_cpu);
    end
    initial begin
        $display(" time   PC        instruction  x1  x2  x3  x4  x8  RAM[1]");
        rst_n = 1'b0;
        #50;
        rst_n = 1'b1;
        #250;
        if (dut.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.ram_file[1] !== 32'd10) errors = errors + 1;
        if (dut.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.ram_file[2] !== 32'd20) errors = errors + 1;
        if (dut.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.ram_file[3] !== 32'd30) errors = errors + 1;
        if (dut.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.ram_file[4] !== 32'd30) errors = errors + 1;
        if (dut.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.ram_file[8] !== 32'd9)  errors = errors + 1;
        if (dut.U_DATA_MEMORY.ram[1] !== 32'd30) errors = errors + 1;
        if (errors == 0)
            $display("PASS: x1=10 x2=20 x3=30 x4=30 x8=9 RAM[1]=30");
        else
            $display("FAIL: %0d checks failed", errors);
        $finish;
    
    end

    always @(negedge clk) begin
        if (rst_n && dut.U_RV32I_CPU.U_DATAPATH.U_PC.pc <= 32'd24)
            $display("%5t  %08h  %08h     %0d  %0d  %0d  %0d  %0d  %0d",
                $time,
                dut.U_RV32I_CPU.U_DATAPATH.U_PC.pc,
                dut.instr_code,
                dut.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.ram_file[1],
                dut.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.ram_file[2],
                dut.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.ram_file[3],
                dut.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.ram_file[4],
                dut.U_RV32I_CPU.U_DATAPATH.U_REG_FILE.ram_file[8],
                dut.U_DATA_MEMORY.ram[1]);
    end

endmodule
