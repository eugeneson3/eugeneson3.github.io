module instruction_rom (
    input  logic [5:0]  instr_addr,
    output logic [31:0] instr_code
);
    logic [31:0] instr_rom [0:15];
    integer i;

    initial begin
        for (i = 0; i < 16; i = i + 1) instr_rom[i] = 32'h00000013; // nop

        // [0] ADDI x1, x0, 10      -> x1 = 10
        instr_rom[0] = 32'h00a00093;

        // [1] ADDI x2, x0, 20      -> x2 = 20
        instr_rom[1] = 32'h01400113;

        // [2] ADD  x3, x1, x2      -> x3 = 10 + 20 = 30 (R-type 테스트)
        instr_rom[2] = 32'h002081b3;

        // [3] SW   x3, 4(x0)       -> RAM 1번방(주소 4)에 30 저장 (S-type 테스트)
        instr_rom[3] = 32'h00302223;

        // [4] LW   x4, 4(x0)       -> RAM 1번방(주소 4)에서 읽어 x4에 30 저장 (IL-type 테스트)
        instr_rom[4] = 32'h00402203;

        // [5] ADDI x8, x7, 2       -> x8 = 7 + 2 = 9 (기존 시뮬레이션 테스트)
        instr_rom[5] = 32'h00238413;
    end

    assign instr_code = instr_rom[instr_addr[5:2]];
endmodule
