`include "uvm_macros.svh"
import uvm_pkg::*;

interface counter_if (
    input logic clk
);

    logic       rst_n;
    logic       enable;
    logic [2:0] counter;
    logic       o_tick;

    clocking drv_cb @(posedge clk);
        default input #1step output #1;
        output rst_n;
        output enable;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input rst_n;
        input enable;
        input counter;
        input o_tick;
    endclocking

    modport drv_mb(clocking drv_cb, input clk);
    modport mon_mb(clocking mon_cb, input clk);

endinterface


class counter_seq_item extends uvm_sequence_item;

    rand bit         enable;
    rand logic       rst_n;   // rand 키워드 추가
    logic      [2:0] counter;
    logic            o_tick;

    constraint c_en {
        enable dist {
            0 := 3,
            1 := 7
        };
    }

    `uvm_object_utils_begin(counter_seq_item)
        `uvm_field_int(enable, UVM_DEFAULT)
        `uvm_field_int(rst_n, UVM_DEFAULT)
        `uvm_field_int(counter, UVM_DEFAULT)
        `uvm_field_int(o_tick, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "counter_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "rst_n=%0b enable=%0b counter=%0d o_tick=%0b",
            rst_n,
            enable,
            counter,
            o_tick
        );
    endfunction

endclass


class reset_sequence extends uvm_sequence #(counter_seq_item);

    `uvm_object_utils(reset_sequence)

    function new(string name = "reset_sequence");
        super.new(name);
    endfunction

    virtual task body();
        repeat (5) begin
            counter_seq_item item;
            item = counter_seq_item::type_id::create("item");

            start_item(item);
            if (!item.randomize() with {
                rst_n  == 1'b0;
                enable == 1'b0;
            }) begin 
                `uvm_error(get_type_name(), "Reset randomize failed")
            end
            finish_item(item);
        end
    endtask

endclass


class counter_sequence extends uvm_sequence #(counter_seq_item);

    `uvm_object_utils(counter_sequence)

    function new(string name = "counter_sequence");
        super.new(name);
    endfunction

    virtual task body();
        repeat (100) begin
            counter_seq_item item;
            item = counter_seq_item::type_id::create("item");

            start_item(item);
            if (!item.randomize() with { rst_n == 1'b1; }) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end
            finish_item(item);
        end
    endtask

endclass


class counter_driver extends uvm_driver #(counter_seq_item);

    `uvm_component_utils(counter_driver)

    virtual counter_if vif;

    function new(string name = "counter_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual counter_if)::get(
                this, "", "vif", vif
            )) begin
            `uvm_fatal(get_type_name(), "Cannot get virtual interface")
        end
    endfunction

    virtual task pre_set();
        vif.drv_cb.rst_n  <= 1'b0; // c_if -> vif로 변경
        vif.drv_cb.enable <= 1'b0;
        @(vif.drv_cb);
    endtask

    task run_phase(uvm_phase phase);
        counter_seq_item item;
        super.run_phase(phase);

        pre_set();
        repeat (2) @(vif.drv_cb);

        forever begin
            seq_item_port.get_next_item(item);

            vif.drv_cb.rst_n  <= item.rst_n;
            vif.drv_cb.enable <= item.enable;

            `uvm_info(get_type_name(), $sformatf(
                      "Drive: enable=%0b, rst_n=%0b", item.enable, item.rst_n), UVM_MEDIUM)

            @(vif.drv_cb);

            seq_item_port.item_done();
        end
    endtask

endclass


class counter_monitor extends uvm_monitor;

    `uvm_component_utils(counter_monitor)

    virtual counter_if vif;
    uvm_analysis_port #(counter_seq_item) ap;

    function new(string name = "counter_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual counter_if)::get(
                this, "", "vif", vif
            )) begin
            `uvm_fatal(get_type_name(), "Cannot get virtual interface")
        end
    endfunction

    task run_phase(uvm_phase phase);
        counter_seq_item item;

        forever begin
            @(vif.mon_cb);

            item = counter_seq_item::type_id::create("item");

            item.rst_n   = vif.mon_cb.rst_n;
            item.enable  = vif.mon_cb.enable;
            item.counter = vif.mon_cb.counter;
            item.o_tick  = vif.mon_cb.o_tick;

            ap.write(item);

            `uvm_info(get_type_name(), {"Monitor: ", item.convert2string()}, UVM_HIGH)
        end
    endtask

endclass


class counter_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(counter_scoreboard)

    uvm_analysis_imp #(counter_seq_item, counter_scoreboard) imp;

    logic [2:0] expected_counter;
    logic       expected_tick;

    function new(string name = "counter_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        imp = new("imp", this);
    endfunction

    function void write(counter_seq_item item);

        if (!item.rst_n) begin
            expected_counter = 3'd0;
            expected_tick    = 1'b0;
        end else begin
            expected_tick = 1'b0;

            if (item.enable) begin
                if (expected_counter == 3'd7) begin
                    expected_counter = 0;
                    expected_tick    = 1'b1;
                end else begin
                    expected_counter = expected_counter + 3'd1;
                end
            end
        end

        if (item.counter !== expected_counter || item.o_tick !== expected_tick) begin
            `uvm_error(
                "COUNTER_MISMATCH",
                $sformatf(
                    "Expected counter=%0d tick=%0b, Actual counter=%0d tick=%0b",
                    expected_counter, expected_tick, item.counter, item.o_tick
                )
            )
        end else begin
            `uvm_info("COUNTER_MATCH", $sformatf("counter=%0d tick=%0b", item.counter, item.o_tick), UVM_LOW)
        end
    endfunction

endclass


class counter_agent extends uvm_agent;

    `uvm_component_utils(counter_agent)

    counter_driver                  driver;
    counter_monitor                 monitor;
    uvm_sequencer #(counter_seq_item) sequencer;

    function new(string name = "counter_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        driver    = counter_driver::type_id::create("driver", this);
        monitor   = counter_monitor::type_id::create("monitor", this);
        sequencer = uvm_sequencer#(counter_seq_item)::type_id::create("sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass


class counter_env extends uvm_env;

    `uvm_component_utils(counter_env)

    counter_agent      agent;
    counter_scoreboard scoreboard;

    function new(string name = "counter_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent      = counter_agent::type_id::create("agent", this);
        scoreboard = counter_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        agent.monitor.ap.connect(scoreboard.imp);
    endfunction

endclass


class counter_test extends uvm_test;

    `uvm_component_utils(counter_test)

    counter_env env;

    function new(string name = "counter_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = counter_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        reset_sequence reset_seq;
        counter_sequence seq;

        phase.raise_objection(this);

        reset_seq = reset_sequence::type_id::create("reset_seq");
        reset_seq.start(env.agent.sequencer);

        seq = counter_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);

        repeat (5) @(env.agent.driver.vif.mon_cb);

        phase.drop_objection(this);
    endtask

endclass


module tb_counter;

    logic clk = 1'b0;

    always #5 clk = ~clk;

    counter_if c_if (clk);

    counter DUT (
        .clk    (clk),
        .rst_n  (c_if.rst_n),
        .enable (c_if.enable),
        .counter(c_if.counter),
        .o_tick (c_if.o_tick)
    );

    initial begin
        $fsdbDumpfile("build/wave.fsdb");
        $fsdbDumpvars(0, tb_counter);
    end

    initial begin
        uvm_config_db#(virtual counter_if)::set(null, "*", "vif", c_if);
        run_test("counter_test");
    end

endmodule