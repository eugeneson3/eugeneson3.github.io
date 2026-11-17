`timescale 1ns / 1ps
interface reg_interface;

    logic        clk;
    logic        rst;
    logic        enable;
    logic [31:0] d;
    logic [31:0] q;
endinterface


class transaction;
    bit             rst;
    rand bit        enable;
    rand bit [31:0] d;
    logic    [31:0] q;
    function void debug_print(string name);
        $display("%t: [%s] enable = %d, d = %d, q = %d", $time, name, enable,
                 d, q);

    endfunction
endclass


class generator;
    transaction tr;
    transaction tr_scb;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) gen2scb_mbox;
    event event2gen;
    function new(mailbox#(transaction) gen2drv_mbox, event event2gen,
                 mailbox#(transaction) gen2scb_mbox);
        this.gen2drv_mbox = gen2drv_mbox;
        this.event2gen = event2gen;
        this.gen2scb_mbox = gen2scb_mbox;
    endfunction
    task run(int run_count);
        repeat (run_count) begin
            tr = new;
            tr_scb = new;
            tr.randomize();
            tr_scb.d      = tr.d;
            tr_scb.q      = tr.q;
            tr_scb.enable = tr.enable;
            gen2drv_mbox.put(tr);
            gen2scb_mbox.put(tr_scb);
            tr_scb.debug_print("GEN_TR_SCB");
            tr.debug_print("GEN");
            @(event2gen);
        end
    endtask
endclass

class driver;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    virtual reg_interface reg_vif;
    function new(mailbox#(transaction) gen2drv_mbox,
                 virtual reg_interface reg_vif);
        this.gen2drv_mbox = gen2drv_mbox;
        this.reg_vif      = reg_vif;
    endfunction

    task preset();
        reg_vif.rst    = 1;
        reg_vif.enable = 0;
        reg_vif.d      = 0;
        @(negedge reg_vif.clk);
        @(negedge reg_vif.clk);
        reg_vif.rst = 0;
        @(negedge reg_vif.clk);
    endtask

    task run();
        forever begin

            gen2drv_mbox.get(tr);
            @(posedge reg_vif.clk);
            #1;
            reg_vif.enable = tr.enable;
            reg_vif.d      = tr.d;
            tr.debug_print("DRV");

        end
    endtask

endclass
class monitor;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    virtual reg_interface reg_vif;
    function new(mailbox#(transaction) mon2scb_mbox,
                 virtual reg_interface reg_vif);
        this.reg_vif      = reg_vif;
        this.mon2scb_mbox = mon2scb_mbox;
    endfunction

    task run();
        forever begin
            @(negedge reg_vif.clk);
            tr = new;
            tr.enable = reg_vif.enable;
            tr.d = reg_vif.d;
            tr.q = reg_vif.q;
            tr.debug_print("MON");
            mon2scb_mbox.put(tr);
            @(posedge reg_vif.clk);
        end
    endtask
endclass
class scoreboard;
    transaction tr;
    transaction tr_scb;
    mailbox #(transaction) mon2scb_mbox;
    mailbox #(transaction) gen2scb_mbox;
    virtual reg_interface reg_vif;
    event event2gen;

    function new(mailbox#(transaction) mon2scb_mbox, event event2gen,
                 virtual reg_interface reg_vif,
                 mailbox#(transaction) gen2scb_mbox);
        this.mon2scb_mbox = mon2scb_mbox;
        this.gen2scb_mbox = gen2scb_mbox;
        this.event2gen = event2gen;
        this.reg_vif = reg_vif;
    endfunction
    logic [31:0] previous_d = 0;
    logic [31:0] previous_d_gen = 0;

    task run();
        forever begin
            gen2scb_mbox.get(tr_scb);
            previous_d_gen = tr_scb.d;
            //                if(tr.enable) begin 
            //                    if(previous_d_gen == tr.q) $display ("PASS");
            //                    else                   $display ("FAIL");
            //                    previous_d_gen = tr.d;
            @(posedge reg_vif.clk);
            #1;
            mon2scb_mbox.get(tr);
            //pass/fail verify
            tr.debug_print("SCB");
            if (tr.enable) begin
                if (previous_d_gen == tr.d) $display("PASS");
                else
                    $display(
                        "FAIL, previous_d_gen = %d, tr.q = %d",
                        previous_d_gen,
                        tr.q
                    );
            end
            //event to generator
            ->event2gen;
        end
    endtask
endclass
class environment;
    virtual reg_interface  reg_vif;
    driver                 drv;
    monitor                mon;
    generator              gen;
    scoreboard             scb;
    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;
    mailbox #(transaction) gen2scb_mbox;
    event                  event2gen;

    function new(virtual reg_interface reg_vif);
        gen2drv_mbox = new;
        mon2scb_mbox = new;
        gen2scb_mbox = new;
        this.reg_vif = reg_vif;
        gen = new(gen2drv_mbox, event2gen, gen2scb_mbox);
        drv = new(gen2drv_mbox, reg_vif);
        mon = new(mon2scb_mbox, reg_vif);
        scb = new(mon2scb_mbox, event2gen, reg_vif, gen2scb_mbox);
    endfunction
    task run();
        drv.preset();
        fork
            gen.run(10);
            drv.run();
            mon.run();
            scb.run();
        join_any
    endtask

endclass


module tb_register_sv ();
    reg_interface reg_if ();
    environment env;

    register_sv dut (
        .clk(reg_if.clk),
        .rst(reg_if.rst),
        .enable(reg_if.enable),
        .d(reg_if.d),
        .q(reg_if.q)
    );
    always #5 reg_if.clk = ~reg_if.clk;
    initial begin
        $timeformat(-9, 0, " ns", 0);

        reg_if.clk = 0;
        env = new(reg_if);
        env.run();
        #10;
        $finish;
    end

endmodule
