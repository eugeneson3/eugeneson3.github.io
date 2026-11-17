`timescale 1ns / 1ps
module watch_control_unit (
    input  clk,
    input  reset,
    input  i_change_L,
    input  i_change_R,
    output o_hour_sel,
    output o_min_sel,
    output o_sec_sel
);

    // state parameter
    parameter NORMAL = 0, HOUR = 1, MIN = 2, SEC = 3;

    // register
    reg [1:0] c_state;
    reg [1:0] n_state;
    reg reg_hour_sel, reg_min_sel, reg_sec_sel, next_hour_sel, next_min_sel, next_sec_sel;


    // output assign
    assign {o_hour_sel, o_min_sel, o_sec_sel} = {reg_hour_sel, reg_min_sel, reg_sec_sel};


    // c_state(Sequential Logic)
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= 0;
        end else begin
            c_state <= n_state;
        end
    end

    // n_state(Combinational Logic)
    always @(c_state or {i_change_L, i_change_R
    })
    begin
        n_state = c_state;
        case (c_state)
            NORMAL: begin
                if (i_change_R) n_state = HOUR;
                else if (i_change_L) n_state = SEC;
            end
            HOUR: begin
                if (i_change_R) n_state = MIN;
                else if (i_change_L) n_state = NORMAL;
            end
            MIN: begin
                if (i_change_R) n_state = SEC;
                else if (i_change_L) n_state = HOUR;
            end
            SEC : begin
                    if (i_change_R) n_state = NORMAL;
                else if (i_change_L) n_state = MIN ;
            end
        endcase
    end

    // output reg (Sequential Logic)
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            reg_hour_sel<= 1'b0;
            reg_min_sel<= 1'b0;
            reg_sec_sel<= 1'b0;
        end else begin
            reg_hour_sel<= next_hour_sel;
            reg_min_sel<= next_min_sel;
            reg_sec_sel<= next_sec_sel;
        end
    end

    // output next (Combinational Logic)
    always @(c_state) begin
        next_hour_sel=reg_hour_sel;
        next_min_sel=reg_min_sel;
        next_sec_sel=reg_sec_sel;
        case (c_state)
            NORMAL: begin
                next_hour_sel=1'b0;
                next_min_sel=1'b0;
                next_sec_sel=1'b0;
            end
            HOUR: begin
                next_hour_sel=1'b1;
                next_min_sel=1'b0;
                next_sec_sel=1'b0;
            end
            MIN: begin
                next_hour_sel=1'b0;
                next_min_sel=1'b1;
                next_sec_sel=1'b0;
            end
            SEC: begin
                next_hour_sel=1'b0;
                next_min_sel=1'b0;
                next_sec_sel=1'b1;
            end
        endcase
    end
endmodule
