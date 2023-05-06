create_clock -period 50 -name clk20_int.clk [get_ports {clk}] -waveform { 0.000000 25.000000  }
set_property HD.CLK_SRC BUFGCTRL_X0Y10 [get_ports {clk}] 
set_max_delay -from [get_pins {LTC2666x2_inst/LTC2666_SPI_inst/CS0_reg_lopt_replica/C}]  -to [get_ports {sDAC0_CS_out}] -datapath_only 25
set_max_delay -from [get_pins {LTC2666x2_inst/LTC2666_SPI_inst/CS1_reg_lopt_replica/C}]  -to [get_ports {sDAC1_CS_out}] -datapath_only 25
set_max_delay -from [get_pins {LTC2666x2_inst/LTC2666_SPI_inst/SDO_reg/C}]  -to [get_ports {sDAC_SDI_out}] -datapath_only 25
set_max_delay -from [get_pins {ODDR_SCK/C}]  -to [get_ports {sDAC_SCK_out}] -datapath_only 25
