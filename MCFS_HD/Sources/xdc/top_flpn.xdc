# Clocks
set_property PACKAGE_PIN AA4 [get_ports clk]

## Display program PBLOCK ##
create_pblock pblock_disp0
add_cells_to_pblock [get_pblocks pblock_disp0] [get_cells -quiet [list disp0]]   
resize_pblock [get_pblocks pblock_disp0] -add {RAMB36_X1Y0:RAMB36_X6Y5 \
                                               RAMB18_X1Y0:RAMB18_X6Y11 \
                                               DSP48_X0Y0:DSP48_X5Y11\
                                               SLICE_X12Y0:SLICE_X109Y32}
set_property CONTAIN_ROUTING 1 [get_pblocks pblock_disp0]
set_property HD.PARTPIN_RANGE {SLICE_X12Y0:SLICE_X12Y32 \
                               SLICE_X12Y0:SLICE_X109Y0 \
                               SLICE_X12Y32:SLICE_X109Y32 \
                               SLICE_X109Y0:SLICE_X109Y32} [get_pins {disp0/*}]

## SR_CTRL PBLOCK ##
create_pblock pblock_SR_CTRL0
add_cells_to_pblock [get_pblocks pblock_SR_CTRL0] [get_cells -quiet SR_CTRL0]
resize_pblock [get_pblocks pblock_SR_CTRL0] -add {SLICE_X8Y0:SLICE_X11Y25}
set_property CONTAIN_ROUTING 1 [get_pblocks pblock_SR_CTRL0]
set_property HD.PARTPIN_RANGE {SLICE_X8Y0:SLICE_X8Y25 \
                               SLICE_X8Y0:SLICE_X11Y0 \
                               SLICE_X8Y25:SLICE_X11Y25 \
                               SLICE_X11Y0:SLICE_X11Y25} [get_pins {SR_CTRL0/*}]

#### PBLOCKS ####
## SlowADCs PBLOCK ##
create_pblock pblock_SlowADCs_inst
add_cells_to_pblock [get_pblocks pblock_SlowADCs_inst] [get_cells -quiet [list SlowADCs_inst]]
resize_pblock [get_pblocks pblock_SlowADCs_inst] -add {RAMB36_X0Y44:RAMB36_X0Y49 \
                                                       RAMB18_X0Y88:RAMB18_X0Y99 \
                                                       SLICE_X0Y218:SLICE_X7Y249}
set_property CONTAIN_ROUTING 1 [get_pblocks pblock_SlowADCs_inst]
set_property HD.PARTPIN_RANGE {SLICE_X0Y218:SLICE_X0Y249 \
                               SLICE_X0Y218:SLICE_X7Y218 \
                               SLICE_X0Y249:SLICE_X7Y249 \
                               SLICE_X7Y218:SLICE_X7Y249} [get_pins {SlowADCs_inst/*}]

# FastDACs PBLOCK ##
create_pblock pblock_fDAC_inst
add_cells_to_pblock [get_pblocks pblock_fDAC_inst] [get_cells -quiet fDAC_inst]
resize_pblock [get_pblocks pblock_fDAC_inst] -add {SLICE_X8Y51:SLICE_X11Y249}
set_property CONTAIN_ROUTING 1 [get_pblocks pblock_fDAC_inst]
set_property HD.PARTPIN_RANGE {SLICE_X8Y51:SLICE_X8Y249 \
                               SLICE_X8Y51:SLICE_X11Y51 \
                               SLICE_X8Y249:SLICE_X11Y249 \
                               SLICE_X11Y51:SLICE_X11Y249} [get_pins {fDAC_inst/*}]

## Slow DAC PBLOCK ##
create_pblock pblock_sDACinst
add_cells_to_pblock [get_pblocks pblock_sDACinst] [get_cells -quiet [list sDACinst]]   
resize_pblock [get_pblocks pblock_sDACinst] -add {RAMB36_X0Y32:RAMB36_X0Y39  \ 
                                                  RAMB18_X0Y64:RAMB18_X0Y79 \ 
                                                  SLICE_X0Y157:SLICE_X7Y199}
set_property CONTAIN_ROUTING 1 [get_pblocks pblock_sDACinst]
set_property HD.PARTPIN_RANGE {SLICE_X0Y157:SLICE_X0Y199 \
                               SLICE_X0Y157:SLICE_X7Y157 \
                               SLICE_X0Y199:SLICE_X7Y199 \
                               SLICE_X7Y157:SLICE_X7Y199} [get_pins {sDACinst/*}]

# FM_MOT PBLOCK ##
create_pblock pblock_FM_MOT0
add_cells_to_pblock [get_pblocks pblock_FM_MOT0] [get_cells -quiet FM_MOT0]
resize_pblock [get_pblocks pblock_FM_MOT0] -add {DSP48_X1Y28:DSP48_X1Y59 \
                                                 SLICE_X12Y70:SLICE_X23Y152}
set_property CONTAIN_ROUTING 1 [get_pblocks pblock_FM_MOT0]
set_property HD.PARTPIN_RANGE {SLICE_X12Y70:SLICE_X12Y152 \
                               SLICE_X12Y70:SLICE_X23Y70 \
                               SLICE_X12Y152:SLICE_X23Y152 \
                               SLICE_X23Y70:SLICE_X23Y152} [get_pins {FM_MOT0/*}]

# Output LEDs on module board
set_property PACKAGE_PIN U9       [get_ports {led_out[3]}]
set_property IOSTANDARD  LVCMOS15 [get_ports {led_out[3]}]
set_property PACKAGE_PIN V12      [get_ports {led_out[2]}]
set_property IOSTANDARD  LVCMOS15 [get_ports {led_out[2]}]
set_property PACKAGE_PIN V13      [get_ports {led_out[1]}]
set_property IOSTANDARD  LVCMOS15 [get_ports {led_out[1]}]
set_property PACKAGE_PIN W13      [get_ports {led_out[0]}]
set_property IOSTANDARD  LVCMOS15 [get_ports {led_out[0]}]

# Shift-register serial lines
set_property PACKAGE_PIN E21      [get_ports SR_STROBE]
set_property IOSTANDARD  LVCMOS25 [get_ports SR_STROBE]
set_property PACKAGE_PIN D24      [get_ports SR_SCLK]
set_property IOSTANDARD  LVCMOS25 [get_ports SR_SCLK]
set_property PACKAGE_PIN E22      [get_ports SR_OUT]
set_property IOSTANDARD  LVCMOS25 [get_ports SR_OUT]
set_property PACKAGE_PIN D23      [get_ports SR_IN]
set_property IOSTANDARD  LVCMOS25 [get_ports SR_IN]
# Shift-register B serial lines
set_property PACKAGE_PIN C22      [get_ports SR_B_STROBE]
set_property IOSTANDARD  LVCMOS25 [get_ports SR_B_STROBE]
set_property PACKAGE_PIN D21      [get_ports SR_B_IN]
set_property IOSTANDARD  LVCMOS25 [get_ports SR_B_IN]
set_property PACKAGE_PIN N16      [get_ports SR_B_SCLK]
set_property IOSTANDARD  LVCMOS33 [get_ports SR_B_SCLK]

# Free digital lines
# Free digital lines (connector B)
set_property PACKAGE_PIN A19      [get_ports A19]
set_property IOSTANDARD  LVCMOS33 [get_ports A19]
set_property PACKAGE_PIN B14      [get_ports B14]
set_property IOSTANDARD  LVCMOS33 [get_ports B14]
set_property PACKAGE_PIN A14      [get_ports A14]
set_property IOSTANDARD  LVCMOS33 [get_ports A14]
set_property PACKAGE_PIN B15      [get_ports B15]
set_property IOSTANDARD  LVCMOS33 [get_ports B15]
set_property PACKAGE_PIN A15      [get_ports A15]
set_property IOSTANDARD  LVCMOS33 [get_ports A15]
set_property PACKAGE_PIN C12      [get_ports C12]
set_property IOSTANDARD  LVCMOS33 [get_ports C12]
# Free digital lines (connector C)
set_property PACKAGE_PIN U16      [get_ports U16]
set_property IOSTANDARD  LVCMOS33 [get_ports U16]
set_property PACKAGE_PIN M22      [get_ports M22]
set_property IOSTANDARD  LVCMOS33 [get_ports M22]
set_property PACKAGE_PIN R26      [get_ports R26]
set_property IOSTANDARD  LVCMOS33 [get_ports R26]
set_property PACKAGE_PIN P26      [get_ports P26]
set_property IOSTANDARD  LVCMOS33 [get_ports P26]
set_property PACKAGE_PIN N26      [get_ports N26]
set_property IOSTANDARD  LVCMOS33 [get_ports N26]
set_property PACKAGE_PIN M25      [get_ports M25]
set_property IOSTANDARD  LVCMOS33 [get_ports M25]
set_property PACKAGE_PIN L25      [get_ports L25]
set_property IOSTANDARD  LVCMOS33 [get_ports L25]
set_property PACKAGE_PIN M26      [get_ports M26]
set_property IOSTANDARD  LVCMOS33 [get_ports M26]

##### Fast ADCs #####
# ADC0 input pins
set_property PACKAGE_PIN W20  [get_ports {D00_p[0]}]
set_property PACKAGE_PIN Y21  [get_ports {D00_n[0]}]
set_property PACKAGE_PIN AD21 [get_ports {D00_p[1]}]
set_property PACKAGE_PIN AE21 [get_ports {D00_n[1]}]
set_property PACKAGE_PIN V21  [get_ports {D01_p[0]}]
set_property PACKAGE_PIN W21  [get_ports {D01_n[0]}]
set_property PACKAGE_PIN V23  [get_ports {D01_p[1]}]
set_property PACKAGE_PIN V24  [get_ports {D01_n[1]}]
# ADC1 input pins
set_property PACKAGE_PIN U24  [get_ports {D10_p[0]}]
set_property PACKAGE_PIN U25  [get_ports {D10_n[0]}]
set_property PACKAGE_PIN AC23 [get_ports {D10_p[1]}]
set_property PACKAGE_PIN AC24 [get_ports {D10_n[1]}]
set_property PACKAGE_PIN U26  [get_ports {D11_p[0]}]
set_property PACKAGE_PIN V26  [get_ports {D11_n[0]}]
set_property PACKAGE_PIN AB26 [get_ports {D11_p[1]}]
set_property PACKAGE_PIN AC26 [get_ports {D11_n[1]}]
# ADC2 input pins
set_property PACKAGE_PIN Y23  [get_ports {D20_p[0]}]
set_property PACKAGE_PIN AA24 [get_ports {D20_n[0]}]
set_property PACKAGE_PIN C21  [get_ports {D20_p[1]}]
set_property PACKAGE_PIN B21  [get_ports {D20_n[1]}]
set_property PACKAGE_PIN A23  [get_ports {D21_p[0]}]
set_property PACKAGE_PIN A24  [get_ports {D21_n[0]}]
set_property PACKAGE_PIN B20  [get_ports {D21_p[1]}]
set_property PACKAGE_PIN A20  [get_ports {D21_n[1]}]
# ADC3 input pins
set_property PACKAGE_PIN AA23 [get_ports {D30_p[0]}]
set_property PACKAGE_PIN AB24 [get_ports {D30_n[0]}]
set_property PACKAGE_PIN AB21 [get_ports {D30_p[1]}]
set_property PACKAGE_PIN AC21 [get_ports {D30_n[1]}]
set_property PACKAGE_PIN AE23 [get_ports {D31_p[0]}]
set_property PACKAGE_PIN AF23 [get_ports {D31_n[0]}]
set_property PACKAGE_PIN AF24 [get_ports {D31_p[1]}]
set_property PACKAGE_PIN AF25 [get_ports {D31_n[1]}]
# ADC4 input pins
set_property PACKAGE_PIN Y22  [get_ports {D40_p[0]}]
set_property PACKAGE_PIN AA22 [get_ports {D40_n[0]}]
set_property PACKAGE_PIN AD25 [get_ports {D40_p[1]}]
set_property PACKAGE_PIN AE25 [get_ports {D40_n[1]}]
set_property PACKAGE_PIN U22  [get_ports {D41_p[0]}]
set_property PACKAGE_PIN V22  [get_ports {D41_n[0]}]
set_property PACKAGE_PIN W23  [get_ports {D41_p[1]}]
set_property PACKAGE_PIN W24  [get_ports {D41_n[1]}]
# ENC input
set_property PACKAGE_PIN F22  [get_ports ENC_p]
set_property PACKAGE_PIN E23  [get_ports ENC_n]
# FR input
set_property PACKAGE_PIN AE22 [get_ports FR0_p]
set_property PACKAGE_PIN AF22 [get_ports FR0_n]
set_property PACKAGE_PIN W25  [get_ports FR1_p]
set_property PACKAGE_PIN W26  [get_ports FR1_n]
set_property PACKAGE_PIN D26  [get_ports FR2_p]
set_property PACKAGE_PIN C26  [get_ports FR2_n]
set_property PACKAGE_PIN AB22 [get_ports FR3_p]
set_property PACKAGE_PIN AC22 [get_ports FR3_n]
set_property PACKAGE_PIN AD23 [get_ports FR4_p]
set_property PACKAGE_PIN AD24 [get_ports FR4_n]
# SPI IOs for ADC
set_property PACKAGE_PIN U21     [get_ports fADC_SCK]
set_property PACKAGE_PIN AB25    [get_ports fADC_SDI]
set_property PACKAGE_PIN AA25    [get_ports fADC_SDO]
set_property PACKAGE_PIN Y20     [get_ports fADC_CS0]
set_property PACKAGE_PIN AD26    [get_ports fADC_CS1]
set_property PACKAGE_PIN AE26    [get_ports fADC_CS2]
set_property PACKAGE_PIN Y25     [get_ports fADC_CS3]
set_property PACKAGE_PIN Y26     [get_ports fADC_CS4]
set_property IOSTANDARD LVCMOS25 [get_ports fADC_SCK]
set_property IOSTANDARD LVCMOS25 [get_ports fADC_SDI]
set_property IOSTANDARD LVCMOS25 [get_ports fADC_SDO]
set_property IOSTANDARD LVCMOS25 [get_ports fADC_CS0]
set_property IOSTANDARD LVCMOS25 [get_ports fADC_CS1]
set_property IOSTANDARD LVCMOS25 [get_ports fADC_CS2]
set_property IOSTANDARD LVCMOS25 [get_ports fADC_CS3]
set_property IOSTANDARD LVCMOS25 [get_ports fADC_CS4]

##### Slow ADC #####
set_property PACKAGE_PIN A10      [get_ports sADC_CNV]
set_property PACKAGE_PIN B11      [get_ports sADC_SDO0]
set_property PACKAGE_PIN A13      [get_ports sADC_SDO1]
set_property PACKAGE_PIN H14      [get_ports sADC_SCKI]
set_property PACKAGE_PIN B10      [get_ports sADC_SDI]
set_property PACKAGE_PIN G14      [get_ports sADC_BUSY0]
set_property PACKAGE_PIN B12      [get_ports sADC_BUSY1]
set_property PACKAGE_PIN A12      [get_ports sADC_CS0]
set_property PACKAGE_PIN C11      [get_ports sADC_CS1]
set_property IOSTANDARD  LVCMOS33 [get_ports sADC_CNV]
set_property IOSTANDARD  LVCMOS33 [get_ports sADC_SDO0]
set_property IOSTANDARD  LVCMOS33 [get_ports sADC_SDO1]
set_property IOSTANDARD  LVCMOS33 [get_ports sADC_SCKI]
set_property IOSTANDARD  LVCMOS33 [get_ports sADC_SDI]
set_property IOSTANDARD  LVCMOS33 [get_ports sADC_BUSY0]
set_property IOSTANDARD  LVCMOS33 [get_ports sADC_BUSY1]
set_property IOSTANDARD  LVCMOS33 [get_ports sADC_CS0]
set_property IOSTANDARD  LVCMOS33 [get_ports sADC_CS1]

##### Fast DAC #####
# Clock for connector B fDACs
set_property PACKAGE_PIN F19      [get_ports fDACclkB]
# Clock for connector C fDACs
set_property PACKAGE_PIN R17      [get_ports fDACclkC]
set_property IOSTANDARD  LVCMOS33 [get_ports fDACclkB]
set_property IOSTANDARD  LVCMOS33 [get_ports fDACclkC]
# DAC0
# fDAC0 sel
set_property PACKAGE_PIN E20      [get_ports fDAC0_sel]
set_property IOSTANDARD  LVCMOS33 [get_ports fDAC0_sel]
set_property IOB         TRUE     [get_ports fDAC0_sel]
# fDAC0 data
set_property PACKAGE_PIN H17      [get_ports fDAC0_out[15]]
set_property PACKAGE_PIN H18      [get_ports fDAC0_out[14]]
set_property PACKAGE_PIN G19      [get_ports fDAC0_out[13]]
set_property PACKAGE_PIN F20      [get_ports fDAC0_out[12]]
set_property PACKAGE_PIN L19      [get_ports fDAC0_out[11]]
set_property PACKAGE_PIN L20      [get_ports fDAC0_out[10]]
set_property PACKAGE_PIN K20      [get_ports fDAC0_out[9]]
set_property PACKAGE_PIN J20      [get_ports fDAC0_out[8]]
set_property PACKAGE_PIN M17      [get_ports fDAC0_out[7]]
set_property PACKAGE_PIN L18      [get_ports fDAC0_out[6]]
set_property PACKAGE_PIN L17      [get_ports fDAC0_out[5]]
set_property PACKAGE_PIN K18      [get_ports fDAC0_out[4]]
set_property PACKAGE_PIN K16      [get_ports fDAC0_out[3]]
set_property PACKAGE_PIN K17      [get_ports fDAC0_out[2]]
set_property PACKAGE_PIN J18      [get_ports fDAC0_out[1]]
set_property PACKAGE_PIN J19      [get_ports fDAC0_out[0]]
set_property IOSTANDARD  LVCMOS33 [get_ports fDAC0_out[*]]
set_property IOB         TRUE     [get_ports fDAC0_out[*]]

# DAC1
# fDAC1 sel
set_property PACKAGE_PIN G11      [get_ports fDAC1_sel]
set_property IOSTANDARD  LVCMOS33 [get_ports fDAC1_sel]
set_property IOB         TRUE     [get_ports fDAC1_sel]
# fDAC1 data
set_property PACKAGE_PIN F10      [get_ports fDAC1_out[15]]
set_property PACKAGE_PIN C14      [get_ports fDAC1_out[14]]
set_property PACKAGE_PIN C13      [get_ports fDAC1_out[13]]
set_property PACKAGE_PIN D14      [get_ports fDAC1_out[12]]
set_property PACKAGE_PIN D13      [get_ports fDAC1_out[11]]
set_property PACKAGE_PIN J13      [get_ports fDAC1_out[10]]
set_property PACKAGE_PIN H13      [get_ports fDAC1_out[9]]
set_property PACKAGE_PIN F14      [get_ports fDAC1_out[8]]
set_property PACKAGE_PIN F13      [get_ports fDAC1_out[7]]
set_property PACKAGE_PIN E13      [get_ports fDAC1_out[6]]
set_property PACKAGE_PIN E12      [get_ports fDAC1_out[5]]
set_property PACKAGE_PIN G12      [get_ports fDAC1_out[4]]
set_property PACKAGE_PIN F12      [get_ports fDAC1_out[3]]
set_property PACKAGE_PIN J11      [get_ports fDAC1_out[2]]
set_property PACKAGE_PIN J10      [get_ports fDAC1_out[1]]
set_property PACKAGE_PIN H12      [get_ports fDAC1_out[0]]
set_property IOSTANDARD  LVCMOS33 [get_ports fDAC1_out[*]]
set_property IOB         TRUE     [get_ports fDAC1_out[*]]

# DAC2
# fDAC2 sel
set_property PACKAGE_PIN H19      [get_ports fDAC2_sel]
set_property IOSTANDARD  LVCMOS33 [get_ports fDAC2_sel]
set_property IOB         TRUE     [get_ports fDAC2_sel]
# fDAC2 data
set_property PACKAGE_PIN G20      [get_ports fDAC2_out[15]]
set_property PACKAGE_PIN D19      [get_ports fDAC2_out[14]]
set_property PACKAGE_PIN D20      [get_ports fDAC2_out[13]]
set_property PACKAGE_PIN G17      [get_ports fDAC2_out[12]]
set_property PACKAGE_PIN F18      [get_ports fDAC2_out[11]]
set_property PACKAGE_PIN C17      [get_ports fDAC2_out[10]]
set_property PACKAGE_PIN C18      [get_ports fDAC2_out[9]]
set_property PACKAGE_PIN C16      [get_ports fDAC2_out[8]]
set_property PACKAGE_PIN B16      [get_ports fDAC2_out[7]]
set_property PACKAGE_PIN B17      [get_ports fDAC2_out[6]]
set_property PACKAGE_PIN A17      [get_ports fDAC2_out[5]]
set_property PACKAGE_PIN E18      [get_ports fDAC2_out[4]]
set_property PACKAGE_PIN D18      [get_ports fDAC2_out[3]]
set_property PACKAGE_PIN C19      [get_ports fDAC2_out[2]]
set_property PACKAGE_PIN B19      [get_ports fDAC2_out[1]]
set_property PACKAGE_PIN A18      [get_ports fDAC2_out[0]]
set_property IOSTANDARD  LVCMOS33 [get_ports fDAC2_out[*]]
set_property IOB         TRUE     [get_ports fDAC2_out[*]]

# DAC3
# fDAC3 sel
set_property PACKAGE_PIN R16      [get_ports fDAC3_sel]
set_property IOSTANDARD  LVCMOS33 [get_ports fDAC3_sel]
set_property IOB         TRUE     [get_ports fDAC3_sel]
# fDAC3 data
set_property PACKAGE_PIN M19      [get_ports fDAC3_out[15]]
set_property PACKAGE_PIN N18      [get_ports fDAC3_out[14]]
set_property PACKAGE_PIN H8       [get_ports fDAC3_out[13]]
set_property PACKAGE_PIN H9       [get_ports fDAC3_out[12]]
set_property PACKAGE_PIN F8       [get_ports fDAC3_out[11]]
set_property PACKAGE_PIN F9       [get_ports fDAC3_out[10]]
set_property PACKAGE_PIN D10      [get_ports fDAC3_out[9]]
set_property PACKAGE_PIN E10      [get_ports fDAC3_out[8]]
set_property PACKAGE_PIN D8       [get_ports fDAC3_out[7]]
set_property PACKAGE_PIN D9       [get_ports fDAC3_out[6]]
set_property PACKAGE_PIN B9       [get_ports fDAC3_out[5]]
set_property PACKAGE_PIN C9       [get_ports fDAC3_out[4]]
set_property PACKAGE_PIN A8       [get_ports fDAC3_out[3]]
set_property PACKAGE_PIN A9       [get_ports fDAC3_out[2]]
set_property PACKAGE_PIN J14      [get_ports fDAC3_out[1]]
set_property PACKAGE_PIN J8       [get_ports fDAC3_out[0]]
set_property IOSTANDARD  LVCMOS33 [get_ports fDAC3_out[*]]
set_property IOB         TRUE     [get_ports fDAC3_out[*]]

# DAC4
# fDAC4 sel
set_property PACKAGE_PIN U17      [get_ports fDAC4_sel]
set_property IOSTANDARD  LVCMOS33 [get_ports fDAC4_sel]
set_property IOB         TRUE     [get_ports fDAC4_sel]
# fDAC4 data
set_property PACKAGE_PIN N17      [get_ports fDAC4_out[15]]
set_property PACKAGE_PIN P16      [get_ports fDAC4_out[14]]
set_property PACKAGE_PIN D16      [get_ports fDAC4_out[13]]
set_property PACKAGE_PIN D15      [get_ports fDAC4_out[12]]
set_property PACKAGE_PIN G16      [get_ports fDAC4_out[11]]
set_property PACKAGE_PIN H16      [get_ports fDAC4_out[10]]
set_property PACKAGE_PIN E16      [get_ports fDAC4_out[9]]
set_property PACKAGE_PIN E15      [get_ports fDAC4_out[8]]
set_property PACKAGE_PIN E17      [get_ports fDAC4_out[7]]
set_property PACKAGE_PIN F17      [get_ports fDAC4_out[6]]
set_property PACKAGE_PIN J16      [get_ports fDAC4_out[5]]
set_property PACKAGE_PIN J15      [get_ports fDAC4_out[4]]
set_property PACKAGE_PIN F15      [get_ports fDAC4_out[3]]
set_property PACKAGE_PIN G15      [get_ports fDAC4_out[2]]
set_property PACKAGE_PIN M16      [get_ports fDAC4_out[1]]
set_property PACKAGE_PIN K15      [get_ports fDAC4_out[0]]
set_property IOSTANDARD  LVCMOS33 [get_ports fDAC4_out[*]]
set_property IOB         TRUE     [get_ports fDAC4_out[*]]

# DAC5
# fDAC5 sel
set_property PACKAGE_PIN M21      [get_ports fDAC5_sel]
set_property IOSTANDARD  LVCMOS33 [get_ports fDAC5_sel]
set_property IOB         TRUE     [get_ports fDAC5_sel]
# fDAC5 data
set_property PACKAGE_PIN P21      [get_ports fDAC5_out[15]]
set_property PACKAGE_PIN R21      [get_ports fDAC5_out[14]]
set_property PACKAGE_PIN P25      [get_ports fDAC5_out[13]]
set_property PACKAGE_PIN R25      [get_ports fDAC5_out[12]]
set_property PACKAGE_PIN R20      [get_ports fDAC5_out[11]]
set_property PACKAGE_PIN T20      [get_ports fDAC5_out[10]]
set_property PACKAGE_PIN U20      [get_ports fDAC5_out[9]]
set_property PACKAGE_PIN U19      [get_ports fDAC5_out[8]]
set_property PACKAGE_PIN T19      [get_ports fDAC5_out[7]]
set_property PACKAGE_PIN T18      [get_ports fDAC5_out[6]]
set_property PACKAGE_PIN M20      [get_ports fDAC5_out[5]]
set_property PACKAGE_PIN N19      [get_ports fDAC5_out[4]]
set_property PACKAGE_PIN T25      [get_ports fDAC5_out[3]]
set_property PACKAGE_PIN T24      [get_ports fDAC5_out[2]]
set_property PACKAGE_PIN N23      [get_ports fDAC5_out[1]]
set_property PACKAGE_PIN P23      [get_ports fDAC5_out[0]]
set_property IOSTANDARD  LVCMOS33 [get_ports {fDAC5_out[*]}]
set_property IOB         TRUE     [get_ports fDAC5_out[*]]

# DAC6
# fDAC6 sel
set_property PACKAGE_PIN L24      [get_ports fDAC6_sel]
set_property IOSTANDARD  LVCMOS33 [get_ports fDAC6_sel]
set_property IOB         TRUE     [get_ports fDAC6_sel]
# fDAC6 data
set_property PACKAGE_PIN M24      [get_ports fDAC6_out[15]]
set_property PACKAGE_PIN N22      [get_ports fDAC6_out[14]]
set_property PACKAGE_PIN N21      [get_ports fDAC6_out[13]]
set_property PACKAGE_PIN K26      [get_ports fDAC6_out[12]]
set_property PACKAGE_PIN K25      [get_ports fDAC6_out[11]]
set_property PACKAGE_PIN T23      [get_ports fDAC6_out[10]]
set_property PACKAGE_PIN T22      [get_ports fDAC6_out[9]]
set_property PACKAGE_PIN P20      [get_ports fDAC6_out[8]]
set_property PACKAGE_PIN P19      [get_ports fDAC6_out[7]]
set_property PACKAGE_PIN N24      [get_ports fDAC6_out[6]]
set_property PACKAGE_PIN P24      [get_ports fDAC6_out[5]]
set_property PACKAGE_PIN R23      [get_ports fDAC6_out[4]]
set_property PACKAGE_PIN R22      [get_ports fDAC6_out[3]]
set_property PACKAGE_PIN P18      [get_ports fDAC6_out[2]]
set_property PACKAGE_PIN R18      [get_ports fDAC6_out[1]]
set_property PACKAGE_PIN T17      [get_ports fDAC6_out[0]]
set_property IOSTANDARD  LVCMOS33 [get_ports fDAC6_out[*]]
set_property IOB         TRUE     [get_ports fDAC6_out[*]]

##### Slow DAC #####
set_property PACKAGE_PIN G9  [get_ports sDAC_SDO]
set_property PACKAGE_PIN E11 [get_ports sDAC_SCK]
set_property PACKAGE_PIN G10 [get_ports sDAC_SDI]
set_property PACKAGE_PIN D11 [get_ports sDAC0_CS]
set_property PACKAGE_PIN H11 [get_ports sDAC1_CS]
set_property IOSTANDARD LVCMOS33 [get_ports sDAC_SDO]
set_property IOSTANDARD LVCMOS33 [get_ports sDAC_SCK]
set_property IOSTANDARD LVCMOS33 [get_ports sDAC_SDI]
set_property IOSTANDARD LVCMOS33 [get_ports sDAC0_CS]
set_property IOSTANDARD LVCMOS33 [get_ports sDAC1_CS]

#Configuration settings (are they needed?)
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 2.5 [current_design]
#Bitstream configuration preference (faster programming from flash)
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

#Declaration of input clock
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

create_generated_clock -name fDACclkB -source [get_pins {fDAC_inst/ODDR_fDACclkB/C}] -divide_by 1 [get_ports {fDACclkB}]
set_output_delay -clock [get_clocks fDACclkB] -max -0.6 [get_ports {fDAC0_out[*]}] 
set_output_delay -clock [get_clocks fDACclkB] -min -2.1 [get_ports {fDAC0_out[*]}]
set_output_delay -clock [get_clocks fDACclkB] -max -0.6 [get_ports fDAC0_sel] 
set_output_delay -clock [get_clocks fDACclkB] -min -2.1 [get_ports fDAC0_sel]
set_output_delay -clock [get_clocks fDACclkB] -max -0.6 [get_ports {fDAC1_out[*]}] 
set_output_delay -clock [get_clocks fDACclkB] -min -2.1 [get_ports {fDAC1_out[*]}]
set_output_delay -clock [get_clocks fDACclkB] -max -0.6 [get_ports fDAC1_sel] 
set_output_delay -clock [get_clocks fDACclkB] -min -2.1 [get_ports fDAC1_sel]
set_output_delay -clock [get_clocks fDACclkB] -max -0.6 [get_ports {fDAC2_out[*]}] 
set_output_delay -clock [get_clocks fDACclkB] -min -2.1 [get_ports {fDAC2_out[*]}]
set_output_delay -clock [get_clocks fDACclkB] -max -0.6 [get_ports fDAC2_sel] 
set_output_delay -clock [get_clocks fDACclkB] -min -2.1 [get_ports fDAC2_sel]

create_generated_clock -name fDACclkC -source [get_pins {fDAC_inst/ODDR_fDACclkC/C}] -divide_by 1 [get_ports {fDACclkC}]
set_output_delay -clock [get_clocks fDACclkC] -max -0.6 [get_ports fDAC3_out[*]] 
set_output_delay -clock [get_clocks fDACclkC] -min -2.1 [get_ports fDAC3_out[*]]
set_output_delay -clock [get_clocks fDACclkC] -max -0.6 [get_ports fDAC3_sel] 
set_output_delay -clock [get_clocks fDACclkC] -min -2.1 [get_ports fDAC3_sel]
set_output_delay -clock [get_clocks fDACclkC] -max -0.6 [get_ports fDAC4_out[*]] 
set_output_delay -clock [get_clocks fDACclkC] -min -2.1 [get_ports fDAC4_out[*]]
set_output_delay -clock [get_clocks fDACclkC] -max -0.6 [get_ports fDAC4_sel] 
set_output_delay -clock [get_clocks fDACclkC] -min -2.1 [get_ports fDAC4_sel]
set_output_delay -clock [get_clocks fDACclkC] -max -0.6 [get_ports fDAC5_out[*]] 
set_output_delay -clock [get_clocks fDACclkC] -min -2.1 [get_ports fDAC5_out[*]]
set_output_delay -clock [get_clocks fDACclkC] -max -0.6 [get_ports fDAC5_sel] 
set_output_delay -clock [get_clocks fDACclkC] -min -2.1 [get_ports fDAC5_sel]
set_output_delay -clock [get_clocks fDACclkC] -min -0.6 [get_ports fDAC6_out[*]] 
set_output_delay -clock [get_clocks fDACclkC] -min -2.1 [get_ports fDAC6_out[*]]
set_output_delay -clock [get_clocks fDACclkC] -min -0.6 [get_ports fDAC6_sel] 
set_output_delay -clock [get_clocks fDACclkC] -min -2.1 [get_ports fDAC6_sel]

### Display program delays ###
create_generated_clock -name SR_SCLK -source [get_pins DisplayProg0/ODDR_SRclk/C] -divide_by 1 [get_ports SR_SCLK]
set_output_delay -clock [get_clocks SR_SCLK] -min -add_delay -2.000 [get_ports SR_OUT]
set_output_delay -clock [get_clocks SR_SCLK] -max -add_delay 3.500 [get_ports SR_OUT]
set_output_delay -clock [get_clocks SR_SCLK] -min -add_delay 10.000 [get_ports SR_STROBE]
set_output_delay -clock [get_clocks SR_SCLK] -max -add_delay 20.000 [get_ports SR_STROBE]