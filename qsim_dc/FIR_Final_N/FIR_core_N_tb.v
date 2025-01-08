`timescale 1ns/1ps
`define WCLK_PERIOD 100000//10kHz sampling frequency
`define RCLK_PERIOD 1000

module FIR_core_N_tb;
parameter DATA_WIDTH = 16;
parameter DATA_DEPTH = 16;
parameter M = 16;
parameter N = 64;
parameter SIN_DATA_NUM = 10; 


reg wclk,rclk,rstn,cload;
reg [M-1:0] din;
reg [M-1:0] cin;
reg valid_in;
reg [5:0] caddr;
wire valid_out;
wire [37:0] dout;
wire [15:0] fl;
FIR_core_N u_fff(
    .clk1(wclk),           // ??1??
    .clk2(rclk),           // ??2??
    .rstn(rstn),           // ?????????

    .din(din),             // ????
    .valid_in(valid_in),   // ??????
    .cin(cin),             // ????
    .caddr(caddr),         // ????
    .cload(cload),         // ??????

    .dout(dout),
	.valid_out(valid_out),
	.fl(fl)
);
//clk setting
initial begin
	wclk = 0;
	forever #(`WCLK_PERIOD/2) wclk = ~wclk;
end

initial begin
	rclk = 0;
	forever #(`RCLK_PERIOD/2) rclk = ~rclk;
end

//stimulation
integer i;
integer	fd1, fd2;
integer err1, err2;
reg [320:0] str1, str2;
reg [15:0] stimulus [0:SIN_DATA_NUM-1];
reg [15:0] coeff [0:N-1];
reg [31:0] OUT;
integer file_dout;
initial begin
    file_dout = $fopen("dout_values.txt", "w");
end
 always @(posedge rclk) begin
    if (valid_out) begin
        // $fwrite(file_dout, "Time: %0t, dout: %016b\n", $time, dout);
        $fwrite(file_dout, "%016b\n", fl);
    end
end
always @(posedge rclk or negedge rstn) begin
	if(!rstn) begin
		OUT <= 'd0;
	end
	else if(dout!=0) begin
		OUT <= dout[31:0];
	end
end
reg [15:0] fp;
always @(posedge rclk or negedge rstn) begin
	if(!rstn) begin
		fp <= 'd0;
	end
	else if(fl!=0) begin
		fp <= fl[15:0];
	end
end
initial begin
	cload = 0;
	caddr = 0;
	cin = 0;
//PT .vcd
	$dumpfile("./FIR_core.vcd");
	$dumpvars(0,FIR_core_N_tb.u_fff);
//data loading from .txt
	fd1 = $fopen("../../matlab/coefficient.txt","r");
	err1 = $ferror(fd1,str1);
	fd2 = $fopen("../../matlab/input.txt","r");
	err2 = $ferror(fd2,str2);
	$display("File:", fd1);
//use below for post verification
	//fd1 = $fopen("../../matlab/coefficient.txt","r");
	//err1 = $ferror(fd1,str1);
	//fd2 = $fopen("../../matlab/input.txt","r");
	//err2 = $ferror(fd2,str2);
	$display("File:", fd2);
	if (!err1) begin
		for (i=0; i<64; i=i+1) begin
			$fscanf(fd1,"%b",coeff[i]);
			$display("coeff: %d, %b",i,coeff[i]);
		end
	end
	if (!err1) begin
		for (i=0; i<SIN_DATA_NUM; i=i+1) begin
			$fscanf(fd2,"%b",stimulus[i]);
			$display("stimulus: %d, %b",i,stimulus[i]);
		end
	end
//rstn	
	din = 0;
	valid_in = 0;
	rstn = 0;
	repeat(10) @(posedge rclk);
	rstn = 1;

//cload, load all the coefficient to sram
	repeat(20) @(negedge rclk);
	@(negedge rclk);
	for(i = 0; i < 64; i = i + 1) begin
		@(negedge rclk);
		cload = 1;
		caddr = i;
		//cin = i;
		cin = coeff[i];
	end
	@(negedge rclk);
	cload = 0;

//start sampling and FIFOs start and calculation
	for(i = 1; i < SIN_DATA_NUM; i = i + 1) begin
		@(negedge wclk);
		valid_in = 1;
		din = stimulus[i];
		//din = i;
	end
	repeat(2) @(negedge wclk);
	$dumpall;
	$dumpflush;
	$finish;

	
end


endmodule




