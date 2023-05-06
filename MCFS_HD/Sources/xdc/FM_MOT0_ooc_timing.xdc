#---------------------------------------
# Create Clock Constraints - FM_MOT0 
#---------------------------------------
create_clock -period 10.000 -name clk100_int.clk [get_ports {clk}] -waveform {0.000 5.000}
set_property HD.CLK_SRC BUFGCTRL_X0Y0 [get_ports {clk}]
set_system_jitter 0.0
set_clock_latency -source -max 5.508 [get_clocks {clk100_int.clk}]
set_clock_latency -source -min 5.038 [get_clocks {clk100_int.clk}]
set_clock_uncertainty 0.080 [get_clocks {clk100_int.clk}]
