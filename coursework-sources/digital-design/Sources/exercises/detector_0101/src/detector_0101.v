`timescale 1ns / 1ps


module detector_0101 (
    input  clk,
    input  reset,
    input  i_num,
    output reg o_num
);
  reg [2:0] current_state;
  reg [2:0] next_state;
  parameter start = 2'b00;
  parameter read_0 = 2'b01;
  parameter read_01 = 2'b10;
  parameter read_010 = 2'b11;

  always @(*) begin
    o_num = 0;
    
    case (current_state)
      start:
        if (i_num == 1) next_state = start;
        else next_state = read_0;
      read_0:
        if(i_num == 1) next_state = read_01;
        else next_state = read_0;
    read_01:
        if (i_num == 1) next_state = start;
        else next_state = read_010;
    read_010:
        if (i_num == 1) begin
            o_num = 1;
            next_state = start;
        end
        else 
            next_state = read_0;
    endcase
  end    
    always @(posedge clk or posedge reset) begin
        if(reset) current_state <= start;
        else        current_state <= next_state;
    end

endmodule
