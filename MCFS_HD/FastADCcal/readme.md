See the manual for the procedure to generate bitstreams for Fast ADC testing. After executing Tcl_Script_Generator.tcl in the MCFS_HD directory, the multiphase.tcl and multitap.tcl scripts execute design.tcl multiple times, saving files, including bitstreams and debugging probes files, for each run in Implement\BIT\dump. These are executed in the Vivado 2020.1 Tcl Shell with �source FastADCcal/multiphase.tcl -notrace� and �source FastADCcal/multitap.tcl -notrace�.