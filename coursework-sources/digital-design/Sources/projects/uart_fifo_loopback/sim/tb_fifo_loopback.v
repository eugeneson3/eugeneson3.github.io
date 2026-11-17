`timescale 1ns / 1ps

module tb_fifo_loopback ();
    parameter BAUD_TICK = 10 * (100_000_000 / 9_600);
    parameter WIDTH = 8;


    reg clk, reset;
    reg           rx;
    wire          tx;
    reg     [WIDTH-1:0] receive_data;
    reg     [WIDTH-1:0] send_data;
    //for simulation loop
    integer       i = 0;
    integer       j = 0;
    top_fifo_loopback #(.WIDTH(WIDTH))
    DUT (
        .clk     (clk),
        .reset   (reset),
        .rx      (rx),
        .tx      (tx)
    );

    always #5 clk = ~clk;

    task SENDER_FOR_UART_RX();
        begin
            rx = 0;
            #(BAUD_TICK);
            for (i = 0; i < 8; i = i + 1) begin
                rx = send_data[i];
                #(BAUD_TICK);
            end
            rx = 1;
            #(BAUD_TICK);
        end
    endtask
    // PC Receiver
    task receiver();
        begin
            wait (~tx);
            #(BAUD_TICK / 2);
            if (tx) $display("%t: start bit error", $time);
            #(BAUD_TICK);
            for (j = 0; j < 8; j = j + 1) begin
                receive_data[j] = tx;
                #(BAUD_TICK);
            end
            #(BAUD_TICK);
            if (~tx) $display("%t: stop bit error", $time);

        end

    endtask
    initial begin
        clk   = 0;
        reset = 1;
        #10;
        reset = 0;
        #10;
        repeat(255) begin
            send_data = $random & 8'hFF;
            SENDER_FOR_UART_RX();
            receiver();
            if(send_data == receive_data) $display ("%t: PASSED", $time);
            else $display ("%t: FAILED, send_data = %d, receive_data = %d", $time,send_data,receive_data);
            //#(BAUD_TICK * 12);
         end
        
        #1_000;
        $finish;
    end
endmodule
