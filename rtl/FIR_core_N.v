module FIR_core_N
	#(
	parameter N=64,//number of taps
	parameter M=16//number of bits
	)(
	output signed [37:0] dout,//output port
	output valid_out,//valid_out high means output valid
	output signed [15:0] fl,

	input clk1,//sampling clk/wclk
	input clk2,//operating clk/rclk
	input rstn,//total rstn
	input signed [15:0] din,//input port
	input valid_in,//valid_in high means there is a input
	input signed [M-1:0] cin,//coefficient input
	input [5:0] caddr,//address for coefficient
	input cload);//control signal for loading coefficient
//counter for control
	reg [5:0] cnt;
	reg mac_enable;
	wire cen;assign cen = 0;
	wire wren, rden, empty, full;wire [15:0] fifo_out;//FIFO
	wire start;
	assign start = !empty;
	reg [5:0] coeff_addr;
///////////////
	wire [5:0] caddress; wire [15:0] coeff;assign caddress = (~cload)?coeff_addr:caddr;
	CMEM_N u_cmem(.Q(coeff), .D(cin), .caddr(caddress), .clk(clk2), .CEN(cen), .WEN(~cload));
///////////////
	wire write_fifo, read_fifo;
	FIFO_N u_fifo (
	    .i_wrclk(clk1), .i_wrstn(rstn), .i_wren(write_fifo), .i_wdata(din),
	    .i_rdclk(clk2), .i_rdrstn(rstn),.i_rden(read_fifo), .o_rdata(fifo_out),
	    .o_full(full), .o_empty(empty)
	);
//////////////
	wire alu_en; wire en_shift; wire shiftDone;
	FSM u_fsm(.clk(clk2), .rstn(rstn), .valid_in(valid_in), .start(start),
				.shiftDone(shiftDone), .valid_out(valid_out), .write_fifo(write_fifo),
				.read_fifo(read_fifo), .en_shift(en_shift), .alu_en(alu_en));
//////////////
	wire [15:0] Xin;
	IMEM_N u_imem(.Q(Xin), .clk(clk2), .Data(fifo_out), .rstn(rstn), .en(alu_en), 
			.en_shift(en_shift), .cnt(cnt), .shiftDone(shiftDone));

	ALU_N u_alu(.rstn(rstn), .clk(clk2), .en(mac_enable), .din(Xin), .cin(coeff),
		.dout(dout), .valid_out(valid_out), .cnt(coeff_addr), .fl(fl));

	always @(negedge clk2 or negedge rstn) begin
		if(!rstn) begin
			coeff_addr <= 'd0;
			mac_enable <= 'd0;
		end else if (alu_en) begin
			coeff_addr <= cnt;
			mac_enable <= alu_en;
		end else begin
			coeff_addr <= coeff_addr;
			mac_enable <= 0;
		end
	end
always @(posedge clk2 or negedge rstn) begin
	if(!rstn) begin
		cnt <= 'd0;
	end
	else if(alu_en) begin
		cnt <= cnt + 'd1;
	end
	else begin
		cnt <= 0;
	end
end
endmodule

