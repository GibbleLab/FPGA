
####################################################################################
# Generated by Vivado 2020.1 built on 'Wed May 27 19:54:49 MDT 2020' by 'xbuild'
# Command Used: write_xdc -force -cell FM_MOT0 ./Sources/xdc/FM_MOT0_phys.xdc
####################################################################################


####################################################################################
# Constraints from file : 'top_flpn.xdc'
####################################################################################

create_pblock pblock_FM_MOT0
add_cells_to_pblock [get_pblocks pblock_FM_MOT0] -top
resize_pblock [get_pblocks pblock_FM_MOT0] -add {SLICE_X12Y70:SLICE_X17Y152}
set_property CONTAIN_ROUTING 1 [get_pblocks pblock_FM_MOT0]
set_property IS_SOFT FALSE [get_pblocks pblock_FM_MOT0]

# User Generated miscellaneous constraints 

set_property HD.PARTITION true [current_design]