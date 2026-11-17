`timescale 1ns / 1ps


module top_dht11(
    input clk,
    input reset,
    input btn_L,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [15:0] led,
    inout dht11_io // n2
    );
    wire w_btn_L;
    
    fnd_controller U_FND_CONTROLLER(
    .clk(clk),
    .reset(reset),
    .fnd_in({1'b0, test_data[15:8]}),
    .fnd_com(fnd_com),
    .fnd_data(fnd_data)
);
    wire [15:0] test_data;
    wire [15:0] temperature_data;
    wire w_valid;
    assign led = {test_data[15:8], temperature_data[15:8]};

    dht11 U_DHT11 (
    .clk(clk),
    .reset(reset),
    .start(w_btn_L),
    .humidity(test_data),
    .temperature(temperature_data),
    .done(),
    .valid(w_valid),
    .check_sum(),
    .dht11_io(dht11_io)
);
    btn_debounce U_BTN_DEBOUNCE (
    .clk(clk),
    .reset(reset),
    .i_btn(btn_L),
    .o_btn(w_btn_L)
);
    ila_0 ila (
    .clk(clk),
    .probe0(w_valid),
    .probe1(w_btn_L),
    .probe2(led)
    );
endmodule
