module apb_bram(
	input		logic					clk,
	input		logic [ 2:0]	itype,
	input		logic					PSEL,
	input		logic					PENABLE,
	input		logic [31:0]	PADDR,
	input		logic [31:0]	PWDATA,
	input		logic					PWRITE,
	output	logic					PREADY,
	output	logic [31:0]	PRDATA
);

	logic [31:0] dmem[0:127];

	assign PREADY	= (PENABLE & PSEL) ? 1'b1:1'b0;


	// store
	always_ff @(posedge clk) begin
		if (PREADY) begin
			case(itype)
				3'b010:		dmem[PADDR[31:2]]	<= PWDATA;
				default:	dmem[PADDR[31:2]]	<= dmem[PADDR[31:2]];
			endcase
		end
	end
	
	// load
	assign PRDATA = (PREADY) ? dmem[PADDR[31:2]]:32'hz;

endmodule

