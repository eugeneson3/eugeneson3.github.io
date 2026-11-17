`timescale 1ns / 1ps

module top_watch_stopwatch #(
    parameter MSEC_WIDTH = 7,
    parameter SEC_WIDTH = 6,
    parameter MIN_WIDTH = 6,
    parameter HOUR_WIDTH = 5,
    parameter BIT_NUM = 4
) (
    input clk,
    input reset,
    input btn_L,  
    input btn_R,  
    input btn_U,  
    input btn_D,  
    input rx,
    inout dht11_io,
    input echo,
    input [15:0] sw,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [15:12] led,
    output trig,
    output tx
);

    wire w_btn_L, w_btn_R, w_btn_U, w_btn_D;
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
    wire [7:0] w_decoder_out;
    wire w_run_uart, w_stop_uart, w_clear_uart, w_mode_uart;
    wire w_L_uart, w_R_uart, w_U_uart, w_D_uart;    
    wire [BIT_NUM - 1 : 0] demux_out0;
    wire [BIT_NUM - 1 : 0] demux_out1;
    assign w_run_uart   = w_decoder_out[7];
    assign w_stop_uart  = w_decoder_out[6];
    assign w_clear_uart = w_decoder_out[5] | demux_out0[1];
    assign w_mode_uart  = w_decoder_out[4] | demux_out0[0];
    assign w_L_uart     = w_decoder_out[3] | demux_out1[3];
    assign w_R_uart     = w_decoder_out[2] | demux_out1[2];
    assign w_U_uart     = w_decoder_out[1] | demux_out1[1];
    assign w_D_uart     = w_decoder_out[0] | demux_out1[0];

    demux_1x2 #(
        .BIT_NUM(BIT_NUM)
    ) U_DEMUX_1X2 (
        .i_in  ({w_btn_L, w_btn_R, w_btn_U, w_btn_D}),
        .i_sel (sw[1]),
        .o_out0(demux_out0),
        .o_out1(demux_out1)
    );
    wire       w_uart_rx_done;
    wire [7:0] w_uart_rx_data;
    wire       w_rx_done;
    wire [7:0] w_rx_data;
    wire       w_rx_fifo_full;
    wire       w_rx_fifo_empty;
    wire [15:0] w_humidity_raw;
    wire [15:0] w_temperature_raw;
    reg  [15:0] w_humidity;
    reg  [15:0] w_temperature;
    wire [7:0] w_check_sum;
    wire       w_valid;
    wire       w_dht_done;
    wire       w_sr04_done;
    wire [8:0] w_sr04_distance_raw;
    reg  [8:0] w_sr04_distance;
    reg        w_sr04_done_d;
    wire       w_tx_start;
    wire [7:0] w_tx_data;
    wire       w_tx_busy;
    wire       w_tx_fifo_push;
    wire [7:0] w_tx_fifo_wdata;
    wire       w_tx_fifo_full;
    wire       w_tx_fifo_empty;
    wire [1:0] w_sensor_command;
    wire       w_dht_start_uart;
    wire       w_sr04_start_uart;

    uart_controller U_UART (
        .clk      (clk),
        .reset    (reset),
        .tx_start (w_tx_start),
        .tx_data  (w_tx_data),
        .rx       (rx),
        .tx_busy  (w_tx_busy),
        .tx_done  (),
        .rx_done  (w_uart_rx_done),
        .rx_data  (w_uart_rx_data),
        .tx       (tx)
    );

    assign w_rx_done = ~w_rx_fifo_empty;

    fifo #(
        .WIDTH(2)
    ) U_RX_FIFO (
        .clk  (clk),
        .reset(reset),
        .push (w_uart_rx_done),
        .pop  (w_rx_done),
        .wdata(w_uart_rx_data),
        .rdata(w_rx_data),
        .full (w_rx_fifo_full),
        .empty(w_rx_fifo_empty)
    );

    assign w_tx_start = ~w_tx_fifo_empty && ~w_tx_busy;

    fifo #(
        .WIDTH(2)
    ) U_TX_FIFO (
        .clk  (clk),
        .reset(reset),
        .push (w_tx_fifo_push),
        .pop  (w_tx_start),
        .wdata(w_tx_fifo_wdata),
        .rdata(w_tx_data),
        .full (w_tx_fifo_full),
        .empty(w_tx_fifo_empty)
    );

    ascii_decoder U_ASCII_DECODER (
        .ascii_data(w_rx_data),
        .rx_done(w_rx_done),
        .reset(reset),
        .decoder_out(w_decoder_out)
    );

    sr04_lecture U_SR04_LECTURE(
        .clk(clk),
        .reset(reset),
        .start(w_sr04_start_uart),
        .echo(echo),
        .trigger(trig),
        .done(w_sr04_done),
        .distance(w_sr04_distance_raw)
    );

    dht11 U_DHT11(
        .clk(clk),
        .reset(reset),
        .start(w_dht_start_uart),
        .humidity(w_humidity_raw),
        .temperature(w_temperature_raw),
        .done(w_dht_done),
        .valid(w_valid),
        .check_sum(w_check_sum),
        .dht11_io(dht11_io)
    );

    sensor_command_parser U_SENSOR_COMMAND_PARSER (
        .clk(clk),
        .reset(reset),
        .rx_done(w_rx_done),
        .rx_data(w_rx_data),
        .command(w_sensor_command)
    );

    sensor_uart_reporter U_SENSOR_UART_REPORTER (
        .clk          (clk),
        .reset        (reset),
        .request      (w_sensor_command),
        .temperature  (w_temperature),
        .humidity     (w_humidity),
        .dht_done     (w_dht_done),
        .dht_valid    (w_valid),
        .distance     (w_sr04_distance),
        .distance_done(w_sr04_done),
        .dht_start    (w_dht_start_uart),
        .distance_start(w_sr04_start_uart),
        .tx_push      (w_tx_fifo_push),
        .tx_data      (w_tx_fifo_wdata),
        .tx_full      (w_tx_fifo_full)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            w_humidity      <= 16'd0;
            w_temperature   <= 16'd0;
            w_sr04_distance <= 9'd0;
            w_sr04_done_d   <= 1'b0;
        end else begin
            w_sr04_done_d <= w_sr04_done;
            if (w_dht_done && w_valid) begin
                if ((w_humidity_raw[7:0] == 8'd0) &&
                    (w_temperature_raw[7:0] == 8'd0)) begin
                    w_humidity    <= w_humidity_raw;
                    w_temperature <= w_temperature_raw;
                end
            end
            if (w_sr04_done_d)
                w_sr04_distance <= (w_sr04_distance_raw < 9'd2) ?
                                   9'd400 : w_sr04_distance_raw;
        end
    end



    wire w_run_stop, w_clear, w_mode;

    stopwatch_control_unit U_STOPWATCH_CONTROL_UNIT (
        .clk(clk),
        .reset(reset),
        .uart_run(w_run_uart),
        .uart_stop(w_stop_uart),
        .i_run_stop(demux_out0[3]), // buttons are toggle, but uart command is seperated run/stop; run/stop is uart_run/uart_stop
        .i_clear(w_clear_uart), // not working with demux_out; changed to 'w_clear_uart'
        .i_mode(w_mode_uart),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear),
        .o_mode(w_mode)
    );

    wire and_lap;
    wire lap_button;
    assign lap_button = w_btn_D && !sw[1];
    assign and_lap = (lap_button || w_decoder_out[0]) && w_run_stop;

    wire [MSEC_WIDTH-1:0] w_msec_stopwatch;
    wire [ SEC_WIDTH-1:0] w_sec_stopwatch;
    wire [ MIN_WIDTH-1:0] w_min_stopwatch;
    wire [HOUR_WIDTH-1:0] w_hour_stopwatch;

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
        .msec_out(w_msec_stopwatch),
        .sec_out(w_sec_stopwatch),
        .min_out(w_min_stopwatch),
        .hour_out(w_hour_stopwatch),
        .sw(sw[15:12]),
        .led_out(led[15:12])
    );
    wire w_hour_sel, w_min_sel, w_sec_sel;
    watch_control_unit U_WATCH_CONTROL_UNIT (
        .clk(clk),
        .reset(reset),
        .i_change_L(w_L_uart),
        .i_change_R(w_R_uart),
        .o_hour_sel(w_hour_sel),
        .o_min_sel(w_min_sel),
        .o_sec_sel(w_sec_sel)
    );
    wire [MSEC_WIDTH-1:0] w_msec_watch;
    wire [ SEC_WIDTH-1:0] w_sec_watch;
    wire [ MIN_WIDTH-1:0] w_min_watch;
    wire [HOUR_WIDTH-1:0] w_hour_watch;
    watch_datapath #(
        .MSEC_WIDTH(MSEC_WIDTH),
        .SEC_WIDTH (SEC_WIDTH),
        .MIN_WIDTH (MIN_WIDTH),
        .HOUR_WIDTH(HOUR_WIDTH)
    ) U_WATCH_DATAPATH (
        .clk(clk),
        .reset(reset),
        .i_hour_sel(w_hour_sel),
        .i_min_sel(w_min_sel),
        .i_sec_sel(w_sec_sel),
        .i_btn_U(w_U_uart),
        .i_btn_D(w_D_uart),
        .msec(w_msec_watch),
        .sec(w_sec_watch),
        .min(w_min_watch),
        .hour(w_hour_watch)
    );

    wire [MSEC_WIDTH-1:0] w_muxout_msec;
    wire [ SEC_WIDTH-1:0] w_muxout_sec;
    wire [ MIN_WIDTH-1:0] w_muxout_min;
    wire [HOUR_WIDTH-1:0] w_muxout_hour;

    mux_2x1_sw1 #(
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_MUX_2x1_MSEC (
        .in0(w_msec_stopwatch),
        .in1(w_msec_watch),
        .i_sel(sw[1]),
        .mux_out(w_muxout_msec)
    );

    mux_2x1_sw1 #(
        .BIT_WIDTH(SEC_WIDTH)
    ) U_MUX_2x1_SEC (
        .in0(w_sec_stopwatch),
        .in1(w_sec_watch),
        .i_sel(sw[1]),
        .mux_out(w_muxout_sec)
    );

    mux_2x1_sw1 #(
        .BIT_WIDTH(MIN_WIDTH)
    ) U_MUX_2x1_MIN (
        .in0(w_min_stopwatch),
        .in1(w_min_watch),
        .i_sel(sw[1]),
        .mux_out(w_muxout_min)
    );

    mux_2x1_sw1 #(
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_MUX_2x1_HOUR (
        .in0(w_hour_stopwatch),
        .in1(w_hour_watch),
        .i_sel(sw[1]),
        .mux_out(w_muxout_hour)
    );



    top_fnd_controller #(
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
         .display_mode(sw[4:0]),
        .humidity(w_humidity),
        .temperature(w_temperature),
        .distance(w_sr04_distance),
        .msec(w_muxout_msec),
        .sec(w_muxout_sec),
        .min(w_muxout_min),
        .hour(w_muxout_hour),
        .sw(sw[1:0]),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );
endmodule


// /get_temp detection
// One-byte UART controls remain separate.
module sensor_command_parser (
    input       clk,
    input       reset,
    input       rx_done,
    input [7:0] rx_data,
    output reg [1:0] command
);
    reg [5:0] char_index;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            char_index <= 6'd0;
            command    <= 2'd0;
        end else begin
            command <= 2'd0;
            if (rx_done) begin
                case (char_index)
                    6'd0: char_index <= (rx_data == 8'h2f) ? 6'd1 : 6'd0; // /
                    6'd1: char_index <= (rx_data == 8'h67) ? 6'd2 : 6'd0; // g
                    6'd2: char_index <= (rx_data == 8'h65) ? 6'd3 : 6'd0; // e
                    6'd3: char_index <= (rx_data == 8'h74) ? 6'd4 : 6'd0; // t
                    6'd4: char_index <= (rx_data == 8'h5f) ? 6'd5 : 6'd0; // _
                    6'd5: begin
                        if (rx_data == 8'h74) char_index <= 6'd6;       // temp
                        else if (rx_data == 8'h68) char_index <= 6'd8;  // humid
                        else if (rx_data == 8'h64) char_index <= 6'd13; // dist
                        else char_index <= 6'd0;                         // invalid
                    end
                    6'd6: char_index <= (rx_data == 8'h65) ? 6'd7 : 6'd0;  // e
                    6'd7: char_index <= (rx_data == 8'h6d) ? 6'd16 : 6'd0; // m
                    6'd8: char_index <= (rx_data == 8'h75) ? 6'd9 : 6'd0;  // u
                    6'd9: begin
                        char_index <= (rx_data == 8'h6d) ? 6'd10 : 6'd0; // m
                    end
                    6'd10: begin
                        char_index <= (rx_data == 8'h69) ? 6'd11 : 6'd0; // i
                    end
                    6'd11: begin
                        char_index <= 6'd0; // humid complete
                        if (rx_data == 8'h64) command <= 2'd2; // d
                    end
                    6'd13: char_index <= (rx_data == 8'h69) ? 6'd14 : 6'd0; // i
                    6'd14: char_index <= (rx_data == 8'h73) ? 6'd15 : 6'd0; // s
                    6'd15: begin
                        char_index <= 6'd0; // dist complete
                        if (rx_data == 8'h74) command <= 2'd3; // t
                    end
                    6'd16: begin
                        char_index <= 6'd0; // temp complete
                        if (rx_data == 8'h70) command <= 2'd1; // p
                    end
                    default: char_index <= 6'd0; // reset state
                endcase
            end
        end
    end
endmodule


// Sensor data UART report
// Example: TEMP=025 HUM=60 DIST=123\r\n
module sensor_uart_reporter (
    input        clk,
    input        reset,
    input [1:0]  request,
    input [15:0] temperature,
    input [15:0] humidity,
    input        dht_done,
    input        dht_valid,
    input [8:0]  distance,
    input        distance_done,
    output reg   dht_start,
    output reg   distance_start,
    output       tx_push,
    output [7:0] tx_data,
    input        tx_full
);
    localparam IDLE = 2'd0, WAIT_SENSOR = 2'd1, SEND = 2'd2;
    reg [1:0] state;
    reg [5:0] msg_index;
    reg [5:0] msg_last;
    reg [27:0] wait_count;
    reg [1:0] request_reg;
    reg dht_seen, distance_seen;
    reg [7:0] message [0:28];
    integer i;

    function [7:0] digit_ascii;
        input integer value;
        begin
            digit_ascii = 8'h30 + value;
        end
    endfunction

    assign tx_push = (state == SEND) && !tx_full;
    assign tx_data = message[msg_index];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state          <= IDLE;
            msg_index      <= 0;
            msg_last       <= 0;
            wait_count     <= 0;
            request_reg    <= 0;
            dht_seen       <= 1'b0;
            distance_seen  <= 1'b0;
            dht_start      <= 1'b0;
            distance_start <= 1'b0;
            for (i = 0; i < 29; i = i + 1) message[i] <= 8'h20;
        end else begin
            dht_start      <= 1'b0;
            distance_start <= 1'b0;

            case (state)
                IDLE: begin
                    if (request != 2'd0) begin
                        request_reg    <= request;
                        dht_start      <= (request != 2'd3);
                        distance_start <= (request != 2'd2);
                        wait_count     <= 0;
                        dht_seen       <= 1'b0;
                        distance_seen  <= 1'b0;
                        state          <= WAIT_SENSOR;
                    end
                end

                WAIT_SENSOR: begin
                    if (dht_done && dht_valid) dht_seen <= 1'b1;
                    if (distance_done) distance_seen <= 1'b1;

                    // Sensor completion or 1 s timeout
                    // Prevent UART lock on sensor failure
                    if (((((request_reg == 2'd3) || dht_seen || (dht_done && dht_valid)) &&
                          ((request_reg == 2'd2) || distance_seen || distance_done))) ||
                        (wait_count >= 28'd100_000_000)) begin
                        if (request_reg == 2'd1) begin
                            message[0]  <= "T"; message[1]  <= "E"; message[2]  <= "M";
                            message[3]  <= "P"; message[4]  <= "=";
                            message[5]  <= digit_ascii(temperature[15:8] / 100);
                            message[6]  <= digit_ascii((temperature[15:8] / 10) % 10);
                            message[7]  <= digit_ascii(temperature[15:8] % 10);
                            message[8]  <= " "; message[9]  <= "H"; message[10] <= "U";
                            message[11] <= "M"; message[12] <= "=";
                            message[13] <= digit_ascii(humidity[15:8] / 10);
                            message[14] <= digit_ascii(humidity[15:8] % 10);
                            message[15] <= " "; message[16] <= "D"; message[17] <= "I";
                            message[18] <= "S"; message[19] <= "T"; message[20] <= "=";
                            message[21] <= digit_ascii((distance > 400) ? 4 : distance / 100);
                            message[22] <= digit_ascii((distance > 400) ? 0 : (distance / 10) % 10);
                            message[23] <= digit_ascii((distance > 400) ? 0 : distance % 10);
                            message[24] <= 8'h0d; message[25] <= 8'h0a;
                            msg_last   <= 6'd25;
                        end else if (request_reg == 2'd2) begin
                            message[0] <= "H"; message[1] <= "U"; message[2] <= "M";
                            message[3] <= "=";
                            message[4] <= digit_ascii(humidity[15:8] / 10);
                            message[5] <= digit_ascii(humidity[15:8] % 10);
                            message[6] <= 8'h0d; message[7] <= 8'h0a;
                            msg_last   <= 6'd7;
                        end else begin
                            message[0] <= "D"; message[1] <= "I"; message[2] <= "S";
                            message[3] <= "T"; message[4] <= "=";
                            message[5] <= digit_ascii((distance > 400) ? 4 : distance / 100);
                            message[6] <= digit_ascii((distance > 400) ? 0 : (distance / 10) % 10);
                            message[7] <= digit_ascii((distance > 400) ? 0 : distance % 10);
                            message[8] <= 8'h0d; message[9] <= 8'h0a;
                            msg_last   <= 6'd9;
                        end
                        msg_index <= 0;
                        state     <= SEND;
                    end else begin
                        wait_count <= wait_count + 1'b1;
                    end
                end

                SEND: begin
                    if (tx_push) begin
                        if (msg_index == msg_last) begin
                            msg_index <= 0;
                            state     <= IDLE;
                        end else begin
                            msg_index <= msg_index + 1'b1;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule

module mux_2x1_sw1 #(
    parameter BIT_WIDTH = 7
) (
    input [BIT_WIDTH-1:0] in0,
    input [BIT_WIDTH-1:0] in1,
    input i_sel,
    output reg [BIT_WIDTH-1:0] mux_out
);
    always @(*) begin
        if (i_sel) begin
            mux_out = in1;  //deafult: stopwatch
        end else begin
            mux_out = in0;  // watch
        end
    end

endmodule
