package rv32_pkg;
    // 1. Opcode (명령어 6:0 비트)
    typedef enum logic [6:0] {
        OP_RTYPE  = 7'b011_0011, // R-type (add, sub, sll...)
        OP_STYPE  = 7'b010_0011, // S-type (sb, sh, sw)
        OP_ITYPE  = 7'b001_0011, // I-type 산술 (addi, slli...)
        OP_ILTYPE = 7'b000_0011, // I-type 로드 (lb, lh, lw...)
        OP_BTYPE  = 7'b110_0011, // B-type 분기 (beq, bne, blt...)
        OP_LUI    = 7'b011_0111,
        OP_AUIPC  = 7'b001_0111,
        OP_JAL    = 7'b110_1111,
        OP_JALR   = 7'b110_0111
    } opcode_e;

    // 2. R-type ALU 연산 제어 코드 ({funct7[5], funct3} -> 4비트)
    typedef enum logic [3:0] {
        ADD  = 4'b0000,
        SUB  = 4'b1000,
        SLL  = 4'b0001,
        SLT  = 4'b0010,
        SLTU = 4'b0011,
        XOR  = 4'b0100,
        SRL  = 4'b0101,
        SRA  = 4'b1101,
        OR   = 4'b0110,
        AND  = 4'b0111
    } instr_rtype_e;
    
    // 3. S-type 메모리 저장 크기 (funct3 -> 3비트)
    typedef enum logic [2:0] {
        SB = 3'b000, // Store Byte (1바이트)
        SH = 3'b001, // Store Halfword (2바이트)
        SW = 3'b010  // Store Word (4바이트)
    } instr_stype_e;
    
    // 4. I-type 산술/논리 즉시값 연산 (funct3 -> 3비트)
    typedef enum logic [2:0] {
        ADDI  = 3'b000,
        SLLI  = 3'b001,
        SLTI  = 3'b010,
        SLTIU = 3'b011,
        XORI  = 3'b100,
        SRLI  = 3'b101, // instr[30]==0 이면 SRLI, 1이면 SRAI
        ORI   = 3'b110,
        ANDI  = 3'b111
    } instr_itype_e;

    // 5. I-type 로드 크기 (funct3 -> 3비트)
    typedef enum logic [2:0] {
        LB  = 3'b000, // Load Byte
        LH  = 3'b001, // Load Halfword
        LW  = 3'b010, // Load Word
        LBU = 3'b100, // Load Byte Unsigned
        LHU = 3'b101  // Load Halfword Unsigned
    } instr_load_e;
    
    // 6. B-type 분기 조건 (funct3 -> 3비트)
    typedef enum logic [2:0] {
        BEQ  = 3'b000, // Branch Equal (==)
        BNE  = 3'b001, // Branch Not Equal (!=)
        BLT  = 3'b100, // Branch Less Than (<, signed)
        BGE  = 3'b101, // Branch Greater or Equal (>=, signed)
        BLTU = 3'b110, // Branch Less Than Unsigned (<, unsigned)
        BGEU = 3'b111  // Branch Greater or Equal Unsigned (>=, unsigned)
    } instr_btype_e;
    
endpackage
