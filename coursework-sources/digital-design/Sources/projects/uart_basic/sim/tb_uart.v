`timescale 1ns / 1ps

module tb_uart_controller ();
    parameter CLK_PERIOD = 10;  // 100MHz
    parameter BAUD_TICK = 10 * (100_000_000 / 9_600);


    reg clk, reset, tx_start;
    reg     [7:0] tx_data;
    reg           rx;
    wire    [7:0] rx_data;
    wire          tx;
    //for simulation loop
    integer       i = 0;
    integer       j = 0;
    uart_controller DUT (
        .clk     (clk),
        .reset   (reset),
        .tx_start(tx_start),
        .tx_data (tx_data),
        .rx      (rx),
        .tx_busy (tx_busy),
        .tx_done (tx_done),
        .rx_done (rx_done),
        .rx_data (rx_data),
        .tx      (tx)
    );


    always #5 clk = ~clk;

    //    task UART_RX_TASK(output [7:0] o_data);
    //        begin
    //            // uart rx
    //            wait (!tx);
    //            #(BAUD_TICK / 2);
    //            if (tx) $display("start bit error");
    //            #(BAUD_TICK);
    //            for (j = 0; j < 8; j = j + 1) begin
    //                o_data[j] = tx;
    //                #(BAUD_TICK);
    //            end
    //            #(BAUD_TICK-60_000);
    //            if (!tx) $display("stop bit error");
    //
    //        end
    //    endtask

    task UART_TX_START_TASK(input [7:0] data);
        begin
            // uart tx
            @(negedge clk);
            tx_start = 1;
            tx_data  = data;
            @(negedge clk);
            tx_start = 0;
            // #(BAUD_TICK * 10); control by time
            wait (DUT.U_UART_TX.tx_done);  // control by event
        end
    endtask

    task WAIT_TX_DONE();
        wait (DUT.U_UART_TX.tx_done);
    endtask

    task SENDER_FOR_UART_RX(input [7:0] send_data);
        begin
            rx = 0;
            #(BAUD_TICK);
            for(i = 0; i <8 ; i = i + 1) begin 
                rx = send_data[i];
                #(BAUD_TICK);
            end
            rx = 1;
            #(BAUD_TICK);
        end
    endtask

    initial begin
        clk      = 0;
        reset    = 1;
        tx_start = 0;
        tx_data  = 0;
        rx       = 1;
        #10;
        reset = 0;
        #10;
        UART_TX_START_TASK(8'h30);
        UART_TX_START_TASK(8'h31);
        SENDER_FOR_UART_RX(8'h32);
        SENDER_FOR_UART_RX(8'h33);
        #1_000;
        $stop;
    end

    //    task press_btn_R;
    //    begin
    //        btn_R = 1'b1;
    //        #(BTN_TIME);
    //        btn_R = 1'b0;
    //        #(BTN_TIME);
    //    end
    //    endtask
    //
    //    task read_uart_byte;
    //    begin
    //        rx_byte = 8'h00;
    //
    //        @(negedge tx);          // start bit
    //        #(BAUD_TIME / 2);
    //
    //        for (i = 0; i < 8; i = i + 1) begin
    //            #(BAUD_TIME);
    //            rx_byte[i] = tx;    // UART is LSB first
    //        end
    //
    //        #(BAUD_TIME);           // stop bit
    //    end
    //    endtask
    //
    //    initial begin
    //        clk = 1'b0;
    //        reset = 1'b1;
    //        btn_R = 1'b0;
    //        rx_byte = 8'h00;
    //        i = 0;
    //
    //        #100;
    //        reset = 1'b0;
    //        #1000;
    //
    //        press_btn_R();
    //        #2_000_000;
    //
    //        press_btn_R();
    //        #2_000_000;
    //
    //        press_btn_R();
    //        #2_000_000;
    //        $stop;
    //    end
    //
    //    initial begin
    //        read_uart_byte();
    //        if (rx_byte == 8'h30)
    //            $display("PASS: rx_byte = %h", rx_byte);
    //        else
    //            $display("FAIL: rx_byte = %h", rx_byte);
    //
    //        read_uart_byte();
    //        if (rx_byte == 8'h30)
    //            $display("PASS: rx_byte = %h", rx_byte);
    //        else
    //            $display("FAIL: rx_byte = %h", rx_byte);
    //
    //        read_uart_byte();
    //        if (rx_byte == 8'h30)
    //            $display("PASS: rx_byte = %h", rx_byte);
    //        else
    //            $display("FAIL: rx_byte = %h", rx_byte);
    //    end            
endmodule
