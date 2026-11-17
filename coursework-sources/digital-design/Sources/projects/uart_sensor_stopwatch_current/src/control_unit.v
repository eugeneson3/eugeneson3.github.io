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

module stopwatch_control_unit (
    input  clk,
    input  reset,
    input uart_run,
    input uart_stop,
    input  i_run_stop,
    input  i_clear,
    input  i_mode,
    output o_run_stop,
    output o_clear,
    output o_mode
);

  parameter STOP = 0, RUN = 1, CLEAR = 2, MODE = 3;
  reg [1:0] current_state, next_state;
  //output
  //assign {o_clear, o_run_stop, o_mode} = (current_state == STOP)? 3'b000:
  //                                        (current_state ==RUN)? 3'b010:
  //                                        (current_state ==CLEAR)? 3'b100:
  //                                        (current_state ==MODE)? 3'b001: 3'b000;


  //change assign statements to sequential logic
  reg run_stop_reg, run_stop_next;
  reg clear_reg, clear_next;
  reg mode_reg, mode_next;

  assign o_run_stop = run_stop_reg;
  assign o_clear = clear_reg;
  assign o_mode = mode_reg;
  //state register
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      current_state  <= STOP;
      run_stop_reg   <= 1'b0;
      clear_reg <= 1'b0;
      mode_reg  <= 1'b0;
    end else begin
      current_state  <= next_state;
      run_stop_reg   <= run_stop_next;
      clear_reg <= clear_next;
      mode_reg  <= mode_next;
    end
  end
  //NEXT state combinational logic
  always @(*) begin
    run_stop_next = run_stop_reg;
    clear_next = clear_reg;
    mode_next = mode_reg;
    next_state = current_state;  // to avoid latch
    case (current_state)
      STOP: begin
        run_stop_next = 1'b0;
        clear_next = 1'b0;

        if(i_run_stop | uart_run) begin // if state has priority, run should run first if run and clear are pressed at the same time
          next_state = RUN;
        end else if (i_clear) begin
          next_state = CLEAR;
        end else if (i_mode) begin
          next_state = MODE;
        end else begin
          next_state = current_state;
        end
      end
      RUN: begin
        run_stop_next = 1'b1;
        if (i_run_stop | uart_stop) begin
          next_state = STOP;
        end else begin
          next_state = current_state;
        end
      end
      CLEAR: begin
        clear_next = 1'b1;
        next_state = STOP;
      end
      MODE: begin
        mode_next  = ~mode_reg;
        next_state = STOP;
      end
      default: next_state = current_state;
    endcase
  end
endmodule