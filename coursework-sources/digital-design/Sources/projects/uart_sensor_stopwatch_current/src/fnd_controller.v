`timescale 1ns / 1ps
module top_fnd_controller #(
    parameter MSEC_WIDTH = 7,
    parameter SEC_WIDTH  = 6,
    parameter MIN_WIDTH  = 6,
    parameter HOUR_WIDTH = 5,
    parameter HUMID_WIDTH = 16,
    parameter TEMP_WIDTH = 16
) (
    input clk,
    input reset,
    input i_hour_sel,
    input i_min_sel,
    input i_sec_sel,
    input [4:0] display_mode,
    input [HUMID_WIDTH-1:0] humidity,
    input [TEMP_WIDTH-1:0] temperature,
    input [8:0] distance,
    input [MSEC_WIDTH-1:0] msec,
    input [SEC_WIDTH-1:0] sec,
    input [MIN_WIDTH-1:0] min,
    input [HOUR_WIDTH-1:0] hour,
    input [1:0] sw,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    // wire
    wire [3:0] w_msec_digit_1, w_msec_digit_10;

    wire [3:0] w_sec_digit_1, w_sec_digit_10;
    wire [3:0] w_sec_digit_1_mux_out, w_sec_digit_10_mux_out;

    wire [3:0] w_min_digit_1, w_min_digit_10;
    wire [3:0] w_min_digit_1_mux_out, w_min_digit_10_mux_out;

    wire [3:0] w_hour_digit_1, w_hour_digit_10;
    wire [3:0] w_hour_digit_1_mux_out, w_hour_digit_10_mux_out;

    wire [3:0] w_humidity_digit_1, w_humidity_digit_10;
    wire [3:0] w_humidity_digit_100, w_humidity_digit_1000;
    wire [3:0] w_humidity_frac_1, w_humidity_frac_10;

    wire [3:0] w_temperature_digit_1, w_temperature_digit_10;
    wire [3:0] w_temperature_digit_100, w_temperature_digit_1000;
    wire [3:0] w_temperature_frac_1, w_temperature_frac_10;
    wire [3:0] w_distance_digit_1, w_distance_digit_10;
    wire [3:0] w_distance_digit_100, w_distance_digit_1000;
    wire [3:0] w_humidity;
    wire [3:0] w_temperature;


    wire [3:0] w_msec_sec, w_min_hour;
    wire [3:0] w_bcd1, w_bcd2;
    wire [2:0] w_digit_sel;
    wire w_1khz;
    wire w_dot_onoff;
    wire w_onoff_hour, w_onoff_min, w_onoff_sec;

    // assignment
    assign {w_onoff_hour, w_onoff_min, w_onoff_sec} = {i_hour_sel, i_min_sel, i_sec_sel} 
                                                    & {3{w_dot_onoff}} 
                                                    & {3{display_mode[1]}};

    // clk_div instantiation
    clk_div U_CLK_DIV (
        .clk(clk),
        .reset(reset),
        .o_1khz(w_1khz)
    );


    // counter_8 instantiation
    counter_8 U_COUNTER_8 (
        .clk      (w_1khz),
        .reset    (reset),
        .digit_sel(w_digit_sel)
    );


    // digit_splitter instantiation
    digit_splitter #(
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_DIGIT_SPLITER_MSEC (
        .ds_in(msec),
        .digit_1(w_msec_digit_1),
        .digit_10(w_msec_digit_10)
    );
    digit_splitter #(
        .BIT_WIDTH(SEC_WIDTH)
    ) U_DIGIT_SPLITER_SEC (
        .ds_in(sec),
        .digit_1(w_sec_digit_1),
        .digit_10(w_sec_digit_10)
    );
    digit_splitter #(
        .BIT_WIDTH(MIN_WIDTH)
    ) U_DIGIT_SPLITER_MIN (
        .ds_in(min),
        .digit_1(w_min_digit_1),
        .digit_10(w_min_digit_10)
    );
    digit_splitter #(
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_DIGIT_SPLITER_HOUR (
        .ds_in(hour),
        .digit_1(w_hour_digit_1),
        .digit_10(w_hour_digit_10)
    );
    digit_splitter #(
        .BIT_WIDTH(HUMID_WIDTH)
    ) U_DIGIT_SPLITER_HUMID_INT (
        .ds_in(humidity[15:8]),
        .digit_1(w_humidity_digit_1),
        .digit_10(w_humidity_digit_10),
        .digit_100(w_humidity_digit_100),
        .digit_1000(w_humidity_digit_1000)
    );
    digit_splitter #(
        .BIT_WIDTH(8)
    ) U_DIGIT_SPLITER_HUMID_FRAC (
        .ds_in(humidity[7:0]),
        .digit_1(w_humidity_frac_1),
        .digit_10(w_humidity_frac_10),
        .digit_100(),
        .digit_1000()
    );

    digit_splitter #(
        .BIT_WIDTH(TEMP_WIDTH)
    ) U_DIGIT_SPLITER_TEMP_INT (
        .ds_in(temperature[15:8]),
        .digit_1(w_temperature_digit_1),
        .digit_10(w_temperature_digit_10),
        .digit_100(w_temperature_digit_100),
        .digit_1000(w_temperature_digit_1000)
    );
    digit_splitter #(
        .BIT_WIDTH(8)
    ) U_DIGIT_SPLITER_TEMP_FRAC (
        .ds_in(temperature[7:0]),
        .digit_1(w_temperature_frac_1),
        .digit_10(w_temperature_frac_10),
        .digit_100(),
        .digit_1000()
    );

    digit_splitter #(
        .BIT_WIDTH(9)
    ) U_DIGIT_SPLITER_DISTANCE (
        .ds_in(distance),
        .digit_1(w_distance_digit_1),
        .digit_10(w_distance_digit_10),
        .digit_100(w_distance_digit_100),
        .digit_1000(w_distance_digit_1000)
    );


    // comparator_dot instantiation
    comparator_dot #(
        .MSEC_WIDTH(MSEC_WIDTH)
    ) U_COMPARATOR_DOT (
        .msec(msec),
        .dot_onoff(w_dot_onoff)
    );

    // mux_2x1 for fnd flicker instantiation
    mux_2x1 U_MUX_2x1_HOUR_DIGIT1 (
        .sel(w_onoff_hour),  
        .in0(w_hour_digit_1),
        .in1(4'hF),
        .mux_out(w_hour_digit_1_mux_out)
    );
    mux_2x1 U_MUX_2x1_HOUR_DIGIT10 (
        .sel(w_onoff_hour),  
        .in0(w_hour_digit_10),
        .in1(4'hF),
        .mux_out(w_hour_digit_10_mux_out)
    );
    mux_2x1 U_MUX_2x1_MIN_DIGIT1 (
        .sel(w_onoff_min),  
        .in0(w_min_digit_1),
        .in1(4'hF),
        .mux_out(w_min_digit_1_mux_out)
    );
    mux_2x1 U_MUX_2x1_MIN_DIGIT10 (
        .sel(w_onoff_min),  
        .in0(w_min_digit_10),
        .in1(4'hF),
        .mux_out(w_min_digit_10_mux_out)
    );
    mux_2x1 U_MUX_2x1_SEC_DIGIT1 (
        .sel(w_onoff_sec),  
        .in0(w_sec_digit_1),
        .in1(4'hF),
        .mux_out(w_sec_digit_1_mux_out)
    );
    mux_2x1 U_MUX_2x1_SEC_DIGIT10 (
        .sel(w_onoff_sec),  
        .in0(w_sec_digit_10),
        .in1(4'hF),
        .mux_out(w_sec_digit_10_mux_out)
    );

    // mux_8x1 instantiation
    mux_8x1 U_MUX_8x1_MSEC_SEC (
        .sel(w_digit_sel),
        .in0(w_msec_digit_1),
        .in1(w_msec_digit_10),
        .in2(w_sec_digit_1_mux_out),
        .in3(w_sec_digit_10_mux_out),
        .in4(4'hF),
        .in5(4'hF),
        .in6({3'b111, w_dot_onoff}),
        .in7(4'hF),
        .mux_out(w_msec_sec)
    );
    mux_8x1 U_MUX_8x1_MIN_HOUR (
        .sel(w_digit_sel),
        .in0(w_min_digit_1_mux_out),
        .in1(w_min_digit_10_mux_out),
        .in2(w_hour_digit_1_mux_out),
        .in3(w_hour_digit_10_mux_out),
        .in4(4'hF),
        .in5(4'hF),
        .in6({3'b111, w_dot_onoff}),
        .in7(4'hF),
        .mux_out(w_min_hour)
    );
    mux_8x1 U_MUX_8x1_HUMIDITY (
        .sel(w_digit_sel),
        .in0(w_humidity_frac_1),
        .in1(w_humidity_frac_10),
        .in2(w_humidity_digit_1),
        .in3(w_humidity_digit_10),
        .in4(4'hF),
        .in5(4'hF),
        .in6(4'b1110),
        .in7(4'hF),
        .mux_out(w_humidity)
    );
    mux_8x1 U_MUX_8x1_TEMPERATURE (
        .sel(w_digit_sel),
        .in0(w_temperature_frac_1),
        .in1(w_temperature_frac_10),
        .in2(w_temperature_digit_1),
        .in3(w_temperature_digit_10),
        .in4(4'hF),
        .in5(4'hF),
        .in6(4'b1110),
        .in7(4'hF),
        .mux_out(w_temperature)
    );

    wire [3:0] w_distance;
    mux_8x1 U_MUX_8x1_DISTANCE (
        .sel(w_digit_sel),
        .in0(w_distance_digit_1),
        .in1(w_distance_digit_10),
        .in2(w_distance_digit_100),
        .in3(w_distance_digit_1000),
        .in4(4'hF),
        .in5(4'hF),
        .in6(4'hF),
        .in7(4'hF),
        .mux_out(w_distance)
    );


    // mux 2x1 for final instantiation
    mux_2x1 U_MUX_2x1_FINAL1 (
        .sel(display_mode[0]),
        .in0(w_msec_sec),
        .in1(w_min_hour),
        .mux_out(w_bcd1)

    );
    assign w_bcd2 = display_mode[4] ? w_distance :
                    display_mode[3] ? w_humidity :
                    display_mode[2] ? w_temperature : w_bcd1;

    // bcd instantiation
    bcd U_BCD (
        .bcd_in (w_bcd2),
        .bcd_out(fnd_data)
    );

    // decoder_2x4 instantiation
    decoder_2x4 U_DECODER_2x4 (
        .digit_sel(w_digit_sel[1:0]),
        .fnd_com  (fnd_com)
    );

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module clk_div (
    input  clk,
    input  reset,
    output o_1khz
);

    reg [15:0] counter_reg;
    reg clk_reg;

    assign o_1khz = clk_reg;

    // sequential logic
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 16'b0;
            clk_reg <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == (50000 - 1)) begin // counter_reg == (N-1) -> 2N divdier
                counter_reg <= 0;
                clk_reg <= ~clk_reg;
            end
        end
    end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module counter_8 (
    input clk,
    input reset,
    output [2:0] digit_sel
);
    // register
    reg [2:0] counter_reg;

    // assignment
    assign digit_sel = counter_reg;

    // Sequential Logic
    always @(posedge clk, posedge reset) begin  // asynchronized reset
        if (reset) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_reg + 1;
        end

    end


endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input [(BIT_WIDTH - 1):0] ds_in,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);
    assign digit_1  = ds_in % 10;
    assign digit_10 = (ds_in / 10) % 10;
    assign digit_100 = (ds_in / 100) % 10;
    assign digit_1000 = (ds_in / 1000) % 10;

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module comparator_dot #(
    parameter MSEC_WIDTH = 7
) (
    input [MSEC_WIDTH - 1 : 0] msec,
    output dot_onoff
);
    //assignment
    assign dot_onoff = (msec < 50) ? 0 : 1;
endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module mux_8x1 (
    // input
    input [2:0] sel,  // mux selection
    input [3:0] in0,
    input [3:0] in1,
    input [3:0] in2,
    input [3:0] in3,
    input [3:0] in4,
    input [3:0] in5,
    input [3:0] in6,
    input [3:0] in7,
    // output
    output [3:0] mux_out
);

    // register
    reg [3:0] mux_reg;

    // assignment
    assign mux_out = mux_reg;

    // Combinational Logic
    always @(*) begin
        case (sel)
            3'b000:  mux_reg = in0;
            3'b001:  mux_reg = in1;
            3'b010:  mux_reg = in2;
            3'b011:  mux_reg = in3;
            3'b100:  mux_reg = in4;
            3'b101:  mux_reg = in5;
            3'b110:  mux_reg = in6;
            3'b111:  mux_reg = in7;
            default: mux_reg = in0;
        endcase
    end

endmodule

///////////////////////////////////////////////////////////////////////////

module mux_4x1 (
    input [1:0] sel,  // mux selection
    input [3:0] in0,
    input [3:0] in1,
    input [3:0] in2,
    input [3:0] in3,
    output [3:0] mux_out

);
    // assignment
    assign mux_out = (sel == 2'b00) ? in0 : 
                      (sel == 2'b01) ? in1 : 
                      (sel == 2'b10) ? in2 : in3;
endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////
module mux_3x1 (
    input [1:0] sel,
    input [3:0] in0,
    input [3:0] in1,
    input [3:0] in2,
    output [3:0] mux_out
);
    // assignment
    assign mux_out = (sel == 2'b00) ? in0 :  // humidity off, temp off, stopwatch/watch on when sw[0]|sw[1] = 0
                     (sel == 2'b01) ? in1 :  // humidity off, temp on, stopwatch off when sw[0] = 1
                     (sel == 2'b10) ? in2 : 4'hF;   // Invalid display mode
endmodule


/////////////////////////////////////////////////////////////////////////////////////////////////////////

module mux_2x1 (
    input sel,  // mux selection
    input [3:0] in0,
    input [3:0] in1,
    output [3:0] mux_out

);
    // assignment
    assign mux_out = (sel) ? in1 : in0;
endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module bcd (
    input [3:0] bcd_in,
    output reg [7:0] bcd_out

);

    always @(bcd_in) begin
        case (bcd_in)
            4'b0000: bcd_out = 8'hC0;  //0
            4'b0001: bcd_out = 8'hF9;  // 1
            4'b0010: bcd_out = 8'hA4;  // 2
            4'b0011: bcd_out = 8'hB0;  // 3  
            4'b0100: bcd_out = 8'h99;  // 4
            4'b0101: bcd_out = 8'h92;  // 5
            4'b0110: bcd_out = 8'h82;  // 6
            4'b0111: bcd_out = 8'hF8;  // 7
            4'b1000: bcd_out = 8'h80;  // 8
            4'b1001: bcd_out = 8'h90;  // 9
            //4'b1010: bcd_out = 8'h88;  // 10
            //4'b1011: bcd_out = 8'h83;  // 11
            //4'b1100: bcd_out = 8'hC6;  // 12
            //4'b1101: bcd_out = 8'hA1;  // 13
            4'b1110: bcd_out = 8'h7F;  // dot display
            4'b1111: bcd_out = 8'hFF;  // dot un-display
            default: bcd_out = 8'h8E;  // default value
        endcase
    end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////

module decoder_2x4 (
    input [1:0] digit_sel,
    output reg [3:0] fnd_com
);

    always @(digit_sel) begin
        case (digit_sel)
            2'b00:   fnd_com = 4'b1110;  // digit 1
            2'b01:   fnd_com = 4'b1101;  // digit 10
            2'b10:   fnd_com = 4'b1011;  // digit 100
            2'b11:   fnd_com = 4'b0111;  // digit 1000
            default: fnd_com = 4'b1110;  // default value
        endcase
    end

endmodule


