create_clock -period 10 -name clk100_int.clk [get_ports {clk}] -waveform { 0.000000 5.000000  }
set_property HD.CLK_SRC BUFGCTRL_X0Y0 [get_ports {clk}] 
set_max_delay -from [get_pins {FM_reg[0]/C}]  -to [get_ports {FM[0]}] -datapath_only 5
set_max_delay -from [get_pins {FM_reg[10]/C}]  -to [get_ports {FM[10]}] -datapath_only 5
set_max_delay -from [get_pins {FM_reg[11]/C}]  -to [get_ports {FM[11]}] -datapath_only 5
set_max_delay -from [get_pins {FM_reg[12]/C}]  -to [get_ports {FM[12]}] -datapath_only 5
set_max_delay -from [get_pins {FM_reg[13]/C}]  -to [get_ports {FM[13]}] -datapath_only 5
set_max_delay -from [get_pins {FM_reg[14]/C}]  -to [get_ports {FM[14]}] -datapath_only 5
set_max_delay -from [get_pins {FM_reg[15]/C}]  -to [get_ports {FM[15]}] -datapath_only 5
set_max_delay -from [get_pins {FM_reg[1]/C}]  -to [get_ports {FM[1]}] -datapath_only 5
set_max_delay -from [get_pins {FM_reg[2]/C}]  -to [get_ports {FM[2]}] -datapath_only 5
set_max_delay -from [get_pins {FM_reg[3]/C}]  -to [get_ports {FM[3]}] -datapath_only 5
set_max_delay -from [get_pins {FM_reg[4]/C}]  -to [get_ports {FM[4]}] -datapath_only 5
set_max_delay -from [get_pins {FM_reg[5]/C}]  -to [get_ports {FM[5]}] -datapath_only 5
set_max_delay -from [get_pins {FM_reg[6]/C}]  -to [get_ports {FM[6]}] -datapath_only 5
set_max_delay -from [get_pins {FM_reg[7]/C}]  -to [get_ports {FM[7]}] -datapath_only 5
set_max_delay -from [get_pins {FM_reg[8]/C}]  -to [get_ports {FM[8]}] -datapath_only 5
set_max_delay -from [get_pins {FM_reg[9]/C}]  -to [get_ports {FM[9]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[0]/C}]  -to [get_ports {Int[0]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[10]/C}]  -to [get_ports {Int[10]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[11]/C}]  -to [get_ports {Int[11]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[12]/C}]  -to [get_ports {Int[12]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[13]/C}]  -to [get_ports {Int[13]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[14]/C}]  -to [get_ports {Int[14]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[15]/C}]  -to [get_ports {Int[15]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[1]/C}]  -to [get_ports {Int[1]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[2]/C}]  -to [get_ports {Int[2]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[3]/C}]  -to [get_ports {Int[3]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[4]/C}]  -to [get_ports {Int[4]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[5]/C}]  -to [get_ports {Int[5]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[6]/C}]  -to [get_ports {Int[6]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[7]/C}]  -to [get_ports {Int[7]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[8]/C}]  -to [get_ports {Int[8]}] -datapath_only 5
set_max_delay -from [get_pins {Int_reg[9]/C}]  -to [get_ports {Int[9]}] -datapath_only 5
set_max_delay -from [get_pins {cI_reg[12]/C}]  -to [get_ports {cI[11]}] -datapath_only 5
set_max_delay -from [get_pins {cI_reg[12]/C}]  -to [get_ports {cI[12]}] -datapath_only 5
set_max_delay -from [get_pins {cI_reg[12]/C}]  -to [get_ports {cI[1]}] -datapath_only 5
set_max_delay -from [get_pins {cI_reg[12]/C}]  -to [get_ports {cI[5]}] -datapath_only 5
set_max_delay -from [get_pins {cI_reg[12]/C}]  -to [get_ports {cI[6]}] -datapath_only 5
set_max_delay -from [get_pins {cI_reg[13]/C}]  -to [get_ports {cI[13]}] -datapath_only 5
set_max_delay -from [get_pins {cI_reg[13]/C}]  -to [get_ports {cI[2]}] -datapath_only 5
set_max_delay -from [get_pins {cI_reg[13]/C}]  -to [get_ports {cI[3]}] -datapath_only 5
set_max_delay -from [get_pins {cI_reg[13]/C}]  -to [get_ports {cI[8]}] -datapath_only 5
set_max_delay -from [get_pins {cI_reg[13]/C}]  -to [get_ports {cI[9]}] -datapath_only 5
set_max_delay -from [get_pins {cI_reg[14]/C}]  -to [get_ports {cI[10]}] -datapath_only 5
set_max_delay -from [get_pins {cI_reg[14]/C}]  -to [get_ports {cI[14]}] -datapath_only 5
set_max_delay -from [get_pins {cI_reg[14]/C}]  -to [get_ports {cI[4]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[0]/C}]  -to [get_ports {demodCOS[0]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[10]/C}]  -to [get_ports {demodCOS[10]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[11]/C}]  -to [get_ports {demodCOS[11]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[12]/C}]  -to [get_ports {demodCOS[12]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[13]/C}]  -to [get_ports {demodCOS[13]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[14]/C}]  -to [get_ports {demodCOS[14]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[15]/C}]  -to [get_ports {demodCOS[15]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[1]/C}]  -to [get_ports {demodCOS[1]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[2]/C}]  -to [get_ports {demodCOS[2]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[3]/C}]  -to [get_ports {demodCOS[3]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[4]/C}]  -to [get_ports {demodCOS[4]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[5]/C}]  -to [get_ports {demodCOS[5]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[6]/C}]  -to [get_ports {demodCOS[6]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[7]/C}]  -to [get_ports {demodCOS[7]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[8]/C}]  -to [get_ports {demodCOS[8]}] -datapath_only 5
set_max_delay -from [get_pins {demodCOS_reg[9]/C}]  -to [get_ports {demodCOS[9]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[0]/C}]  -to [get_ports {demodSIN[0]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[10]/C}]  -to [get_ports {demodSIN[10]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[11]/C}]  -to [get_ports {demodSIN[11]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[12]/C}]  -to [get_ports {demodSIN[12]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[13]/C}]  -to [get_ports {demodSIN[13]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[14]/C}]  -to [get_ports {demodSIN[14]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[15]/C}]  -to [get_ports {demodSIN[15]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[1]/C}]  -to [get_ports {demodSIN[1]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[2]/C}]  -to [get_ports {demodSIN[2]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[3]/C}]  -to [get_ports {demodSIN[3]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[4]/C}]  -to [get_ports {demodSIN[4]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[5]/C}]  -to [get_ports {demodSIN[5]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[6]/C}]  -to [get_ports {demodSIN[6]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[7]/C}]  -to [get_ports {demodSIN[7]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[8]/C}]  -to [get_ports {demodSIN[8]}] -datapath_only 5
set_max_delay -from [get_pins {demodSIN_reg[9]/C}]  -to [get_ports {demodSIN[9]}] -datapath_only 5
set_max_delay -from [get_pins {dithEN_reg/C}]  -to [get_ports {dithEN}] -datapath_only 5
set_max_delay -from [get_pins {lockIn_inst/trig_out_reg/C}]  -to [get_ports {trigD}] -datapath_only 5
