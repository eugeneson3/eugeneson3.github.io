`define SIMULATION

module datapath (
    input  logic        clk,
    rst_n,
    input  logic        rf_we,
    input  logic [ 3:0] alu_control,
    input  logic [31:0] instr_code,
    input  logic        alusrc_sel,
    output logic [31:0] daddr,
    output logic [31:0] dwdata,
    output logic [31:0] instr_addr
);
    logic [31:0] alu_result, rf_rd1, rf_rd2;
    logic [31:0] pc_next;
    logic [31:0] imm_extend;
    logic [31:0] alusrc_muxout;
    assign daddr  = alu_result;
    assign dwdata = rf_rd2;

    reg_file U_REG_FILE (
        .clk(clk),
        .rst_n(rst_n),
        .ra1(instr_code[19:15]),
        .ra2(instr_code[24:20]),
        .wa(instr_code[11:7]),
        .wd(alu_result),
        .we(rf_we),
        .rd1(rf_rd1),
        .rd2(rf_rd2)
    );
    imm_extned U_IMM_EXTNED (
        .instr_code(instr_code),
        .imm_extend(imm_extend)
    );
    alu U_ALU (
        .rs1(rf_rd1),
        .rs2(rf_rd2),
        .alu_control(alu_control),
        .alu_result(alu_result)
    );
    mux_2x1 U_MUX_2X1 (
        .in0(rf_rd2),
        .in1(imm_extend),
        .sel(alusrc_sel),
        .out(alusrc_muxout)
    );

    program_counter U_PC (
        .clk(clk),
        .rst_n(rst_n),
        .pc(pc_next)
    );
    assign instr_addr = pc_next[5:0];
endmodule

module reg_file (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [ 4:0] ra1,
    ra2,
    wa,
    input  logic [31:0] wd,
    input  logic        we,
    output logic [31:0] rd1,
    rd2
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
    input  logic [31:0] rs1,
    input  logic [31:0] rs2,
    input  logic [ 3:0] alu_control,
    output logic [31:0] alu_result
);
    always_comb begin
        case (alu_control)
            // func7[5], func3
            4'b0_000: alu_result = rs1 + rs2;
            4'b1_000: alu_result = rs1 - rs2;
            4'b0_100: alu_result = rs1 ^ rs2;
            4'b0_110: alu_result = rs1 | rs2;
            4'b0_111: alu_result = rs1 & rs2;
            4'b0_001: alu_result = rs1 << rs2;
            4'b0_101: alu_result = rs1 >> rs2;
            4'b1_101: alu_result = $signed(rs1) >>> rs2;
            4'b0_010: alu_result = $signed(rs1) < $signed(rs2);
            4'b0_011: alu_result = rs1 < rs2;  // sltu

            default: alu_result = 32'd0;
        endcase
    end
endmodule

// imm extender, no flipflop
module imm_extned (
    input  logic [31:0] instr_code,
    output logic [31:0] imm_extend
);
    always_comb begin
        case (instr_code[6:0])
            7'b010_0011:
            imm_extend = {
                {20{instr_code[31]}}, instr_code[31:25], instr_code[11:7]
            };
        endcase
    end

endmodule

module program_counter (
    input logic clk,
    rst_n,
    output logic [31:0] pc
);
    always_ff @(posedge clk) begin
        if (!rst_n) pc <= 32'd0;
        else pc <= pc + 32'd4;
    end
endmodule

module mux_2x1 (
    input  logic [31:0] in0,
    input  logic [31:0] in1,
    input  logic        sel,
    output logic [31:0] out
);
    always_comb begin
        case (sel)
            1'b0: out = in0;
            1'b1: out = in1;
            default: out = 32'd0;
        endcase
    end
endmodule
