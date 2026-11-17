`timescale 1ns / 1ps

module tb_adder();

reg [7:0]a,b; //4bit msb:lsb
reg cin;
wire [7:0]s; //4bit wire
wire c;
integer i = 0; // 32bit variable for FOR loop in #43
integer j = 0;

//    full_adder dut(
//            .a(a),
//            .b(b),
//            .cin(cin),
//            .s(s),
//            .c(c)
//    );

//Reconstruct seperated variables (.a0(a[0]) -> .a(a))
// full_adder_4bit dut(
//.a0(a[0])
//...
//);

//full_adder_4bit dut(
//    .a(a),
//    .b(b),
//    .s(s),
//    .c(c)
//);

Adder dut(
    .a(a),
    .b(b),
    .s(s),
    .c(c)

);

initial 
begin
    a = 4'b0000;
    b = 4'b0000;
    cin = 1'b0;
    #10;
    for (i = 0; i < 256; i = i+1) 
    begin
        for (j = 0; j < 256; j = j + 1) 
        begin
            a = i;
            b = j;
            #10;
        end 
    end
    
    a = 4'b0000;
    b = 4'b0000;
    cin = 1'b1;
    for (i = 0; i < 256; i = i+1) 
    begin
        for (j = 0; j < 256; j = j + 1) 
        begin
            a = i;
            b = j;
            #10;
        end 
    end    
    // $stop;
    $finish;
end    
endmodule
