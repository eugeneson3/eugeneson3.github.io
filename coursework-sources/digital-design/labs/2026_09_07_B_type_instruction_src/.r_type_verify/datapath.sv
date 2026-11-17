`define SIMULATION

import rv32_pkg::*;

module datapath (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        rf_we,
    input  logic        alusrc_sel,
    input  logic        rf_srcsel,
    input  logic [ 3:0] alu_control,
    input  logic [31:0] instr_code,
    input  logic [31:0] drdata,
    output logic [ 5:0] instr_addr,
    output logic [31:0] daddr,
    output logic [31:0] dwdata
);
    logic [31:0] alu_result, rf_rd1, rf_rd2;
    logic [31:0] imm_ext, alusrc_muxout, rf_wd;
    logic [31:0] pc;

    assign instr_addr = pc[5:0];
    assign daddr      = alu_result;   // 메모리 주소 (rs1 + offset)
    assign dwdata     = rf_rd2;       // 메모리에 쓸 데이터 (rs2)

    // 1. 레지스터 파일 (Register File)
    reg_file U_REG_FILE (
        .clk(clk),
        .rst_n(rst_n),
        .ra1(instr_code[19:15]),
        .ra2(instr_code[24:20]),
        .wa(instr_code[11:7]),
        .wd(rf_wd),
        .we(rf_we),
        .rd1(rf_rd1),
        .rd2(rf_rd2)
    );

    // 2. 즉시값 부호 확장기 (Immediate Extender)
    imm_ext U_IMM_EXT (
        .instr_code(instr_code),
        .imm_ext(imm_ext)
    );

    // 3. ALU B 입력 선택 MUX (0: rf_rd2, 1: imm_ext)
    mux_2x1 U_ALUSRC_MUX (
        .sel(alusrc_sel),
        .in0(rf_rd2),
        .in1(imm_ext),
        .mux_out(alusrc_muxout)
    );

    // 4. 연산기 (ALU)
    alu U_ALU (
        .a(rf_rd1),
        .b(alusrc_muxout),
        .alu_control(alu_control),
        .alu_result(alu_result)
    );

    // 5. 레지스터 파일 쓰기 데이터 선택 MUX (0: alu_result, 1: drdata)
    mux_2x1 U_WB_MUX (
        .sel(rf_srcsel),
        .in0(alu_result),
        .in1(drdata),
        .mux_out(rf_wd)
    );

    // 6. 프로그램 카운터 (PC)
    program_counter U_PC (
        .clk(clk),
        .rst_n(rst_n),
        .pc(pc)
    );

endmodule

module mux_2x1 (
    input  logic        sel,
    input  logic [31:0] in0,
    input  logic [31:0] in1,
    output logic [31:0] mux_out
);
    assign mux_out = sel ? in1 : in0;
endmodule

module imm_ext (
    input  logic [31:0] instr_code,
    output logic [31:0] imm_ext
);
    opcode_e opcode;
    assign opcode = opcode_e'(instr_code[6:0]);

    always_comb begin
        case (opcode)
            OP_STYPE:
                imm_ext = {{20{instr_code[31]}}, instr_code[31:25], instr_code[11:7]};
            OP_ITYPE, OP_ILTYPE:
                imm_ext = {{20{instr_code[31]}}, instr_code[31:20]};
            default:
                imm_ext = 32'd0;
        endcase
    end
endmodule

module reg_file (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [ 4:0] ra1,
    input  logic [ 4:0] ra2,
    input  logic [ 4:0] wa,
    input  logic [31:0] wd,
    input  logic        we,
    output logic [31:0] rd1,
    output logic [31:0] rd2
);
    logic [31:0] ram_file[1:31];
    integer i;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
`ifdef SIMULATION
            for (i = 1; i < 32; i = i + 1) ram_file[i] <= i;
`else
            for (i = 1; i < 32; i = i + 1) ram_file[i] <= 32'd0;
`endif
        end else if (we && (wa != 0)) begin
            ram_file[wa] <= wd;
        end
    end

    assign rd1 = (ra1 != 0) ? ram_file[ra1] : 32'd0;
    assign rd2 = (ra2 != 0) ? ram_file[ra2] : 32'd0;
endmodule

module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [ 3:0] alu_control,
    output logic [31:0] alu_result
);
    always_comb begin
        case (alu_control)
            4'b0_000: alu_result = a + b;
            4'b1_000: alu_result = a - b;
            4'b0_100: alu_result = a ^ b;
            4'b0_110: alu_result = a | b;
            4'b0_111: alu_result = a & b;
            4'b0_001: alu_result = a << b[4:0];
            4'b0_101: alu_result = a >> b[4:0];
            4'b1_101: alu_result = $signed(a) >>> b[4:0];
            4'b0_010: alu_result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            4'b0_011: alu_result = (a < b) ? 32'd1 : 32'd0;
            default:  alu_result = 32'd0;
        endcase
    end
endmodule

module program_counter (
    input  logic        clk,
    input  logic        rst_n,
    output logic [31:0] pc
);
    always_ff @(posedge clk) begin
        if (!rst_n) pc <= 32'd0;
        else        pc <= pc + 32'd4;
    end
endmodule
