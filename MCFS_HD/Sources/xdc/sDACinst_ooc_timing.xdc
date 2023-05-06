#---------------------------------------
# Create Clock Constraints - sDACinst 
#---------------------------------------
create_clock -period 50.000 -name clk20_int.clk [get_ports {clk}] -waveform {0.000 25.000}
set_property HD.CLK_SRC BUFGCTRL_X0Y10 [get_ports {clk}]
set_system_jitter 0.0
set_clock_latency -source -max 4.577999999999999 [get_clocks {clk20_int.clk}]
set_clock_latency -source -min 3.721 [get_clocks {clk20_int.clk}]
set_clock_uncertainty 0.103 [get_clocks {clk20_int.clk}]
