`timescale 1ns / 1ps

module data_path (
    input         clk,
    input         reset,
    output [13:0] counter
);
    wire w_tick;
counter_10000 U_COUNTER_10000(
    .clk(clk),
    .reset(reset),
    .i_tick(w_tick),
    .counter(counter)
);

tick_gen U_TICK_GEN (
    .clk(clk),
    .reset(reset),
    .tick(w_tick)
);
endmodule

module counter_10000 (
    input clk,
    input reset,
    input i_tick,
    output [13:0] counter
);
    reg [$clog2(10_000)-1 : 0] tick_counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            tick_counter_reg <= 0;
        end else begin
            if (i_tick) tick_counter_reg <= tick_counter_reg + 1;
        end
        if (tick_counter_reg == 10_000 - 1) tick_counter_reg <= 0;
    end
endmodule

module tick_gen (
    input  clk,
    input  reset,
    output tick
);
    reg [$clog2(1_000_000) - 1:0] counter_reg;
    reg tick_reg;
    assign tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            tick_reg <= 0;
        end else begin
            counter_reg = counter_reg + 1;
            if (counter_reg == 1_000_000 - 1) begin
                counter_reg <= 0;
                tick_reg <= 1'b1;
            end else begin
                tick_reg <= 1'b0;
            end
        end
    end
endmodule
