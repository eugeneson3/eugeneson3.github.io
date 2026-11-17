module memory(
    input logic clk,
    input logic [31:0] daddr,
    input logic [31:0] dwdata,
    input logic        dwe,
    input logic [2:0] itype,
    output logic [31:0] rdata
);
    logic [31:0] ram_file[0:127];
    always_ff @(posedge clk) begin
        if (dwe) begin
            case (itype)
                3'b010: ram_file[daddr[31:2]] <= dwdata;
                default: ram_file[daddr[31:2]] <= ram_file[daddr[31:2]];
            endcase
    end
end
assign rdata = ram_file[daddr[6:0]];   // ← read도 슬라이싱

endmodule