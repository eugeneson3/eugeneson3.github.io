module data_memory (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [ 6:0] daddr,
    input  logic [31:0] dwdata,
    input  logic        dwe,
    input  logic [ 2:0] itype,
    output logic [31:0] drdata
);
    logic [31:0] ram[0:31];
    integer i;

    wire [4:0] word_idx    = daddr[6:2]; // 상위 5비트: 32개 워드 방 번호 (0 ~ 31)
    wire [1:0] byte_offset = daddr[1:0]; // 하위 2비트: 워드 내 바이트 위치 (0 ~ 3)

    // 동기식 쓰기 (Clock posedge) 및 rst_n 비동기 리셋 처리
    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) ram[i] <= 32'd0;
        end else if (dwe) begin
            case (itype)
                // 1. sb (Store Byte, itype == 3'b000)
                3'b000: begin
                    case (byte_offset)
                        2'b00: ram[word_idx][ 7: 0] <= dwdata[7:0];
                        2'b01: ram[word_idx][15: 8] <= dwdata[7:0];
                        2'b10: ram[word_idx][23:16] <= dwdata[7:0];
                        2'b11: ram[word_idx][31:24] <= dwdata[7:0];
                    endcase
                end

                // 2. sh (Store Halfword, itype == 3'b001)
                3'b001: begin
                    case (byte_offset[1])
                        1'b0: ram[word_idx][15: 0] <= dwdata[15:0];
                        1'b1: ram[word_idx][31:16] <= dwdata[15:0];
                    endcase
                end

                // 3. sw (Store Word, itype == 3'b010)
                3'b010: begin
                    ram[word_idx] <= dwdata;
                end

                default: begin
                    ram[word_idx] <= dwdata;
                end
            endcase
        end
    end

    // 비동기식(조합논리) 읽기 - 단일 사이클 CPU 필수!
    assign drdata = ram[word_idx];

endmodule
