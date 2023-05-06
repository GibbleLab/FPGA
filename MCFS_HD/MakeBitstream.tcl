# HDL directory and directory to save implemented results
set hdl "Sources/hdl"
set saveDir "Implement/BIT/dump"
file delete -force $saveDir
file mkdir $saveDir
# Save scripts and phases
file copy -force "design.tcl" "$saveDir/design.tcl"
file copy -force "MakeBitstream.tcl" "$saveDir/MakeBitstream.tcl"
# Save source files
file copy -force  "Sources" "$saveDir"
# Run design.tcl
exec vivado -mode batch -source design.tcl -notrace
# Save vivado log file
file copy -force "vivado.log" "$saveDir/vivado.log"
# Save the bit file
file copy -force "Implement/top/top.bit" "$saveDir/top.bit"
# Save routed design checkpoint
file copy -force "Implement/top/top_route_design.dcp" "$saveDir/top_route_design.dcp"
# Save the debug related files
file copy -force "Implement/top/top.ltx" "$saveDir/top.ltx"
file copy -force "Tcl/make_debug.tcl" "$saveDir/make_debug.tcl"
file copy -force "Tcl/write_ltx.tcl" "$saveDir/write_ltx.tcl"