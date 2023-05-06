# HDL directory and directory to save implemented results
set hdl "Sources/hdl"
set saveDir "Implement/BIT/dump"
set bakDir "$saveDir/bak"
file delete -force $saveDir
file mkdir $saveDir
file mkdir $bakDir
# Save scripts and phases
file copy -force "design.tcl" "$saveDir/design_ooc.tcl"
file copy -force "MakeOOC.tcl" "$saveDir/MakeOOC.tcl"
# Back-up old files
file copy -force "Synth/display/display_synth.dcp" "$bakDir/display_synth.dcp"
file copy -force "Synth/FastDACs/FastDACs_synth.dcp" "$bakDir/FastDACs_synth.dcp"
file copy -force "Synth/FM_MOT/FM_MOT_synth.dcp" "$bakDir/FM_MOT_synth.dcp"
file copy -force "Synth/SlowADCs/SlowADCs_synth.dcp" "$bakDir/SlowADCs_synth.dcp"
file copy -force "Synth/SlowDACs/SlowDACs_synth.dcp" "$bakDir/SlowDACs_synth.dcp"
file copy -force "Synth/SR_CTRL/SR_CTRL_synth.dcp" "$bakDir/SR_CTRL_synth.dcp"
file copy -force "Sources/xdc" "$bakDir/xdc"
file copy -force "Implement/disp0/disp0_route_design.dcp" "$bakDir/disp0_route_design.dcp"
file copy -force "Implement/fDAC_inst/fDAC_inst_route_design.dcp" "$bakDir/fDAC_inst_route_design.dcp"
file copy -force "Implement/FM_MOT0/FM_MOT0_route_design.dcp" "$bakDir/FM_MOT0_route_design.dcp"
file copy -force "Implement/sDACinst/sDACinst_route_design.dcp" "$bakDir/sDACinst_route_design.dcp"
file copy -force "Implement/SlowADCs_inst/SlowADCs_inst_route_design.dcp" "$bakDir/SlowADCs_inst_route_design.dcp"
file copy -force "Implement/SR_CTRL0/SR_CTRL0_route_design.dcp" "$bakDir/SR_CTRL0_route_design.dcp"
# Run design_ooc.tcl
exec vivado -mode batch -source design_ooc.tcl -notrace
# Save source files
file copy -force  "Sources" "$saveDir"
# Save vivado log file
file copy -force "vivado.log" "$saveDir/vivado.log"
# Save routed design checkpoints
file copy -force "Synth/top/top_synth.dcp" "$saveDir/top_synth.dcp"
file copy -force "Implement/disp0/disp0_route_design.dcp" "$saveDir/disp0_route_design.dcp"
file copy -force "Implement/fDAC_inst/fDAC_inst_route_design.dcp" "$saveDir/fDAC_inst_route_design.dcp"
file copy -force "Implement/FM_MOT0/FM_MOT0_route_design.dcp" "$saveDir/FM_MOT0_route_design.dcp"
file copy -force "Implement/sDACinst/sDACinst_route_design.dcp" "$saveDir/sDACinst_route_design.dcp"
file copy -force "Implement/SlowADCs_inst/SlowADCs_inst_route_design.dcp" "$saveDir/SlowADCs_inst_route_design.dcp"
file copy -force "Implement/SR_CTRL0/SR_CTRL0_route_design.dcp" "$saveDir/SR_CTRL0_route_design.dcp"