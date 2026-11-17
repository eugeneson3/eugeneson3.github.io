`timescale 1ns / 1ps
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
