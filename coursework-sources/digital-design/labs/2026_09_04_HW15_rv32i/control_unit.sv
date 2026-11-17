module control_unit(
    input  logic [31:0] instr_code,
    output logic        rf_we,
    output logic        alusrc_sel,
    output logic [3:0]  alu_control,
    output logic        dwe,
    output logic [2:0] itype // instruction type
);
    logic [2:0] funct3;
    assign funct3 = instr_code[14:12];
    always_comb begin
        rf_we = 1'b0;
        alu_control = 4'b0;
        alusrc_sel = 1'b0;
        dwe = 1'b0;
        itype = 3'b010;
        case (instr_code[6:0])
            7'b011_0011: begin //r type
                rf_we = 1'b1;
                alusrc_sel = 1'b0;
                dwe = 0;
                alu_control = {instr_code[30], funct3};
                itype = 3'b000;
            end
            7'b010_0011: begin // s type
                rf_we = 1'b0;
                alusrc_sel = 1'b1;
                alu_control = 4'b0000;
                dwe = 1;
                itype = funct3;
            end
            
        endcase
    end
endmodule
