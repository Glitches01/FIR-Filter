###################################################################### 
## Timing setup for logic synthesis
## The unit for time is ns as defined in the IBM delay-power library
## The unit for wireload is pF as defined in the IBM delay-power library
## MS 2015
###################################################################### 

# Setting variables

set clk_period 10.000
set clk_periodrd 10.000
set clk_uncertainty 0
set clk_transition 0.010
set typical_input_delay 0.05
set typical_output_delay 0.05
set typical_wire_load 0.005


#Create real clock if clock port is found
if {[sizeof_collection [get_ports i_wrclk]] > 0} {
  set clk_name "i_wrclk"
    set clk_port "i_wrclk"
    set clk_name2 "i_rdclk"
    set clk_port2 "i_rdclk"
    #If no waveform is specified, 50% duty cycle is assumed
    create_clock -name i_wrclk -period 100000 [get_ports i_wrclk]
    create_clock -name i_rdclk -period 1000 [get_ports i_rdclk]
    set_drive 0 [get_clocks i_wrclk]
    set_drive 0 [get_clocks i_rdclk]
}

#Set clock uncertainty
set_clock_uncertainty $clk_uncertainty [get_clocks $clk_name2]
#Propagated clock used for gated clocks only
set_clock_transition $clk_transition [get_clocks $clk_name2]

# Configure the clock network
set_fix_hold [all_clocks] 
set_dont_touch_network $clk_port 
set_ideal_network $clk_port
set_dont_touch_network $clk_port2
set_ideal_network $clk_port2 
#set_ideal_network pad_*
#set_ideal_network sc_*

# Set the paths to be ignored in timing opt
#set_false_path -from pad_*
#set_false_path -from sc_*

# Set input and output delays
set_driving_cell -lib_cell INVX1TS [all_inputs]
set_input_delay $typical_input_delay [all_inputs] -clock $clk_name 
remove_input_delay -clock $clk_name [find port $clk_port]
set_input_delay $typical_input_delay [all_inputs] -clock $clk_name2
remove_input_delay -clock $clk_name [find port $clk_port2]
set_output_delay $typical_output_delay [all_outputs] -clock $clk_name2 

# Customize for block
#set_output_delay 52 [all_outputs] -clock $clk_name 
#set_output_delay 0 next_* -clock $clk_name 

# Set loading of outputs 
set_load 0.005 [all_outputs] 
