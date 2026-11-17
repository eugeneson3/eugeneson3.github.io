`timescale 1ns / 1ps
//interface to connect objects 
interface adder_interface ();
    logic [7:0] a;
    logic [7:0] b;
    logic       mode;
    logic [7:0] s;
    logic       c;
endinterface
//stimulus 

class transaction;
    rand bit [7:0] a;
    rand bit [7:0] b;
    rand bit       mode;
    logic    [7:0] s;
    logic          c;

    constraint mode_dist2{
        mode dist{
            0 :/ 90,
            1 :/ 10
        };
    }
    //available in systemverilog, not verilog. no return type.
    function void debug_print (string name);
        $display("%t: [%s] a = %d, b = %d, mode = %d, s = %d, c = %d",$time,name,a,b,mode,s,c);
        
    endfunction
endclass

class generator;  //sequencer
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    event event2gen;
    function new(mailbox#(transaction) gen2drv_mbox, event event2gen);
        this.gen2drv_mbox = gen2drv_mbox;
        this.event2gen = event2gen;
    endfunction

    task run(int run_count);
        //forever begin
        repeat(run_count) begin
            tr = new;  //dynamic allocation 
            // randomize who has 'rand' in tr
            tr.randomize();
            gen2drv_mbox.put(tr);
            tr.debug_print("GEN");
            //wait 
            @(event2gen);
        end
        $display ("GENERATION STOPPED");
    endtask

endclass

class driver;
    transaction tr;
    mailbox #(transaction) gen2drv_mbox;
    virtual adder_interface adder_vif;
    event event2gen;


    function new(mailbox#(transaction) gen2drv_mbox,
        event event2gen,
         virtual adder_interface adder_vif);
        this.adder_vif = adder_vif;
        this.gen2drv_mbox = gen2drv_mbox;
        this.event2gen = event2gen;

    endfunction
    task run();
        forever begin
            gen2drv_mbox.get(tr);
            adder_vif.a = tr.a;
            adder_vif.b = tr.b;
            adder_vif.mode = tr.mode;
            tr.debug_print("DRV");
            #10;
            ->event2gen;

        end
        $display("DRV STOPPED");
    endtask

endclass

class monitor;
    transaction             tr;
    mailbox #(transaction)  mon2scb_mbox;
    virtual adder_interface adder_vif;


    function new(mailbox#(transaction) mon2scb_mbox,
                 virtual adder_interface adder_vif);
        this.adder_vif = adder_vif;
        this.mon2scb_mbox = mon2scb_mbox;
    endfunction

    task run();
        forever begin
            #1;
            tr = new;
            tr.a = adder_vif.a;
            tr.b = adder_vif.b;
            tr.mode = adder_vif.mode;
            tr.s = adder_vif.s;
            tr.c = adder_vif.c;
            mon2scb_mbox.put(tr);
            tr.debug_print("MON");
            #9;
        end
    endtask
endclass


class scoreboard;
    transaction tr;
    mailbox #(transaction) mon2scb_mbox;
    bit [7:0] compare_sum;
    bit       compare_carry;
    int pass_cnt = 0, fail_cnt = 0, total_cnt = 0;
    function new(mailbox#(transaction) mon2scb_mbox);
        this.mon2scb_mbox = mon2scb_mbox;
    endfunction
    
    task run();
        forever begin
            mon2scb_mbox.get(tr);
            tr.debug_print("SCB");
            if(tr.mode) {compare_carry, compare_sum} = tr.a - tr.b;
            else        {compare_carry, compare_sum} = tr.a + tr.b;
            if(compare_sum == tr.s && compare_carry == tr.c) begin 
                $display ("%t: SCB PASS", $time);
                pass_cnt++;
            end 
            else begin 
                $display ("%t: SCB FAIL",$time);
                fail_cnt++;
            end
        end
    endtask

endclass
class environment;
    virtual adder_interface adder_env_vif;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    mailbox #(transaction) gen2drv_mbox;
    mailbox #(transaction) mon2scb_mbox;
    event event2gen;

    function new(virtual adder_interface adder_vif);  //argument interface
        gen2drv_mbox = new();
        mon2scb_mbox = new();
        this.adder_env_vif = adder_vif;
        gen = new(gen2drv_mbox, event2gen);
        drv = new(gen2drv_mbox, event2gen, adder_vif);
        mon = new(mon2scb_mbox, adder_vif);
        scb = new(mon2scb_mbox);
    endfunction

    task run();
        fork
            gen.run(20);
            drv.run();
            mon.run();
            scb.run();
        join_any
        #10;
        $display ("_______________");
        $display ("** TOTAL TEST = %4d**",scb.total_cnt);
        $display ("** PASS COUNT = %4d**",scb.pass_cnt);
        $display ("** FAIL COUNT = %4d**",scb.fail_cnt);
        $display ("_______________");
    endtask

endclass


module tb_adder ();
    adder_interface adder_if ();
    environment env;

    adder DUT (
        .a   (adder_if.a),
        .b   (adder_if.b),
        .mode(adder_if.mode),
        .s   (adder_if.s),
        .c   (adder_if.c)
    );

    initial begin
        env = new(adder_if);
        env.run();
        //#10;
        $stop;
    end
endmodule
