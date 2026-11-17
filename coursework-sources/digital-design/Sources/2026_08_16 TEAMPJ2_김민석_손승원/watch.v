`timescale 1ns / 1ps
module top_watch #(
    parameter MSEC_WIDTH = 7,
    parameter SEC_WIDTH  = 6,
    parameter MIN_WIDTH  = 6,
    parameter HOUR_WIDTH = 5
) (
    input clk,
    input reset,
    input btn_L,  // HMS change L
    input btn_R,  // HMS change R
    input btn_U,  // Count Up
    input btn_D,  // Count Down
    input [1:0] sw,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [1:0] led
);
    // wire
    wire w_btn_L, w_btn_R, w_btn_U, w_btn_D;
    wire w_hour_sel, w_min_sel, w_sec_sel;
    wire [MSEC_WIDTH - 1 : 0] w_msec;
    wire [SEC_WIDTH-1:0] w_sec;
    wire [MIN_WIDTH-1:0] w_min;
    wire [HOUR_WIDTH-1:0] w_hour;

    // assignment
    assign led = sw;

    // btn_debounce instantiation
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

    // watch_control_unit instantiation
    watch_control_unit U_WATCH_CONTROL_UNIT (
        .clk(clk),
        .reset(reset),
        .i_change_L(w_btn_L),
        .i_change_R(w_btn_R),
        .o_hour_sel(w_hour_sel),
        .o_min_sel(w_min_sel),
        .o_sec_sel(w_sec_sel)
    );

    // stopwatch_datapath instantiation
    watch_datapath #(
        .MSEC_WIDTH(MSEC_WIDTH),
        .SEC_WIDTH (SEC_WIDTH),
        .MIN_WIDTH (MIN_WIDTH),
        .HOUR_WIDTH(HOUR_WIDTH)
    ) U_WATCH_DATAPATH (
        .clk       (clk),
        .reset     (reset),
        .i_hour_sel(w_hour_sel),
        .i_min_sel (w_min_sel),
        .i_sec_sel (w_sec_sel),
        .i_btn_U   (w_btn_U),
        .i_btn_D   (w_btn_D),
        .msec      (w_msec),
        .sec       (w_sec),
        .min       (w_min),
        .hour      (w_hour)
    );

    // fnd_controller instantiation
    watch_fnd_controller #(
        .MSEC_WIDTH(MSEC_WIDTH),
        .SEC_WIDTH (SEC_WIDTH),
        .MIN_WIDTH (MIN_WIDTH),
        .HOUR_WIDTH(HOUR_WIDTH)
    ) U_WATCH_FND_CONTROLLER (
        .clk(clk),
        .reset(reset),
        .i_hour_sel(w_hour_sel),
        .i_min_sel(w_min_sel),
        .i_sec_sel(w_sec_sel),
        .display_mode(sw),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );



endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module watch_datapath #(
    parameter MSEC_WIDTH = 7,
    parameter SEC_WIDTH  = 6,
    parameter MIN_WIDTH  = 6,
    parameter HOUR_WIDTH = 5
) (
    input                      clk,
    input                      reset,
    input                      i_hour_sel,
    input                      i_min_sel,
    input                      i_sec_sel,
    input                      i_btn_U,
    input                      i_btn_D,
    output [   MSEC_WIDTH-1:0] msec,
    output [ SEC_WIDTH -1 : 0] sec,
    output [  MIN_WIDTH-1 : 0] min,
    output [HOUR_WIDTH -1 : 0] hour
);
    // wire
    wire w_tick_100hz;
    wire w_tick_msec, w_tick_sec, w_tick_min;
    wire w_hour_count_up, w_hour_count_down;
    wire w_min_count_up, w_min_count_down;
    wire w_sec_count_up, w_sec_count_down;

    // assignment
    assign {w_hour_count_up,w_min_count_up,w_sec_count_up} = {i_hour_sel, i_min_sel, i_sec_sel} & {3{i_btn_U}};
    assign {w_hour_count_down,w_min_count_down,w_sec_count_down} = {i_hour_sel, i_min_sel, i_sec_sel} & {3{i_btn_D}};

    // tick_gen instantiation
    tick_gen_100hz U_TICK_GEN_100HZ (
        .clk(clk),
        .reset(reset),
        .o_tick(w_tick_100hz)
    );

    // time_counter instantiation for msec
    time_counter_watch #(
        .BIT_WIDTH(MSEC_WIDTH),
        .TIMES(100),
        .INIT_NUM(0)
    ) U_MSEC_COUNTER (
        .clk(clk),
        .reset(reset),
        .i_tick(w_tick_100hz),
        .i_count_up(),
        .i_count_down(),
        .time_count(msec),
        .o_tick(w_tick_msec)
    );

    // time_counter instantiation for sec
    time_counter_watch #(
        .BIT_WIDTH(SEC_WIDTH),
        .TIMES(60),
        .INIT_NUM(0)
    ) U_SEC_COUNTER (
        .clk(clk),
        .reset(reset),
        .i_tick(w_tick_msec),
        .i_count_up(w_sec_count_up),
        .i_count_down(w_sec_count_down),
        .time_count(sec),
        .o_tick(w_tick_sec)
    );

    // time_counter instantiation for min
    time_counter_watch #(
        .BIT_WIDTH(MIN_WIDTH),
        .TIMES(60),
        .INIT_NUM(0)
    ) U_MIN_COUNTER (
        .clk(clk),
        .reset(reset),
        .i_tick(w_tick_sec),
        .i_count_up(w_min_count_up),
        .i_count_down(w_min_count_down),
        .time_count(min),
        .o_tick(w_tick_min)
    );

    // time_counter instantiation for hour
    time_counter_watch #(
        .BIT_WIDTH(HOUR_WIDTH),
        .TIMES(24),
        .INIT_NUM(12)
    ) U_HOUR_COUNTER (
        .clk(clk),
        .reset(reset),
        .i_tick(w_tick_min),
        .i_count_up(w_hour_count_up),
        .i_count_down(w_hour_count_down),
        .time_count(hour),
        .o_tick()
    );

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

//module tick_gen_100hz (
//    input  clk,
//    input  reset,
//    output o_tick
//);
//    // parameter
//    parameter F_COUNT = 1_000_000;
//
//    // register
//    reg tick_reg;
//    reg [$clog2(F_COUNT) -1 : 0] counter_reg;
//
//    // assignment
//    assign o_tick = tick_reg;
//
//    // Sequential Logic
//    always @(posedge clk, posedge reset) begin
//        if (reset) begin
//            tick_reg <= 1'b0;
//            counter_reg <= 0;
//        end else begin
//            if (counter_reg == F_COUNT - 1) begin
//                tick_reg <= 1'b1;
//                counter_reg <= 0;
//            end else begin
//                tick_reg <= 1'b0;
//                counter_reg <= counter_reg + 1;
//            end
//        end
//    end
//endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module time_counter_watch #(
    parameter BIT_WIDTH = 7,  // required bit width for TIMES
    parameter TIMES   = 100,   // max counting number(msec : 100 / sec : 60 / min : 60 / hour : 24)
    parameter INIT_NUM = 0 // initial number for watch(msec : 0 / sec : 0 / min : 0 / hour : 12 )
) (
    input                          clk,
    input                          reset,
    input                          i_tick,
    input                          i_count_up,
    input                          i_count_down,
    output [$clog2(TIMES) - 1 : 0] time_count,
    output                         o_tick
);
    // register
    reg [$clog2(TIMES) - 1 : 0] reg_time_count;
    reg reg_tick;

    // assignment
    assign time_count = reg_time_count;
    assign o_tick = reg_tick;

    // Sequential Logic
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            reg_time_count <= INIT_NUM;
            reg_tick <= 0;
        end else begin
            if (i_tick | i_count_up) begin
                if (reg_time_count == (TIMES - 1)) begin
                    reg_time_count <= 0;
                    reg_tick <= 1'b1;
                end else begin
                    reg_time_count <= reg_time_count + 1;
                end
            end else if (i_count_down) begin
                if (reg_time_count == (0)) begin
                    reg_time_count <= (TIMES - 1);
                end else begin
                    reg_time_count <= reg_time_count - 1;
                end
            end else begin
                reg_tick <= 1'b0;
            end
        end
    end
endmodule
