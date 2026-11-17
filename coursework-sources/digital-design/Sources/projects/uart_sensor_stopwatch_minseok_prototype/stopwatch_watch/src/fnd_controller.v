`timescale 1ns / 1ps

module fnd_controller #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input                   clk,
    input                   reset,
    input  [MSEC_WIDTH-1:0] msec,
    input  [ SEC_WIDTH-1:0] sec,
    input  [ MIN_WIDTH-1:0] min,
    input  [HOUR_WIDTH-1:0] hour,
    input                   display_mode,
    output [           3:0] fnd_com,
    output [           7:0] fnd_data
);

    wire [3:0] bcd;
    wire [2:0] w_digit_sel;
    wire w_1kHz;
    wire [3:0] w_msec_sec, w_min_hour;
    wire [3:0] w_msec_digit_1, w_msec_digit_10;
    wire [3:0] w_sec_digit_1, w_sec_digit_10;
    wire [3:0] w_min_digit_1, w_min_digit_10;
    wire [3:0] w_hour_digit_1, w_hour_digit_10;
    wire w_dot_onoff;

    clk_div U_CLK_DIV (
        .clk   (clk),
        .reset (reset),
        .o_1kHz(w_1kHz)
    );

    counter_8 U_COUNTER_8 (
        .clk      (w_1kHz),
        .reset    (reset),
        .digit_sel(w_digit_sel)
    );

    decoder_2x4 U_DECODER_2x4 (
        .digit_sel(w_digit_sel[1:0]),  // recommend
        .fnd_com  (fnd_com)
    );

    comparator_dot U_COMP_DOT (
        .msec     (msec),
        .dot_onoff(w_dot_onoff)
    );

    digit_splitter #(
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_DIGIT_SPLITTER_MSEC (
        .ds_in(msec),
        .digit_1(w_msec_digit_1),
        .digit_10(w_msec_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(SEC_WIDTH)
    ) U_DIGIT_SPLITTER_SEC (
        .ds_in(sec),
        .digit_1(w_sec_digit_1),
        .digit_10(w_sec_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(MIN_WIDTH)
    ) U_DIGIT_SPLITTER_MIN (
        .ds_in(min),
        .digit_1(w_min_digit_1),
        .digit_10(w_min_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_DIGIT_SPLITTER_HOUR (
        .ds_in(hour),
        .digit_1(w_hour_digit_1),
        .digit_10(w_hour_digit_10)
    );

    mux_8x1 U_MUX_8x1_MSEC_SEC (
        .sel    (w_digit_sel),
        .in_0   (w_msec_digit_1),
        .in_1   (w_msec_digit_10),
        .in_2   (w_sec_digit_1),
        .in_3   (w_sec_digit_10),
        .in_4   (4'hf),
        .in_5   (4'hf),
        .in_6   ({3'b111, w_dot_onoff}),
        .in_7   (4'hf),
        .mux_out(w_msec_sec)
    );

    mux_8x1 U_MUX_8x1_MIN_HOUR (
        .sel    (w_digit_sel),
        .in_0   (w_min_digit_1),
        .in_1   (w_min_digit_10),
        .in_2   (w_hour_digit_1),
        .in_3   (w_hour_digit_10),
        .in_4   (4'hf),
        .in_5   (4'hf),
        .in_6   ({3'b111, w_dot_onoff}),
        .in_7   (4'hf),
        .mux_out(w_min_hour)
    );

    mux_2x1 U_MUX_2x1 (
        .sel    (display_mode),
        .in_0   (w_msec_sec),
        .in_1   (w_min_hour),
        .mux_out(bcd)
    );

    bcd U_BCD (
        .bcd_in (bcd),
        .bcd_out(fnd_data)
    );

endmodule

module comparator_dot #(
    parameter MSEC_WIDTH = 7
) (
    input [MSEC_WIDTH-1:0] msec,
    output dot_onoff
);

    assign dot_onoff = (msec < 50);

endmodule

module clk_div (
    input  clk,
    input  reset,
    output o_1kHz
);

    reg [15:0] counter_reg;
    reg clk_reg;

    assign o_1kHz = clk_reg;

    // sequential logic
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;  // same timing for all module
            clk_reg <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == (50000 - 1)) begin
                counter_reg <= 0;
                clk_reg     <= ~clk_reg;
            end
        end
    end

endmodule

module counter_8 (
    input        clk,
    input        reset,
    output [2:0] digit_sel
);

    reg [2:0] counter_reg;  // 8digit - 3bit, reg in always

    assign digit_sel = counter_reg;  // len 0 wire

    // sequential logic : SL
    always @(posedge clk, posedge reset) begin  // rising edge
        if (reset) begin
            counter_reg <= 0;
        end else begin
            // operation
            counter_reg <= counter_reg + 1;  // 2bit
        end
    end

endmodule

module decoder_2x4 (
    input      [1:0] digit_sel,
    output reg [3:0] fnd_com
);

    always @(digit_sel) begin
        case (digit_sel)
            2'b00:   fnd_com = 4'b1110;  // digit 1
            2'b01:   fnd_com = 4'b1101;  // digit 10
            2'b10:   fnd_com = 4'b1011;  // digit 100
            2'b11:   fnd_com = 4'b0111;  // digit 1000
            default: fnd_com = 4'b1110;  //default value
        endcase
    end

endmodule

module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input  [BIT_WIDTH-1:0] ds_in,
    output [          3:0] digit_1,
    output [          3:0] digit_10
);

    assign digit_1  = (ds_in) % 10;
    assign digit_10 = (ds_in / 10) % 10;

endmodule

module mux_2x1 (
    input sel,
    input [3:0] in_0,
    input [3:0] in_1,
    output [3:0] mux_out
);

    assign mux_out = (sel) ? in_1 : in_0;

endmodule


module mux_8x1 (
    input      [2:0] sel,     // mux selection
    input      [3:0] in_0,    // sel 3'b000
    input      [3:0] in_1,    // sel 3'b001
    input      [3:0] in_2,    // sel 3'b010
    input      [3:0] in_3,    // sel 3'b011
    input      [3:0] in_4,    // sel 3'b100
    input      [3:0] in_5,    // sel 3'b101
    input      [3:0] in_6,    // sel 3'b110
    input      [3:0] in_7,    // sel 3'b111
    output reg [3:0] mux_out
);

    //    // assign
    //    assign mux_out = (sel == 2'b00) ? digit_1 :  // true
    //        (sel == 2'b01) ? digit_10: 
    //                     (sel == 2'b10) ? digit_100:
    //                     (sel == 2'b11) ? digit_1000:
    //                     4'b1111; // don't use X, Z

    always @(*) begin
        case (sel)
            3'b000: mux_out = in_0;
            3'b001: mux_out = in_1;
            3'b010: mux_out = in_2;
            3'b011: mux_out = in_3;
            3'b100: mux_out = in_4;
            3'b101: mux_out = in_5;
            3'b110: mux_out = in_6;
            3'b111: mux_out = in_7;
        endcase
    end

endmodule

module bcd (
    input      [3:0] bcd_in,
    output reg [7:0] bcd_out
);

    always @(bcd_in) begin
        case (bcd_in)
            4'b0000: bcd_out = 8'hc0;  // 0
            4'b0001: bcd_out = 8'hf9;
            4'b0010: bcd_out = 8'ha4;
            4'b0011: bcd_out = 8'hb0;
            4'b0100: bcd_out = 8'h99;
            4'b0101: bcd_out = 8'h92;
            4'b0110: bcd_out = 8'h82;
            4'b0111: bcd_out = 8'hf8;
            4'b1000: bcd_out = 8'h80;
            4'b1001: bcd_out = 8'h90;
            4'b1010: bcd_out = 8'h88;  // a
            4'b1011: bcd_out = 8'h83;  // b
            4'b1100: bcd_out = 8'hc6;  // c
            4'b1101: bcd_out = 8'ha1;  // d
            4'b1110: bcd_out = 8'h7f;  // dot display on
            4'b1111: bcd_out = 8'hff;  // dot display off
        endcase
    end

endmodule

