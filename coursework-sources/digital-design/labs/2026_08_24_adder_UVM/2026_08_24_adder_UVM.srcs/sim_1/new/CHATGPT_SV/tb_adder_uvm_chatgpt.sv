`timescale 1ns / 1ps
// UVM 매크로 정의 파일을 포함합니다. 아래의 `uvm_* 매크로를 사용할 수 있게 합니다.
`include "uvm_macros.svh"
// uvm_pkg 안의 UVM 클래스, Factory, phase, config_db 등을 현재 파일에서 사용합니다.
import uvm_pkg::*;

interface adder_if (
    input logic clk
);
    logic [7:0] a, b;
    logic [8:0] y;
endinterface

class adder_item extends uvm_sequence_item;
    // Sequence가 Driver로 전달할 하나의 transaction입니다. a와 b는 randomize 대상입니다.
    rand logic [7:0] a, b;
    logic [8:0] y;
    `uvm_object_utils_begin(adder_item)
    // adder_item을 UVM Factory에 등록하고 type_id::create() 생성을 가능하게 합니다.
        `uvm_field_int(a, UVM_DEFAULT)
    // a를 UVM 자동 print/copy/compare/record 처리 대상에 등록합니다.
        `uvm_field_int(b, UVM_DEFAULT)
    // b를 UVM 자동 print/copy/compare/record 처리 대상에 등록합니다.
        `uvm_field_int(y, UVM_DEFAULT)
    // y를 UVM 자동 처리 대상에 등록합니다. 이 begin/end 구간이 field 등록 영역입니다.
    `uvm_object_utils_end
    function new(string name = "adder_item");
        // uvm_sequence_item의 이름을 부모 생성자에 전달합니다. item은 parent가 없습니다.
        super.new(name);
    endfunction
endclass

class adder_sequence extends uvm_sequence #(adder_item);
    // #(adder_item)은 이 Sequence가 adder_item transaction만 다룬다는 뜻입니다.
    // Sequence 자체를 Factory에 등록하여 type_id::create()로 만들 수 있게 합니다.
    `uvm_object_utils(adder_sequence)
    function new(string name = "adder_sequence");
        super.new(name);
    endfunction
    task body();
        // body()는 seq.start(...)를 호출했을 때 UVM이 실행하는 Sequence의 본문입니다.
        adder_item req;
        repeat (100) begin
            // Factory에서 transaction을 만들고 sequencer를 통해 Driver로 보냅니다.
            // type_id::create()는 UVM Factory를 통해 객체를 생성합니다.
            // 직접 new()하지 않으므로 Factory override로 다른 파생 타입으로 교체할 수 있습니다.
            req = adder_item::type_id::create("req");
            // start_item(): Sequencer에 transaction 전송을 시작한다고 알리고,
            // Driver가 이 transaction을 받을 수 있는 시점까지 필요하면 기다립니다.
            start_item(req);
            // rand 필드 a,b에 임의 값을 생성합니다. 실패하면 즉시 시뮬레이션을 중단합니다.
            if (!req.randomize()) `uvm_fatal("RAND", "Randomization failed")
            // finish_item(): randomize가 끝난 req를 Sequencer에 전달합니다.
            // 이후 Driver의 get_next_item(req)가 같은 transaction을 받습니다.
            finish_item(req);
        end
    endtask
endclass

class adder_driver extends uvm_driver #(adder_item);
    // Sequencer의 transaction을 받아 DUT 입력 신호로 변환하는 UVM 컴포넌트입니다.
    // component_utils는 이 컴포넌트를 Factory에 등록합니다.
    // uvm_driver가 상속해 주는 seq_item_port와 req를 사용합니다.
    // #(adder_item) 때문에 req의 타입은 adder_item이며, 포트도 adder_item만 전달합니다.
    `uvm_component_utils(adder_driver)
    // virtual interface는 class 안에서 module/interface의 신호에 접근하기 위한 핸들입니다.
    virtual adder_if vif;
    function new(string name, uvm_component parent);
        // component는 UVM 계층에 소속되므로 name과 parent를 모두 부모 생성자에 전달합니다.
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        // build_phase는 UVM이 컴포넌트를 만들고 설정값을 준비하는 단계에 한 번 호출합니다.
        super.build_phase(phase);
        // config_db::get()은 top에서 저장한 interface 핸들을 읽어 오는 함수입니다.
        // this=현재 Driver, ""=현재 위치, "vif"=설정 이름, 마지막 vif=받은 값을 담을 변수입니다.
        // get()은 성공 시 1, 찾지 못하면 0을 반환합니다.
        if (!uvm_config_db#(virtual adder_if)::get(this, "", "vif", vif))
            // `uvm_fatal은 오류를 출력하고 시뮬레이션을 즉시 종료합니다.
            `uvm_fatal(
            "NOVIF", "adder_if was not configured")
    endfunction
    task run_phase(uvm_phase phase);
        // run_phase는 시간 진행이 가능한 실행 단계이며, Driver가 계속 transaction을 처리합니다.
        forever begin
            // seq_item_port는 Driver가 Sequencer에서 transaction을 pull(가져오기)하는 TLM 포트입니다.
            // get_next_item(req): Sequence가 finish_item()한 다음 transaction을 req에 넣습니다.
            // 아직 전달된 transaction이 없으면 여기서 대기하며, 받은 뒤에는 item_done()을 호출해야 합니다.
            seq_item_port.get_next_item(req);
            // 다음 transaction을 받고, clock falling edge에 DUT 입력을 구동합니다.
            @(negedge vif.clk);
            vif.a <= req.a;
            vif.b <= req.b;
            // item_done(): get_next_item()으로 받은 현재 transaction의 처리가 끝났음을 Sequencer에 알립니다.
            // 이 호출 뒤에 Sequencer는 다음 transaction을 Driver에 전달할 수 있습니다.
            seq_item_port.item_done();
        end
    endtask
endclass

class adder_monitor extends uvm_monitor;
    // DUT의 입력/출력을 관찰하여 transaction으로 만들어 분석 포트로 전송합니다.
    `uvm_component_utils(adder_monitor)
    virtual adder_if vif;
    uvm_analysis_port #(adder_item) ap;
    // 다른 컴포넌트가 transaction을 구독할 수 있는 broadcast 포트입니다.
    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
        // analysis_port 객체를 생성합니다. connect_phase에서 Scoreboard에 연결됩니다.
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Driver와 같은 key("vif")로 virtual interface를 가져옵니다.
        // interface가 없으면 DUT 신호를 관찰할 수 없으므로 fatal로 종료합니다.
        if (!uvm_config_db#(virtual adder_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "adder_if was not configured")
    endfunction
    task run_phase(uvm_phase phase);
        adder_item item;
        forever begin
            @(posedge vif.clk);
            #1;
            // Monitor용 transaction도 Factory를 통해 생성합니다.
            item   = adder_item::type_id::create("item");
            item.a = vif.a;
            item.b = vif.b;
            item.y = vif.y;
            // 관찰한 값을 scoreboard로 전달합니다. DUT 신호를 직접 scoreboard가 보지 않습니다.
            ap.write(item);
            // write()는 연결된 모든 analysis_export에 item을 전달합니다.
        end
    endtask
endclass

class adder_scoreboard extends uvm_subscriber #(adder_item);
    // Monitor가 보낸 transaction을 받아 예상값과 DUT 결과를 비교합니다.
    // uvm_subscriber는 analysis_export를 이미 가지므로 Monitor와 연결할 수 있습니다.
    `uvm_component_utils(adder_scoreboard)
    int pass_count, fail_count;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    function void write(adder_item item);
        // adder의 정답은 a+b이며, y와 다르면 UVM 오류를 발생시킵니다.
        if (item.y === (item.a + item.b)) begin
            pass_count++;
            // `uvm_info는 설정한 verbosity 이상일 때만 정보 메시지를 출력합니다.
            `uvm_info("PASS", $sformatf("a=%0d b=%0d y=%0d", item.a, item.b,
                                        item.y), UVM_MEDIUM)
        end else begin
            fail_count++;
            // `uvm_error는 오류를 기록하지만 이 문장만으로 즉시 종료되지는 않습니다.
            `uvm_error("FAIL", $sformatf(
                       "a=%0d b=%0d y=%0d expected=%0d",
                       item.a,
                       item.b,
                       item.y,
                       item.a + item.b
                       ))
        end
    endfunction
    function void report_phase(uvm_phase phase);
        // report_phase는 모든 run_phase가 끝난 뒤 결과 요약을 출력하는 단계입니다.
        `uvm_info("SUMMARY", $sformatf(
                  "PASS=%0d FAIL=%0d", pass_count, fail_count), UVM_NONE)
        if (fail_count != 0) `uvm_error("RESULT", "ADDER UVM TEST FAILED")
    endfunction
endclass

class adder_agent extends uvm_agent;
    // 하나의 검증 인터페이스 단위입니다. Sequencer, Driver, Monitor를 묶습니다.
    `uvm_component_utils(adder_agent)
    uvm_sequencer #(adder_item) sequencer;
    // Sequencer는 Sequence와 Driver 사이에서 transaction 전달을 중재합니다.
    adder_driver driver;
    adder_monitor monitor;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // type_id::create(name, parent)는 Factory로 UVM 컴포넌트를 계층에 생성합니다.
        // Factory override가 있으면 지정한 파생 클래스가 대신 생성될 수 있습니다.
        sequencer =
            uvm_sequencer#(adder_item)::type_id::create("sequencer", this);
        driver  = adder_driver::type_id::create("driver", this);
        monitor = adder_monitor::type_id::create("monitor", this);
    endfunction
    function void connect_phase(uvm_phase phase);
        // Sequencer가 만든 transaction을 Driver가 받도록 TLM 포트를 연결합니다.
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass

class adder_env extends uvm_env;
    // 전체 검증 환경입니다. Agent와 Scoreboard를 포함합니다.
    `uvm_component_utils(adder_env)
    adder_agent agent;
    adder_scoreboard scoreboard;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // type_id::create()는 이름과 parent를 사용해 UVM 계층에 컴포넌트를 생성합니다.
        // Factory override를 적용할 수 있어 재사용성과 확장성이 높습니다.
        agent = adder_agent::type_id::create("agent", this);
        scoreboard = adder_scoreboard::type_id::create("scoreboard", this);
    endfunction
    function void connect_phase(uvm_phase phase);
        // Monitor의 broadcast 포트를 Scoreboard의 입력에 연결합니다.
        agent.monitor.ap.connect(scoreboard.analysis_export);
    endfunction
endclass

class adder_test extends uvm_test;
    // 최상위 UVM 테스트입니다. 환경을 만들고 sequence를 실행합니다.
    `uvm_component_utils(adder_test)
    adder_env env;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // UVM Factory에서 환경을 생성합니다. 두 번째 인자는 부모 컴포넌트입니다.
        env = adder_env::type_id::create("env", this);
    endfunction
    task run_phase(uvm_phase phase);
        // Sequence도 Factory로 생성하므로 테스트 설정에 따라 다른 Sequence로 교체할 수 있습니다.
        adder_sequence seq = adder_sequence::type_id::create("seq");
        // raise_objection(): "테스트가 아직 진행 중"이라고 UVM phase에 선언합니다.
        // objection 수가 0이 되기 전에는 UVM이 run_phase를 끝내지 않습니다.
        phase.raise_objection(this);
        // start()가 sequence의 body()를 실행하고, 대상 sequencer로 item을 전달합니다.
        seq.start(env.agent.sequencer);
        #20;
        // drop_objection(): 이 test의 작업이 끝났다고 알립니다.
        // 모든 컴포넌트의 objection 수가 0이 되면 UVM은 run_phase를 종료합니다.
        phase.drop_objection(this);
    endtask
endclass

module tb_adder_uvm_chatgpt;
    // 실제 DUT, clock, interface, UVM test를 연결하는 최상위 모듈입니다.
    logic clk = 0;
    always #5 clk = ~clk;
    adder_if vif (clk);
    adder dut (
        .a(vif.a),
        .b(vif.b),
        .y(vif.y)
    );
    initial begin
        // 시작 시 DUT 입력을 알 수 없는 X가 아닌 0으로 초기화합니다.
        vif.a = '0;
        vif.b = '0;
        // set()은 UVM config_db에 virtual interface를 저장합니다.
        // null=최상위 기준, "uvm_test_top.env.agent*"=Driver/Monitor를 포함하는 적용 경로,
        // "vif"=key, 마지막 vif=저장할 실제 interface입니다.
        uvm_config_db#(virtual adder_if)::set(null, "uvm_test_top.env.agent*",
                                              "vif", vif);
        // UVM test 이름으로 Factory를 통해 adder_test를 생성하고 실행합니다.
        // run_test()는 build/connect/run/report 등 UVM phase 전체를 순서대로 진행합니다.
        run_test("adder_test");
    end
endmodule
