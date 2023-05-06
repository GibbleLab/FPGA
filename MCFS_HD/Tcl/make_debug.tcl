### FM-MOT DSP Signal Probes ###
set_property mark_debug true [get_nets [list {read_addr[1]} {read_addr[15]} {read_addr[19]} {read_addr[26]} {read_addr[30]} {MOTDiffDiffMem[6]} {MOTDiffDiffMem[2]} {MOTDiffDiffMem[8]} {MOTDiffMem[1]} {MOTDiffMem[3]} {MOTDiffMem[7]} {MOTDiffMem[15]} {read_addr[9]} {read_addr[21]} {read_addr[28]} {MOTDiffDiffMem[0]} {MOTDiffDiffMem[5]} {MOTDiffDiffMem[12]} {MOTDiffMem[0]} {MOTDiffMem[5]} {MOTDiffMem[10]} {read_addr[4]} {read_addr[16]} {read_addr[24]} {read_addr[25]} {read_addr[27]} {MOTDiffDiffMem[3]} {MOTDiffMem[12]} {MOTDiffMem[14]} {read_addr[3]} {read_addr[10]} {read_addr[17]} {MOTDiffDiffMem[1]} {MOTDiffDiffMem[10]} {MOTDiffMem[9]} {MOTDiffMem[13]} {read_addr[0]} {read_addr[2]} {read_addr[7]} {read_addr[8]} {read_addr[11]} {read_addr[14]} {MOTDiffDiffMem[14]} {MOTDiffDiffMem[4]} {read_addr[12]} {read_addr[20]} {read_addr[22]} {read_addr[29]} {read_addr[31]} {MOTDiffDiffMem[13]} {MOTDiffMem[11]} {read_addr[5]} {read_addr[6]} {read_addr[13]} {MOTDiffDiffMem[7]} {MOTDiffDiffMem[9]} {MOTDiffMem[2]} {MOTDiffMem[6]} {read_addr[18]} {read_addr[23]} {MOTDiffDiffMem[11]} {MOTDiffDiffMem[15]} {MOTDiffMem[4]} {MOTDiffMem[8]}]]
create_debug_core u_ila_0 ila
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
# startgroup 
# set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0 ]
# set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0 ]
# set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0 ]
# set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0 ]
# endgroup
connect_debug_port u_ila_0/clk [get_nets [list clk100 ]]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {MOTDiffDiffMem[0]} {MOTDiffDiffMem[1]} {MOTDiffDiffMem[2]} {MOTDiffDiffMem[3]} {MOTDiffDiffMem[4]} {MOTDiffDiffMem[5]} {MOTDiffDiffMem[6]} {MOTDiffDiffMem[7]} {MOTDiffDiffMem[8]} {MOTDiffDiffMem[9]} {MOTDiffDiffMem[10]} {MOTDiffDiffMem[11]} {MOTDiffDiffMem[12]} {MOTDiffDiffMem[13]} {MOTDiffDiffMem[14]} {MOTDiffDiffMem[15]} ]]
create_debug_port u_ila_0 probe
set_property port_width 16 [get_debug_ports u_ila_0/probe1]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {MOTDiffMem[0]} {MOTDiffMem[1]} {MOTDiffMem[2]} {MOTDiffMem[3]} {MOTDiffMem[4]} {MOTDiffMem[5]} {MOTDiffMem[6]} {MOTDiffMem[7]} {MOTDiffMem[8]} {MOTDiffMem[9]} {MOTDiffMem[10]} {MOTDiffMem[11]} {MOTDiffMem[12]} {MOTDiffMem[13]} {MOTDiffMem[14]} {MOTDiffMem[15]} ]]
create_debug_port u_ila_0 probe
set_property port_width 32 [get_debug_ports u_ila_0/probe2]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {read_addr[0]} {read_addr[1]} {read_addr[2]} {read_addr[3]} {read_addr[4]} {read_addr[5]} {read_addr[6]} {read_addr[7]} {read_addr[8]} {read_addr[9]} {read_addr[10]} {read_addr[11]} {read_addr[12]} {read_addr[13]} {read_addr[14]} {read_addr[15]} {read_addr[16]} {read_addr[17]} {read_addr[18]} {read_addr[19]} {read_addr[20]} {read_addr[21]} {read_addr[22]} {read_addr[23]} {read_addr[24]} {read_addr[25]} {read_addr[26]} {read_addr[27]} {read_addr[28]} {read_addr[29]} {read_addr[30]} {read_addr[31]} ]]
### Fast ADC Probes ###
# set_property mark_debug true [get_nets [list {f_in_4[9]} {f_in_2[10]} {f_in_1[15]} {f_in_3[3]} {f_in_5[2]} {f_in_5[3]} {f_in_8[1]} {f_in_4[11]} {f_in_9[13]} {f_in_3[2]} {f_in_0[1]} {f_in_1[6]} {f_in_5[14]} {f_in_9[1]} {f_in_9[6]} {f_in_3[8]} {f_in_4[0]} {f_in_7[4]} {f_in_7[13]} {f_in_8[9]} {f_in_7[14]} {f_in_3[15]} {f_in_2[12]} {f_in_3[7]} {f_in_4[5]} {f_in_7[2]} {f_in_8[0]} {f_in_8[3]} {f_in_9[4]} {f_in_9[14]} {f_in_0[8]} {f_in_0[9]} {f_in_5[1]} {f_in_4[15]} {f_in_7[5]} {f_in_8[11]} {f_in_9[11]} {f_in_5[0]} {f_in_1[8]} {f_in_3[11]} {f_in_2[13]} {f_in_1[0]} {f_in_0[6]} {f_in_4[8]} {f_in_6[3]} {f_in_5[13]} {f_in_7[15]} {f_in_1[14]} {f_in_3[9]} {f_in_3[13]} {f_in_7[8]} {f_in_4[2]} {f_in_0[12]} {f_in_5[7]} {f_in_3[1]} {f_in_2[0]} {f_in_6[9]} {f_in_8[6]} {f_in_8[7]} {f_in_9[15]} {f_in_0[7]} {f_in_0[11]} {f_in_3[6]} {f_in_3[14]} {f_in_4[13]} {f_in_5[6]} {f_in_6[7]} {f_in_6[13]} {f_in_9[3]} {f_in_9[5]} {f_in_9[10]} {f_in_0[10]} {f_in_1[3]} {f_in_0[2]} {f_in_4[12]} {f_in_5[10]} {f_in_9[8]} {f_in_9[9]} {f_in_5[5]} {f_in_6[14]} {f_in_2[15]} {f_in_2[1]} {f_in_4[3]} {f_in_2[2]} {f_in_1[5]} {f_in_3[10]} {f_in_4[10]} {f_in_5[9]} {f_in_6[5]} {f_in_6[10]} {f_in_8[8]} {f_in_8[10]} {f_in_9[7]} {f_in_1[9]} {f_in_1[2]} {f_in_0[0]} {f_in_1[13]} {f_in_4[7]} {f_in_5[11]} {f_in_6[4]} {f_in_7[0]} {f_in_4[1]} {f_in_1[1]} {f_in_0[15]} {f_in_0[3]} {f_in_5[15]} {f_in_1[4]} {f_in_1[7]} {f_in_6[8]} {f_in_7[3]} {f_in_7[10]} {f_in_2[11]} {f_in_2[8]} {f_in_0[5]} {f_in_5[4]} {f_in_8[15]} {f_in_0[13]} {f_in_3[5]} {f_in_6[2]} {f_in_6[6]} {f_in_8[4]} {f_in_2[7]} {f_in_1[11]} {f_in_4[14]} {f_in_2[5]} {f_in_4[6]} {f_in_6[11]} {f_in_6[15]} {f_in_7[7]} {f_in_9[2]} {f_in_2[3]} {f_in_0[14]} {f_in_0[4]} {f_in_6[0]} {f_in_8[14]} {f_in_9[0]} {f_in_2[6]} {f_in_3[0]} {f_in_6[1]} {f_in_7[11]} {f_in_7[12]} {f_in_3[12]} {f_in_1[10]} {f_in_2[9]} {f_in_3[4]} {f_in_5[8]} {f_in_7[6]} {f_in_7[9]} {f_in_8[5]} {f_in_8[13]} {f_in_7[1]} {f_in_2[4]} {f_in_5[12]} {f_in_2[14]} {f_in_4[4]} {f_in_1[12]} {f_in_6[12]} {f_in_8[2]} {f_in_8[12]} {f_in_9[12]}]]
# set_property mark_debug true [get_nets [list {fr3_out[2]} {fr0_out[0]} {fr0_out[1]} {fr0_out[4]} {fr1_out[2]} {fr1_out[3]} {fr2_out[6]} {fr4_out[4]} {fr3_out[0]} {fr3_out[7]} {fr0_out[6]} {fr1_out[4]} {fr1_out[7]} {fr2_out[2]} {fr2_out[5]} {fr3_out[1]} {fr3_out[3]} {fr3_out[6]} {fr4_out[5]} {fr0_out[2]} {fr1_out[5]} {fr1_out[0]} {fr2_out[0]} {fr2_out[4]} {fr3_out[4]} {fr3_out[5]} {fr4_out[3]} {fr4_out[6]} {fr4_out[0]} {fr4_out[2]} {fr0_out[5]} {fr0_out[3]} {fr0_out[7]} {fr1_out[1]} {fr1_out[6]} {fr2_out[1]} {fr2_out[3]} {fr4_out[7]} {fr2_out[7]} {fr4_out[1]}]]
# create_debug_core u_ila_1 ila
# set_property C_DATA_DEPTH 16384 [get_debug_cores u_ila_1]
# set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
# set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
# set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
# set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
# set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
# set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
# set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
# connect_debug_port u_ila_1/clk [get_nets [list clk100 ]]
# set_property port_width 16 [get_debug_ports u_ila_1/probe0]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
# connect_debug_port u_ila_1/probe0 [get_nets [list {f_in_0[0]} {f_in_0[1]} {f_in_0[2]} {f_in_0[3]} {f_in_0[4]} {f_in_0[5]} {f_in_0[6]} {f_in_0[7]} {f_in_0[8]} {f_in_0[9]} {f_in_0[10]} {f_in_0[11]} {f_in_0[12]} {f_in_0[13]} {f_in_0[14]} {f_in_0[15]} ]]
# create_debug_port u_ila_1 probe
# set_property port_width 16 [get_debug_ports u_ila_1/probe1]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
# connect_debug_port u_ila_1/probe1 [get_nets [list {f_in_1[0]} {f_in_1[1]} {f_in_1[2]} {f_in_1[3]} {f_in_1[4]} {f_in_1[5]} {f_in_1[6]} {f_in_1[7]} {f_in_1[8]} {f_in_1[9]} {f_in_1[10]} {f_in_1[11]} {f_in_1[12]} {f_in_1[13]} {f_in_1[14]} {f_in_1[15]} ]]
# create_debug_port u_ila_1 probe
# set_property port_width 16 [get_debug_ports u_ila_1/probe2]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe2]
# connect_debug_port u_ila_1/probe2 [get_nets [list {f_in_2[0]} {f_in_2[1]} {f_in_2[2]} {f_in_2[3]} {f_in_2[4]} {f_in_2[5]} {f_in_2[6]} {f_in_2[7]} {f_in_2[8]} {f_in_2[9]} {f_in_2[10]} {f_in_2[11]} {f_in_2[12]} {f_in_2[13]} {f_in_2[14]} {f_in_2[15]} ]]
# create_debug_port u_ila_1 probe
# set_property port_width 16 [get_debug_ports u_ila_1/probe3]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe3]
# connect_debug_port u_ila_1/probe3 [get_nets [list {f_in_3[0]} {f_in_3[1]} {f_in_3[2]} {f_in_3[3]} {f_in_3[4]} {f_in_3[5]} {f_in_3[6]} {f_in_3[7]} {f_in_3[8]} {f_in_3[9]} {f_in_3[10]} {f_in_3[11]} {f_in_3[12]} {f_in_3[13]} {f_in_3[14]} {f_in_3[15]} ]]
# create_debug_port u_ila_1 probe
# set_property port_width 16 [get_debug_ports u_ila_1/probe4]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe4]
# connect_debug_port u_ila_1/probe4 [get_nets [list {f_in_4[0]} {f_in_4[1]} {f_in_4[2]} {f_in_4[3]} {f_in_4[4]} {f_in_4[5]} {f_in_4[6]} {f_in_4[7]} {f_in_4[8]} {f_in_4[9]} {f_in_4[10]} {f_in_4[11]} {f_in_4[12]} {f_in_4[13]} {f_in_4[14]} {f_in_4[15]} ]]
# create_debug_port u_ila_1 probe
# set_property port_width 16 [get_debug_ports u_ila_1/probe5]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe5]
# connect_debug_port u_ila_1/probe5 [get_nets [list {f_in_5[0]} {f_in_5[1]} {f_in_5[2]} {f_in_5[3]} {f_in_5[4]} {f_in_5[5]} {f_in_5[6]} {f_in_5[7]} {f_in_5[8]} {f_in_5[9]} {f_in_5[10]} {f_in_5[11]} {f_in_5[12]} {f_in_5[13]} {f_in_5[14]} {f_in_5[15]} ]]
# create_debug_port u_ila_1 probe
# set_property port_width 16 [get_debug_ports u_ila_1/probe6]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe6]
# connect_debug_port u_ila_1/probe6 [get_nets [list {f_in_6[0]} {f_in_6[1]} {f_in_6[2]} {f_in_6[3]} {f_in_6[4]} {f_in_6[5]} {f_in_6[6]} {f_in_6[7]} {f_in_6[8]} {f_in_6[9]} {f_in_6[10]} {f_in_6[11]} {f_in_6[12]} {f_in_6[13]} {f_in_6[14]} {f_in_6[15]} ]]
# create_debug_port u_ila_1 probe
# set_property port_width 16 [get_debug_ports u_ila_1/probe7]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe7]
# connect_debug_port u_ila_1/probe7 [get_nets [list {f_in_7[0]} {f_in_7[1]} {f_in_7[2]} {f_in_7[3]} {f_in_7[4]} {f_in_7[5]} {f_in_7[6]} {f_in_7[7]} {f_in_7[8]} {f_in_7[9]} {f_in_7[10]} {f_in_7[11]} {f_in_7[12]} {f_in_7[13]} {f_in_7[14]} {f_in_7[15]} ]]
# create_debug_port u_ila_1 probe
# set_property port_width 16 [get_debug_ports u_ila_1/probe8]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe8]
# connect_debug_port u_ila_1/probe8 [get_nets [list {f_in_8[0]} {f_in_8[1]} {f_in_8[2]} {f_in_8[3]} {f_in_8[4]} {f_in_8[5]} {f_in_8[6]} {f_in_8[7]} {f_in_8[8]} {f_in_8[9]} {f_in_8[10]} {f_in_8[11]} {f_in_8[12]} {f_in_8[13]} {f_in_8[14]} {f_in_8[15]} ]]
# create_debug_port u_ila_1 probe
# set_property port_width 16 [get_debug_ports u_ila_1/probe9]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe9]
# connect_debug_port u_ila_1/probe9 [get_nets [list {f_in_9[0]} {f_in_9[1]} {f_in_9[2]} {f_in_9[3]} {f_in_9[4]} {f_in_9[5]} {f_in_9[6]} {f_in_9[7]} {f_in_9[8]} {f_in_9[9]} {f_in_9[10]} {f_in_9[11]} {f_in_9[12]} {f_in_9[13]} {f_in_9[14]} {f_in_9[15]} ]]
# create_debug_port u_ila_1 probe
# set_property port_width 8 [get_debug_ports u_ila_1/probe10]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe10]
# connect_debug_port u_ila_1/probe10 [get_nets [list {fr0_out[0]} {fr0_out[1]} {fr0_out[2]} {fr0_out[3]} {fr0_out[4]} {fr0_out[5]} {fr0_out[6]} {fr0_out[7]} ]]
# create_debug_port u_ila_1 probe
# set_property port_width 8 [get_debug_ports u_ila_1/probe11]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe11]
# connect_debug_port u_ila_1/probe11 [get_nets [list {fr1_out[0]} {fr1_out[1]} {fr1_out[2]} {fr1_out[3]} {fr1_out[4]} {fr1_out[5]} {fr1_out[6]} {fr1_out[7]} ]]
# create_debug_port u_ila_1 probe
# set_property port_width 8 [get_debug_ports u_ila_1/probe12]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe12]
# connect_debug_port u_ila_1/probe12 [get_nets [list {fr2_out[0]} {fr2_out[1]} {fr2_out[2]} {fr2_out[3]} {fr2_out[4]} {fr2_out[5]} {fr2_out[6]} {fr2_out[7]} ]]
# create_debug_port u_ila_1 probe
# set_property port_width 8 [get_debug_ports u_ila_1/probe13]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe13]
# connect_debug_port u_ila_1/probe13 [get_nets [list {fr3_out[0]} {fr3_out[1]} {fr3_out[2]} {fr3_out[3]} {fr3_out[4]} {fr3_out[5]} {fr3_out[6]} {fr3_out[7]} ]]
# create_debug_port u_ila_1 probe
# set_property port_width 8 [get_debug_ports u_ila_1/probe14]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe14]
# connect_debug_port u_ila_1/probe14 [get_nets [list {fr4_out[0]} {fr4_out[1]} {fr4_out[2]} {fr4_out[3]} {fr4_out[4]} {fr4_out[5]} {fr4_out[6]} {fr4_out[7]} ]]