`timescale 1ns / 1ps
module sr04_lecture (
    input            clk,
    input            reset,
    input            start,
    input            echo,
    output reg       trigger,
    output reg       done,
    output reg [8:0]     distance
);
    wire w_tick_us;
    reg [8:0] distance_reg, distance_next;
    //FSM
    localparam [2:0] IDLE = 0, START = 1, WAIT = 2, COUNT = 3, DISTANCE = 4;
    reg [2:0] c_state, n_state;
    reg run_stop;
    reg clear;
    reg [$clog2(58*400)-1:0] counter_reg, counter_next;
    reg echo_meta, echo_sync;

    tick_us U_TICK_US (
        .clk      (clk),
        .reset    (reset),
        .clear    (clear),
        .run_stop (run_stop),
        .o_tick_us(w_tick_us)
    );
    // ila_0 U_ILA (
    //     .clk(clk),
    //     .probe0(start), // start
    //     .probe1(trigger), // trigger
    //     .probe2(echo), // echo
    //     .probe3(c_state) // c_state
    // );

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= IDLE;
            counter_reg <= 0;
            distance_reg <= 0;
            distance <= 0;
            echo_meta <= 1'b0;
            echo_sync <= 1'b0;
        end else begin
            c_state <= n_state;
            counter_reg <= counter_next;
            distance_reg <= distance_next;
            echo_meta <= echo;
            echo_sync <= echo_meta;
            if (c_state == DISTANCE)
                distance <= (distance_reg < 9'd2 || distance_reg >= 9'd400) ?
                            9'd400 : distance_reg + 1'b1;
        end
    end
    //next, output
    always @(*) begin
        distance_next = distance_reg;
        n_state  = c_state;
        run_stop = 1'b0;
        clear    = 1'b0;
        trigger  = 1'b0;
        done = 0;
        counter_next = counter_reg;
        case (c_state)
            IDLE: begin
                distance_next = 9'b0;
                run_stop = 0;
                clear    = 1'b1;
                done     = 1'b0;
                if (start) begin

                    n_state = START;
                    counter_next = 0;
                end
            end
            START: begin
                trigger = 1;
                run_stop = 1;
                clear = 0;
                if (w_tick_us) begin
                    counter_next = counter_reg + 1;
                end
                if (counter_reg == 11) begin
                    counter_next = 0;
                    n_state = WAIT;
                end
            end
            WAIT: begin
                trigger = 0;
                run_stop = 1'b1;
                if (echo_sync) begin
                    counter_next = 0;
                    n_state = COUNT;
                end else if (w_tick_us) begin
                    counter_next = counter_reg + 1'b1;
                    if (counter_reg >= 15'd30_000) begin
                        distance_next = 9'd400;
                        counter_next = 0;
                        n_state = DISTANCE;
                    end
                end
            end
            COUNT: begin
                run_stop = 1'b1;
                if (w_tick_us) counter_next = counter_reg + 1;
                if (distance_reg >= 9'd400 || !echo_sync)
                    n_state = DISTANCE;
                else if (counter_reg == 58) begin // if statement troubleshooting
                    counter_next = 0;
                    distance_next = distance_reg + 1;
                end                    
            end
            DISTANCE: begin
                run_stop = 1'b0;
                n_state = IDLE;
                done = 1'b1;
            end
        endcase
    end





endmodule

module tick_us (
    input  clk,
    input  reset,
    input  clear,
    input  run_stop,
    output o_tick_us
);
    parameter F_COUNT = 100;
    reg [$clog2(F_COUNT)-1:0] counter_reg;
    reg tick_us_reg;
    assign o_tick_us = tick_us_reg;


    always @(posedge clk, posedge reset) begin
        if (reset | clear) begin
            counter_reg <= 0;
            tick_us_reg <= 1'b0;
        end else begin
            if (run_stop) begin  // runs when run_stop = 1; 
                counter_reg <= counter_reg + 1;
                if (counter_reg == (F_COUNT - 1)) begin
                    counter_reg <= 0;
                    tick_us_reg <= 1'b1;
                end else tick_us_reg <= 0;
            end
        end
    end
endmodule
