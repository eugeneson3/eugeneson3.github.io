module instruction_rom (
    input  logic [5:0]  instr_addr,
    output logic [31:0] instr_code
);
    logic [31:0] instr_rom [0:63];
    integer i;

    initial begin
        for (i = 0; i < 64; i = i + 1)
            instr_rom[i] = 32'h0000_0013; //nop
        // R Type 10 instructions
        instr_rom[0] = 32'h01C6_11B3; // sll  x3, x12, x28
        instr_rom[1] = 32'h0011_D233; // srl  x4, x3,  x1
        instr_rom[2] = 32'h4011_D2B3; // sra  x5, x3,  x1
        instr_rom[3] = 32'h0017_61B3; // or   x3, x14, x1
        instr_rom[4] = 32'h0017_71B3; // and  x3, x14, x1
        instr_rom[5] = 32'h00D6_01B3; // add  x3, x12, x13
        instr_rom[6] = 32'h40D6_01B3; // sub  x3, x12, x13
        instr_rom[7] = 32'h0074_C1B3; // xor  x3, x9,  x7
        instr_rom[8] = 32'h0074_21B3; // slt  x3, x8,  x7
        instr_rom[9] = 32'h0083_B1B3; // sltu x3, x7,  x8
        // S Type 10 instructions
        instr_rom[10] = 32'h01C6_11B3; // SW
        instr_rom[11] = 32'h0011_D233; // SH
        instr_rom[12] = 32'h4011_D2B3; // SB
    end

    assign instr_code = instr_rom[instr_addr[5:2]];
endmodule
