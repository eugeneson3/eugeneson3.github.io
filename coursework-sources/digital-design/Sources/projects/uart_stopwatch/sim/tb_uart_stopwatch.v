`timescale 1ns / 1ps

module tb_uart_stopwatch();
    parameter CLK_PERIOD = 10;  // 100MHz
    parameter BAUD_TICK = 10 * (100_000_000 / 9_600);
    reg clk;
    reg reset;
    reg btn_L;
    reg btn_R;
    reg btn_U;
    reg btn_D;
    reg [15:0] sw;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire [15:0] led;
    reg rx;
    wire tx;
    integer i = 0;
    top_watch_stopwatch UUT (
        .clk(clk),
        .reset(reset),
        .btn_L(btn_L),
        .btn_R(btn_R),
        .btn_U(btn_U),
        .btn_D(btn_D),
        .sw(sw),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .led(led),
        .rx(rx),
        .tx(tx)
    );

    always #5 clk = ~clk;
    task SENDER_FOR_UART_RX(input [7:0] send_data);
        begin
            rx = 0;
            #(BAUD_TICK);
            for(i = 0; i <8 ; i = i + 1) begin 
                rx = send_data[i];
                #(BAUD_TICK);
            end
            rx = 1;

        end
    endtask

    initial begin
        clk = 0;
        reset = 1'b1;
        btn_L = 1'b0;
        btn_R = 1'b0;
        btn_U = 1'b0;
        btn_D = 1'b0;
        sw = 16'b0;
        rx = 1'b1;
        #10;
        reset = 1'b0;
        #10;
        SENDER_FOR_UART_RX(8'h52); // 0111_0010
        #12_000_000; // wait for 120ms
        SENDER_FOR_UART_RX(8'h53);
        #12_000_000;

        SENDER_FOR_UART_RX(8'h4d);
        #12_000_000;

        SENDER_FOR_UART_RX(8'h52); 
        #12_000_000; 
        SENDER_FOR_UART_RX(8'h53);
        #12_000_000;

        SENDER_FOR_UART_RX(8'h43);
        #12_000_000;
        sw[1] = 1; // change from stopwatch to watch mode

        SENDER_FOR_UART_RX(8'h6c); // change sec 
        #12_000_000;
        sw[0] = 1; // to change view to hour:min from sec:msec

        SENDER_FOR_UART_RX(8'h6c); // change min
        #12_000_000;
        SENDER_FOR_UART_RX(8'h6c); //change hour
        #12_000_000;
        SENDER_FOR_UART_RX(8'h72); //change min
        #12_000_000;
        sw[0] = 0;
        SENDER_FOR_UART_RX(8'h72); // change sec
        #12_000_000;
        SENDER_FOR_UART_RX(8'h75);
        #12_000_000;
        SENDER_FOR_UART_RX(8'h64);
        #12_000_000;
        $finish;
        


    end
endmodule
// ascii_data 
// r = 0x52 -> run
// s = 0x53 -> stop
// c = 0x43 -> clear
// m  = 0x5d  mode
// L = 0x6c -> go Left digit (stopwatch mode)
// R = 0x72 -> go Right digit (stopwatch mode)
// U = 0x75 -> time digit up (watch mode)
// D = 0x64 -> time digit down (watch mode)