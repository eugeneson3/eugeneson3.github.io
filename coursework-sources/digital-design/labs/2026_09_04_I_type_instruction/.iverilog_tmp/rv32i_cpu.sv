module rv32i_top (
    input logic clk,
    input logic rst_n
);
    logic [31:0] instr_code;
    logic [ 5:0] instr_addr;
    logic [31:0] daddr;
    logic [31:0] dwdata;
    logic [31:0] drdata;
    logic        dwe;
    logic [ 2:0] itype;

    // 1. 명령어 메모리 (ROM)
    instruction_rom U_INSTR_ROM (
        .instr_addr(instr_addr),
        .instr_code(instr_code)
    );

    // 2. CPU 코어
    rv32i_cpu U_RV32I_CPU (
        .clk       (clk),
        .rst_n     (rst_n),
        .instr_code(instr_code),
        .drdata    (drdata),
        .instr_addr(instr_addr),
        .daddr     (daddr),
        .dwdata    (dwdata),
        .dwe       (dwe),
        .itype     (itype)
    );

    // 3. 데이터 메모리 (RAM)
    data_memory U_DATA_MEMORY (
        .clk   (clk),
        .rst_n (rst_n),
        .daddr (daddr[6:2]), // 바이트 주소 -> 워드 인덱스 (32개 방)
        .dwdata(dwdata),
        .dwe   (dwe),
        .itype (itype),
        .drdata(drdata)
    );

endmodule

module rv32i_cpu (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] instr_code,
    input  logic [31:0] drdata,
    output logic [ 5:0] instr_addr,
    output logic [31:0] daddr,
    output logic [31:0] dwdata,
    output logic        dwe,
    output logic [ 2:0] itype
);
    logic       rf_we;
    logic       alusrc_sel;
    logic       rf_srcsel;
    logic [3:0] alu_control;

    control_unit U_CONTROL_UNIT (.*);
    datapath     U_DATAPATH     (.*);

endmodule
