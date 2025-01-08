module CMEM_N(
	output wire [15:0] Q,
	input wire [15:0] D,
	input wire [5:0] caddr,
	input wire clk,
	input wire WEN,
	input wire CEN
);
	RF1SHD sram(
		.Q	(Q),
		.A	(caddr),
		.D  (D),
		.WEN	(WEN),
		.CEN	(CEN),
		.CLK	(clk)
	);
endmodule	
