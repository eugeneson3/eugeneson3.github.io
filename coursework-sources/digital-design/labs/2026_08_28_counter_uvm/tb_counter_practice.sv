`include "uvm_macros.svh"
import uvm_pkg::*;

interface counter_if(input clk);
    
    logic       enable;
    logic       rst_n;
    logic [2:0] counter;
    logic       o_tick;


    
endinterface