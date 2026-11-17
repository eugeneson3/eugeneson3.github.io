`timescale 1ns / 1ps


module top_sr04(
    input clk,
    input reset,
    input btn_L,
    input echo,
    output trigger,
    output [3:0] fnd_com,
    output [7:0] fnd_data
    );
    wire w_btn_L;
    wire [8:0] w_distance;
    fnd_controller U_FND_CONTROLLER(
    .clk(clk),
    .reset(reset),
    .fnd_in(w_distance),
    .fnd_com(fnd_com),
    .fnd_data(fnd_data)
);


    sr04_lecture U_SR04 (
    .clk(clk),
    .reset(reset),
    .start(w_btn_L),
    .echo(echo),
    .trigger(trigger),
    .done(),
    .distance(w_distance)
);


    btn_debounce U_BTN_DEBOUNCE (
    .clk(clk),
    .reset(reset),
    .i_btn(btn_L),
    .o_btn(w_btn_L)

);
// ila_0 ila (
// .clk(clk),
// .probe0(trigger),
// .probe1(echo),
// .probe2(w_distance)
// );

endmodule
