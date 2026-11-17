`timescale 1ns / 1ps

module dht11 (
    input         clk,
    input         reset,
    input         start,
    output [15:0] humidity,
    output [15:0] temperature,
    output        done,
    output        valid,
    output [7:0]  check_sum,
    inout         dht11_io
);
    //FSM
    localparam [2:0] IDLE = 0, START = 1, WAIT = 2, DATA = 3, STOP = 4;
    reg [2:0] c_state, n_state;
    reg [$clog2(19_000)-1:0] tick_count_reg, tick_count_next;
    reg [5:0] bit_num_reg, bit_num_next;
    reg [39:0] data_reg, data_next;
    reg [39:0] whole_data_reg, whole_data_next;
    reg valid_reg, valid_next;
    reg dht_meta_reg, dht_sync_reg, io_tick;

    wire tick_us;

    assign humidity    = whole_data_reg[39:24];
    assign temperature = whole_data_reg[23:8];
    assign check_sum   = whole_data_reg[7:0];
    assign valid       = valid_reg;
    assign done        = (c_state == STOP);
    assign dht11_io = (c_state == START) ? 1'b0 : 1'bz;

    tick_gen_1us U_TICK_GEN_1US (
        .clk   (clk),
        .reset (reset),
        .o_tick(tick_us)
    );

    // for posedge, negedge detection
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            dht_meta_reg <= 1'b1;
            dht_sync_reg <= 1'b1;
            io_tick      <= 1'b1;
        end else begin
            dht_meta_reg <= dht11_io;
            dht_sync_reg <= dht_meta_reg;
            io_tick      <= dht_sync_reg;
        end
    end

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state        <= IDLE;
            tick_count_reg <= 0;
            bit_num_reg    <= 0;
            data_reg       <= 0;
            whole_data_reg <= 0;
            valid_reg      <= 0;
        end else begin
            c_state        <= n_state;
            tick_count_reg <= tick_count_next;
            bit_num_reg    <= bit_num_next;
            data_reg       <= data_next;
            whole_data_reg <= whole_data_next;
            valid_reg      <= valid_next;
        end
    end

    //next, output
    always @(*) begin
        n_state         = c_state;
        tick_count_next = tick_count_reg;
        bit_num_next    = bit_num_reg;
        data_next       = data_reg;
        whole_data_next = whole_data_reg;
        valid_next      = valid_reg;

        case (c_state)
            IDLE: begin
                tick_count_next = 0;
                if (start) begin
                    tick_count_next = 0;
                    bit_num_next    = 0;
                    data_next       = 0;
                    valid_next      = 1'b0;
                    n_state         = START;
                end
            end

            START: begin
                if (tick_us) begin
                    //delay 19ms low
                    if (tick_count_reg == 19_000 - 1) begin
                        tick_count_next = 0;
                        n_state = WAIT;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end

            WAIT: begin
                // 30us high + 80us low + 80us high response
                if (tick_us) begin
                    if (tick_count_reg == 250) begin
                        tick_count_next = 0;
                        valid_next = 1'b0;
                        n_state = IDLE;
                    end else tick_count_next = tick_count_reg + 1;
                end
                // ignore the first response negedge, start at the second negedge
                if ((io_tick) & (!dht_sync_reg) & (tick_count_reg > 100)) begin 
                        tick_count_next = 0;
                        n_state = DATA;
                end
            end

            DATA: begin
                if (tick_us) begin
                    if (tick_count_reg == 120) begin
                        tick_count_next = 0;
                        bit_num_next = 0;
                        valid_next = 1'b0;
                        n_state = IDLE;
                    end else tick_count_next = tick_count_reg + 1;
                end

                // reset counter at posedge
                if ((!io_tick) & dht_sync_reg) begin
                    tick_count_next = 0;
                end

                // negedge detection
                if ((io_tick) & (!dht_sync_reg)) begin
                    data_next = {data_reg[38:0], (tick_count_reg > 50)}; // left shift 
                    tick_count_next = 0;

                    if (bit_num_reg == 39) begin
                        if (data_next[7:0] ==
                           (data_next[39:32] + data_next[31:24] +
                            data_next[23:16] + data_next[15:8])) begin
                            whole_data_next = data_next;
                            valid_next = 1'b1;
                        end else valid_next = 1'b0;
                        n_state = STOP;
                    end else begin
                        bit_num_next = bit_num_reg + 1;
                    end
                end
            end

            STOP: begin
                n_state = IDLE;
            end
        endcase
    end
endmodule

module tick_gen_1us (
    input  clk,
    input  reset,
    output o_tick
);
    parameter F_COUNT = 100;
    reg tick_reg;
    assign o_tick = tick_reg;

    reg [$clog2(F_COUNT)-1:0] counter_reg;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            tick_reg    <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == F_COUNT - 1) begin
                counter_reg <= 0;
                tick_reg    <= 1'b1;
            end else tick_reg <= 1'b0;
        end
    end
endmodule
