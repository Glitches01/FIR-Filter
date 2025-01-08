module FIFO_N #(
	parameter DEPTH = 16,
	parameter WIDTH = 16
)(
	input i_wrclk	,
	input i_wrstn	,
	input i_wren	,
	input [WIDTH-1:0] i_wdata	,

	input i_rdclk	,
	input i_rdrstn	,
	input i_rden	,
	output [WIDTH-1:0] o_rdata	,
	output o_full	,
	output o_empty);

//ptr
reg	[clogb2(DEPTH-1):0]	r_wrptr;
reg [clogb2(DEPTH-1):0]	r_rdptr;
wire [clogb2(DEPTH-1)-1:0]	w_wraddr;
wire [clogb2(DEPTH-1)-1:0]	w_rdaddr;

assign w_wraddr = r_wrptr[clogb2(DEPTH-1)-1:0];
assign w_rdaddr = r_rdptr[clogb2(DEPTH-1)-1:0];

always @(posedge i_wrclk or negedge i_wrstn) begin
	if(!i_wrstn)
		r_wrptr <= 'd0;
	else if(i_wren && !o_full)
		r_wrptr <= r_wrptr + 1'b1;
	else
		r_wrptr <= r_wrptr;
end

always @(posedge i_rdclk or negedge i_rdrstn) begin
	if(!i_rdrstn)
		r_rdptr <= 'd0;
	else if(i_rden && !o_empty)
		r_rdptr <= r_rdptr + 1'b1;
	else
		r_rdptr <= r_rdptr;
end

//gray code addr
wire [clogb2(DEPTH-1):0]	r_wrptr_gray;
wire [clogb2(DEPTH-1):0]	r_rdptr_gray;

assign r_wrptr_gray = r_wrptr ^ (r_wrptr>>1);
assign r_rdptr_gray = r_rdptr ^ (r_rdptr>>1);

reg [clogb2(DEPTH-1):0]	r_rdptr_gray_d0;
reg [clogb2(DEPTH-1):0]	r_rdptr_gray_d1;
always @(posedge  i_wrclk or negedge i_wrstn) begin
	if(!i_wrstn) begin
		r_rdptr_gray_d0 <= 'd0;
		r_rdptr_gray_d1 <= 'd0;
	end
	else begin
		r_rdptr_gray_d0 <= r_rdptr_gray;
		r_rdptr_gray_d1 <= r_rdptr_gray_d0;
	end
end
reg [clogb2(DEPTH-1):0]	r_wrptr_gray_d0;
reg [clogb2(DEPTH-1):0]	r_wrptr_gray_d1;
always @(posedge  i_rdclk or negedge i_rdrstn) begin
	if(!i_rdrstn) begin
		r_wrptr_gray_d0 <= 'd0;
		r_wrptr_gray_d1 <= 'd0;
	end
	else begin
		r_wrptr_gray_d0 <= r_wrptr_gray;
		r_wrptr_gray_d1 <= r_wrptr_gray_d0;
	end
end

assign o_empty = (r_rdptr_gray == r_wrptr_gray_d1);
assign o_full = (r_wrptr_gray == {~r_rdptr_gray_d1[clogb2(DEPTH-1):clogb2(DEPTH-1)-1],r_rdptr_gray_d1[clogb2(DEPTH-1)-2:0]});

ram #(
	.DATA_WIDTH(WIDTH),
	.DATA_DEPTH(DEPTH)
)
u_ram(
	.i_wrclk(i_wrclk),
	.i_wrstn(i_wrstn),
	.i_wren(i_wren),
	.i_waddr(w_wraddr),
	.i_wdata(i_wdata),
	.i_rdclk(i_rdclk),
	.i_rdrstn(i_rdrstn),
	.i_rden(i_rden),
	.i_raddr(w_rdaddr),
	.o_rdata(o_rdata)
);

function integer clogb2(input integer number);
begin
	for(clogb2 = 0; number > 0; clogb2 = clogb2 + 1)
		number = number >> 1;
end
endfunction

endmodule

module ram #(
	parameter DATA_WIDTH = 16	,
	parameter DATA_DEPTH = 16
)
(
	input	i_wrclk	,
	input 	i_wrstn	,
	input 	i_wren	,
	input	[clogb2(DATA_DEPTH-1)-1:0]	i_waddr	,
	input	[DATA_WIDTH-1:0]	i_wdata	,

	input	i_rdclk	,
	input 	i_rdrstn	,
	input 	i_rden	,
	input	[clogb2(DATA_DEPTH-1)-1:0] i_raddr	,
	output	[DATA_WIDTH-1:0]	o_rdata
);

reg [DATA_WIDTH-1:0] dual_ram [0:DATA_DEPTH];
reg [DATA_WIDTH-1:0] r_rdata;

integer i;

always @(posedge i_wrclk or negedge i_wrstn) begin
	if(!i_wrstn)
		for(i = 0; i < DATA_DEPTH ; i = i + 1)
			dual_ram[i] <= 'd0;
	else if (i_wren)
		dual_ram[i_waddr] <= i_wdata;
	else
		dual_ram[i_waddr] <= dual_ram[i_waddr];
end

always @(posedge i_rdclk or negedge i_rdrstn) begin
	if(!i_rdrstn)
		r_rdata <= 'd0;
	else if(i_rden)
		r_rdata <= dual_ram[i_raddr];
	else
		r_rdata <= r_rdata;
end

assign o_rdata = r_rdata;

function integer clogb2(input integer number);
begin
	for(clogb2 = 0; number > 0; clogb2 = clogb2 + 1)
		number = number >> 1;
end
endfunction

endmodule
