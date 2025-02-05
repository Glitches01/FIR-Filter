`timescale 1ns/1ps
`define SD #0.010
`define HALF_CLOCK_PERIOD #5
`define QSIM_OUT_FN "./qsim.out"
`define MATLAB_OUT_FN "../../matlab/lfsr1/lfsr1.results"

module testbench();

   reg clk, resetn;
   reg [15:0] seed;
   //reg [15:0] lfsr_out_matlab;
   integer lfsr_out_matlab,lfsr_out_qsim;
   wire [15:0] lfsr_out;
   integer i,ret_write,ret_read,qsim_out_file,matlab_out_file;
   integer error_count = 0;

   lfsr1 lfsr_0 ( .clk(clk), .resetn(resetn), .seed(seed), .lfsr_out(lfsr_out) );

   always begin
      `HALF_CLOCK_PERIOD;
      clk = ~clk;
   end

   initial begin
       //File IO
       qsim_out_file = $fopen(`QSIM_OUT_FN,"w");
       if (!qsim_out_file)
       begin
          $display("Couldn't create the output file.");
          $finish;
       end
       matlab_out_file = $fopen(`MATLAB_OUT_FN,"r");
       if (!matlab_out_file)
       begin
          $display("Couldn't open the Matlab file.");
          $finish;
       end
       
       $dumpfile("./lfsr1.vcd");
       $dumpvars(0,testbench.lfsr_0);

       //register setup
       clk = 0;
       resetn = 0;
       seed = 16'd1;
       @(posedge clk);

       @(negedge clk);   //release resetn
       resetn = 1;      

       @(posedge clk);   //start the first cycle
       for (i=0 ; i<256; i=i+1)
       begin
          //compare w/ the results from Matlab sim
          ret_read = $fscanf(matlab_out_file, "%d", lfsr_out_matlab);
          lfsr_out_qsim=lfsr_out;
          if(lfsr_out_qsim != lfsr_out_matlab)
          begin
             error_count = error_count + 1;
          end

          @(posedge clk);  //next cycle
       end

       //Any mismatch b/w rtl and matlab sims?
       if(error_count>0) $display("The results DO NOT match with those from Matlab :( ");
       else $display("The results DO match with those from Matlab :) ");
         
 
       //finishing this testbench
       $fclose(qsim_out_file);
       $fclose(matlab_out_file);
       
       $dumpall;
       $dumpflush;

       $finish;
   end 

endmodule // testbench

