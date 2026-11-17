`timescale 1ns / 1ps
module tb_time_counter();
    parameter BIT_WIDTH = 7;
    parameter TIMES = 100;
    
    reg clk;
    reg reset;
    reg i_tick;
    reg mode;
    reg run_stop;
    reg clear;
    wire [BIT_WIDTH - 1 : 0] time_count;
    wire o_tick;

    time_counter #(
        .BIT_WIDTH(BIT_WIDTH),
        .TIMES(TIMES)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .i_tick(i_tick),
        .mode(mode),
        .run_stop(run_stop),
        .clear(clear),
        .time_count(time_count),
        .o_tick(o_tick)
    );
    task tick;
    begin
        i_tick = 1'b1;
        #10;
        i_tick = 1'b0;
        #10;
    end
    endtask
    // clock generation
    always #5 clk = ~clk;

    // scenario
    initial begin
        clk = 0;
        reset = 1;
        i_tick = 0;
        mode = 0;
        run_stop = 0;
        clear = 0;
        #10;
        reset = 0; // initialization

        #10;
        run_stop = 1;
        repeat(102)
            tick;
        run_stop = 0;
        #10;

        mode = 1;
        #20;
        
        repeat(100)
            tick;
        
        run_stop = 1;
        #10;
        run_stop = 0;
        #20;

        clear = 1;
        #10;
        clear = 0;

        mode = 1;
        run_stop = 1;
        repeat(100)
            tick;
        run_stop = 0;
        
        $finish;
    end
endmodule

module tb_stopwatch_control_unit();
    reg clk;
    reg reset;
    reg i_run_stop;
    reg i_clear;
    reg i_mode;
    wire w_run_stop;
    wire w_clear;
    wire w_mode;

    stopwatch_control_unit DUT(
        .clk(clk),
        .reset(reset),
        .i_run_stop(i_run_stop),
        .i_clear(i_clear),
        .i_mode(i_mode),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear),
        .o_mode(w_mode)
    );

    // clock generation
    always #5 clk = ~clk;

    // scenario
    initial begin
        clk = 0;
        reset = 1;
        i_run_stop = 0;
        i_clear = 0;
        i_mode = 0;
        #10;
        reset = 0;

        #10;
        i_run_stop = 1;
        #10;
        i_run_stop = 0;
        #20_000_000;
        
        i_run_stop = 1;
        #10;
        i_run_stop = 0;


        i_clear = 1;
        #10;
        i_clear = 0;

        #20;
        i_run_stop = 1;
        #10;
        i_run_stop = 0;

        #20_000_000;

        i_run_stop = 1;
        #10;
        i_run_stop = 0;

        #20;
        i_mode = 1;
        #10;
        i_mode = 0;
        #20_000_000;
        $finish;
    end
endmodule

module tb_debounce_4 ();
    reg clk;
    reg reset;
    reg i_btn_L;
    reg i_btn_R;
    reg i_btn_U;
    reg i_btn_D;
    wire o_btn_L;
    wire o_btn_R;
    wire o_btn_U;
    wire o_btn_D;

    btn_debounce_4 DUT(
        .clk(clk),
        .reset(reset),
        .i_btn_L(i_btn_L),
        .i_btn_R(i_btn_R),
        .i_btn_U(i_btn_U),
        .i_btn_D(i_btn_D),
        .o_btn_L(o_btn_L),
        .o_btn_R(o_btn_R),
        .o_btn_U(o_btn_U),
        .o_btn_D(o_btn_D)
    );
    // clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        i_btn_L = 0;
        i_btn_R = 0;
        i_btn_U = 0;
        i_btn_D = 0;
        #10;
        reset = 0;
        #2000;
        i_btn_L = 1;
        #2000;
        i_btn_L = 0;
        #2000;
        i_btn_R = 1;
        #2000;
        i_btn_R = 0;
        #2000;
        i_btn_U = 1;
        #2000;
        i_btn_U = 0;
        #2000;
        i_btn_D = 1;
        #2000;
        i_btn_D = 0;
        #2000;
        $finish;
    end
endmodule


module tb_top_fnd_controller #(
    parameter MSEC_WIDTH = 7,
    parameter SEC_WIDTH  = 6,
    parameter MIN_WIDTH  = 6,
    parameter HOUR_WIDTH = 5
);
    reg                   clk;
    reg                   reset;
    reg                   i_hour_sel;
    reg                   i_min_sel;
    reg                   i_sec_sel;
    reg  [           1:0] display_mode;
    reg  [MSEC_WIDTH-1:0] msec;
    reg  [ SEC_WIDTH-1:0] sec;
    reg  [ MIN_WIDTH-1:0] min;
    reg  [HOUR_WIDTH-1:0] hour;
    wire [           3:0] fnd_com;
    wire [           7:0] fnd_data;

    // delay parameter
    parameter ms_10 = 1_000_000*10;

    // DUT instantiation
    top_fnd_controller #(
        .MSEC_WIDTH(MSEC_WIDTH),
        .SEC_WIDTH (SEC_WIDTH),
        .MIN_WIDTH (MIN_WIDTH),
        .HOUR_WIDTH(HOUR_WIDTH)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .i_hour_sel(i_hour_sel),
        .i_min_sel(i_min_sel),
        .i_sec_sel(i_sec_sel),
        .display_mode(display_mode),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    // clock generation
    always #5 clk = ~clk;

    // scenario
    initial begin
        clk = 0;
        reset = 1;
        {i_hour_sel, i_min_sel, i_sec_sel} = 3'b000;
        display_mode = 2'b00;
        {hour, sec, min, msec} = {7'd0,6'd0,6'd0,5'd0};
        #10;
        reset = 0;

        // #1 03:45:23:34 & min modify mode
        {i_hour_sel, i_min_sel, i_sec_sel} = 3'b010;
        display_mode = 2'b00; 
        {hour, sec, min, msec} = {5'd3,6'd45,6'd23,7'd34};
        # ms_10;

        display_mode = 2'b01;
        # ms_10;

        display_mode = 2'b10;
        # ms_10;

        display_mode = 2'b11;
        # ms_10;

        // #2 16:59:48:89 & hour modify mode
        {i_hour_sel, i_min_sel, i_sec_sel} = 3'b100;
        display_mode = 2'b00; 
        {hour, sec, min, msec} = {5'd16,6'd59,6'd48,7'd89};
        # ms_10;

        display_mode = 2'b01;
        # ms_10;

        display_mode = 2'b10;
        # ms_10;

        display_mode = 2'b11;
        # ms_10;
        $stop;
    end

endmodule

//////////

module tb_demux_2x1 #(
    parameter BIT_NUM = 4
);
    reg [BIT_NUM -1 : 0] i_in;
    reg i_sel;
    wire [BIT_NUM-1:0] o_out0;
    wire [BIT_NUM-1:0] o_out1;

    // DUT instantiation 
    demux_1x2 #(
        .BIT_NUM(BIT_NUM)
    ) DUT (
        .i_in  (i_in),
        .i_sel (i_sel),
        .o_out0(o_out0),
        .o_out1(o_out1)
    );

    // scenario
    initial begin
        i_in  = 4'b0101;
        i_sel = 1'b0;
        #10;

        i_in = 4'b1010;
        #10;

        i_sel = 1'b1;
        #10;

        i_in = 4'b0101;
        #10;
        $stop;
    end
endmodule

module tb_tick_gen_100hz();
    reg clk;
    reg reset;
    wire o_tick;
    tick_gen_100hz DUT(
        .clk(clk),
        .reset(reset),
        .o_tick(o_tick)
    );
    always #5 clk = ~clk;
    initial begin
        clk = 0;
        reset = 1;
        #10;
        reset = 0;
        #100_000_000;
        $finish;
    end
endmodule