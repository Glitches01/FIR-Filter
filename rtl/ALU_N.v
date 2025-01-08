module ALU_N
	#(
	parameter N=64,
	parameter M=16
	)(
	output signed [37:0] dout,
	output reg valid_out,
	output signed [15:0] fl,

	input clk,
	input rstn,
	input signed [M-1:0] din,
	input en,
	//input en_remake,
	//input en_shift,
	input [5:0] cnt,
	input signed [M-1:0] cin);

//	reg signed [31:0] mul_out;
//	reg [5:0] cnt;
	reg signed [37:0] sum;
	wire signed [31:0] sum_cut;
	assign sum_cut = valid_out?dout[31:0]:0;

	assign dout = valid_out?sum:0;
	fx2fp u_fx2fl(.fx(sum_cut),.fp(fl));

	//counter for 64 multiplication

	always @(posedge clk or negedge rstn) begin
		if(!rstn) begin
			sum <= 0;
			valid_out <= 0;
		end
		else if (en && cnt == 63) begin
			sum <= sum + din*cin;
			valid_out <= 1;
		end
		else if (en) begin
			sum <= sum + din*cin;
			valid_out <= 0;
		end
		else if (!en) begin
			sum <= 0;
			valid_out <= 0;
		end
		else begin
			sum <= sum;
			valid_out <= 0;
		end
	end
endmodule

module fx2fp (fx, fp);
input		[31:0]  fx;
output reg	[15:0]  fp;

reg		[ 4:0]  bit_position;
reg		[ 4:0]  exp;
wire		[31:0]  fx2;
wire 			valid;

integer			j,reverse_bit, count;

assign fx2 = fx[31] ? (~fx + fx[31]) : fx;
assign valid = |fx;


always @ (fx, valid, fx2)
begin
		fp = 16'b0;
        	fp[15] = fx[31];
    if (valid)
    begin

        begin: search_for_1
            for (count = 32; count > 0; count = count - 1)
                begin
                bit_position = count - 1;
                if (fx2[bit_position] == 1)
                    disable search_for_1;
                end
        end
        exp = bit_position - 16; // 6 is the interger bits for the 22 bits fx number
        fp[14:10] = 5'd15 + exp;
        fp[9:0]  = 9'b0;
        j = 9;
        for (count = 0; count < bit_position; count = count + 1)
        begin
            reverse_bit = bit_position - count - 1; // bit position is just the counting cycles, so don't update
            fp[j] = fx2[reverse_bit];
            	j = j - 1;
        end
    end
end
endmodule


