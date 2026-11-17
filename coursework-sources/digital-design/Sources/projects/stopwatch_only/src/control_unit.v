`timescale 1ns / 1ps

module control_unit (
    input  clk,
    input  reset,
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

        if(i_run_stop) begin // if state has priority, run should run first if run and clear are pressed at the same time
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
        if (i_run_stop) begin
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

