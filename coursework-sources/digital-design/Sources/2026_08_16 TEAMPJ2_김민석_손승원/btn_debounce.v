`timescale 1ns / 1ps
module btn_debounce_4 (
	input clk,
	input reset,
	input i_btn_L,
	input i_btn_R,
	input i_btn_U,
	input i_btn_D,
	output o_btn_L,
	output o_btn_R,
	output o_btn_U,
	output o_btn_D
);

	// btn_debouncer instantiation
	btn_debounce U_BTN_DEBOUNCE_L (
        .clk  (clk),
        .reset(reset),
        .i_btn(i_btn_L),
        .o_btn(o_btn_L)
    );
    btn_debounce U_BTN_DEBOUNCE_R (
        .clk  (clk),
        .reset(reset),
        .i_btn(i_btn_R),
        .o_btn(o_btn_R)
    );
    btn_debounce U_BTN_DEBOUNCE_U (
        .clk  (clk),
        .reset(reset),
        .i_btn(i_btn_U),
        .o_btn(o_btn_U)
    );
    btn_debounce U_BTN_DEBOUNCE_D (
        .clk  (clk),
        .reset(reset),
        .i_btn(i_btn_D),
        .o_btn(o_btn_D)
    );
endmodule

///////////////////////////

module btn_debounce (
    input  clk,
    input  reset,
    input  i_btn,
    output o_btn
);

    // parameter
    parameter CLKDIV_COUNT_BIT = $clog2(500);

    // register
    reg [5:0] q_reg;  // 10bit shift register SIPO
    wire debounce;  // output of 8 input AND gate
    reg debounce_z;  // 1 delay signal
    reg clk_100khz;  // register for 100kHz clk
    reg [CLKDIV_COUNT_BIT-1 : 0] counter_clk_div; // register for clk_div counter

    // clock divider to 100kHz
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_100khz <= 1'b0;
            counter_clk_div <= 0;
        end else begin
            if (counter_clk_div == 500 - 1) begin
                clk_100khz <= ~clk_100khz;
                counter_clk_div <= 0;
            end else begin
                counter_clk_div <= counter_clk_div + 1;
            end
        end
    end

    // SIPO
    always @(posedge clk_100khz or posedge reset) begin
        if (reset) q_reg <= 6'b0;
        else q_reg <= {q_reg[4:0], i_btn};
    end

    // AND reduce
    assign debounce = &q_reg;

    // tick
    always @(posedge clk or posedge reset) begin
        if (reset) debounce_z <= 1'b0;
        else debounce_z <= debounce;
    end

    // o_btn operation
    assign o_btn = debounce & (~debounce_z);

endmodule
