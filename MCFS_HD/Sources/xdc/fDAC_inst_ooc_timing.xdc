#---------------------------------------
# Create Clock Constraints - fDAC_inst 
#---------------------------------------
create_clock -period 5.000 -name fDAC_clk.clk_in [get_ports {clk_in}] -waveform {0.000 2.500}
set_property HD.CLK_SRC MMCME2_ADV_X1Y2 [get_ports {clk_in}]
create_clock -period 5.000 -name fDAC_clk_out.clk_out_in [get_ports {clk_out_in}] -waveform {1.719 4.219}
set_property HD.CLK_SRC MMCME2_ADV_X1Y2 [get_ports {clk_out_in}]
set_system_jitter 0.0
set_clock_latency -source -max 4.154 [get_clocks {fDAC_clk.clk_in}]
set_clock_latency -source -min 3.307 [get_clocks {fDAC_clk.clk_in}]
set_clock_uncertainty 0.072 [get_clocks {fDAC_clk.clk_in}]
