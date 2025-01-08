module IMEM_N
	#(
	parameter N=64,
	parameter M=16
	)(
	output reg [15:0] Q,
	input clk,
	input [M-1:0] Data,
	input rstn,
	input en,
	input en_shift,
	input [5:0] cnt,
	output reg shiftDone
	);
	
	integer i;
	reg [M-1:0] xshift [0:N-1];
//	reg [5:0] cnt;

	always @(posedge clk or negedge rstn) begin
		if(!rstn) begin
			for (i=0 ; i<N; i=i+1) begin
				xshift[i] <= 0;
			end
			shiftDone <= 0;
		end
		else if(en_shift) begin
			for (i=0 ; i<N; i=i+1) begin
				xshift[i+1] <= xshift[i];
			end
			xshift[0] <= Data;
			shiftDone <= 'd1;
		end
		else begin
			for (i=0 ; i<N; i=i+1) begin
				xshift[i] <= xshift[i];
			end
			shiftDone <= 0;
		end
	end

	always @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			Q <= 0;
		end
		else if (en) begin
			Q <= xshift[cnt];
		end
		else begin
			Q <= 0;
		end
	end
endmodule
		
		
	
