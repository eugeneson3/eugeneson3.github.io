import rv32_pkg::*;

module control_unit (
    input  logic [31:0] instr_code,
    output logic        rf_we,
    output logic        alusrc_sel,
    output logic        rf_srcsel,
    output logic [ 3:0] alu_control,
    output logic        dwe,
    output logic [ 2:0] itype
);
    logic [2:0] funct3;

    opcode_e opcode;
    assign opcode = opcode_e'(instr_code[6:0]);

    assign funct3 = instr_code[14:12];

    always_comb begin
        rf_we       = 1'b0;
        alusrc_sel  = 1'b0;
        rf_srcsel   = 1'b0;     // 0: alu_result, 1: drdata
        alu_control = 4'b0_000; // {funct7[5], funct3}
        dwe         = 1'b0;
        itype       = 3'b010;   // SW, LW

        case (opcode)
            OP_RTYPE: begin // R-type
                rf_we       = 1'b1;
                alusrc_sel  = 1'b0;
                rf_srcsel   = 1'b0; // alu_result
                alu_control = {instr_code[30], funct3};
                dwe         = 1'b0;
                itype       = 3'b000; // SW, LW
            end

            OP_STYPE: begin // S-type (sw)
                rf_we       = 1'b0;
                alusrc_sel  = 1'b1; // imm_ext (offset)
                rf_srcsel   = 1'b0;
                alu_control = 4'b0_000; // ADD (rs1 + offset)
                dwe         = 1'b1; // write to memory
                itype       = funct3; // SW, LW
            end

            OP_ITYPE: begin // I-type (addi, etc.)
                rf_we       = 1'b1;
                alusrc_sel  = 1'b1; // imm_ext
                rf_srcsel   = 1'b0; // alu_result
                if (funct3 == 3'b101)
                    alu_control = {instr_code[30], funct3};
                else
                    alu_control = {1'b0, funct3};
                dwe         = 1'b0;
                itype       = 3'b111; // default
            end

            OP_ILTYPE: begin  // IL-type (lw)
                rf_we       = 1'b1; // write to register rd
                alusrc_sel  = 1'b1; // imm_ext (offset)
                rf_srcsel   = 1'b1; // drdata from memory!
                alu_control = 4'b0_000; // ADD (rs1 + offset)
                dwe         = 1'b0; // read from memory
                itype       = funct3; // SW, LW               
            end

            default: ;
        endcase
    end

endmodule
