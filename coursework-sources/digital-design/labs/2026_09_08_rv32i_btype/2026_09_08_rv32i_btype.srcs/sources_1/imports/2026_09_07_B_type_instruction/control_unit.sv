import rv32_pkg::*;

module control_unit (
    input  logic [31:0] instr_code,
    output logic        rf_we,
    output logic        alusrc_sel,
    output logic [ 2:0] rf_srcsel,
    output logic [ 3:0] alu_control,
    output logic        dwe,
    output logic        branch,
    output logic [ 2:0] itype
);
    logic [2:0] funct3;

    opcode_e opcode;
    assign opcode = opcode_e'(instr_code[6:0]);

    assign funct3 = instr_code[14:12];

    always_comb begin
        rf_we       = 1'b0;
        alusrc_sel  = 1'b0;
        rf_srcsel   = 3'b000;   // 0: alu_result, 1: drdata, 2: lui, 3: auipc
        alu_control = 4'b0_000; // {funct7[5], funct3}
        dwe         = 1'b0;
        itype       = 3'b010;   // SW, LW
        branch      = 1'b0;

        case (opcode)
            //funct7   rs2    rs1   funct3    rd     opcode 
            OP_RTYPE: begin // R-type
                rf_we       = 1'b1;
                alu_control = {instr_code[30], funct3};
            end
            // imm[11:5] rs2 rs1 imm[4:0] opcode
            OP_STYPE: begin // S-type (sw)
                alusrc_sel  = 1'b1; // imm_ext (offset)
                dwe         = 1'b1; // write to memory
                itype       = funct3; // SW, LW
            end
            // imm[11:0] rs1 funct3 rd opcode
            OP_ITYPE: begin // I-type (addi, etc.)
                rf_we       = 1'b1;
                alusrc_sel  = 1'b1; // imm_ext
                if (funct3 == 3'b101)
                    alu_control = {instr_code[30], funct3};
                else
                    alu_control = {1'b0, funct3};
            end
            // imm[11:0] rs1 funct3 rd opcode
            OP_ILTYPE: begin  // IL-type (lw)
                rf_we       = 1'b1;  // write to register rd
                alusrc_sel  = 1'b1;  // imm_ext (offset)
                rf_srcsel   = 3'b001; // 1: drdata from memory!
            end
            //  imm[12] imm[10:5] rs2 rs1 funct3 imm[4:1] imm[11] opcode 
            OP_BTYPE: begin 
                alusrc_sel = 1'b1;
                branch     = 1'b1;
            end
            
            OP_LUI: begin
                rf_we       = 1'b1;
                rf_srcsel   = 3'b010; // 2: Load U Imm LUI (imm_ext)
            end            
            OP_AUIPC: begin 
                rf_we       = 1'b1;
                rf_srcsel   = 3'b011; // 3: AUIPC (PC + imm_ext)
            end
            OP_JAL,OP_JALR: begin 
                rf_we       = 1'b1;
                rf_srcsel   = 3'b100; // 4: JAL / JALR (PC + 4)
            end
            default: ;
        endcase
    end

endmodule
