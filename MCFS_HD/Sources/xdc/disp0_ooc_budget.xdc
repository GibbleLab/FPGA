create_clock -period 20 -name clk50_int.sclk [get_ports {sclk}] -waveform { 0.000000 10.000000  }
set_property HD.CLK_SRC BUFGCTRL_X0Y11 [get_ports {sclk}] 
set_max_delay -from [get_pins {CS0_OUT_reg/C}]  -to [get_ports {CS0_OUT}] -datapath_only 10
set_max_delay -from [get_pins {CS0_OUT_reg/C}]  -to [get_ports {CS1_OUT}] -datapath_only 10
set_max_delay -from [get_pins {PD_OUT_reg/C}]  -to [get_ports {PD_OUT}] -datapath_only 10
set_max_delay -from [get_pins {SCK_reg/C}]  -to [get_ports {SCK}] -datapath_only 10
set_max_delay -from [get_pins {SDO_reg/C}]  -to [get_ports {SDO}] -datapath_only 10
set_max_delay -from [get_pins {active_reg/C}]  -to [get_ports {active_out}] -datapath_only 10
set_max_delay -from [get_pins {data_active_reg/C}]  -to [get_ports {data_active_out}] -datapath_only 10
set_max_delay -from [get_pins {scanarr_reg[1]/C}]  -to [get_ports {scan0}] -datapath_only 10
set_max_delay -from [get_pins {scanarr_reg[2]/C}]  -to [get_ports {scan1}] -datapath_only 10
set_max_delay -from [get_pins {scanarr_reg[3]/C}]  -to [get_ports {scan2}] -datapath_only 10
set_max_delay -from [get_pins {scanarr_reg[4]/C}]  -to [get_ports {scan3}] -datapath_only 10
set_max_delay -from [get_pins {scanarr_reg[6]/C}]  -to [get_ports {scan4}] -datapath_only 10
set_max_delay -from [get_pins {scanarr_reg[7]/C}]  -to [get_ports {scan5}] -datapath_only 10
set_max_delay -from [get_pins {scanarr_reg[8]/C}]  -to [get_ports {scan6}] -datapath_only 10
set_max_delay -from [get_pins {stoparr_reg[1]/C}]  -to [get_ports {stop0}] -datapath_only 10
set_max_delay -from [get_pins {stoparr_reg[2]/C}]  -to [get_ports {stop1}] -datapath_only 10
set_max_delay -from [get_pins {stoparr_reg[3]/C}]  -to [get_ports {stop2}] -datapath_only 10
set_max_delay -from [get_pins {stoparr_reg[4]/C}]  -to [get_ports {stop3}] -datapath_only 10
set_max_delay -from [get_pins {stoparr_reg[6]/C}]  -to [get_ports {stop4}] -datapath_only 10
set_max_delay -from [get_pins {stoparr_reg[7]/C}]  -to [get_ports {stop5}] -datapath_only 10
set_max_delay -from [get_pins {stoparr_reg[8]/C}]  -to [get_ports {stop6}] -datapath_only 10
set_max_delay -from [get_pins {touch_count9_reg/C}]  -to [get_ports {STOPservos}] -datapath_only 10
set_max_delay -from [get_pins {touch_countarr_reg[10][0]/C}]  -to [get_ports {MOT_state[0]}] -datapath_only 10
set_max_delay -from [get_pins {touch_countarr_reg[10][1]/C}]  -to [get_ports {MOT_state[1]}] -datapath_only 10
set_max_delay -from [get_pins {touch_countarr_reg[5][0]/C}]  -to [get_ports {Cd_oven_state[0]}] -datapath_only 10
set_max_delay -from [get_pins {touch_countarr_reg[5][1]/C}]  -to [get_ports {Cd_oven_state[1]}] -datapath_only 10
