`timescale 1ns / 1ps

module debounce (
    input  clk,
    input  reset,
    input  btn_L,
    input  btn_U,
    input  btn_R,
    input  btn_D,
    output o_btn_L,
    output o_btn_U,
    output o_btn_R,
    output o_btn_D
);


    btn_debounce U_BD_L (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_L),
        .o_btn(o_btn_L)
    );

    btn_debounce U_BD_U (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_U),
        .o_btn(o_btn_U)
    );

    btn_debounce U_BD_R (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_R),
        .o_btn(o_btn_R)
    );

    btn_debounce U_BD_D (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_D),
        .o_btn(o_btn_D)
    );
endmodule

module btn_debounce (
    input  clk,
    input  reset,
    input  i_btn,
    output o_btn
);

    reg  [           7:0] q_reg;  //8tab shift register SIPO
    wire                  debounce;  // output of 8 input AND gat
    reg                   edge_reg;

    reg  [$clog2(50)-1:0] counter_reg;
    reg                   o_1MHz;

    // clock div : 100MHz -> 1MHz
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            o_1MHz <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == (50 - 1)) begin
                counter_reg <= 0;
                o_1MHz      <= ~o_1MHz;
            end
        end
    end

    // 8bit shift register SIPO
    always @(posedge o_1MHz, posedge reset) begin
        if (reset) begin
            q_reg <= 8'h00;
        end else begin
            // q_reg <= {q_reg[6:0], i_btn}; // shift left
            q_reg <= {i_btn, q_reg[7:1]};  // shift right
        end
    end

    // 8bit input AND gate
    assign debounce = &q_reg;

    // 1clock delay by debounce
    always @(posedge clk, posedge reset) begin
        if (reset) edge_reg <= 1'b0;
        else begin
            edge_reg <= debounce;
        end
    end

    // edge detection
    assign o_btn = debounce & (~edge_reg);

endmodule
