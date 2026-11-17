`timescale 1ns / 1ps

module top_stopwatch #(
    parameter MSEC_WIDTH = 7,
    parameter SEC_WIDTH  = 6,
    parameter MIN_WIDTH  = 6,
    parameter HOUR_WIDTH = 5
) (
    input         clk,
    input         reset,
    input         btn_L,
    input         btn_R,
    input         btn_U,
    input         btn_D,
    input  [15:0] sw,
    output [ 3:0] fnd_com,
    output [ 7:0] fnd_data,
    output [ 3:0] led
);
    wire w_btn_L, w_btn_R, w_btn_U, w_btn_D;
    wire w_run_stop, w_clear, w_mode;

    wire and_lap;  // lap while stop is not permitted; iphone stopwatch
    assign and_lap = (w_btn_D) && (w_run_stop);

    wire [MSEC_WIDTH - 1:0] w_msec;
    wire [ SEC_WIDTH - 1:0] w_sec;
    wire [ MIN_WIDTH - 1:0] w_min;
    wire [HOUR_WIDTH - 1:0] w_hour;


    btn_debounce_4 U_BTN_DEBOUNCE_4 (
        .clk(clk),
        .reset(reset),
        .i_btn_L(btn_L),
        .i_btn_R(btn_R),
        .i_btn_U(btn_U),
        .i_btn_D(btn_D),
        .o_btn_L(w_btn_L),
        .o_btn_R(w_btn_R),
        .o_btn_U(w_btn_U),
        .o_btn_D(w_btn_D)
    );

    stopwatch_control_unit U_CONTROL_UNIT (
        .clk(clk),
        .reset(reset),
        .i_run_stop(w_btn_L),
        .i_clear(w_btn_R),
        .i_mode(w_btn_U),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear),
        .o_mode(w_mode)
    );

    stopwatch_datapath #(
        .MSEC_WIDTH(MSEC_WIDTH),
        .SEC_WIDTH (SEC_WIDTH),
        .MIN_WIDTH (MIN_WIDTH),
        .HOUR_WIDTH(HOUR_WIDTH)

    ) U_STOPWATCH_DATAPATH (
        .clk(clk),
        .reset(reset),
        .run_stop(w_run_stop),
        .clear(w_clear),
        .mode(w_mode),
        .lap(and_lap),  // lap while stop is not permitted
        .msec_out(w_msec),
        .sec_out(w_sec),
        .min_out(w_min),
        .hour_out(w_hour),
        .sw(sw[15:12]),
        .led_out(led)
    );
    fnd_controller #(
        .MSEC_WIDTH(MSEC_WIDTH),
        .SEC_WIDTH (SEC_WIDTH),
        .MIN_WIDTH (MIN_WIDTH),
        .HOUR_WIDTH(HOUR_WIDTH)
    ) U_FND_CNTL (
        .clk(clk),
        .reset(reset),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour),
        .display_mode(sw[0]),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
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
    input                   run_stop,
    input                   clear,
    input                   mode,
    input                   lap,
    input  [           3:0] sw,
    //input option
    output [MSEC_WIDTH-1:0] msec_out,
    output [ SEC_WIDTH-1:0] sec_out,
    output [ MIN_WIDTH-1:0] min_out,
    output [HOUR_WIDTH-1:0] hour_out,
    output [           3:0] led_out
);

    wire w_tick_100hz, w_tick_sec, w_tick_min, w_tick_hour;
    wire [MSEC_WIDTH - 1:0] msec;
    wire [ SEC_WIDTH - 1:0] sec;
    wire [ MIN_WIDTH - 1:0] min;
    wire [HOUR_WIDTH - 1:0] hour;

    tick_gen_100hz U_TICK_GEN_100HZ (
        .clk(clk),
        .reset(reset),
        .o_tick(w_tick_100hz)
    );

    lap_memory #(
        .MSEC_WIDTH(MSEC_WIDTH),
        .SEC_WIDTH (SEC_WIDTH),
        .MIN_WIDTH (MIN_WIDTH),
        .HOUR_WIDTH(HOUR_WIDTH)
    ) U_LAP_MEMORY (
        .clk(clk),
        .reset(reset),
        .lap(lap),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour),
        .msec_out(msec_out),
        .sec_out(sec_out),
        .min_out(min_out),
        .hour_out(hour_out),
        .sw(sw),
        .i_tick(w_tick_100hz),
        .led_out(led_out)

    );

    time_counter #(
        .BIT_WIDTH(HOUR_WIDTH),
        .TIMES(24)
    ) U_HOUR_COUNTER (
        .clk       (clk),
        .reset     (reset),
        .i_tick    (w_tick_min),
        .mode      (mode),
        .run_stop  (run_stop),
        .clear     (clear),
        .time_count(hour),
        .o_tick    (w_tick_hour)
    );
    time_counter #(
        .BIT_WIDTH(MIN_WIDTH),
        .TIMES(60)
    ) U_MIN_COUNTER (
        .clk       (clk),
        .reset     (reset),
        .i_tick    (w_tick_sec),
        .mode      (mode),
        .run_stop  (run_stop),
        .clear     (clear),
        .time_count(min),
        .o_tick    (w_tick_min)
    );
    time_counter #(
        .BIT_WIDTH(SEC_WIDTH),
        .TIMES(60)
    ) U_SEC_COUNTER (
        .clk       (clk),
        .reset     (reset),
        .i_tick    (w_tick_msec),
        .mode      (mode),
        .run_stop  (run_stop),
        .clear     (clear),
        .time_count(sec),
        .o_tick    (w_tick_sec)
    );

    time_counter #(
        .BIT_WIDTH(MSEC_WIDTH),
        .TIMES(100)
    ) U_MSEC_COUNTER (
        .clk       (clk),
        .reset     (reset),
        .i_tick    (w_tick_100hz),
        .mode      (mode),
        .run_stop  (run_stop),
        .clear     (clear),
        .time_count(msec),
        .o_tick    (w_tick_msec)
    );

    //  parameter MSEC_WIDTH = 7, SEC_WIDTH = 6, MIN_WIDTH = 6, HOUR_WIDTH = 5;
endmodule

// 1kHz tick generator
module tick_gen_100hz (
    input  clk,
    input  reset,
    output o_tick
);
    parameter F_COUNT = 1_000_000;
    reg tick_reg;
    assign o_tick = tick_reg;

    reg [$clog2(F_COUNT)-1:0] counter_reg;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            tick_reg    <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;

            if (counter_reg == (F_COUNT - 1)) begin
                counter_reg <= 0;
                tick_reg <= 1'b1;
            end else tick_reg <= 0;
        end
    end
endmodule

module time_counter #(
    parameter BIT_WIDTH = 7,
    TIMES = 100
) (
    input                          clk,
    input                          reset,
    input                          i_tick,
    input                          mode,
    input                          run_stop,
    input                          clear,
    output     [BIT_WIDTH - 1 : 0] time_count,
    output reg                     o_tick
);
    reg [$clog2(TIMES)-1:0] counter_reg;
    assign time_count = counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset | clear) begin
            counter_reg <= 0;
            o_tick <= 1'b0;
        end else begin
            if (i_tick && run_stop) begin
                if (!mode) begin
                    if (counter_reg == (TIMES - 1)) begin
                        counter_reg <= 0;
                        o_tick <= 1'b1;
                    end else counter_reg <= counter_reg + 1;
                end else begin
                    if (counter_reg == (0)) begin
                        counter_reg <= (TIMES - 1);
                        o_tick <= 1'b1;
                    end else counter_reg <= counter_reg - 1;
                end
            end else begin
                o_tick <= 1'b0;
            end
        end
    end

endmodule


module lap_memory #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input                     clk,
    input                     reset,
    input                     lap,
    input  [MSEC_WIDTH - 1:0] msec,
    input  [ SEC_WIDTH - 1:0] sec,
    input  [ MIN_WIDTH - 1:0] min,
    input  [HOUR_WIDTH - 1:0] hour,
    input                     i_tick,
    input  [             3:0] sw,
    output [MSEC_WIDTH - 1:0] msec_out,
    output [ SEC_WIDTH - 1:0] sec_out,
    output [ MIN_WIDTH - 1:0] min_out,
    output [HOUR_WIDTH - 1:0] hour_out,
    output [             3:0] led_out

);
    integer i;
    reg [1:0] empty_bit;
    reg [3:0] led_reg;
    reg [23:0] lap_memory_reg[3:0];
    reg [23:0] data_stream;
    wire [23:0] time_array;
    assign led_out = led_reg;

    always @(*) begin
        empty_bit = 2'b00;
        if (~led_reg[3]) empty_bit = 2'b11;
        else if (~led_reg[2]) empty_bit = 2'b10;
        else if (~led_reg[1]) empty_bit = 2'b01;
        else if (~led_reg[0]) empty_bit = 2'b00;
    end

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            data_stream <= 24'b0;
            led_reg <= 4'b0000;
            for (i = 0; i < 4; i = i + 1) begin
                lap_memory_reg[i] <= 24'b0;
            end
        end else begin
            data_stream <= {hour, min, sec, msec};
            if (lap) begin
                //turn off all led with switch on'd
                if (|sw[3:0]) begin
                    for (i = 0; i < 4; i = i + 1) begin
                        if (sw[i]) begin
                            lap_memory_reg[i] <= 24'b0;
                            led_reg[i] <= 1'b0;
                        end
                    end
                end else if ((~&led_reg[3:0])) begin
                    lap_memory_reg[empty_bit] <= {hour, min, sec, msec};
                    led_reg[empty_bit] <= 1'b1;
                end
            end

        end

    end
    mux_5x1 U_MUX_5X1 (
        .sel(sw),
        .in0(data_stream),
        .in1(lap_memory_reg[0]),
        .in2(lap_memory_reg[1]),
        .in3(lap_memory_reg[2]),
        .in4(lap_memory_reg[3]),
        .mux_out(time_array)
    );
    time_splitter U_TIME_SPLITTER (
        .timer(time_array),
        .msec (msec_out),
        .sec  (sec_out),
        .min  (min_out),
        .hour (hour_out)
    );

endmodule

module mux_5x1 (
    input [3:0] sel,
    input [23:0] in0,
    input [23:0] in1,
    input [23:0] in2,
    input [23:0] in3,
    input [23:0] in4,
    output reg [23:0] mux_out
);
    always @(*) begin
        if (sel[3]) mux_out = in4;
        else if (sel[2]) mux_out = in3;
        else if (sel[1]) mux_out = in2;
        else if (sel[0]) mux_out = in1;
        else mux_out = in0;
    end


endmodule
module time_splitter (
    input  [23:0] timer,
    output [ 6:0] msec,
    output [ 5:0] sec,
    output [ 5:0] min,
    output [ 4:0] hour
);
    assign {hour, min, sec, msec} = timer;
endmodule
