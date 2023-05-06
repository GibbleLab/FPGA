# Serial Control Interface

The FPGA firmware module serialLine.v uses a two-wire 100 kS/s serial interface to set servo and arbitrary waveform parameters. The serial packet begins and ends with a 16-bit handshake that specifies the parameters to update, which are encoded as 27 sequential 35-bit numbers. 

The gains and other servo parameters, or arbitrary waveform parameters, can be entered into the spreadsheets in this folder. Spreadsheet macros, with keyboard shortcut Ctrl-q, generate the serial packets, writes them to a file param.txt, and calculates the PID transfer function, which is displayed.

The LabVIEW 6 vi Write SRS Arb.vi loads param.txt as a “point” arbitrary waveform on an SRS DS345 via GPIB. Write SRS Arb.exe is also provided, which requires the 32-bit 2020 LabVIEW Run-Time Engine. For the default firmware, the SRS output should be connected to FPGA pin C12 (serial_in in top.sv) and the SRS trigger output to A14 (serial_trig_in in top.sv).  The SRS should be configured for an arbitrary waveform output, with an internal trigger (4 Hz), 100 kHz sample rate, and a 2V pk-to-pk amplitude with 0 offset.
