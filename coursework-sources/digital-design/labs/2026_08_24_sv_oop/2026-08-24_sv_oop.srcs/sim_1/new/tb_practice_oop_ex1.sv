`timescale 1ns / 1ps

module tb_practice_oop_ex1;

    class base_packet;
        int id;

        function new(int id);
            this.id = id;
            $display("1) base_packet::new runs (id = %0d)", id);
        endfunction
    endclass

    class eth_packet extends base_packet;
        bit [47:0] mac_da;

        function new(int id, bit [47:0] da);
            super.new(id);
            mac_da = da;
            $display("2) ETH_PACKET::NEW RUNS (DA = %012h)", da);
        endfunction
    endclass

    eth_packet e;

    initial begin
        $display("[ex01] executing a single line: eth_packet e = new()");
        e = new(7, 48'haabbccddeeff);

        $display("3) finished object: id = %0d, da = %012h",
                 e.id, e.mac_da);

        $display("=> The child inherits parent's member (id) and uses it");
    end

endmodule