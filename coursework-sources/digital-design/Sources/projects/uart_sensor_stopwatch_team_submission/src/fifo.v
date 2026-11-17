`timescale 1ns / 1ps

// Synchronous byte FIFO with a combinational head-data output.
// WIDTH is the address width, so WIDTH=2 creates four 8-bit entries.
module fifo #(
    parameter WIDTH = 2
) (
    input        clk,
    input        reset,
    input        push,
    input        pop,
    input  [7:0] wdata,
    output [7:0] rdata,
    output       full,
    output       empty
);
    localparam DEPTH = (1 << WIDTH);

    reg [7:0] mem [0:DEPTH-1];
    reg [WIDTH-1:0] write_ptr;
    reg [WIDTH-1:0] read_ptr;
    reg [WIDTH:0]   count;

    wire push_accept;
    wire pop_accept;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);
    assign rdata = mem[read_ptr];

    assign push_accept = push && !full;
    assign pop_accept  = pop && !empty;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_ptr <= 0;
            read_ptr  <= 0;
            count     <= 0;
        end else begin
            case ({push_accept, pop_accept})
                2'b10: begin
                    mem[write_ptr] <= wdata;
                    write_ptr      <= write_ptr + 1'b1;
                    count          <= count + 1'b1;
                end

                2'b01: begin
                    read_ptr <= read_ptr + 1'b1;
                    count    <= count - 1'b1;
                end

                2'b11: begin
                    mem[write_ptr] <= wdata;
                    write_ptr      <= write_ptr + 1'b1;
                    read_ptr       <= read_ptr + 1'b1;
                end

                default: begin
                    write_ptr <= write_ptr;
                    read_ptr  <= read_ptr;
                    count     <= count;
                end
            endcase
        end
    end
endmodule
