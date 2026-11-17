`timescale 1ns / 1ps

module uart_controller (
    input        clk,
    input        reset,
    input        tx_start,
    input  [7:0] tx_data,
    input        rx,
    output       tx_busy,
    output       tx_done,
    output       rx_done,
    output [7:0] rx_data,
    output       tx
);
    wire w_baud_tick_x16;
    uart_rx U_UART_RX (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .i_baud_tick(w_baud_tick_x16),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );
    uart_tx U_UART_TX (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .i_baud_tick(w_baud_tick_x16),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx(tx)
    );
    baud_tick_x16 U_BAUD_TICK_X16 (
        .clk(clk),
        .reset(reset),
        .o_baud_tick(w_baud_tick_x16)
    );
endmodule

module baud_tick (
    input  clk,
    input  reset,
    output o_baud_tick
);
    //9600 baud tick generator
    //seperate combinational logic and sequential logic
    parameter tick_count = 100_000_000 / 9_600;
    reg  [$clog2(tick_count)-1:0] counter_current;
    wire [$clog2(tick_count)-1:0] counter_next;
    reg                           o_baud_tick_reg;

    //counter SL
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_current <= 0;
        end else begin
            counter_current <= counter_next;

        end
    end
    // next CL
    assign counter_next = (counter_current == (tick_count - 1))? 0 : counter_current + 1;
    assign o_baud_tick = (counter_current == (tick_count - 1)) ? 1 : 0;
    //always @(*) begin 
    //    counter_next = counter_current + 1;
    //    if(counter_current == tick_count - 1) begin
    //        counter_next = 0;
    //        else
    //        counter_next = counter_current + 1;
    //    end
    //end 
endmodule

module uart_tx (
    input clk,
    input reset,
    input tx_start,
    input [7:0] tx_data,
    input i_baud_tick,
    output tx,
    output tx_busy,
    output tx_done
);

    //reg tx_reg;
    //assign tx = tx_reg;
    localparam [1:0] IDLE = 2'b00, START = 2'b01;
    localparam [1:0] STOP = 2'b10, DATA = 2'b11;


    reg [1:0] c_state, n_state;
    reg [3:0] tick_count_reg, tick_count_next;
    reg [2:0] bit_count_reg, bit_count_next;
    reg tx_reg, tx_next;
    assign tx = tx_reg;
    //add 8 bit register to safe use of tx_data;
    reg [7:0] data_reg, data_next;

    reg tx_busy_reg;
    reg tx_busy_next;
    reg tx_done_reg;
    reg tx_done_next;
    assign tx_busy = tx_busy_reg;
    assign tx_done = tx_done_reg;

    // state register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state        <= IDLE;
            tx_reg         <= 1'b1;
            bit_count_reg  <= 3'd0;
            data_reg       <= 8'h00;
            tick_count_reg <= 4'b0000;
            tx_busy_reg    <= 0;
            tx_done_reg    <= 0;
        end else begin
            c_state        <= n_state;
            tx_reg         <= tx_next;
            data_reg       <= data_next;
            bit_count_reg  <= bit_count_next;
            tick_count_reg <= tick_count_next;
            tx_busy_reg    <= tx_busy_next;
            tx_done_reg    <= tx_done_next;
        end
    end
    //avoid latch
    always @(*) begin
        n_state = c_state;
        bit_count_next = bit_count_reg;
        tx_next = tx_reg;
        data_next = data_reg;
        tick_count_next = tick_count_reg;
        tx_busy_next = tx_busy_reg;
        tx_done_next = tx_done_reg;
        bit_count_next = bit_count_reg;

        case (c_state)
            IDLE: begin
                tick_count_next = 0;
                bit_count_next = 0;
                //output
                tx_next = 1'b1;
                tx_busy_next = 1'b0;
                tx_done_next = 1'b0;
                if (tx_start) begin
                    data_next = tx_data;
                    tx_busy_next = 1'b1;
                    n_state = START;
                end
            end
            START: begin
                tx_next = 1'b0;
                if (i_baud_tick) begin
                        if (tick_count_reg == 15) begin
                            tick_count_next = 0;
                            n_state = DATA;
                        end else begin
                            tick_count_next = tick_count_reg + 1;
                        end
                    end
            end
            STOP: begin
                tx_next = 1'b1;
                if (i_baud_tick) begin
                    if(tick_count_reg == 15) begin 
                        tx_busy_next = 1'b0;
                        tx_done_next = 1'b1;
                        n_state = IDLE;
                    end else tick_count_next = tick_count_reg + 1;
                end 
            end

            DATA: begin
                tx_next = data_reg[0]; // LSB first
                
                if (i_baud_tick) begin
                    if (tick_count_reg == 15) begin
                            tick_count_next = 0;
                        if (bit_count_reg == 7) begin
                            n_state = STOP;
                        end else begin
                            n_state = DATA;

                            data_next = {1'b0,data_reg[7:1]};
                            // data_next = data_reg >> 1;
                            bit_count_next = bit_count_reg + 1;
                        end
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            default: begin
                n_state = IDLE;
                bit_count_next = 0;
                tx_next = 1'b1;
            end
        endcase
    end
endmodule

module uart_rx (
    input clk,
    input reset,
    input rx,
    input i_baud_tick,
    output [7:0] rx_data,
    output rx_done
);
    localparam [1:0] IDLE = 2'd0, START = 2'h01;
    localparam [1:0] STOP = 2'd2, DATA = 2'h3;
    reg [1:0] c_state, n_state;
    reg [3:0] tick_count_reg, tick_count_next;
    reg [2:0] bit_count_reg, bit_count_next;
    reg [7:0] data_reg, data_next;
    reg rx_done_reg, rx_done_next;
    assign rx_done = rx_done_reg;
    assign rx_data = data_reg;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= IDLE;
            tick_count_reg <= 0;
            bit_count_reg <= 0;
            data_reg <= 0;
            //data_next <= 0;
            rx_done_reg <= 0;
        end else begin
            c_state <= n_state;
            tick_count_reg <= tick_count_next;
            bit_count_reg <= bit_count_next;
            data_reg <= data_next;
            rx_done_reg <= rx_done_next;
        end
    end
    always @(*) begin
        n_state         = c_state;
        tick_count_next = tick_count_reg;
        bit_count_next  = bit_count_reg;
        data_next       = data_reg;
        // rx_done_reg = 0;
        rx_done_next    = rx_done_reg;
        case (c_state)
            IDLE: begin
                bit_count_next = 0;
                rx_done_next = 0;
                if (i_baud_tick) begin
                    if (rx == 0) begin
                        if (tick_count_reg == 7) begin
                            n_state = START;
                            tick_count_next = 0;
                        end else begin
                            tick_count_next = tick_count_reg + 1;
                        end
                    end else begin
                        // data_next = 0;
                        tick_count_next = 0;
                    end
                end
            end
            START: begin
                if (i_baud_tick) begin
                    if (tick_count_reg == 15) begin
                        n_state = DATA;
                        tick_count_next = 0;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            DATA: begin
                if (i_baud_tick) begin
                    if (tick_count_reg == 0) begin
                        // data_next = data_reg[bit_count_reg]; //bit indexing
                        //cascading
                        data_next = {rx, data_reg[7:1]}; 
                    end
                    if (tick_count_reg == 15) begin
                        tick_count_next = 0;
                        if (bit_count_reg == 7) begin
                            n_state = STOP;
                        end else begin
                            bit_count_next = bit_count_reg + 1;
                        end
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            STOP: begin
                if (i_baud_tick) begin
                    if (tick_count_reg == 7) begin
                        // CL output of done
                        rx_done_next = 1;
                        n_state      = IDLE;
                        tick_count_next = 0;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule

module baud_tick_x16 (
    input  clk,
    input  reset,
    output o_baud_tick
);
    //9600 baud tick generator
    //seperate combinational logic and sequential logic
    parameter tick_count = 100_000_000 / (9_600 * 16);
    reg  [$clog2(tick_count)-1:0] counter_current;
    wire [$clog2(tick_count)-1:0] counter_next;
    reg                           o_baud_tick_reg;

    //counter SL
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_current <= 0;
        end else begin
            counter_current <= counter_next;

        end
    end
    // next CL
    assign counter_next = (counter_current == (tick_count - 1))? 0 : counter_current + 1;
    assign o_baud_tick = (counter_current == (tick_count - 1)) ? 1 : 0;
    //always @(*) begin 
    //    counter_next = counter_current + 1;
    //    if(counter_current == tick_count - 1) begin
    //        counter_next = 0;
    //        else
    //        counter_next = counter_current + 1;
    //    end
    //end 
endmodule
