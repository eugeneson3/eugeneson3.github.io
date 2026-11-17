`timescale 1ns / 1ps

module tb_fifo();
    parameter WIDTH = 2;
    reg clk,reset;
    reg push,pop;
    reg  [7:0] wdata;
    wire [7:0] rdata;
    wire full,empty;
    reg [7:0] compare_buffer[0:2**WIDTH-1];
    reg [WIDTH-1:0] push_cnt;
    reg [WIDTH-1:0] pop_cnt;
    integer pass_count = 0;
    integer fail_count = 0;
    
    fifo #(.WIDTH(2))
    DUT (
    .clk(clk),
    .reset(reset),
    .push(push),
    .pop(pop),
    .wdata(wdata),
    .rdata(rdata),
    .full(full),
    .empty(empty)
    );

    integer i = 0;
    always #5 clk = ~clk;
    initial begin 
        clk = 0;
        reset = 1;
        push = 0;
        pop = 0;
        wdata = 8'b0;
        #10;
        reset = 0;

        push_cnt = 0;
        pop_cnt = 0;

        $display("%t: RANDOM TEST START", $time);


        wdata = 8'b0;
        for (i = 0; i < 256; i = i + 1) begin 
            @(posedge clk);
            #1;
            // stimulus generation & Driving
            push = $random % 2;
            pop = $random % 2;
            wdata = $random % 256;
            $display("%t: compare_buffer = %d, push = %d, pop = %d, wdata = %d", 
            $time,compare_buffer[push_cnt],push,pop,wdata);
            @(negedge clk);
            #1;
            if(!full & push) begin 
                compare_buffer[push_cnt] = wdata;
                $display("%t: compare_buffer = %d, push = %d, pop = %d, wdata = %d", 
                $time,compare_buffer[push_cnt],push,pop,wdata);
                push_cnt = push_cnt + 1;
                end
            if(!empty & pop) begin 
                if(compare_buffer[pop_cnt] == rdata) begin 
                    $display("%t: PASS!! compare_data = %d, rdata = %d, pop = %d, empty = %d", 
                    $time, compare_buffer[pop_cnt], rdata, pop, empty);
                    pass_count = pass_count + 1;
                    end 
                else begin 
                    $display("%t: FAIL!! compare_data = %d, rdata = %d, pop = %d, empty = %d", 
                    $time, compare_buffer[pop_cnt], rdata, pop, empty);
                    fail_count = fail_count + 1;
                    end
                pop_cnt = pop_cnt + 1;
            end
        
//        #10;
        end
        $display("%t: pass count = %d, fail count = %d", $time,pass_count,fail_count);

        $finish;
    end
endmodule