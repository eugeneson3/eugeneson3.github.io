`timescale 1ns / 1ps

module tb_ram ();

    reg        clk;
    reg  [5:0] addr;
    reg  [7:0] wdata;
    reg        wr;
    wire [7:0] rdata;
    ram_ip DUT (
        .clk(clk),
        .addr(addr),
        .wdata(wdata),
        .wr(wr),
        .rdata(rdata)
    );

    always #5 clk = ~clk;
    initial begin
        clk   = 0;
        addr  = 0;
        wdata = 0;
        wr    = 0;
        #10;

        addr  = 10;
        wdata = 8'ha;
        wr    = 1;
        #10;

        addr  = 11;
        wdata = 8'hb;
        wr    = 1;
        #10;

        addr  = 31;
        wdata = 8'hc;
        wr    = 1;
        #10;
        addr  = 32;
        wdata = 8'hd;
        wr    = 1;
        #10;
        addr = 10;
        wr   = 0;
        #10;
        addr = 11;
        wr   = 0;
        #10;
        addr = 31;
        wr   = 0;
        #10;
        addr = 32;
        wr   = 0;
        #10;
        $stop;
        $finish;
    end

endmodule
