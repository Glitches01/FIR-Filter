##################################################
#  Modelsim do file to run simuilation
#  MS 7/2015
##################################################

#Setup
 vlib work 
 vmap work work

#Include Netlist and Testbench
 vlog +acc -incr /courses/ee6321/share/ibm13rflpvt/verilog/ibm13rflpvt.v
 vlog +acc -incr ../../dc/FIR_Final/FIR_core_N.nl.v
 vlog +acc -incr ../../dc/cmem/CMEM_N.nl.v
 vlog +acc -incr ../../dc/FIFO/FIFO_N.nl.v
 vlog +acc -incr ../../dc/FSM/FSM.nl.v
 vlog +acc -incr ../../dc/IMEM/IMEM_N.nl.v
 vlog +acc -incr ../../dc/ALU/ALU_N.nl.v
 vlog +acc -incr ../../RTL/RF1SHD.v
 vlog +acc -incr ../../RTL/FIR_core_N_tb.v

#Run Simulator 
#SDF from DC is annotated for the timing check 
vsim -voptargs=+acc -t ps -lib work -sdftyp u_fff=../../dc/FIR_Final/FIR_core_N.syn.sdf FIR_core_N_tb
 run -all
