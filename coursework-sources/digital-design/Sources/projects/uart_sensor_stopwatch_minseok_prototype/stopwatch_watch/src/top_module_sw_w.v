`timescale 1ns / 1ps

module top_module_sw_w (
    input         clk,
    input         reset,
    input         btn_L,
    input         btn_U,
    input         btn_R,
    input         btn_D,
    input  [ 2:0] sw,
    output [ 3:0] fnd_com,
    output [ 7:0] fnd_data,
    output [15:0] led
);

    wire w_btn_L_pulse, w_btn_U_pulse, w_btn_R_pulse, w_btn_D_pulse;
    wire w_sw_mode;
    wire w_edit_mode;
    wire w_wt_btn_L, w_wt_btn_U, w_wt_btn_R, w_wt_btn_D;
    wire w_sw_btn_L, w_sw_btn_U, w_sw_btn_R, w_sw_btn_D;

    wire w_to_watch, w_to_stopwatch;

    wire [6:0] w_wt_msec;
    wire [5:0] w_wt_sec;
    wire [5:0] w_wt_min;
    wire [4:0] w_wt_hour;

    wire [6:0] w_sw_msec;
    wire [5:0] w_sw_sec;
    wire [5:0] w_sw_min;
    wire [4:0] w_sw_hour;

    wire [6:0] w_fnd_msec;
    wire [5:0] w_fnd_sec;
    wire [5:0] w_fnd_min;
    wire [4:0] w_fnd_hour;

    assign led[1:0]  = (sw[1]) ? 2'b10 : 2'b01;
    assign led[14:2] = 13'b0;
    assign led[15]   = (sw[1]) ? w_edit_mode : w_sw_mode;


    debounce U_DEBOUNCE (
        .clk    (clk),
        .reset  (reset),
        .btn_L  (btn_L),
        .btn_U  (btn_U),
        .btn_R  (btn_R),
        .btn_D  (btn_D),
        .o_btn_L(w_btn_L_pulse),
        .o_btn_U(w_btn_U_pulse),
        .o_btn_R(w_btn_R_pulse),
        .o_btn_D(w_btn_D_pulse)
    );

    demux U_DEMUX (
        .sel            (sw[1]),
        .sw             (sw[2]),
        .sw_to_watch    (w_to_watch),
        .sw_to_stopwatch(w_to_stopwatch),

        .i_btn_L        (w_btn_L_pulse),
        .i_btn_U        (w_btn_U_pulse),
        .i_btn_R        (w_btn_R_pulse),
        .i_btn_D        (w_btn_D_pulse),

        .o_wt_btn_L     (w_wt_btn_L),
        .o_wt_btn_U     (w_wt_btn_U),
        .o_wt_btn_R     (w_wt_btn_R),
        .o_wt_btn_D     (w_wt_btn_D),
        
        .o_sw_btn_L     (w_sw_btn_L),
        .o_sw_btn_U     (w_sw_btn_U),
        .o_sw_btn_R     (w_sw_btn_R),
        .o_sw_btn_D     (w_sw_btn_D)
    );

    top_watch U_TOP_WATCH (
        .clk         (clk),
        .reset       (reset),
        .i_h_up_pulse(w_wt_btn_L),
        .i_m_up_pulse(w_wt_btn_U),
        .i_s_up_pulse(w_wt_btn_R),
        .i_opt_pulse (w_wt_btn_D),
        .sw          (w_to_watch),
        .o_msec      (w_wt_msec),
        .o_sec       (w_wt_sec),
        .o_min       (w_wt_min),
        .o_hour      (w_wt_hour),
        .o_edit_mode (w_edit_mode)
    );

    top_stopwatch U_TOP_STOPWATCH (
        .clk             (clk),
        .reset           (reset),
        .i_run_stop_pulse(w_sw_btn_L),
        .i_mode_pulse    (w_sw_btn_U),
        .i_clear_pulse   (w_sw_btn_R),
        .i_record_pulse  (w_sw_btn_D),
        .sw              (w_to_stopwatch),
        .o_msec          (w_sw_msec),
        .o_sec           (w_sw_sec),
        .o_min           (w_sw_min),
        .o_hour          (w_sw_hour),
        .o_mode          (w_sw_mode)
    );

    mux_8x4 U_MUX_8x4_TOP (
        .sel      (sw[1]),
        .in_a_msec(w_sw_msec),
        .in_a_sec (w_sw_sec),
        .in_a_min (w_sw_min),
        .in_a_hour(w_sw_hour),
        .in_b_msec(w_wt_msec),
        .in_b_sec (w_wt_sec),
        .in_b_min (w_wt_min),
        .in_b_hour(w_wt_hour),
        .out_msec (w_fnd_msec),
        .out_sec  (w_fnd_sec),
        .out_min  (w_fnd_min),
        .out_hour (w_fnd_hour)
    );

    fnd_controller U_FND_CTRL (
        .clk         (clk),
        .reset       (reset),
        .msec        (w_fnd_msec),
        .sec         (w_fnd_sec),
        .min         (w_fnd_min),
        .hour        (w_fnd_hour),
        .display_mode(sw[0]),
        .fnd_com     (fnd_com),
        .fnd_data    (fnd_data)
    );

endmodule



module demux (
    input  sel,
    input  sw,
    input  i_btn_L,
    input  i_btn_U,
    input  i_btn_R,
    input  i_btn_D,
    output sw_to_watch,
    output sw_to_stopwatch,
    output o_wt_btn_L,
    output o_wt_btn_U,
    output o_wt_btn_R,
    output o_wt_btn_D,
    output o_sw_btn_L,
    output o_sw_btn_U,
    output o_sw_btn_R,
    output o_sw_btn_D
);

    assign o_wt_btn_L      = sel ? i_btn_L : 1'b0;
    assign o_wt_btn_U      = sel ? i_btn_U : 1'b0;
    assign o_wt_btn_R      = sel ? i_btn_R : 1'b0;
    assign o_wt_btn_D      = sel ? i_btn_D : 1'b0;

    assign o_sw_btn_L      = ~sel ? i_btn_L : 1'b0;
    assign o_sw_btn_U      = ~sel ? i_btn_U : 1'b0;
    assign o_sw_btn_R      = ~sel ? i_btn_R : 1'b0;
    assign o_sw_btn_D      = ~sel ? i_btn_D : 1'b0;

    assign sw_to_watch     = sel ? sw : 1'b0;
    assign sw_to_stopwatch = ~sel ? sw : 1'b0;

endmodule

