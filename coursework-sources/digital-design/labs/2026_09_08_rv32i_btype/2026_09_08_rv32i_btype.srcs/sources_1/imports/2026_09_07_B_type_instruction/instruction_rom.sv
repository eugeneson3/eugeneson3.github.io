module instruction_rom (
    input  logic [8:0]  instr_addr,
    output logic [31:0] instr_code
);
    logic [31:0] instr_rom [0:127];
    integer i;

`ifdef SIMULATION_TEST
    initial begin
        // R type instructions
        instr_rom[0] = 32'h01c6_11b3; // sll  x3, x12, x28 -> 0xc0000000
        instr_rom[1] = 32'h0011_d233; // srl  x4, x3,  x1  -> 0x60000000
        instr_rom[2] = 32'h4011_d2b3; // sra  x5, x3,  x1  -> 0xe0000000
        instr_rom[3] = 32'h0017_61b3; // or   x3, x14, x1  -> 15
        instr_rom[4] = 32'h0017_71b3; // and  x3, x14, x1  -> 0
        instr_rom[5] = 32'h00d6_01b3; // add  x3, x12, x13 -> 25
        instr_rom[6] = 32'h40d6_01b3; // sub  x3, x12, x13 -> -1 (0xffffffff)
        instr_rom[7] = 32'h0074_c1b3; // xor  x3, x9,  x7  -> 14
        instr_rom[8] = 32'h0083_a1b3; // slt  x3, x7,  x8  -> 1
        instr_rom[9] = 32'h0074_31b3; // sltu x3, x8,  x7  -> 0

        // x3에 32'h1234_5678 생성 (sb, sh, sw 테스트용)
        instr_rom[10] = 32'h1230_0193; // addi x3, x0, 12'h123 -> x3 = 0x0000_0123
        instr_rom[11] = 32'h00c1_9193; // slli x3, x3, 12      -> x3 = 0x0012_3000
        instr_rom[12] = 32'h4561_e193; // ori  x3, x3, 12'h456 -> x3 = 0x0012_3456
        instr_rom[13] = 32'h0081_9193; // slli x3, x3, 8       -> x3 = 0x1234_5600
        instr_rom[14] = 32'h0781_e193; // ori  x3, x3, 12'h078 -> x3 = 0x1234_5678

        // S type instructions  
        instr_rom[15] = 32'h0030_0623; // sb   x3, 12(x0)
        instr_rom[16] = 32'h0030_1823; // sh   x3, 16(x0)
        instr_rom[17] = 32'h0030_2ca3; // sw   x3, 25(x0)
        
        // B type instructions
        instr_rom[18] = 32'h0020_9463; // bne x1, x2, +8
        instr_rom[19] = 32'h0010_0093; // addi x1, x0, 1  
        instr_rom[20] = 32'h0020_0113; // addi x2, x0, 2 

        // lui instructions
        instr_rom[21] = 32'h1234_5537; // lui  x10, 0x12345
        instr_rom[22] = 32'h6785_0513; // addi x10, x10, 0x678

        // AUIPC instruction
        instr_rom[23] = 32'h0000_1597; // auipc x11, 1

        // JAL instruction
        instr_rom[24] = 32'h0080_00ef; // jal  x1, +8
        instr_rom[25] = 32'h0050_0293; // addi x5, x0, 5

        // JALR instruction
        instr_rom[26] = 32'h0740_0313; // addi x6, x0, 116
        instr_rom[27] = 32'h0003_03e7; // jalr x7, 0(x6)
        instr_rom[28] = 32'h0080_0413; // addi x8, x0, 8
        instr_rom[29] = 32'h0090_0493; // addi x9, x0, 9
    end
`else
    initial begin 
        // 16진수 hex 파일을 읽을 때는 $readmemh 사용
        $readmemh("./rtl/rom_code_2.mem", instr_rom);
    end
`endif

    // least 2 bits are always 0 for RV32I; like 0,4,8,...
    assign instr_code = instr_rom[instr_addr[8:2]]; 
    
endmodule
