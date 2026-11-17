`timescale 1ns / 1ps

module tb_top_sr04();
    reg  clk,reset,btn_L,echo;
    wire trigger;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    integer i;
    top_sr04 DUT (
        .clk(clk),
        .reset(reset),
        .btn_L(btn_L),
        .echo(echo),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),  // max_distance = 400 cm; 9 bit max = 51()
        .trigger(trigger)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0;
        reset = 1;
        btn_L = 0;
        echo = 0;

        #10;
        reset = 0;
        for (i = 0; i < 8; i = i + 1) begin 
            btn_L = 1;
            #(100_000);
        
            btn_L = 0;

            #200_000;

            echo = 1;
            #(580_000 * 5*(i + 1)); // 50cm * (i + 1)
            echo = 0;
            #100;

        end
        $finish;
    end

endmodule









module tb_sr04 ();

    reg  clk,reset,start,echo;
    wire trigger, done;
    wire [8:0] distance;
    integer i;
    sr04_lecture DUT (
        .clk(clk),
        .reset(reset),
        .start(start),
        .echo(echo),
        .done(done),
        .distance(distance),  // max_distance = 400 cm; 9 bit max = 51()
        .trigger(trigger)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0;
        reset = 1;
        start = 0;
        echo = 0;

        #10;
        reset = 0;
        for (i = 0; i < 9; i = i + 1) begin 
            start = 1;
            #(1_000*11);
        
            start = 0;
            @(negedge trigger);
            #200_000;
            echo = 1;
            #(580_000 * 5*(i + 1)); // 50cm 
            echo = 0;
            #100000;
            $display (" at %0d, current distance = %0d", $time, distance);

        end
        #100_000;

        $finish;
    end
endmodule
