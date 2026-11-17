`timescale 1ns / 1ps

module top_watch (
    input        clk,
    input        reset,
    input        i_opt_pulse,
    input        i_h_up_pulse,
    input        i_m_up_pulse,
    input        i_s_up_pulse,
    input        sw,
    output [6:0] o_msec,
    output [5:0] o_sec,
    output [5:0] o_min,
    output [4:0] o_hour,
    output       o_edit_mode
);

    wire w_run_enable;
    wire w_o_h_up, w_o_m_up, w_o_s_up;

    assign o_edit_mode = ~w_run_enable;

    watch_control_unit U_WATCH_CTRL_UNIT (
        .clk         (clk),
        .reset       (reset),
        .i_h_up      (i_h_up_pulse),
        .i_m_up      (i_m_up_pulse),
        .i_s_up      (i_s_up_pulse),
        .opt         (i_opt_pulse),
        .o_run_enable(w_run_enable),
        .o_h_up      (w_o_h_up),
        .o_m_up      (w_o_m_up),
        .o_s_up      (w_o_s_up)
    );

    watch_datapath U_WATCH_DATAPATH (
        .clk       (clk),
        .reset     (reset),
        .sw        (sw),
        .h_up      (w_o_h_up),
        .m_up      (w_o_m_up),
        .s_up      (w_o_s_up),
        .run_enable(w_run_enable),
        .o_msec    (o_msec),
        .o_sec     (o_sec),
        .o_min     (o_min),
        .o_hour    (o_hour)
    );

endmodule

module watch_datapath #(
    parameter MSEC_WIDTH = 7,
              SEC_WIDTH  = 6,
              MIN_WIDTH  = 6,
              HOUR_WIDTH = 5
) (
    input                   clk,
    input                   reset,
    input                   sw,
    input                   h_up,
    input                   m_up,
    input                   s_up,
    input                   run_enable,
    output [MSEC_WIDTH-1:0] o_msec,
    output [ SEC_WIDTH-1:0] o_sec,
    output [ MIN_WIDTH-1:0] o_min,
    output [HOUR_WIDTH-1:0] o_hour
);

    wire w_tick_100Hz_watch;
    wire w_tick_sec_watch;
    wire w_tick_min_watch;
    wire w_tick_hour_watch;

    wire [HOUR_WIDTH-1:0] w_hour_24_to_12;

    wire w_tick_100Hz_gated;
    assign w_tick_100Hz_gated = w_tick_100Hz_watch & run_enable;

    change_24_to_12 U_CH_24_TO_12 (
        .i_change(w_hour_24_to_12),
        .sw      (sw),
        .o_change(o_hour)
    );

    watch_time_counter #(
        .BIT_WIDTH(HOUR_WIDTH),
        .TIMES(24),
        .INIT_VALUE(12)
    ) U_HOUR_CO (
        .clk       (clk),
        .reset     (reset),
        .i_tick    (w_tick_hour_watch),
        .i_up      (h_up),
        .time_count(w_hour_24_to_12),
        .o_tick    ()
    );

    watch_time_counter #(
        .BIT_WIDTH(MIN_WIDTH),
        .TIMES(60)
    ) U_MIN_CO (
        .clk       (clk),
        .reset     (reset),
        .i_tick    (w_tick_min_watch),
        .i_up      (m_up),
        .time_count(o_min),
        .o_tick    (w_tick_hour_watch)
    );

    watch_time_counter #(
        .BIT_WIDTH(SEC_WIDTH),
        .TIMES(60)
    ) U_SEC_CO (
        .clk       (clk),
        .reset     (reset),
        .i_tick    (w_tick_sec_watch),
        .i_up      (s_up),
        .time_count(o_sec),
        .o_tick    (w_tick_min_watch)
    );

    watch_time_counter #(
        .BIT_WIDTH(MSEC_WIDTH),
        .TIMES(100)
    ) U_MSEC_CO (
        .clk       (clk),
        .reset     (reset),
        .i_tick    (w_tick_100Hz_gated),
        .i_up      (1'b0),
        .time_count(o_msec),
        .o_tick    (w_tick_sec_watch)
    );

    watch_tick_gen_100Hz U_WT_TICK_GEN_100Hz (
        .clk   (clk),
        .reset (reset),
        .o_tick(w_tick_100Hz_watch)
    );

endmodule


module watch_tick_gen_100Hz (
    input      clk,
    input      reset,
    output reg o_tick
);

    parameter F_COUNT = 1_000_000;
    reg [$clog2(F_COUNT)-1:0] counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 1'b0;
            o_tick      <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == (F_COUNT - 1)) begin
                counter_reg <= 1'b0;
                o_tick <= 1'b1;
            end else begin
                o_tick <= 1'b0;
            end
        end
    end

endmodule


module watch_time_counter #(
    parameter BIT_WIDTH = 7,
    TIMES = 100,
    INIT_VALUE = 0
) (
    input                      clk,
    input                      reset,
    input                      i_tick,
    input                      i_up,
    output     [BIT_WIDTH-1:0] time_count,
    output reg                 o_tick
);

    reg [$clog2(TIMES)-1:0] counter_reg;

    assign time_count = counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= INIT_VALUE;
            o_tick      <= 1'b0;
        end else begin
            if (i_tick || i_up) begin
                if (counter_reg == (TIMES - 1)) begin
                    counter_reg <= 1'b0;
                    o_tick      <= (i_up) ? 1'b0 : 1'b1;
                end else begin
                    counter_reg <= counter_reg + 1;
                    o_tick <= 1'b0;
                end
            end else begin
                o_tick <= 1'b0;
            end
        end
    end

endmodule

module change_24_to_12 (
    input      [4:0] i_change,
    input            sw,
    output reg [4:0] o_change
);

    always @(*) begin
        if (sw) begin
            if (i_change == 0) begin
                o_change = 12;
            end else if (i_change > 12) begin
                o_change = i_change - 12;
            end else begin
                o_change = i_change;
            end
        end else begin
            o_change = i_change;
        end
    end

endmodule
