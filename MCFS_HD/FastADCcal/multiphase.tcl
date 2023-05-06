# HDL directory and directory to save implemented results
set hdl "Sources/hdl"
set saveDir "Implement/BIT/dump"
file delete -force $saveDir
file mkdir $saveDir
#  Slurp up the data file
set fp [open "FastADCcal/top_fADC_master.sv" r]
file copy -force "FastADCcal/top_fADC_master.sv" "$saveDir/top_fADC_master.sv"
# Change to an array where each element is a line of the file.
set fd [split [read $fp] "\n"]
close $fp
# File containing all the phases
set fph [open "FastADCcal/phases.sv" r]
set fphd [split [read $fph] "\n"]
close $fph
# Number of bitstreams to generate (phases are declared in a single line blocks in phases.sv).
set Nph [expr [llength $fphd]/1]
# Save scripts and phases
file copy -force "FastADCcal/design.tcl" "$saveDir/design.tcl"
file copy -force "FastADCcal/multiphase.tcl" "$saveDir/multiphase.tcl"
file copy -force "FastADCcal/phases.sv" "$saveDir/phases.sv"
file copy -force "FastADCcal/make_debug.tcl" "$saveDir/make_debug.tcl"
file copy -force "FastADCcal/write_ltx.tcl" "$saveDir/write_ltx.tcl"
# Save one copty of all source files
file copy -force  "Sources" "$saveDir"
# Loop through all lines in phases.sv, one run per line, and save the results.
for {set i 0} {$i < $Nph} {incr i} {
   puts $i
   set newfp [open "top_fADC.sv.tmp" w]
   set count 0
   # Go through lines of the file.
   foreach line $fd {
      incr count
      # Replace line 106 with the corresponding phases from phases.sv.
      if {$count==106} {
         set newline [lindex $fphd $i]
         puts $newfp $newline
      # Make all the other lines the same as the original.
      } else {
         set newline $line
         puts $newfp $newline
      }
   }
   close $newfp
   file rename -force "top_fADC.sv.tmp" "$hdl/top_fADC.sv"
   # Run synthesis and implementation.
   exec vivado -mode batch -source FastADCcal/design.tcl -notrace
   # Save the hdl
   set subDir "$saveDir/$i"
   file mkdir $subDir
   file copy -force "$hdl/top_fADC.sv" "$subDir/top_fADC.sv"
   # Save the bit and ltx files
   file copy -force "Implement/top_fADC/top_fADC.bit" "$saveDir/top_fADC$i.bit"
   file copy -force "Implement/top_fADC/top_fADC.ltx" "$saveDir/top_fADC$i.ltx"
   # Save routed design checkpoint
   file copy -force "Implement/top_fADC/top_fADC_route_design.dcp" "$subDir/top_fADC_route_design.dcp"
}