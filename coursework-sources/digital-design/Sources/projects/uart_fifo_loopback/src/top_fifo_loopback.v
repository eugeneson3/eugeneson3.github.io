`timescale 1ns / 1ps

module top_fifo_loopback #(
    parameter WIDTH = 8
) (
    input  clk,
    input  reset,
    input  rx,
    output tx
);

    wire w_push_rx, w_pop_rx;
    wire [WIDTH-1:0] w_wdata_rx, w_rdata_rx;
    wire w_full_rx, w_empty_rx;
    wire w_baud_tick_x16;

    wire w_empty_tx;
    wire [WIDTH-1:0] w_rdata_tx;

    baud_tick_x16 U_BAUD_TICK_X16 (
        .clk(clk),
        .reset(reset),
        .o_baud_tick(w_baud_tick_x16)
    );
    uart_rx_lecture U_UART_RX (
        .clk        (clk),
        .reset      (reset),
        .rx         (rx),
        .i_baud_tick(w_baud_tick_x16),
        .rx_data    (w_wdata_rx),
        .rx_done    (w_push_rx)
    );
    uart_tx U_UART_TX (
        .clk(clk),
        .reset(reset),
        .tx_start(~w_empty_tx),
        .tx_data(w_rdata_tx),
        .i_baud_tick(w_baud_tick_x16),
        .tx(tx),
        .tx_busy(w_pop_tx),
        .tx_done()
);    
 
    fifo #(
        .WIDTH(WIDTH)
    ) U_FIFO_RX (
        .clk  (clk),
        .reset(reset),
        .push (w_push_rx),
        .pop  (~w_full_tx),
        .wdata(w_wdata_rx),
        .rdata(w_rdata_rx),
        .full (), // intentionally unconnected
        .empty(w_empty_rx)
    );
    fifo #(
        .WIDTH(WIDTH)
    ) U_FIFO_TX (
        .clk  (clk),
        .reset(reset),
        .push (~w_empty_rx),
        .pop  (~w_pop_tx),
        .wdata(w_rdata_rx),
        .rdata(w_rdata_tx),
        .full (w_full_tx),
        .empty(w_empty_tx)
    );
endmodule
