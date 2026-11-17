`timescale 1ns / 1ps
// virtual function (static binding, dynamic binding)
module tb_practice_oop_ex6 ();
    class transaction;
        function void hello_nonvirtual();
            $display(" execute: transaction::hello_nonvirtual");
        endfunction

        virtual function void hello_virtual();
            $display(" execute: transaction::hello_nonvirtual");
        endfunction
    endclass


    class read_txn extends transaction;
        function void hello_nonvirtual();
            $display(" execute: read_txn::hello_nonvirtual");
        endfunction

        virtual function void hello_virtual();
            $display(" execute: read_txn::hello_nonvirtual");
        endfunction
    endclass
    transaction t;
    read_txn    r;
    initial begin 
        $display("[ex6] handle is transaction, actual object is read_txn");
        r = new();
        t = r;// t: upcasting, parent's handle by child object

        $display("A) t.hello_nonvirtual() execute");
        t.hello_nonvirtual();

        $display("B) r.hello_nonvirtual() execute");
        r.hello_nonvirtual();

        $display("A) t.hello_virtual() execute");
        t.hello_virtual();

        $display("B) r.hello_virtual() execute");
        r.hello_virtual();
        $finish;
    end
endmodule
