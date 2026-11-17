`timescale 1ns / 1ps
module tb_top_dht11();
    reg clk,reset;
    reg btn_L;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire [15:0] led;
    // wire [15:0] humidity, temperature;

    tri1 dht11_io;
    reg dht11_sensor_io, dht11_sensor_io_control;
    assign dht11_io = (dht11_sensor_io_control) ? dht11_sensor_io : 1'bz;
    reg [39:0] sensor_data;

    top_dht11 DUT(
    .clk(clk),
    .reset(reset),
    .btn_L(btn_L),
    .fnd_com(fnd_com),
    .fnd_data(fnd_data),
    .led(led),
    .dht11_io(dht11_io)
    );

    integer i = 0;
    always #5 clk = ~clk;
    initial begin 
        clk = 0;
        reset = 1;
        btn_L = 0;
        dht11_sensor_io = 1;
        dht11_sensor_io_control = 0;
        #10;
        reset = 0;
        btn_L = 1;
        #60_000;
        btn_L = 0;
        // Respond relative to the DUT's actual LOW and release timing.
        wait (dht11_io === 1'b0);
        wait (dht11_io === 1'b1);
        #(30_000);

        dht11_sensor_io = 1'b0;
        dht11_sensor_io_control = 1;
        #(80_000);
        dht11_sensor_io = 1'b1;
        #(80_000);
        sensor_data = 40'h19_00_19_00_32;
        for (i = 0; i < 40; i = i + 1) begin 
            dht11_sensor_io = 1'b0;
            #(50_000);
            if(sensor_data[39-i]) begin 
                dht11_sensor_io = 1'b1;
                #(70_000);
                dht11_sensor_io = 1'b0;
            end else begin 
                dht11_sensor_io = 1'b1;
                #(27_000);
                dht11_sensor_io = 1'b0;
            end
        end
        #(50_000);
        dht11_sensor_io_control = 0;
        #(1_000);
        if ((DUT.test_data === 16'h1900) &&
            (led === 16'h1919) &&
            (DUT.U_DHT11.valid === 1'b1)) begin
            $display("PASS tb_top_dht11: humidity=%h led=%h", DUT.test_data, led);
        end else begin
            $error("FAIL tb_top_dht11: humidity=%h led=%h valid=%b",
                   DUT.test_data, led, DUT.U_DHT11.valid);
        end

        // A new measurement must not clear the last displayed data.
        btn_L = 1;
        #60_000;
        btn_L = 0;
        wait (dht11_io === 1'b0);
        #(100_000);
        if ((DUT.test_data === 16'h1900) && (led === 16'h1919)) begin
            $display("PASS hold data while measuring: humidity=%h led=%h",
                     DUT.test_data, led);
        end else begin
            $error("FAIL data cleared while measuring: humidity=%h led=%h",
                   DUT.test_data, led);
        end
        $finish;
    end

endmodule


module tb_dht11 ();

    reg clk, reset, start;
    wire [15:0] humidity, temperature;
    wire done, valid;
    wire [7:0] check_sum;
    tri1 dht11_io;
    reg dht11_sensor_io, dht11_sensor_io_control;
    reg [39:0] sensor_data;
    assign dht11_io = (dht11_sensor_io_control) ? dht11_sensor_io : 1'bz;
    dht11 DUT (
        .clk        (clk),
        .reset      (reset),
        .start      (start),
        .humidity   (humidity),
        .temperature(temperature),
        .done       (done),
        .valid      (valid),
        .check_sum  (check_sum),
        .dht11_io   (dht11_io)
    );
    integer i = 0;
    always #5 clk = ~clk;
    initial begin 
        clk = 0;
        reset = 1;
        start = 0;
        dht11_sensor_io = 1;
        dht11_sensor_io_control = 0;
        #10;
        reset = 0;
        start = 1;
        #10;
        start = 0;
        // Respond relative to the DUT's actual LOW and release timing.
        wait (dht11_io === 1'b0);
        wait (dht11_io === 1'b1);
        #(30_000);

        dht11_sensor_io = 1'b0;
        dht11_sensor_io_control = 1;
        #(80_000);
        dht11_sensor_io = 1'b1;
        #(80_000);
        sensor_data = 40'h19_00_19_00_32;
        for (i = 0; i < 40; i = i + 1) begin 
            dht11_sensor_io = 1'b0;
            #(50_000);
            if(sensor_data[39-i]) begin 
                dht11_sensor_io = 1'b1;
                #(70_000);
                dht11_sensor_io = 1'b0;
            end else begin 
                dht11_sensor_io = 1'b1;
                #(27_000);
                dht11_sensor_io = 1'b0;
            end
        end
        #(50_000);
        dht11_sensor_io_control = 0;
        #(1_000);
        if ((humidity === 16'h1900) &&
            (temperature === 16'h1900) &&
            (check_sum === 8'h32) &&
            (valid === 1'b1)) begin
            $display("PASS tb_dht11: humidity=%h temperature=%h checksum=%h",
                     humidity, temperature, check_sum);
        end else begin
            $error("FAIL tb_dht11: humidity=%h temperature=%h checksum=%h valid=%b",
                   humidity, temperature, check_sum, valid);
        end
        $finish;
    end
endmodule
