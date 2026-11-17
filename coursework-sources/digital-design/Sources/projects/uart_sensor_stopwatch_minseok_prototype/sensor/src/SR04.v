`timescale 1ns / 1ps

module TOP_SR04 (
    input         clk,
    input         reset,
    input         btn_R,
    input         echo,
    output        trigger,
    output [15:0] led,
    output [ 3:0] fnd_com,
    output [ 7:0] fnd_data
);

    wire [8:0] w_distance;
    wire w_start, enable;


    assign led[14:0] = 0;
    assign led[15]   = enable;

    btn_debounce U_BTN_DEBOUNCE (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_R),
        .o_btn(w_start)
    );

    fnd_controller U_FND_CONTROLLER (
        .clk     (clk),
        .reset   (reset),
        .fnd_in  (w_distance),
        .fnd_com (fnd_com),
        .fnd_data(fnd_data)
    );

    SR04_controller U_SR04_CONTROLER_UNIT (
        .clk     (clk),
        .reset   (reset),
        .start   (w_start),
        .echo    (echo),
        .trigger (trigger),
        .enable  (enable),
        .distance(w_distance)
    );

endmodule


module SR04_controller (
    input        clk,
    input        reset,
    input        start,
    input        echo,
    output       trigger,
    output       enable,
    output [8:0] distance
);

    wire w_tick;

    SR04_control_unit U_SR04_CONTROL_UNIT (
        .clk     (clk),
        .reset   (reset),
        .i_tick  (w_tick),
        .i_start (start),
        .echo    (echo),
        .trigger (trigger),
        .enable  (enable),
        .distance(distance)
    );

    tick_1us U_TICK_GEN (
        .clk   (clk),
        .reset (reset),
        .o_tick(w_tick)
    );

endmodule


module SR04_control_unit (
    input        clk,
    input        reset,
    input        i_tick,
    input        i_start,
    input        echo,
    output       trigger,
    output       enable,
    output [8:0] distance
);

    localparam [2:0] STAY = 0, START = 1, TRIGGER = 2, WAIT = 3, COUNT = 4, DISTANCE = 5;

    reg enable_reg, enable_next;
    reg trigger_reg, trigger_next;
    reg [2:0] c_state, n_state;
    reg [$clog2(58*400)-1:0] tick_count_reg, tick_count_next;
    reg [8:0] distance_reg, distance_next;

   ila_0 U_ILA (
        .clk   (clk),
        .probe0(i_start),
        .probe1(trigger),
        .probe2(echo),
        .probe3(c_state)
    );

    // output CL
    assign trigger  = trigger_reg;
    assign enable   = enable_reg;
    assign distance = distance_reg;

    // state SL
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state        <= STAY;
            enable_reg     <= 0;
            trigger_reg    <= 0;
            tick_count_reg <= 0;
            distance_reg   <= 0;
        end else begin
            c_state        <= n_state;
            enable_reg     <= enable_next;
            trigger_reg    <= trigger_next;
            tick_count_reg <= tick_count_next;
            distance_reg   <= distance_next;
        end
    end

    // next CL
    always @(*) begin
        n_state         = c_state;
        enable_next     = enable_reg;
        trigger_next    = trigger_reg;
        tick_count_next = tick_count_reg;
        distance_next   = distance_reg;
        case (c_state)
            STAY: begin
                enable_next     = 1;
                tick_count_next = 0;
                if (i_start) begin
                    n_state = START;
                end
            end
            START: begin
                enable_next   = 0;
                distance_next = 0;
                if (i_tick) begin
                    n_state = TRIGGER;
                end
            end
            TRIGGER: begin
                if (i_tick) begin
                    trigger_next = 1;
                    if (tick_count_reg == 11) begin
                        trigger_next    = 0;
                        tick_count_next = 0;
                        n_state         = WAIT;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                        n_state         = TRIGGER;
                    end
                end
            end
            WAIT: begin
                if (echo) begin
                    n_state = COUNT;
                end else begin
                    n_state = WAIT;
                end
            end
            COUNT: begin
                if (!echo) begin
                    if (tick_count_reg > 18000) begin
                        n_state = STAY;
                    end else begin
                        n_state = DISTANCE;
                    end
                end else begin
                    if (i_tick) begin
                        tick_count_next = tick_count_reg + 1;
                        n_state         = COUNT;
                    end
                end
            end
            DISTANCE: begin
                distance_next = tick_count_reg / 58;
                n_state = STAY;
            end
        endcase
    end

endmodule


module tick_1us (
    input      clk,
    input      reset,
    output reg o_tick
);

    reg [6:0] count_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
            o_tick    <= 0;
        end else begin
            count_reg <= count_reg + 1;
            if (count_reg == 100 - 1) begin
                count_reg <= 0;
                o_tick    <= 1;
            end else begin
                o_tick <= 0;
            end
        end
    end

endmodule
