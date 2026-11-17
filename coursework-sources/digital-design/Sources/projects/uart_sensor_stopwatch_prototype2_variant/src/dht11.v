`timescale 1ns / 1ps `timescale 1ns / 1ps

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
    //add tick gen here
    localparam [2:0] IDLE = 0, START = 1, WAIT = 2, SYNC = 3, DATA = 4, STOP = 5;
    reg [2:0] c_state, n_state;
    // MCU should send LOW signal for minimum 18ms; typically 19ms 
    reg [$clog2(19_000)-1:0] tick_count_reg, tick_count_next;
    reg dht11_io_reg, dht11_io_next;
    reg [5:0] bit_num_reg, bit_num_next;
    reg [39:0] whole_data_reg,whole_data_next;
    reg io_tick;
    assign humidity =  whole_data_reg  [39:24]; // [39:32] humidity_int, [31:24] humidity_dec
    assign temperature =  whole_data_reg  [23:8] ; // [23:16] temperature_int, [15:28] temperature_dec
    assign check_sum = whole_data_reg  [7:0] ; // whole_data is 40 bit output of module; 
    assign valid = (whole_data_reg[7:0] == 
                    (humidity[15:8] + humidity[7:0] 
                    + temperature[15:8] + temperature[7:0]));

    reg io_control;
    assign dht11_io = (io_control) ? (dht11_io_reg) : 1'bz;
    wire tick_us;
    tick_gen_1us U_TICK_GEN_1US (
        .clk   (clk),
        .reset (reset),
        .o_tick(tick_us)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) io_tick <= 1'b0;
        else io_tick <= dht11_io;
    end


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state        <= IDLE;
            dht11_io_reg   <= 1'b1;
            tick_count_reg <= 0;
            bit_num_reg    <= 0;
            whole_data_reg <= 40'b0;
        end else begin
            c_state <= n_state;
            dht11_io_reg <= dht11_io_next;
            tick_count_reg <= tick_count_next;
            bit_num_reg <= bit_num_next;
            whole_data_reg <= whole_data_next;
        end
    end

    always @(*) begin
        n_state         = c_state;
        dht11_io_next   = dht11_io_reg;
//        io_control      = 1'b1;
        tick_count_next = tick_count_reg;
        bit_num_next    = bit_num_reg;
        whole_data_next  = whole_data_reg;
        case (c_state)
            IDLE: begin
                tick_count_next = 0;
                dht11_io_next = 1'b1;
                io_control = 1'b1;
                if (start) begin
                    n_state = START;
                end
            end
            START: begin
                dht11_io_next = 1'b0;
                if (tick_us) begin
                //delay 19ms low
                    if (tick_count_reg == 19_000) begin
                        tick_count_next = 0;
                        n_state = WAIT;
                        dht11_io_next = 1'b1;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                        n_state = START;
                    end
                end
            end
            WAIT: begin
                if(tick_us) begin
                    if (tick_count_reg == 30) begin
                        tick_count_next = 0;
                        n_state = SYNC;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                        n_state = WAIT;
                    end
                end

            end
            SYNC: begin
                io_control = 0;
                if (tick_us) begin
                    if (tick_count_reg == 180) begin // low 80us-> high 80us -> data
                        n_state = DATA;
                        tick_count_next = 0;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                        n_state = SYNC;
                    end
                end
            end
            DATA: begin
                io_control      = 1'b0;
                if (tick_us) begin
                    if (dht11_io) begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
                // negedge detection
                if ((io_tick) & (!dht11_io)) begin
                    whole_data_next [39-bit_num_reg] = (tick_count_reg > 50);
                    bit_num_next                = bit_num_reg + 1;
                    tick_count_next = 0;
                end
                if (bit_num_reg > 39) begin 
                    n_state = STOP;
                    tick_count_next = 0;
                    end
                else n_state = DATA;
            end

            STOP: begin
                if (tick_count_reg > 1) begin
                    tick_count_next = 0;
                    io_control = 1'b0;
                    n_state = IDLE;
                end
                else begin tick_count_next = tick_count_reg + 1;
                    n_state = STOP;
                end
            end
        endcase
    end


endmodule
module tick_gen_1us (
    input  clk,
    input  reset,
    output o_tick
);
    parameter F_COUNT = 1_00;
    reg tick_reg;
    assign o_tick = tick_reg;

    reg [$clog2(F_COUNT)-1:0] counter_reg;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            tick_reg    <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;

            if (counter_reg == (F_COUNT - 1)) begin
                counter_reg <= 0;
                tick_reg <= 1'b1;
            end else tick_reg <= 0;
        end
    end
endmodule
