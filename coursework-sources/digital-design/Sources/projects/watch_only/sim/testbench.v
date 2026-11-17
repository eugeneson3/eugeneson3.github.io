`timescale 1ns / 1ps
module tb_top_watch #(
    parameter MSEC_WIDTH = 7,
    parameter SEC_WIDTH  = 6,
    parameter MIN_WIDTH  = 6,
    parameter HOUR_WIDTH = 5
);
    reg clk;
    reg reset;
    reg btn_L;  // HMS change L
    reg btn_R;  // HMS change R
    reg btn_U;  // Count Up
    reg btn_D;  // Count Down
    reg [1:0] sw;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire [1:0] led;

    // DUT instantiation
    top_watch #(
        .MSEC_WIDTH(MSEC_WIDTH),
        .SEC_WIDTH (SEC_WIDTH),
        .MIN_WIDTH (MIN_WIDTH),
        .HOUR_WIDTH(HOUR_WIDTH)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .btn_L(btn_L),
        .btn_R(btn_R),
        .btn_U(btn_U),
        .btn_D(btn_D),
        .sw(sw),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .led(led)
    );
    // Delay parameter
    parameter us_10 = 1_000 * 10;
    parameter ms_10 = 1_000_000 * 10;


    // clk generation
    always #5 clk = ~clk;

    // integer delclaration for loop
    integer i;

    // scenario
    initial begin
        clk = 0;
        reset = 1;
        sw = 2'b00;
        {btn_L, btn_R, btn_U, btn_D} = 4'b0000;
        #10;
        reset = 0;

        // #1 Hour Down Count
        {btn_L, btn_R, btn_U, btn_D} = 4'b0100;
        #(20 * us_10);

        for (i = 0; i < 13; i = i + 1) begin
            {btn_L, btn_R, btn_U, btn_D} = 4'b0001;
            #(20 * us_10);

            {btn_L, btn_R, btn_U, btn_D} = 4'b0000;
            #ms_10;
        end

        // #2 Min Down Count
        {btn_L, btn_R, btn_U, btn_D} = 4'b0100;
        #(20 * us_10);

        for (i = 0; i < 11; i = i + 1) begin
            {btn_L, btn_R, btn_U, btn_D} = 4'b0001;
            #(20 * us_10);

            {btn_L, btn_R, btn_U, btn_D} = 4'b0000;
            #ms_10;
        end

        // #3 Sec Down Count
        {btn_L, btn_R, btn_U, btn_D} = 4'b0100;
        #(20 * us_10);

        for (i = 0; i < 11; i = i + 1) begin
            {btn_L, btn_R, btn_U, btn_D} = 4'b0001;
            #(20 * us_10);

            {btn_L, btn_R, btn_U, btn_D} = 4'b0000;
            #ms_10;
        end

        // #4 Hour Up Count
        sw = 2'b11;

        {btn_L, btn_R, btn_U, btn_D} = 4'b1000;
        #(20 * us_10);

        {btn_L, btn_R, btn_U, btn_D} = 4'b0000;
        #(20 * us_10);

        {btn_L, btn_R, btn_U, btn_D} = 4'b1000;
        #(20 * us_10);

        for (i = 0; i < 2; i = i + 1) begin
            {btn_L, btn_R, btn_U, btn_D} = 4'b0010;
            #(20 * us_10);

            {btn_L, btn_R, btn_U, btn_D} = 4'b0000;
            #ms_10;
        end

        // #5 Min Up Count
        {btn_L, btn_R, btn_U, btn_D} = 4'b0100;
        #(20 * us_10);

        for (i = 0; i < 11; i = i + 1) begin
            {btn_L, btn_R, btn_U, btn_D} = 4'b0010;
            #(20 * us_10);

            {btn_L, btn_R, btn_U, btn_D} = 4'b0000;
            #ms_10;
        end

        // #6 Sec Up Count
        {btn_L, btn_R, btn_U, btn_D} = 4'b0100;
        #(20 * us_10);

        for (i = 0; i < 11; i = i + 1) begin
            {btn_L, btn_R, btn_U, btn_D} = 4'b0010;
            #(20 * us_10);

            {btn_L, btn_R, btn_U, btn_D} = 4'b0000;
            #ms_10;
        end
        $stop;
    end
endmodule

//////////

module tb_watch_datatpath #(
    parameter MSEC_WIDTH = 7,
    parameter SEC_WIDTH  = 6,
    parameter MIN_WIDTH  = 6,
    parameter HOUR_WIDTH = 5
);
    reg                      clk;
    reg                      reset;
    reg                      i_hour_sel;
    reg                      i_min_sel;
    reg                      i_sec_sel;
    reg                      i_btn_U;
    reg                      i_btn_D;
    wire [   MSEC_WIDTH-1:0] msec;
    wire [ SEC_WIDTH -1 : 0] sec;
    wire [  MIN_WIDTH-1 : 0] min;
    wire [HOUR_WIDTH -1 : 0] hour;

    // Delay parameter
    parameter us_10 = 1_000 * 10;
    parameter ms_10 = 1_000_000 * 10;

    // DUT instantiation
    watch_datapath #(
        .MSEC_WIDTH(MSEC_WIDTH),
        .SEC_WIDTH (SEC_WIDTH),
        .MIN_WIDTH (MIN_WIDTH),
        .HOUR_WIDTH(HOUR_WIDTH)
    ) DUT (
        .clk       (clk),
        .reset     (reset),
        .i_hour_sel(i_hour_sel),
        .i_min_sel (i_min_sel),
        .i_sec_sel (i_sec_sel),
        .i_btn_U   (i_btn_U),
        .i_btn_D   (i_btn_D),
        .msec      (msec),
        .sec       (sec),
        .min       (min),
        .hour      (hour)
    );

    // clk generation
    always #5 clk = ~clk;

    // integer delclaration for loop
    integer i;

    // scenario
    initial begin
        clk = 0;
        reset = 1;
        i_hour_sel = 0;
        i_min_sel = 0;
        i_sec_sel = 0;
        i_btn_U = 0;
        i_btn_D = 0;
        #10;
        reset = 0;

        // #1 Hour Down Count
        {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b10000;
        #ms_10;

        for (i = 0; i < 13; i = i + 1) begin
            {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b10001;
            #10;

            {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b10000;
            #ms_10;
        end

        // #2 Min Down Count
        {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b01000;
        #ms_10;

        for (i = 0; i < 11; i = i + 1) begin
            {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b01001;
            #10;

            {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b01000;
            #ms_10;
        end

        // #3 Sec Down Count
        {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b00100;
        #ms_10;

        for (i = 0; i < 11; i = i + 1) begin
            {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b00101;
            #10;

            {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b00100;
            #ms_10;
        end

        // #4 Hour Up Count
        {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b10000;
        #ms_10;

        for (i = 0; i < 2; i = i + 1) begin
            {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b10010;
            #10;

            {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b10000;
            #ms_10;
        end

        // #5 Min Up Count
        {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b01000;
        #ms_10;

        for (i = 0; i < 11; i = i + 1) begin
            {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b01010;
            #10;

            {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b01000;
            #ms_10;
        end

        // #6 Sec Up Count
        {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b00100;
        #ms_10;

        for (i = 0; i < 11; i = i + 1) begin
            {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b00110;
            #10;

            {i_hour_sel, i_min_sel, i_sec_sel, i_btn_U, i_btn_D} = 5'b00100;
            #ms_10;
        end
        $stop;
    end


endmodule

//////////

module tb_watch_control_unit;
    reg  clk;
    reg  reset;
    reg  i_change_L;
    reg  i_change_R;
    wire o_hour_sel;
    wire o_min_sel;
    wire o_sec_sel;

    // DUT instantiation
    watch_control_unit DUT (
        .clk(clk),
        .reset(reset),
        .i_change_L(i_change_L),
        .i_change_R(i_change_R),
        .o_hour_sel(o_hour_sel),
        .o_min_sel(o_min_sel),
        .o_sec_sel(o_sec_sel)
    );

    // clk generation
    always #5 clk = ~clk;

    // scenario
    initial begin
        clk = 0;
        reset = 1;
        i_change_L = 0;
        i_change_R = 0;
        #10;
        reset = 0;

        // #1 NORMAL -> HOUR
        i_change_R = 1;
        #10;
        i_change_R = 0;
        #50;

        // #2 HOUR ->MIN
        i_change_R = 1;
        #10;
        i_change_R = 0;
        #50;

        // #3 MIN -> SEC
        i_change_R = 1;
        #10;
        i_change_R = 0;
        #50;

        // #4 SEC -> NORMAL
        i_change_R = 1;
        #10;
        i_change_R = 0;
        #50;

        // #5 NORMAL->SEC
        i_change_L = 1;
        #10;
        i_change_L = 0;
        #50;

        // #6 SEC->MIN
        i_change_L = 1;
        #10;
        i_change_L = 0;
        #50;


        // #7 MIN->HOUR
        i_change_L = 1;
        #10;
        i_change_L = 0;
        #50;


        // #8 HOUR->NORMAL
        i_change_L = 1;
        #10;
        i_change_L = 0;
        #50;
        $stop;



    end

endmodule
