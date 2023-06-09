
####################################################################################
# Generated by Vivado 2020.1 built on 'Wed May 27 19:54:49 MDT 2020' by 'xbuild'
# Command Used: write_xdc -force -cell SlowADCs_inst ./Sources/xdc/SlowADCs_inst_phys.xdc
####################################################################################


####################################################################################
# Constraints from file : 'top_flpn.xdc'
####################################################################################

create_pblock pblock_SlowADCs_inst
add_cells_to_pblock [get_pblocks pblock_SlowADCs_inst] -top
resize_pblock [get_pblocks pblock_SlowADCs_inst] -add {SLICE_X0Y218:SLICE_X7Y249}
resize_pblock [get_pblocks pblock_SlowADCs_inst] -add {RAMB18_X0Y88:RAMB18_X0Y99}
resize_pblock [get_pblocks pblock_SlowADCs_inst] -add {RAMB36_X0Y44:RAMB36_X0Y49}
set_property CONTAIN_ROUTING 1 [get_pblocks pblock_SlowADCs_inst]
set_property IS_SOFT FALSE [get_pblocks pblock_SlowADCs_inst]
set_property PACKAGE_PIN A10 [get_ports sADC_CNV_out]
set_property PACKAGE_PIN B11 [get_ports sADC_SDO0_in]
set_property PACKAGE_PIN A13 [get_ports sADC_SDO1_in]
set_property PACKAGE_PIN H14 [get_ports sADC_SCKI_out]
set_property PACKAGE_PIN B10 [get_ports sADC_SDI_out]
set_property PACKAGE_PIN G14 [get_ports sADC_BUSY0_in]
set_property PACKAGE_PIN B12 [get_ports sADC_BUSY1_in]
set_property PACKAGE_PIN A12 [get_ports sADC_CS0_out]
set_property PACKAGE_PIN C11 [get_ports sADC_CS1_out]
set_property IOSTANDARD LVCMOS33 [get_ports sADC_CNV_out]
set_property IOSTANDARD LVCMOS33 [get_ports sADC_SDO0_in]
set_property IOSTANDARD LVCMOS33 [get_ports sADC_SDO1_in]
set_property IOSTANDARD LVCMOS33 [get_ports sADC_SCKI_out]
set_property IOSTANDARD LVCMOS33 [get_ports sADC_SDI_out]
set_property IOSTANDARD LVCMOS33 [get_ports sADC_BUSY0_in]
set_property IOSTANDARD LVCMOS33 [get_ports sADC_BUSY1_in]
set_property IOSTANDARD LVCMOS33 [get_ports sADC_CS0_out]
set_property IOSTANDARD LVCMOS33 [get_ports sADC_CS1_out]

# User Generated miscellaneous constraints 

set_property HD.PARTITION true [current_design]
