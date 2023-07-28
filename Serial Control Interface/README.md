# Serial Control Interface

The FPGA firmware module serialLine.v uses a two-wire 100 kS/s serial interface to set servo and arbitrary waveform parameters. The serial packet begins and ends with a 16-bit handshake that specifies the parameters to update, which are encoded as 27 sequential 35-bit numbers. 

The gains and other servo parameters, or arbitrary waveform parameters, can be entered into the spreadsheets in this folder. Spreadsheet macros, with keyboard shortcut Ctrl-q, generate the serial packets, writes them to a file param.txt, and calculates the PID transfer function, which is displayed.

The LabVIEW vi Write SRS Arb.vi loads PIDparam.txt as a “point” arbitrary waveform on an SRS DS345 via GPIB. Write SRS Arb.exe is also provided, which requires the 64-bit 2023.Q1 LabVIEW Run-Time Engine. A driver for the GPIB interface may be required; if using the NI GPIB-USB-HS adapter, the 2022 Q4 NI-488.2 driver and NI-488.2 Runtime are needed. For the default firmware, the SRS output should be connected to FPGA pin C12 (serial_in in top.sv) and the SRS trigger output to A14 (serial_trig_in in top.sv). The SRS should be configured for an arbitrary waveform output, with an internal trigger (4 Hz), 100 kHz sample rate, and a 3.2V pk-to-pk amplitude with 0 offset.
