
####################################################################################
# Generated by Vivado 2020.1 built on 'Wed May 27 19:54:49 MDT 2020' by 'xbuild'
# Command Used: write_xdc -force -cell disp0 ./Sources/xdc/disp0_phys.xdc
####################################################################################


####################################################################################
# Constraints from file : 'top_flpn.xdc'
####################################################################################

create_pblock pblock_disp0
add_cells_to_pblock [get_pblocks pblock_disp0] -top
resize_pblock [get_pblocks pblock_disp0] -add {SLICE_X12Y0:SLICE_X109Y32}
resize_pblock [get_pblocks pblock_disp0] -add {DSP48_X0Y0:DSP48_X5Y11}
resize_pblock [get_pblocks pblock_disp0] -add {RAMB18_X1Y0:RAMB18_X6Y11}
resize_pblock [get_pblocks pblock_disp0] -add {RAMB36_X1Y0:RAMB36_X6Y5}
set_property CONTAIN_ROUTING 1 [get_pblocks pblock_disp0]
set_property IS_SOFT FALSE [get_pblocks pblock_disp0]

# User Generated miscellaneous constraints 

set_property HD.PARTITION true [current_design]
