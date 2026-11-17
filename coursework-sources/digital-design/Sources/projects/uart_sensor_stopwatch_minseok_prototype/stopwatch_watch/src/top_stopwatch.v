`timescale 1ns / 1ps

module top_stopwatch (
    input        clk,
    input        reset,
    input        i_run_stop_pulse,
    input        i_clear_pulse,
    input        i_mode_pulse,
    input        i_record_pulse,
    input        sw,
    output [6:0] o_msec,
    output [5:0] o_sec,
    output [5:0] o_min,
    output [4:0] o_hour,
    output       o_mode
);

    wire w_run_stop, w_clear, w_mode, w_record;

    assign o_mode = w_mode;

    stopwatch_control_unit U_CONTROL_UNIT (
        .clk       (clk),
        .reset     (reset),
        .i_run_stop(i_run_stop_pulse),
        .i_clear   (i_clear_pulse),
        .i_mode    (i_mode_pulse),
        .i_record  (i_record_pulse),
        .o_run_stop(w_run_stop),
        .o_clear   (w_clear),
        .o_mode    (w_mode),
        .o_record  (w_record)
    );

    stopwatch_datapath U_STOPWATCH_DATAPATH (
        .clk     (clk),
        .reset   (reset),
        .sw      (sw),
        .run_stop(w_run_stop),
        .clear   (w_clear),
        .mode    (w_mode),
        .record  (w_record),
        .MSEC    (o_msec),
        .SEC     (o_sec),
        .MIN     (o_min),
        .HOUR    (o_hour)
    );

endmodule

module stopwatch_datapath #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input                   clk,
    input                   reset,
    input                   sw,
    input                   run_stop,
    input                   clear,
    input                   mode,
    input                   record,
    output [MSEC_WIDTH-1:0] MSEC,
    output [ SEC_WIDTH-1:0] SEC,
    output [ MIN_WIDTH-1:0] MIN,
    output [HOUR_WIDTH-1:0] HOUR
);

    wire w_tick_100hz_sw, w_tick_sec_sw, w_tick_min_sw, w_tick_hour_sw;
    wire [6:0] w_run_msec, w_rec_msec;
    wire [5:0] w_run_sec, w_rec_sec;
    wire [5:0] w_run_min, w_rec_min;
    wire [5:0] w_run_hour, w_rec_hour;

    mux_8x4 U_MUX_8x4 (
        .sel      (sw),
        .in_a_msec(w_run_msec),
        .in_a_sec (w_run_sec),
        .in_a_min (w_run_min),
        .in_a_hour(w_run_hour),
        .in_b_msec(w_rec_msec),
        .in_b_sec (w_rec_sec),
        .in_b_min (w_rec_min),
        .in_b_hour(w_rec_hour),
        .out_msec (MSEC),
        .out_sec  (SEC),
        .out_min  (MIN),
        .out_hour (HOUR)
    );

    record_mem #(
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_RECORD_HOUR (
        .clk           (clk),
        .reset         (reset),
        .clear         (clear),
        .record        (record),
        .running_time  (w_run_hour),
        .recording_time(w_rec_hour)
    );

    record_mem #(
        .BIT_WIDTH(MIN_WIDTH)
    ) U_RECORD_MIN (
        .clk           (clk),
        .reset         (reset),
        .clear         (clear),
        .record        (record),
        .running_time  (w_run_min),
        .recording_time(w_rec_min)
    );

    record_mem #(
        .BIT_WIDTH(SEC_WIDTH)
    ) U_RECORD_SEC (
        .clk           (clk),
        .reset         (reset),
        .clear         (clear),
        .record        (record),
        .running_time  (w_run_sec),
        .recording_time(w_rec_sec)
    );

    record_mem #(
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_RECORD_MSEC (
        .clk           (clk),
        .reset         (reset),
        .clear         (clear),
        .record        (record),
        .running_time  (w_run_msec),
        .recording_time(w_rec_msec)
    );

    sw_time_counter #(
        .BIT_WIDTH(HOUR_WIDTH),
        .TIMES(24)
    ) U_HOUR_CO (
        .clk       (clk),
        .reset     (reset),
        .i_tick    (w_tick_hour_sw),
        .mode      (mode),
        .run_stop  (run_stop),
        .clear     (clear),
        .time_count(w_run_hour),
        .o_tick    ()
    );

    sw_time_counter #(
        .BIT_WIDTH(MIN_WIDTH),
        .TIMES(60)
    ) U_MIN_CO (
        .clk       (clk),
        .reset     (reset),
        .i_tick    (w_tick_min_sw),
        .mode      (mode),
        .run_stop  (run_stop),
        .clear     (clear),
        .time_count(w_run_min),
        .o_tick    (w_tick_hour_sw)
    );

    sw_time_counter #(
        .BIT_WIDTH(SEC_WIDTH),
        .TIMES(60)
    ) U_SEC_CO (
        .clk       (clk),
        .reset     (reset),
        .i_tick    (w_tick_sec_sw),
        .mode      (mode),
        .run_stop  (run_stop),
        .clear     (clear),
        .time_count(w_run_sec),
        .o_tick    (w_tick_min_sw)
    );

    sw_time_counter #(
        .BIT_WIDTH(MSEC_WIDTH),
        .TIMES(100)
    ) U_MSEC_CO (
        .clk       (clk),
        .reset     (reset),
        .i_tick    (w_tick_100hz_sw),
        .mode      (mode),
        .run_stop  (run_stop),
        .clear     (clear),
        .time_count(w_run_msec),
        .o_tick    (w_tick_sec_sw)
    );

    sw_tick_gen_100Hz U_SW_TICK_GEN_100Hz (
        .clk   (clk),
        .reset (reset),
        .o_tick(w_tick_100hz_sw)
    );


endmodule

module sw_tick_gen_100Hz (
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

module sw_time_counter #(
    parameter BIT_WIDTH = 7,
    TIMES = 100
) (
    input                      clk,
    input                      reset,
    input                      i_tick,
    input                      mode,
    input                      run_stop,
    input                      clear,
    output     [BIT_WIDTH-1:0] time_count,
    output reg                 o_tick
);

    reg [$clog2(TIMES)-1:0] counter_reg;
    assign time_count = counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset | clear) begin
            counter_reg <= 1'b0;
            o_tick      <= 1'b0;
        end else begin
            if (i_tick & run_stop) begin
                if (mode == 0) begin
                    counter_reg <= counter_reg + 1;
                    if (counter_reg == TIMES - 1) begin
                        counter_reg <= 0;
                        o_tick      <= 1'b1;
                    end
                end else begin
                    counter_reg <= counter_reg - 1;
                    if (counter_reg == 0) begin
                        counter_reg <= (TIMES - 1);
                        o_tick <= 1'b1;
                    end
                end
            end else begin
                o_tick <= 1'b0;
            end
        end
    end

endmodule

module record_mem #(
    parameter BIT_WIDTH = 7
) (
    input                    clk,
    input                    reset,
    input                    clear,
    input                    record,
    input  [(BIT_WIDTH-1):0] running_time,
    output [(BIT_WIDTH-1):0] recording_time
);

    reg [(BIT_WIDTH-1):0] record_reg;
    assign recording_time = record_reg;

    always @(posedge clk, posedge reset) begin
        if (reset | clear) begin
            record_reg <= 0;
        end else begin
            if (record) begin
                record_reg <= running_time;
            end else begin
                record_reg <= record_reg;
            end
        end
    end

endmodule

module mux_8x4 #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input                     sel,
    input  [(MSEC_WIDTH-1):0] in_a_msec,
    input  [ (SEC_WIDTH-1):0] in_a_sec,
    input  [ (MIN_WIDTH-1):0] in_a_min,
    input  [(HOUR_WIDTH-1):0] in_a_hour,
    input  [(MSEC_WIDTH-1):0] in_b_msec,
    input  [ (SEC_WIDTH-1):0] in_b_sec,
    input  [ (MIN_WIDTH-1):0] in_b_min,
    input  [(HOUR_WIDTH-1):0] in_b_hour,
    output [(MSEC_WIDTH-1):0] out_msec,
    output [ (SEC_WIDTH-1):0] out_sec,
    output [ (MIN_WIDTH-1):0] out_min,
    output [(HOUR_WIDTH-1):0] out_hour
);

    assign out_msec = (sel) ? in_b_msec : in_a_msec;
    assign out_sec  = (sel) ? in_b_sec : in_a_sec;
    assign out_min  = (sel) ? in_b_min : in_a_min;
    assign out_hour = (sel) ? in_b_hour : in_a_hour;

endmodule

