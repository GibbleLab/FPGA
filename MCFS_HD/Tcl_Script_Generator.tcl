# This script runs in the Vivado Tcl Shell and generates the Tcl scripts to synthesize and implement the MCFS_HD design and produce a bitstream. 
# It and the MCFS_HD synthesis and implementation flow use files from the UG946: Vivado Design Suite Tutorial - Hierarchical Design (v2014.1) reference design. The Tcl scripts can be generated by:
#   1) Use the following link from UG946 version 2014.1 <https://secure.xilinx.com/webreg/clickthrough.do?cid=356076&license=RefDesLicense&filename=ug946-vivado-hierarchical-design-tutorial.zip> 
#      to sign the Design License Agreement and download the reference design files. Xilinx requires a signed user agreement to download the reference design files used by this script. 
#      The MCFS_HD synthesis and implementation flow uses Tcl files from the downloaded zip file. Preserve the directory structure when extracting the 14 Tcl files. 
#   2) Replace c:/MCFS_HD/UG946 in the following set xil command with the reference design root directory, which contains design_complete.tcl. Note: use / not \ in directory addresses.

set xil "c:/MCFS_HD/UG946"

#   3) Enter the following command in the Vivado Tcl shell, version 2020.1:
#        source Tcl_Script_Generator.tcl -notrace
#
# This script, Tcl_Script_Generator.tcl, will:
#   1) Copy all files from c:/MCFS_HD/UG946/Tcl, 
#   2) Change the Vivado version number in Tcl/run.tcl to 2020.1 to avoid a Vivado error when running the design*.tcl scripts,
#   3) Use c:/MCFS_HD/UG946/design_complete.tcl to generate a modified version, MCFS_HD/design.tcl, for the MCFS HD Flow
#   4) Use that design.tcl to generate 2 more files, MCFS_HD/design_ooc.tcl and MCFS_HD/FastADCcal/design.tcl, for OOC synthesis and implementation and for calibrating the FPGA's fast ADC interface.

#------Copy the Tcl scripts from the reference design directory to MCFS_HD------#

# lt is a list of all the files in the template project's Tcl directory. 
set lt [concat [glob -directory "$xil/Tcl" *]]
# Get the length of lt.
set Ntcl [expr [llength $lt]/1]
# Copy Tcl scripts from c:/MCFS_HD/UG946/Tcl to MCFS_HD/Tcl.
for {set i 0} {$i < $Ntcl} {incr i} {
    # Remove the $xil path name from the beginning of each element of lt.
    set ft [regsub $xil/ [lindex $lt $i] ""]
    file copy -force "$xil/$ft" "$ft"
}

#------Change the Vivado version number in the Tcl/run.tcl------#
# Open Tcl/run.tcl.
set run_orig [open "Tcl/run.tcl" r]
# Read and load run_orig into an array where each element is a line of the file.
set fd [split [read $run_orig] "\n"]
# Close Tcl/run.tcl.
close $run_orig
# Create a temporary output file.
set newfp [open "run.tcl.tmp" w]
# Initialize count.
set count 0
# Modify line 5 to change the version from 2014.1 to 2020.1 and copy all other lines.
foreach line $fd {
    incr count
    switch $count {
        5 { 
            # Replace Vivado version "2014.1" with "2020.1" in line 5.
            set newline [regsub "2014.1" $line "2020.1"]
            # Add newline to the temporary file.
            puts $newfp $newline
        }
        default { 
            # Copy all other lines.
            set newline $line
            # Add newline to the temporary file
            puts $newfp $newline
        }  
    }
}
# Close the temporary file.
close $newfp
# Rename the temporary file.
file rename -force "run.tcl.tmp" "Tcl/run.tcl"

#------Add ExploreWithRemap as permitted an opt_design directive in Tcl/design_utils.tcl------#
# Open Tcl/design_utils.tcl.
set design_utils_orig [open "Tcl/design_utils.tcl" r]
# Read and load design_utils_orig into an array where each element is a line of the file.
set fd [split [read $design_utils_orig] "\n"]
# Close Tcl/design_utils.tcl.
close $design_utils_orig
# Create a temporary output file.
set newfp [open "design_utils.tcl.tmp" w]
# Initialize count.
set count 0
# Add a line after line 10 to allow the ExploreWithRemap directive to be optionally used in the opt_design implementation step.
foreach line $fd {
    incr count
    switch $count {
        10 { 
            # Copy the line then add another line with ExploreWithRemap
            set newline $line            
            puts $newfp $newline
            puts $newfp "                           ExploreWithRemap       \\"
        }
        default { 
            # Copy all other lines.
            set newline $line
            # Add newline to the temporary file
            puts $newfp $newline
        }  
    }
}
# Close the temporary file.
close $newfp
# Rename the temporary file.
file rename -force "design_utils.tcl.tmp" "Tcl/design_utils.tcl"

#------Generate a modified design.tcl from <reference design/design_complete.tcl------#
# This block follows the same structure as above. 
# Open c:/MCFS_HD/UG946/design_complete.tcl
set design_orig [open "$xil/design_complete.tcl" r]
set fd [split [read $design_orig] "\n"]
close $design_orig
set newfp [open "design.tcl.tmp" w]
set count 0
# Go through lines of the file.
foreach line $fd {
    incr count
    switch $count {
        6 { # Add a line after line 6 to increase max threads.
            set newline $line
            puts $newfp $newline
            puts $newfp "                    general.maxThreads        8 \\"
        } 
        22 { 
            # FPGA part number is "xc7k160t".
            set newline [regsub "xc7k70t" $line "xc7k160t"]
            puts $newfp $newline
        }
        23   { 
            # FPGA package type is "ffg676".
            set newline [regsub "fbg676" $line "ffg676"]
            puts $newfp $newline
        }
        32 - 33 - 34 { 
            # Set the run.oocSynth, run.tdImpl and run.oocImpl flow control variables to 0.
            set newline [regsub "1" $line "0"]
            puts $newfp $newline
        }
        68 - 69 - 70 - 100 - 101 - 102 - 103 - 104 - 105 - 106 - 107 - 
        108 - 109 - 110 - 111 - 112 - 113 - 114 - 115 - 116 - 117 - 
        118 - 119 - 120 - 121 - 122 - 123 - 124 - 125 - 126 - 127 - 
        128 - 129 - 130 - 131 - 132 - 133 - 144 - 145 - 146 - 147 - 148 - 
        159 - 160 - 161 - 162 - 163 {
            # Omit these lines
        } 
	  71 {
            # Include optional commented-out synthesis directives to improve timing margin 
            set newline $line
            puts $newfp $newline
		    puts $newfp "# set_attribute module \$top    synth_options \"-directive PerformanceOptimized -fsm_extraction one_hot -keep_equivalent_registers -resource_sharing off -no_lc -shreg_min_size 5\""
    }
        77 { 
            # Set the hd.impl attribute of top to 1  
            set newline $line
            puts $newfp $newline    
            # Include optional commented-out implementation directives to improve timing margin 
            puts $newfp "# Implementation Directives"
            puts $newfp "# set_attribute impl \$top     opt_directive   \"ExploreWithRemap\""
            puts $newfp "# set_attribute impl \$top     place_directive \"Explore\""
            puts $newfp "# set_attribute impl \$top     phys_directive  \"Explore\""
            puts $newfp "# set_attribute impl \$top     route_options   \"-tns_cleanup\""
            puts $newfp "# set_attribute impl \$top     route_directive \"MoreGlobalIterations\""
            # Implementation attributes (link, opt.pre, opt, place, phys, route, bitstream.pre and bitstream). Attributes other than opt.pre and bitsream.pre are set to 1.
            puts $newfp "# Attributes that control top-level implementation steps."
            puts $newfp [regsub "hd.impl" $line "link   "]
            puts $newfp [regsub "hd.impl       1" $line "opt.pre       \"\$tclDir/make_debug.tcl\""]
            puts $newfp [regsub "hd.impl" $line "opt    "]
            puts $newfp [regsub "hd.impl" $line "place  "]
            puts $newfp [regsub "hd.impl" $line "phys   "]
            puts $newfp [regsub "hd.impl" $line "route  "]
            puts $newfp [regsub "hd.impl       1" $line "bitstream.pre \"\$tclDir/write_ltx.tcl\""]
            puts $newfp [regsub "hd.impl  " $line "bitstream"]
            puts $newfp "\nputs \$xdcDir/\${top}.xdc"
        }
        79 { 
            # This section, through line 99, declares the instance of the display OOC Module. The lines are assembled in modlist and adapted below to declare the other OOC modules.
            # Add the first comment line for the display module OOC section.
            set newline $line
            set modlist $newline
            puts $newfp $newline
        }
        82 { 
            # Declare the display module. Replace "module1" with "module 0" and "usbf_top" with "display".
            set newline [regsub "usbf_top" [regsub "module1" $line "module0"] "display"]
            lappend modlist $newline
            puts $newfp $newline
        }
        83 - 84 - 89 { 
            # Change "module1" to "module0".
            set newline [regsub -all "module1" $line "module0"]
            lappend modlist $newline
            puts $newfp $newline
        }
        85 { 
            # Comment out the line setting the default synth attribute "${run.oocSynth}" and add a line setting it to "0".
            set newline [regsub "1" $line "0"]
            puts $newfp "# $newline"
            lappend modlist "# $newline"
            puts $newfp [regsub "\\\${run.oocSynth}" $newline "0"]
            lappend modlist [regsub "\\\${run.oocSynth}" $newline "0"]
        }
        87 { 
            # Change the OOC module name from "usbEngine0" to "disp0".
            set newline [regsub "usbEngine0" $line "disp0"]
            lappend modlist $newline
            puts $newfp $newline
        }
        
        97 { 
            # Comment out the line setting the default impl attribute "${run.oocImpl}" and add a line setting it to "0".
            set newline [regsub "1" $line "0"]
            puts $newfp "# $newline"
            puts $newfp [regsub "\\\${run.oocImpl}" $newline "0"]
            lappend modlist "# $newline"
            lappend modlist [regsub "\\\${run.oocImpl}" $newline "0"]
        }
        80 - 81 - 86 - 88 - 90 - 91 - 92 - 93 - 94 - 95 - 96 - 98 { 
            # These lines are identical for all module sections.
            set newline $line
            lappend modlist $newline
            puts $newfp $newline
        }
        99 { 
            # Add a blank line at the end the display OOC Module section and then generate the other 5 OOC module sections.
            set newline $line
            lappend modlist $newline
            puts $newfp $newline
            # Use modlist to declare the SR_CTRL OOC module. Replace "display" with "SR_CTRL", "module0" with "module1", and "disp0" with "SR_CTRL0".
            set len_modlist [expr [llength $modlist]/1]
            for {set i 0} {$i < $len_modlist} {incr i} {
                set newline [lindex $modlist $i]
                switch $i {
                    3 {puts $newfp [regsub "module0" [regsub "display" $newline "SR_CTRL"] "module1"]}
                    5 {puts $newfp [regsub -all "module0" $newline "module1"]}
                    9 {puts $newfp [regsub "disp0" $newline "SR_CTRL0"]}
                    20 {puts $newfp $newline}
                    default {puts $newfp [regsub "module0" $newline "module1"]}
                }
            }
            # Use modlist to declare the SlowADCs OOC module. Replace "display" with "SlowADCs", "module0" with "module2", and "disp0" with "SlowADCs_inst".
            for {set i 0} {$i < $len_modlist} {incr i} {
                set newline [lindex $modlist $i]
                switch $i {
                    3 {puts $newfp [regsub "module0" [regsub "display" $newline "SlowADCs"] "module2"]}
                    5 {puts $newfp [regsub -all "module0" $newline "module2"]}
                    9 {puts $newfp [regsub "disp0" $newline "SlowADCs_inst"]}
                    20 {puts $newfp $newline}
                    default {puts $newfp [regsub "module0" $newline "module2"]}
                }
            }
            # Use modlist to declare the FastDACs OOC module. Replace "display" with "FastDACs", "module0" with "module3", and "disp0" with "fDAC_inst".
            for {set i 0} {$i < $len_modlist} {incr i} {
                set newline [lindex $modlist $i]
                switch $i {
                    3 {puts $newfp [regsub "module0" [regsub "display" $newline "FastDACs"] "module3"]}
                    5 {puts $newfp [regsub -all "module0" $newline "module3"]}
                    9 {puts $newfp [regsub "disp0" $newline "fDAC_inst"]}
                    20 {puts $newfp $newline}
                    default {puts $newfp [regsub "module0" $newline "module3"]}
                }
            }
            # Use modlist to declare the SlowDACs OOC module. Replace "display" with "SlowDACs ", "module0" with "module4", "disp0" with "sDACinst", and change the preservation attribute from "routing" to "placement".
            for {set i 0} {$i < $len_modlist} {incr i} {
                set newline [lindex $modlist $i]
                switch $i {
                    3 {puts $newfp [regsub "module0" [regsub "display" $newline "SlowDACs"] "module4"]}
                    5 {puts $newfp [regsub -all "module0" $newline "module4"]}
                    9 {puts $newfp [regsub "disp0" $newline "sDACinst"]}
                    20 {puts $newfp $newline}
                    21 {puts $newfp [regsub "routing" $newline "placement"]} # preserve placement, not routing for slow DAC.
                    default {puts $newfp [regsub "module0" $newline "module4"]}
                }
            }
            # Use modlist to delcare the FM_MOT OOC module. Replace "display" with "FM_MOT", "module0" with "module5", and "disp0" with "FM_MOT0".
            for {set i 0} {$i < $len_modlist} {incr i} {
                set newline [lindex $modlist $i]
                switch $i {
                    3 {puts $newfp [regsub "module0" [regsub "display" $newline "FM_MOT"] "module5"]}
                    5 {puts $newfp [regsub -all "module0" $newline "module5"]}
                    9 {puts $newfp [regsub "disp0" $newline "FM_MOT0"]}
                    20 {puts $newfp $newline}
                    default {puts $newfp [regsub "module0" $newline "module5"]}
                }
            }
        }
        137 { 
            # Set the OOC Module file names for module0 and module1.
            set newline $line
            puts $newfp [regsub -all "module1" $newline "module0"]
            puts $newfp $newline
        }
        138 { 
            # Set the ooc module file name for "module2", and add names for "module3", "module 4" and "module5".
            set newline $line
            puts $newfp $newline
            puts $newfp [regsub -all "module2" $newline "module3"]
            puts $newfp [regsub -all "module2" $newline "module4"]
            puts $newfp [regsub -all "module2" $newline "module5"]
        }
        143 { 
            # Add "$module0File" and  "$module3File $module4File $module5File]" to this line.
            set newline $line
            puts $newfp [regsub "\\\$module1File" [regsub "                          \\\\" $newline "\] "] "\$module0File \$module1File \$module2File \$module3File \$module4File \$module5File"]
        }
        155 - 156 - 157 - 164 { 
            # Comment out these lines.
            set newline "# $line"
            puts $newfp $newline
        }
        158 { 
            # Substitute "$module1File" with "$module0File" and add a "]" at the end of the line.
            set newline $line
            puts $newfp [regsub "module1File" [regsub "                          \\\\" "# $newline" "\] "] "module0File"]
        }
        default { 
            # Copy unchanged lines.
            set newline $line
            puts $newfp $newline
        }  
    }
}
close $newfp
file rename -force "design.tcl.tmp" "design.tcl"

#------Generate a modified design_ooc.tcl from the design.tcl generated above------#
# This block follows the same structure as above. 
# Open MCFS_HD/design.tcl
set design_orig [open "design.tcl" r]
set fd [split [read $design_orig] "\n"]
close $design_orig
set newfp [open "design_ooc.tcl.tmp" w]
set count 0
# Go through lines of the file.
foreach line $fd {
    incr count
    switch $count {
        33 - 34 - 35 { 
            # Change the run.oocSynth, runtdImpl and run.oocImpl flow control variables from 0 to 1 to enable OOC synthesis and implementation, and TopDown implementation.
            set newline $line
            puts $newfp [regsub "0" $newline "1"]
        }
        36 { 
            # Change the run.topImpl flow control variable from 1 to 0 to disable top implementation.
            set newline $line
            puts $newfp [regsub "1" $newline "0"]
        }
        68 { 
            # Use the top_ooc.prj file (instead of top.prj) for the top.sv variant in Sources/hdl/ooc.
            set newline $line
            puts $newfp [regsub "\\\$top.prj" $newline "\$\{top\}_ooc.prj"]
        }
        70 - 77 - 78 - 79 - 80 - 81 - 82 - 85 - 90 { 
            # Do not copy these lines
        } 
        101 - 114 - 124 - 137 - 147 - 160 - 170 - 183 - 193 - 206 - 216 - 229 {
            # Remove the comments from the specified lines to enable OOC Synthesis and OOC Implementation to run.
            set newline $line
            puts $newfp [regsub "# " $newline ""]
        }
        102 - 115 - 125 - 138 - 148 - 161 - 171 - 184 - 194 - 207 - 217 - 230 {
            # Comment out these lines, which prevent OOC Synthesis and OOC Implementation from running.
            set newline $line
            puts $newfp "# $newline"
        }
        default {
            # Copy unchanged lines.
            set newline $line
            puts $newfp $newline
        }  
    }
}
close $newfp
file rename -force "design_ooc.tcl.tmp" "design_ooc.tcl"

#------Generate a modified FastADCcal/design.tcl from the design.tcl generated above------#
# This block follows the same structure as above. 
# Open MCFS_HD/design.tcl
set design_orig [open "design.tcl" r]
set fd [split [read $design_orig] "\n"]
close $design_orig
set newfp [open "FastADCcal/design.tcl.tmp" w]
set count 0
# Go through lines of the file.
foreach line $fd {
    incr count
    switch $count {
        65 { 
            # Change top module name to top_fADC.
            set newline $line
            puts $newfp [regsub "top_fADC" [regsub -all "top" $newline "top_fADC"] "top"]
        }
        74 { 
            # Use top.xdc instead of ${top}.xdc, which would evaluate to "top_fADC.xdc".
            set newline $line
            puts $newfp [regsub "\\\$\{top\}" $newline "top"]
        }
        70 - 77 - 78 - 79 - 80 - 81 - 82 - 83 - 
        83 - 95 - 96 - 
        97 - 98 - 99 - 100 - 101 - 102 - 103 - 104 - 105 - 106 - 
        107 - 108 - 109 - 110 - 111 - 112 - 113 - 114 - 115 - 116 - 
        117 - 118 - 119 - 120 - 121 - 122 - 123 - 124 - 125 - 126 - 
        127 - 128 - 129 - 130 - 131 - 132 - 133 - 134 - 135 - 136 - 
        137 - 138 - 139 - 140 - 141 - 142 - 143 - 144 - 145 - 146 - 
        147 - 148 - 149 - 150 - 151 - 152 - 153 - 154 - 155 - 156 - 
        157 - 158 - 159 - 160 - 161 - 162 - 163 - 
        187 - 188 - 189 - 190 - 191 - 192 - 193 - 194 - 195 - 196 - 
        197 - 198 - 199 - 200 - 201 - 202 - 203 - 204 - 205 - 206 - 
        207 - 208 - 209 - 210 - 211 - 212 - 213 - 214 - 215 - 216 - 
        217 - 218 - 219 - 220 - 221 - 222 - 223 - 224 - 225 - 226 - 
        227 - 228 - 229 - 230 - 231 - 232 - 
        236 - 237 - 238 - 239 - 240 {
            # Omit these lines.
        } 
        85 - 90 { 
            # Change the directory to ../FastADCcal/ from Tcl/ for this output script so it uses the tcl scripts for debugging, make_debug.tcl and write_ltc/tcl.
            set newline $line
            puts $newfp [regsub "\\\$tclDir" $newline "FastADCcal"]
        }
        167 - 168 - 169 - 170 - 171 - 175 { 
            # Change the variable name from "module3" to "module5" for the fDAC module.
            set newline $line
            puts $newfp [regsub -all "module3" $newline "module5"]
        }
        246 { 
            # Delete references to OOC modules not used for calibration.
            set newline $line
            puts $newfp [regsub "\\\$module0File \\\$module1File \\\$module2File \\\$module3File \\\$module4File " $newline ""]
        }
        default { 
            # Copy unchanged lines.
            set newline $line
            puts $newfp $newline
        }  
    }
}
close $newfp
file rename -force "FastADCcal/design.tcl.tmp" "FastADCcal/design.tcl"
