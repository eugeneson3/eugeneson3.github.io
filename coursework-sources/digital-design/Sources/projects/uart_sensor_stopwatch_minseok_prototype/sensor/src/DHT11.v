`timescale 1ns / 1ps

module DHT11_controller (
    input         clk,
    input         reset,
    input         start,
    output [15:0] humidity,
    output [15:0] temperature,
    output        enable,
    output        valid,
    inout         dht11_io
);

    tick_gen_us U_TICK_US (
        .clk   (clk),
        .reset (reset),
        .clear (clear),
        .o_tick(tick_us)
    );

    localparam [2:0] IDLE = 0 , START =1 , WAIT = 2, SYNC_L = 3, SYNC_H = 4, DATA_L = 5, DATA_H = 6, STOP = 7;
    localparam TIME_OUT = 120;
    reg [2:0] c_state, n_state;
    reg [$clog2(19_000)-1:0] tick_count_reg, tick_count_next;
    reg [$clog2(40)-1:0] data_count_reg, data_count_next;
    reg [39:0] sensor_data_reg, sensor_data_next;

    reg io_control;
    reg dht11_io_reg, dht11_io_next;

    reg enable_reg;
    wire [7:0] sum;

    // syncronyzer 
    reg dht11_sync1;
    reg dht11_sync2;

    // edge detect
    reg dht_detect_reg;
    wire dht_rise = dht11_sync2 & ~dht_detect_reg;
    wire dht_fall = ~dht11_sync2 & dht_detect_reg;

    assign dht11_io = (io_control) ? (dht11_io_reg) : 1'bz;
    assign humidity = sensor_data_reg[39:24];
    assign temperature = sensor_data_reg[23:8];
    assign sum = (sensor_data_reg[39:32] + sensor_data_reg[31:24] + sensor_data_reg[23:16] + sensor_data_reg[15:8]);
    assign valid = (c_state == IDLE && (sensor_data_reg[7:0] == sum));
    assign enable = enable_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state         <= IDLE;
            dht11_io_reg    <= 1'b1;
            tick_count_reg  <= 0;
            data_count_reg  <= 0;
            sensor_data_reg <= 0;
            dht11_sync1     <= 1;
            dht11_sync2     <= 1;
            dht_detect_reg  <= 1;
        end else begin
            c_state         <= n_state;
            dht11_io_reg    <= dht11_io_next;
            tick_count_reg  <= tick_count_next;
            data_count_reg  <= data_count_next;
            sensor_data_reg <= sensor_data_next;
            dht11_sync1     <= dht11_io;
            dht11_sync2     <= dht11_sync1;
            dht_detect_reg  <= dht11_sync2;
        end
    end

    always @(*) begin
        n_state          = c_state;
        dht11_io_next    = dht11_io_reg;
        io_control       = 1'b1;
        enable_reg       = 1'b0;
        tick_count_next  = tick_count_reg;
        data_count_next  = data_count_reg;
        sensor_data_next = sensor_data_reg;
        case (c_state)
            IDLE: begin
                dht11_io_next   = 1'b1;
                enable_reg      = 1'b1;
                tick_count_next = 0;
                data_count_next = 0;
                if (start) begin
                    n_state = START;
                end
            end
            START: begin
                dht11_io_next    = 1'b0;
                enable_reg       = 1'b0;
                sensor_data_next = 40'o0;
                // delay 19 msec low
                if (tick_us)
                    if (tick_count_reg == 19_000) begin
                        tick_count_next = 0;
                        n_state         = WAIT;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                        n_state         = START;
                    end
            end
            WAIT: begin
                dht11_io_next = 1'b1;

                if (tick_count_reg >= 25) io_control = 1'b0;

                if (tick_us) begin
                    if (tick_count_reg >= 50) begin
                        tick_count_next = 0;
                        n_state         = SYNC_L;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end

            end
            SYNC_L: begin
                io_control = 1'b0;  // by pull up 
                if (dht_rise) begin
                    tick_count_next = 0;
                    n_state         = SYNC_H;
                end else if (tick_us) begin
                    if (tick_count_reg >= (TIME_OUT)) begin
                        tick_count_next = 0;
                        n_state         = IDLE;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end

            SYNC_H: begin
                io_control = 1'b0;
                if (dht_fall) begin
                    tick_count_next = 0;
                    n_state         = DATA_L;
                end else if (tick_us) begin
                    if (tick_count_reg >= (TIME_OUT)) begin
                        tick_count_next = 0;
                        n_state         = IDLE;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            DATA_L: begin
                io_control = 1'b0;
                if (data_count_reg == 40) begin
                    tick_count_next = 0;
                    n_state         = STOP;
                end else if (dht_rise) begin
                    if (tick_count_reg > 40) begin
                        tick_count_next = 0;
                        n_state = DATA_H;
                    end
                end else if (tick_us) begin
                    if (tick_count_reg > (TIME_OUT)) begin
                        tick_count_next = 0;
                        n_state = IDLE;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            DATA_H: begin
                io_control = 1'b0;
                if (dht_fall) begin
                    if (tick_count_reg > 50) begin
                        sensor_data_next[39-(data_count_reg)] = 1;
                        data_count_next = data_count_reg + 1;
                        tick_count_next = 0;
                        n_state = DATA_L;
                    end else if (tick_count_reg <=  50) begin
                        sensor_data_next[39-(data_count_reg)] = 0;
                        data_count_next = data_count_reg + 1;
                        tick_count_next = 0;
                        n_state = DATA_L;
                    end
                end else if (tick_us) begin
                    if (tick_count_reg > (TIME_OUT)) begin
                        tick_count_next = 0;
                        n_state = IDLE;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            STOP: begin
                io_control = 1'b0;
                if (tick_us) begin
                    if (tick_count_reg == 50) begin
                        n_state = IDLE;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule

module tick_gen_us (
    input  clk,
    input  reset,
    input  clear,
    output o_tick
);

    parameter F_COUNT = 100;
    reg [$clog2(F_COUNT)-1:0] counter_reg;
    reg tick_reg;

    assign o_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset | clear) begin
            counter_reg <= 0;
            tick_reg <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == (F_COUNT - 1)) begin
                counter_reg <= 0;
                tick_reg <= 1'b1;
            end else begin
                tick_reg <= 1'b0;
            end
        end
    end

endmodule
