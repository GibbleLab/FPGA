# HDL directory and directory to save implemented results
set hdl "Sources/hdl"
set saveDir "Implement/BIT/dump"
file delete -force $saveDir
file mkdir $saveDir
#  Slurp up the data file
set fp [open "FastADCcal/FastADCsDDR_master.v" r]
file copy -force "FastADCcal/FastADCsDDR_master.v" "$saveDir/FastADCsDDR_master.v"
# Change to an array where each element is a line of the file.
set fd [split [read $fp] "\n"]
close $fp
# File containing all the taps
set ft [open "FastADCcal/taps.sv" r]
set ftd [split [read $ft] "\n"]
close $ft
# Number of bitstreams to generate (taps are in 6 line blocks in taps.sv).
set Nt [expr [llength $ftd]/6]
# Save top_fADC.sv
file copy -force "$hdl/top_fADC.sv" "$saveDir/top_fADC.sv"
# Save scripts and taps
file copy -force "FastADCcal/design.tcl" "$saveDir/design.tcl"
file copy -force "FastADCcal/multitap.tcl" "$saveDir/multitap.tcl"
file copy -force "FastADCcal/taps.sv" "$saveDir/taps.sv"
file copy -force "FastADCcal/make_debug.tcl" "$saveDir/make_debug.tcl"
file copy -force "FastADCcal/write_ltx.tcl" "$saveDir/write_ltx.tcl"
# Save one copy of all source files
file copy -force  "Sources" "$saveDir"
# Loop through all lines in taps.sv, one run per line, and save the results.
for {set i 0} {$i < $Nt} {incr i} {
   puts $i
   set newfp [open "FastADCsDDR.v.tmp" w]
   set count 0
   # Go through lines of the file.
   foreach line $fd {
      incr count
      switch $count {
         "98" {
            set newline [lindex $ftd [expr 6*$i + 0]]
            puts $newfp $newline
         }
         "99" {
            set newline [lindex $ftd [expr 6*$i + 1]]
            puts $newfp $newline
         }
         "100" {
            set newline [lindex $ftd [expr 6*$i + 2]]
            puts $newfp $newline
         }
         "101" {
            set newline [lindex $ftd [expr 6*$i + 3]]
            puts $newfp $newline
         }
         "102" {
            set newline [lindex $ftd [expr 6*$i + 4]]
            puts $newfp $newline
         }
         "103" {
            set newline [lindex $ftd [expr 6*$i + 5]]
            puts $newfp $newline
         }
         default {
            set newline $line
            puts $newfp $newline
         }
      }
   }
   close $newfp
   file rename -force "FastADCsDDR.v.tmp" "$hdl/FastADCsDDR.v"
   # Run synthesis and implementation.
   exec vivado -mode batch -source FastADCcal/design.tcl -notrace
   # Save the hdl
   set subDir "$saveDir/$i"
   file mkdir $subDir
   file copy -force "$hdl/FastADCsDDR.v" "$subDir/FastADCsDDR.v"
   # Save the bit and ltx files
   file copy -force "Implement/top_fADC/top_fADC.bit" "$saveDir/top_fADC$i.bit"
   file copy -force "Implement/top_fADC/top_fADC.ltx" "$saveDir/top_fADC$i.ltx"
   # Save routed design checkpoint
   file copy -force "Implement/top_fADC/top_fADC_route_design.dcp" "$subDir/top_fADC_route_design.dcp"
}