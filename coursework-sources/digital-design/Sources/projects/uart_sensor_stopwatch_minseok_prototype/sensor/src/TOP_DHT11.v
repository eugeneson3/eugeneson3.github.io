`timescale 1ns / 1ps

module TOP_DHT11 (
    input         clk,
    input         reset,
    input         btn_R,
    input  [ 1:0] sw,        //0
    output [15:0] led,
    output [ 3:0] fnd_com,
    output [ 7:0] fnd_data,
    inout         dht11_io
);

    assign led[13:0] = 0;

    wire        w_start;
    wire [15:0] w_humidity;
    wire [15:0] w_temperature;
    wire [15:0] w_data_sel;
    wire [ 7:0] w_data_div;


    btn_debounce U_BD (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_R),
        .o_btn(w_start)
    );

    DHT11_controller U_DHT11_CONTROLLER (
        .clk        (clk),
        .reset      (reset),
        .start      (w_start),
        .humidity   (w_humidity),
        .temperature(w_temperature),
        .enable     (led[15]),
        .valid      (led[14]),
        .dht11_io   (dht11_io)
    );

    sel_data U_SEL_DATA (
        .sel     (sw[0]),
        .data_hum(w_humidity),
        .data_tem(w_temperature),
        .data_sel(w_data_sel)
    );

    int_spliter U_INT_SPLITER (
        .sel     (sw[1]),
        .data_sel(w_data_sel),
        .div     (w_data_div)
    );

    fnd_controller U_FND_CONTROLLER (
        .clk     (clk),
        .reset   (reset),
        .fnd_in  (w_data_div),
        .fnd_com (fnd_com),
        .fnd_data(fnd_data)
    );


endmodule

module sel_data (
    input         sel,
    input  [15:0] data_hum,
    input  [15:0] data_tem,
    output [15:0] data_sel
);

    assign data_sel = (sel) ? data_tem : data_hum;
endmodule

module int_spliter (
    input         sel,
    input  [15:0] data_sel,
    output [ 7:0] div
);

    assign div = (!sel) ? data_sel[15:8] : data_sel[7:0];
endmodule


