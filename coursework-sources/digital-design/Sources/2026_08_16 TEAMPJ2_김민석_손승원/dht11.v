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
    localparam [3:0] IDLE=4'd0, START=4'd1, WAIT_R=4'd2,
                     SYNC_L=4'd3, SYNC_H=4'd4, DATA_L=4'd5,
                     DATA_H=4'd6, STOP=4'd7;
    localparam [14:0] START_US = 15'd19000;
    localparam [7:0] TIMEOUT_US = 8'd120;

    reg [3:0] state, next_state;
    reg [14:0] tick_count, next_tick_count;
    reg [5:0] bit_count, next_bit_count;
    reg [39:0] data_reg, next_data_reg;
    reg io_control, io_reg, next_io_reg;
    reg sync_ff1, sync_ff2, sync_prev;
    wire io_rise = sync_ff2 & ~sync_prev;
    wire io_fall = ~sync_ff2 & sync_prev;
    wire tick_us;

    assign dht11_io = io_control ? io_reg : 1'bz;
    assign humidity = data_reg[39:24];
    assign temperature = data_reg[23:8];
    assign check_sum = data_reg[7:0];
    assign done = (state == STOP);
    assign valid = (state == STOP) &&
                   (data_reg[7:0] == data_reg[39:32] + data_reg[31:24] +
                                     data_reg[23:16] + data_reg[15:8]);

    tick_gen_1us U_TICK_GEN_1US (.clk(clk), .reset(reset), .o_tick(tick_us));

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tick_count <= 0;
            bit_count <= 0;
            data_reg <= 0;
            io_reg <= 1'b1;
            sync_ff1 <= 1'b1;
            sync_ff2 <= 1'b1;
            sync_prev <= 1'b1;
        end else begin
            state <= next_state;
            tick_count <= next_tick_count;
            bit_count <= next_bit_count;
            data_reg <= next_data_reg;
            io_reg <= next_io_reg;
            sync_ff1 <= dht11_io;
            sync_ff2 <= sync_ff1;
            sync_prev <= sync_ff2;
        end
    end

    always @(*) begin
        next_state = state;
        next_tick_count = tick_count;
        next_bit_count = bit_count;
        next_data_reg = data_reg;
        next_io_reg = io_reg;
        io_control = 1'b0;

        case (state)
            IDLE: begin
                next_tick_count = 0;
                next_bit_count = 0;
                next_io_reg = 1'b1;
                if (start) begin
                    next_data_reg = 0;
                    next_state = START;
                end
            end
            START: begin
                io_control = 1'b1;
                next_io_reg = 1'b0;
                if (tick_us) begin
                    if (tick_count == START_US) begin
                        next_tick_count = 0;
                        next_state = WAIT_R;
                    end else begin
                        next_tick_count = tick_count + 1'b1;
                    end
                end
            end
            WAIT_R: begin
                if (tick_us) begin
                    if (tick_count == 8'd40) begin
                        next_tick_count = 0;
                        next_state = SYNC_L;
                    end else begin
                        next_tick_count = tick_count + 1'b1;
                    end
                end
            end
            SYNC_L: begin
                if (io_rise) begin
                    next_tick_count = 0;
                    next_state = SYNC_H;
                end else if (tick_us) begin
                    if (tick_count >= TIMEOUT_US) begin
                        next_tick_count = 0;
                        next_state = IDLE;
                    end else begin
                        next_tick_count = tick_count + 1'b1;
                    end
                end
            end
            SYNC_H: begin
                if (io_fall) begin
                    next_tick_count = 0;
                    next_state = DATA_L;
                end else if (tick_us) begin
                    if (tick_count >= TIMEOUT_US) begin
                        next_tick_count = 0;
                        next_state = IDLE;
                    end else begin
                        next_tick_count = tick_count + 1'b1;
                    end
                end
            end
            DATA_L: begin
                if (bit_count == 40) begin
                    next_tick_count = 0;
                    next_state = STOP;
                end else if (io_rise) begin
                    next_tick_count = 0;
                    next_state = DATA_H;
                end else if (tick_us) begin
                    if (tick_count >= TIMEOUT_US) begin
                        next_tick_count = 0;
                        next_state = IDLE;
                    end else begin
                        next_tick_count = tick_count + 1'b1;
                    end
                end
            end
            DATA_H: begin
                if (io_fall) begin
                    next_data_reg[39-bit_count] = (tick_count > 8'd50);
                    next_bit_count = bit_count + 1'b1;
                    next_tick_count = 0;
                    next_state = DATA_L;
                end else if (tick_us) begin
                    if (tick_count >= TIMEOUT_US) begin
                        next_tick_count = 0;
                        next_state = IDLE;
                    end else begin
                        next_tick_count = tick_count + 1'b1;
                    end
                end
            end
            STOP: begin
                if (tick_us) begin
                    if (tick_count >= 8'd2) begin
                        next_tick_count = 0;
                        next_state = IDLE;
                    end else begin
                        next_tick_count = tick_count + 1'b1;
                    end
                end
            end
            default: begin
                next_state = IDLE;
                next_tick_count = 0;
                next_bit_count = 0;
                next_data_reg = 0;
            end
        endcase
    end
endmodule

module tick_gen_1us (
    input clk,
    input reset,
    output o_tick
);
    parameter F_COUNT = 100;
    reg [$clog2(F_COUNT)-1:0] counter_reg;
    reg tick_reg;
    assign o_tick = tick_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            tick_reg <= 1'b0;
        end else if (counter_reg == F_COUNT - 1) begin
            counter_reg <= 0;
            tick_reg <= 1'b1;
        end else begin
            counter_reg <= counter_reg + 1'b1;
            tick_reg <= 1'b0;
        end
    end
endmodule
