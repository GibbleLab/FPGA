#---------------------------------------
# Create Clock Constraints - SlowADCs_inst 
#---------------------------------------
create_clock -period 10.000 -name sADC_clk_int.clk [get_ports {clk}] -waveform {0.000 5.000}
set_property HD.CLK_SRC BUFGCTRL_X0Y8 [get_ports {clk}]
create_clock -period 10.000 -name sADC_clk_in_int.data_in_clk [get_ports {data_in_clk}] -waveform {0.000 5.000}
set_property HD.CLK_SRC BUFGCTRL_X0Y9 [get_ports {data_in_clk}]
set_system_jitter 0.0
set_clock_latency -source -max 4.58 [get_clocks {sADC_clk_int.clk}]
set_clock_latency -source -min 3.721 [get_clocks {sADC_clk_int.clk}]
set_clock_uncertainty 0.080 [get_clocks {sADC_clk_int.clk}]
set_clock_latency -source -max 4.191 [get_clocks {sADC_clk_in_int.data_in_clk}]
set_clock_latency -source -min 3.7209999999999996 [get_clocks {sADC_clk_in_int.data_in_clk}]
set_clock_uncertainty 0.080 [get_clocks {sADC_clk_in_int.data_in_clk}]
set_clock_uncertainty -from [get_clocks {sADC_clk_int.clk}] -to [get_clocks {sADC_clk_in_int.data_in_clk}] 0.200
set_clock_uncertainty -from [get_clocks {sADC_clk_in_int.data_in_clk}] -to [get_clocks {sADC_clk_int.clk}] 0.200
