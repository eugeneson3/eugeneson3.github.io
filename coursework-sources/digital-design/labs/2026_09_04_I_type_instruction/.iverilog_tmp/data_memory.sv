module data_memory (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [ 4:0] daddr,
    input  logic [31:0] dwdata,
    input  logic        dwe,
    input  logic [ 2:0] itype,
    output logic [31:0] drdata
);
    logic [31:0] ram[0:31];
    integer i;

    // 동기식 쓰기 (Clock posedge) 및 rst_n 비동기 리셋 처리
    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) ram[i] <= 32'd0;
        end else if (dwe) begin
            ram[daddr] <= dwdata;
        end
    end

    // 비동기식(조합논리) 읽기 - 단일 사이클 CPU 필수!
    assign drdata = ram[daddr];

endmodule
