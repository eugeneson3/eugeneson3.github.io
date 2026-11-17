`timescale 1ns / 1ps

module ram_ip (
    input        clk,
    input  [5:0] addr,
    input  [7:0] wdata,
    input        wr,
    output reg [7:0] rdata
);
    // adress: a to 10, b to 11,... 32 to d
    reg [7:0] ram[0:63];
    always @(posedge clk) begin
        if (wr) 
        begin
            ram[addr] <= wdata;
        end 
        else rdata <= ram[addr];
    end
    // assign rdata = (!wr)? ram[addr]:8'hz
//    assign rdata = ram[addr];
endmodule