#---------------------------------------
# Create Clock Constraints - SR_CTRL0 
#---------------------------------------
create_clock -period 20.000 -name clk50_int.CLK_IN [get_ports {CLK_IN}] -waveform {0.000 10.000}
set_property HD.CLK_SRC BUFGCTRL_X0Y11 [get_ports {CLK_IN}]
set_system_jitter 0.0
set_clock_latency -source -max 4.57 [get_clocks {clk50_int.CLK_IN}]
set_clock_latency -source -min 3.721 [get_clocks {clk50_int.CLK_IN}]
set_clock_uncertainty 0.089 [get_clocks {clk50_int.CLK_IN}]
