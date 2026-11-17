`timescale 1ns / 1ps

module tb_stopwatch;

    reg clk;
    reg reset;
    reg btn_L;
    reg btn_R;
    reg btn_UP;
    reg btn_D;
    reg [15:0] sw;

    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire [3:0] led;

    top_stopwatch DUT (
        .clk(clk),
        .reset(reset),
        .btn_L(btn_L),
        .btn_R(btn_R),
        .btn_UP(btn_UP),
        .btn_D(btn_D),
        .sw(sw),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .led(led)
    );

    always #5 clk = ~clk; // 100 MHz

    task press_run_stop;
    begin
        btn_L = 1'b1;
        #100_000;
        btn_L = 1'b0;
        #100_000;
    end
    endtask

    task press_clear;
    begin
        btn_R = 1'b1;
        #100_000;
        btn_R = 1'b0;
        #100_000;
    end
    endtask

    task press_mode;
    begin
        btn_UP = 1'b1;
        #100_000;
        btn_UP = 1'b0;
        #100_000;
    end
    endtask

    task press_lap;
    begin
        btn_D = 1'b1;
        #100_000;
        btn_D = 1'b0;
        #100_000;
    end
    endtask

    initial begin
        $monitor("t=%0t run=%b clear=%b mode=%b tick=%b msec=%0d sec=%0d min=%0d hour=%0d led=%b lap0=%h lap1=%h lap2=%h lap3=%h fnd_com=%b fnd_data=%h",
                 $time,
                 DUT.w_run_stop,
                 DUT.w_clear,
                 DUT.w_mode,
                 DUT.U_STOPWATCH_DATAPATH.w_tick_100hz,
                 DUT.w_msec,
                 DUT.w_sec,
                 DUT.w_min,
                 DUT.w_hour,
                 led,
                 DUT.U_STOPWATCH_DATAPATH.U_LAP_MEMORY.lap_memory_reg[0],
                 DUT.U_STOPWATCH_DATAPATH.U_LAP_MEMORY.lap_memory_reg[1],
                 DUT.U_STOPWATCH_DATAPATH.U_LAP_MEMORY.lap_memory_reg[2],
                 DUT.U_STOPWATCH_DATAPATH.U_LAP_MEMORY.lap_memory_reg[3],
                 fnd_com,
                 fnd_data);
    end

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        btn_L = 1'b0;
        btn_R = 1'b0;
        btn_UP = 1'b0;
        btn_D = 1'b0;
        sw = 16'h0000;

        #1_000;
        reset = 1'b0;
        #1_000_000;

        // Start stopwatch and let msec increase several times.
        press_run_stop();
        #60_000_000;

        // Save two lap values while running.
        press_lap();
        #20_000_000;
        press_lap();
        #20_000_000;

        // Delete one saved lap while still running: sw[15:12] maps to local sw[3:0].
        sw = 16'h8000;
        #1_000_000;
        press_lap();
        #10_000_000;
        sw = 16'h0000;
        #10_000_000;

        // Save another lap after deleting one slot.
        press_lap();
        #20_000_000;

        // Stop. msec should hold while stopped.
        press_run_stop();
        #30_000_000;

        // Show saved lap slots using switches 15 and 14.
        sw = 16'h8000;
        #20_000_000;
        sw = 16'h4000;
        #20_000_000;
        sw = 16'h0000;
        #10_000_000;

        // Clear while stopped.
        press_clear();
        #20_000_000;

        // Run again in down-count mode.
        press_mode();
        #10_000_000;
        press_run_stop();
        #60_000_000;
        press_run_stop();
        #10_000_000;

        $stop;
    end

endmodule
