`timescale 1ns / 1ps

module fifo #(
    parameter WIDTH = 4
) (
    input clk,
    input reset,
    input push,
    input pop,
    input [7:0] wdata,
    output [7:0] rdata,
    output full,
    output empty
);
    wire [WIDTH-1:0] w_wptr, w_rptr;


    register_file #(
        .WIDTH(WIDTH)
    ) U_REGISTER_FILE (
        .clk(clk),
        .waddr(w_wptr),
        .raddr(w_rptr),
        .wdata(wdata),
        .we((push) & (~full)),
        .rdata(rdata)
    );

    control_unit #(
        .WIDTH(WIDTH)
    ) U_CONTROL_UNIT (
        .clk  (clk),
        .reset(reset),
        .push (push),
        .pop  (pop),
        .wptr (w_wptr),
        .rptr (w_rptr),
        .full (full),
        .empty(empty)
    );

endmodule


module register_file #(
    parameter WIDTH = 4
) (
    input                 clk,
    input  [WIDTH -1 : 0] waddr,
    input  [WIDTH -1 : 0] raddr,
    input  [         7:0] wdata,
    input                 we,
    output [         7:0] rdata
);
    reg [7:0] register_file[0:(1<<WIDTH)-1];

    always @(posedge clk) begin
        if (we) register_file[waddr] <= wdata;
    end
    // rdata: CL output
    assign rdata = register_file[raddr];
endmodule

module control_unit #(
    parameter WIDTH = 4

) (
    input                 clk,
    input                 reset,
    input                 push,
    input                 pop,
    output [WIDTH -1 : 0] wptr,
    output [WIDTH -1 : 0] rptr,
    output                full,
    output                empty
);
    reg full_reg, empty_reg;
    reg full_next, empty_next;
    reg [WIDTH-1:0] wptr_next, rptr_next;
    reg [WIDTH-1:0] wptr_reg, rptr_reg;
    assign wptr  = wptr_reg;
    assign rptr  = rptr_reg;
    assign full  = full_reg;
    assign empty = empty_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            wptr_reg  <= 0;
            rptr_reg  <= 0;
            full_reg  <= 0;
            empty_reg <= 1;
        end else begin
            wptr_reg  <= wptr_next;
            rptr_reg  <= rptr_next;
            full_reg  <= full_next;
            empty_reg <= empty_next;
        end
    end
    // output logic
    always @(*) begin
        wptr_next  = wptr_reg;
        rptr_next  = rptr_reg;
        full_next  = full_reg;
        empty_next = empty_reg;
        empty_next = empty_reg;
        full_next  = full_reg;
        case ({
            push, pop
        })
            2'b00: begin
            end
            2'b01: begin
                if (!empty) begin
                    rptr_next = rptr_reg + 1;
                    full_next = 0;
                end
                if (rptr_next == wptr) empty_next = 1;
            end
            2'b10: begin
                if (!full) begin
                    wptr_next  = wptr_reg + 1;
                    empty_next = 0;
                end
                if (wptr_next == rptr_reg) full_next = 1;
            end
            2'b11: begin
                if (full) begin
                    rptr_next = rptr_reg + 1;
                    full_next = 1'b0;
                end else if (empty) begin
                    wptr_next  = wptr_reg + 1;
                    empty_next = 1'b0;
                end else begin
                    wptr_next = wptr_reg + 1;
                    rptr_next = rptr_reg + 1;
                end

            end
        endcase

    end


endmodule
