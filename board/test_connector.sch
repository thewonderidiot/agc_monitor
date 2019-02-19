EESchema Schematic File Version 4
LIBS:agc_monitor-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 4
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L agc_monitor:test_connector P1
U 1 1 5C348453
P 3500 2650
F 0 "P1" H 3600 3450 50  0000 L CNN
F 1 "test_connector" H 3879 2555 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 3500 2650 50  0001 C CNN
F 3 "" H 3500 2650 50  0001 C CNN
	1    3500 2650
	1    0    0    -1  
$EndComp
$Comp
L agc_monitor:test_connector P1
U 2 1 5C34852D
P 4700 2650
F 0 "P1" H 4800 3450 50  0000 L CNN
F 1 "test_connector" H 5079 2555 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 4700 2650 50  0001 C CNN
F 3 "" H 4700 2650 50  0001 C CNN
	2    4700 2650
	1    0    0    -1  
$EndComp
$Comp
L agc_monitor:test_connector P1
U 3 1 5C348601
P 5800 2650
F 0 "P1" H 5900 3450 50  0000 L CNN
F 1 "test_connector" H 6179 2555 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 5800 2650 50  0001 C CNN
F 3 "" H 5800 2650 50  0001 C CNN
	3    5800 2650
	1    0    0    -1  
$EndComp
$Comp
L agc_monitor:test_connector P1
U 4 1 5C348607
P 6950 2650
F 0 "P1" H 7050 3450 50  0000 L CNN
F 1 "test_connector" H 7329 2555 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 6950 2650 50  0001 C CNN
F 3 "" H 6950 2650 50  0001 C CNN
	4    6950 2650
	1    0    0    -1  
$EndComp
$Comp
L agc_monitor:test_connector P1
U 5 1 5C3486F3
P 8000 2650
F 0 "P1" H 8100 3450 50  0000 L CNN
F 1 "test_connector" H 8379 2555 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 8000 2650 50  0001 C CNN
F 3 "" H 8000 2650 50  0001 C CNN
	5    8000 2650
	1    0    0    -1  
$EndComp
$Comp
L agc_monitor:test_connector P1
U 6 1 5C3487FE
P 4000 4550
F 0 "P1" H 4100 5350 50  0000 L CNN
F 1 "test_connector" H 4379 4455 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 4000 4550 50  0001 C CNN
F 3 "" H 4000 4550 50  0001 C CNN
	6    4000 4550
	1    0    0    -1  
$EndComp
$Comp
L agc_monitor:test_connector P1
U 7 1 5C348804
P 5250 4550
F 0 "P1" H 5350 5350 50  0000 L CNN
F 1 "test_connector" H 5629 4455 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 5250 4550 50  0001 C CNN
F 3 "" H 5250 4550 50  0001 C CNN
	7    5250 4550
	1    0    0    -1  
$EndComp
$Comp
L agc_monitor:test_connector P1
U 9 1 5C348810
P 7650 4550
F 0 "P1" H 7750 5350 50  0000 L CNN
F 1 "test_connector" H 8029 4455 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 7650 4550 50  0001 C CNN
F 3 "" H 7650 4550 50  0001 C CNN
	9    7650 4550
	1    0    0    -1  
$EndComp
Wire Wire Line
	7500 3850 7050 3850
Wire Wire Line
	7050 3850 7050 4050
$Comp
L power:GND #PWR0101
U 1 1 5C348B58
P 7050 5450
F 0 "#PWR0101" H 7050 5200 50  0001 C CNN
F 1 "GND" H 7055 5277 50  0000 C CNN
F 2 "" H 7050 5450 50  0001 C CNN
F 3 "" H 7050 5450 50  0001 C CNN
	1    7050 5450
	1    0    0    -1  
$EndComp
Wire Wire Line
	7500 4050 7050 4050
Connection ~ 7050 4050
Wire Wire Line
	7050 4050 7050 4250
Wire Wire Line
	7500 4250 7050 4250
Connection ~ 7050 4250
Wire Wire Line
	7050 4250 7050 4450
Wire Wire Line
	7500 4450 7050 4450
Connection ~ 7050 4450
Wire Wire Line
	7050 4450 7050 4650
Wire Wire Line
	7500 4650 7050 4650
Connection ~ 7050 4650
Wire Wire Line
	7050 4650 7050 4850
Wire Wire Line
	7500 4850 7050 4850
Connection ~ 7050 4850
Wire Wire Line
	7050 4850 7050 5050
Wire Wire Line
	7500 5050 7050 5050
Connection ~ 7050 5050
Wire Wire Line
	7050 5050 7050 5250
Wire Wire Line
	7500 5250 7050 5250
Connection ~ 7050 5250
Wire Wire Line
	7050 5250 7050 5450
Text GLabel 3300 1950 0    50   Input ~ 0
MDT01
Wire Wire Line
	3300 1950 3350 1950
Text GLabel 3300 2050 0    50   Input ~ 0
MDT02
Wire Wire Line
	3300 2050 3350 2050
Text GLabel 3300 2150 0    50   Input ~ 0
MDT03
Wire Wire Line
	3300 2150 3350 2150
Text GLabel 3300 2250 0    50   Input ~ 0
MDT04
Wire Wire Line
	3300 2250 3350 2250
Text GLabel 3300 2350 0    50   Input ~ 0
MDT05
Wire Wire Line
	3300 2350 3350 2350
Text GLabel 3300 2450 0    50   Input ~ 0
MDT06
Wire Wire Line
	3300 2450 3350 2450
Text GLabel 3300 2550 0    50   Input ~ 0
MDT07
Wire Wire Line
	3300 2550 3350 2550
Text GLabel 3300 2650 0    50   Input ~ 0
MDT08
Wire Wire Line
	3300 2650 3350 2650
Text GLabel 3300 2750 0    50   Input ~ 0
MDT09
Wire Wire Line
	3300 2750 3350 2750
Text GLabel 3300 2850 0    50   Input ~ 0
MDT10
Wire Wire Line
	3300 2850 3350 2850
Text GLabel 3300 2950 0    50   Input ~ 0
MDT11
Wire Wire Line
	3300 2950 3350 2950
Text GLabel 3300 3050 0    50   Input ~ 0
MDT12
Wire Wire Line
	3300 3050 3350 3050
Text GLabel 3300 3150 0    50   Input ~ 0
MDT13
Wire Wire Line
	3300 3150 3350 3150
Text GLabel 3300 3250 0    50   Input ~ 0
MDT14
Wire Wire Line
	3300 3250 3350 3250
Text GLabel 3300 3350 0    50   Input ~ 0
MDT15
Wire Wire Line
	3300 3350 3350 3350
Text GLabel 3300 3450 0    50   Input ~ 0
MDT16
Wire Wire Line
	3300 3450 3350 3450
Text GLabel 4500 1950 0    50   Output ~ 0
MWL01
Wire Wire Line
	4550 1950 4500 1950
Text GLabel 4500 2050 0    50   Output ~ 0
MWL02
Wire Wire Line
	4550 2050 4500 2050
Text GLabel 4500 2150 0    50   Output ~ 0
MWL03
Wire Wire Line
	4550 2150 4500 2150
Text GLabel 4500 2250 0    50   Output ~ 0
MWL04
Wire Wire Line
	4550 2250 4500 2250
Text GLabel 4500 2350 0    50   Output ~ 0
MWL05
Wire Wire Line
	4550 2350 4500 2350
Text GLabel 4500 2450 0    50   Output ~ 0
MWL06
Wire Wire Line
	4550 2450 4500 2450
Text GLabel 4500 2550 0    50   Output ~ 0
MWL07
Wire Wire Line
	4550 2550 4500 2550
Text GLabel 4500 2650 0    50   Output ~ 0
MWL08
Wire Wire Line
	4550 2650 4500 2650
Text GLabel 4500 2750 0    50   Output ~ 0
MWL09
Wire Wire Line
	4550 2750 4500 2750
Text GLabel 4500 2850 0    50   Output ~ 0
MWL10
Wire Wire Line
	4550 2850 4500 2850
Text GLabel 4500 2950 0    50   Output ~ 0
MWL11
Wire Wire Line
	4550 2950 4500 2950
Text GLabel 4500 3050 0    50   Output ~ 0
MWL12
Wire Wire Line
	4550 3050 4500 3050
Text GLabel 4500 3150 0    50   Output ~ 0
MWL13
Wire Wire Line
	4550 3150 4500 3150
Text GLabel 4500 3250 0    50   Output ~ 0
MWL14
Wire Wire Line
	4550 3250 4500 3250
Text GLabel 4500 3350 0    50   Output ~ 0
MWL15
Wire Wire Line
	4550 3350 4500 3350
Text GLabel 4500 3450 0    50   Output ~ 0
MWL16
Wire Wire Line
	4550 3450 4500 3450
Text GLabel 5600 1950 0    50   Output ~ 0
MT01
Wire Wire Line
	5650 1950 5600 1950
Text GLabel 5600 2050 0    50   Output ~ 0
MT02
Wire Wire Line
	5650 2050 5600 2050
Text GLabel 5600 2150 0    50   Output ~ 0
MT03
Wire Wire Line
	5650 2150 5600 2150
Text GLabel 5600 2250 0    50   Output ~ 0
MT04
Wire Wire Line
	5650 2250 5600 2250
Text GLabel 5600 2350 0    50   Output ~ 0
MT05
Wire Wire Line
	5650 2350 5600 2350
Text GLabel 5600 2450 0    50   Output ~ 0
MT06
Wire Wire Line
	5650 2450 5600 2450
Text GLabel 5600 2550 0    50   Output ~ 0
MT07
Wire Wire Line
	5650 2550 5600 2550
Text GLabel 5600 2650 0    50   Output ~ 0
MT08
Wire Wire Line
	5650 2650 5600 2650
Text GLabel 5600 2750 0    50   Output ~ 0
MT09
Wire Wire Line
	5650 2750 5600 2750
Text GLabel 5600 2850 0    50   Output ~ 0
MT10
Wire Wire Line
	5650 2850 5600 2850
Text GLabel 5600 2950 0    50   Output ~ 0
MT11
Wire Wire Line
	5650 2950 5600 2950
Text GLabel 5600 3050 0    50   Output ~ 0
MT12
Wire Wire Line
	5650 3050 5600 3050
Text GLabel 5600 3150 0    50   Output ~ 0
MRULOG
Wire Wire Line
	5650 3150 5600 3150
Text GLabel 5600 3250 0    50   Output ~ 0
MWFBG
Wire Wire Line
	5650 3250 5600 3250
Text GLabel 5600 3350 0    50   Output ~ 0
MWEBG
Wire Wire Line
	5650 3350 5600 3350
Text GLabel 5600 3450 0    50   Output ~ 0
MWBBEG
Wire Wire Line
	5650 3450 5600 3450
Text GLabel 6750 1950 0    50   Output ~ 0
MST1
Wire Wire Line
	6800 1950 6750 1950
Text GLabel 6750 2050 0    50   Output ~ 0
MST2
Wire Wire Line
	6800 2050 6750 2050
Text GLabel 6750 2150 0    50   Output ~ 0
MST3
Wire Wire Line
	6800 2150 6750 2150
Text GLabel 6750 2250 0    50   Output ~ 0
MTCSA_n
Wire Wire Line
	6800 2250 6750 2250
Text GLabel 6750 2350 0    50   Output ~ 0
MWSG
Wire Wire Line
	6800 2350 6750 2350
Text GLabel 6750 2450 0    50   Output ~ 0
MWZG
Wire Wire Line
	6800 2450 6750 2450
Text GLabel 6750 2550 0    50   Output ~ 0
MWYG
Wire Wire Line
	6800 2550 6750 2550
Text GLabel 6750 2650 0    50   Output ~ 0
MWQG
Wire Wire Line
	6800 2650 6750 2650
Text GLabel 6750 2750 0    50   Output ~ 0
MWBG
Wire Wire Line
	6800 2750 6750 2750
Text GLabel 6750 2850 0    50   Output ~ 0
MSQ10
Wire Wire Line
	6800 2850 6750 2850
Text GLabel 6750 2950 0    50   Output ~ 0
MSQ11
Wire Wire Line
	6800 2950 6750 2950
Text GLabel 6750 3050 0    50   Output ~ 0
MSQ12
Wire Wire Line
	6800 3050 6750 3050
Text GLabel 6750 3150 0    50   Output ~ 0
MSQ13
Wire Wire Line
	6800 3150 6750 3150
Text GLabel 6750 3250 0    50   Output ~ 0
MSQ14
Wire Wire Line
	6800 3250 6750 3250
Text GLabel 6750 3350 0    50   Output ~ 0
MSQEXT
Wire Wire Line
	6800 3350 6750 3350
Text GLabel 6750 3450 0    50   Output ~ 0
MSQ16
Wire Wire Line
	6800 3450 6750 3450
Text GLabel 7800 1950 0    50   Output ~ 0
MBR1
Wire Wire Line
	7850 1950 7800 1950
Text GLabel 7800 2050 0    50   Output ~ 0
MBR2
Wire Wire Line
	7850 2050 7800 2050
Text GLabel 7800 2150 0    50   Output ~ 0
MIIP
Wire Wire Line
	7850 2150 7800 2150
Text GLabel 7800 2250 0    50   Output ~ 0
MCTRAL_n
Wire Wire Line
	7850 2250 7800 2250
Text GLabel 7800 2350 0    50   Output ~ 0
MTCAL_n
Wire Wire Line
	7850 2350 7800 2350
Text GLabel 7800 2450 0    50   Output ~ 0
MRPTAL_n
Wire Wire Line
	7850 2450 7800 2450
Text GLabel 7800 2550 0    50   BiDi ~ 0
ALGA
Wire Wire Line
	7850 2550 7800 2550
Text GLabel 7800 2650 0    50   Output ~ 0
MPAL_n
Wire Wire Line
	7850 2650 7800 2650
Text GLabel 7800 2750 0    50   Output ~ 0
MSTPIT_n
Wire Wire Line
	7850 2750 7800 2750
Text GLabel 7800 2850 0    50   Output ~ 0
MGOJAM
Wire Wire Line
	7850 2850 7800 2850
Text GLabel 7800 2950 0    50   Output ~ 0
MINHL
Wire Wire Line
	7850 2950 7800 2950
Text GLabel 7800 3050 0    50   Output ~ 0
MINKL
Wire Wire Line
	7850 3050 7800 3050
Text GLabel 7800 3150 0    50   Output ~ 0
MWLG
Wire Wire Line
	7850 3150 7800 3150
Text GLabel 7800 3250 0    50   Output ~ 0
MONWT
Wire Wire Line
	7850 3250 7800 3250
Text GLabel 7800 3350 0    50   Output ~ 0
MRSC
Wire Wire Line
	7850 3350 7800 3350
Text GLabel 7800 3450 0    50   Output ~ 0
MRLG
Wire Wire Line
	7850 3450 7800 3450
Text GLabel 3800 3850 0    50   BiDi ~ 0
STRT1
Wire Wire Line
	3850 3850 3800 3850
Text GLabel 3800 3950 0    50   BiDi ~ 0
STRT2
Wire Wire Line
	3850 3950 3800 3950
Text GLabel 3800 4050 0    50   Input ~ 0
MNHSBF
Wire Wire Line
	3800 4050 3850 4050
Text GLabel 3800 4150 0    50   Input ~ 0
MNHNC
Wire Wire Line
	3800 4150 3850 4150
Text GLabel 3800 4250 0    50   Input ~ 0
MNHRPT
Wire Wire Line
	3800 4250 3850 4250
Text GLabel 3800 4350 0    50   Input ~ 0
MTCSAI
Wire Wire Line
	3800 4350 3850 4350
Text GLabel 3800 4450 0    50   Input ~ 0
MSTRT
Wire Wire Line
	3800 4450 3850 4450
Text GLabel 3800 4550 0    50   Input ~ 0
MSTP
Wire Wire Line
	3800 4550 3850 4550
Text GLabel 3800 4650 0    50   Input ~ 0
MSBSTP
Wire Wire Line
	3800 4650 3850 4650
Text GLabel 3800 4750 0    50   Input ~ 0
MRDCH
Wire Wire Line
	3800 4750 3850 4750
Text GLabel 3800 4850 0    50   Input ~ 0
MLDCH
Wire Wire Line
	3800 4850 3850 4850
Text GLabel 3800 4950 0    50   Output ~ 0
MGP_n
Wire Wire Line
	3850 4950 3800 4950
Text GLabel 3800 5050 0    50   Output ~ 0
MSP
Wire Wire Line
	3850 5050 3800 5050
Text GLabel 3800 5150 0    50   Output ~ 0
MRGG
Wire Wire Line
	3850 5150 3800 5150
Text GLabel 3800 5250 0    50   Output ~ 0
MWAG
Wire Wire Line
	3850 5250 3800 5250
Text GLabel 3800 5350 0    50   Output ~ 0
MRAG
Wire Wire Line
	3850 5350 3800 5350
Text GLabel 5050 3850 0    50   Input ~ 0
CTRL1
Wire Wire Line
	5050 3850 5100 3850
Text GLabel 5050 3950 0    50   Input ~ 0
CTRL2
Wire Wire Line
	5050 3950 5100 3950
Text GLabel 5050 4050 0    50   Output ~ 0
MTHI
Wire Wire Line
	5100 4050 5050 4050
Text GLabel 5050 4150 0    50   Output ~ 0
MTLO
Wire Wire Line
	5100 4150 5050 4150
Text GLabel 5050 4250 0    50   Output ~ 0
MWCH
Wire Wire Line
	5100 4250 5050 4250
Text GLabel 5050 4350 0    50   Output ~ 0
MRCH
Wire Wire Line
	5100 4350 5050 4350
Text GLabel 5050 4450 0    50   Input ~ 0
MONPAR
Wire Wire Line
	5050 4450 5100 4450
Text GLabel 5050 4550 0    50   Input ~ 0
MONWBK
Wire Wire Line
	5050 4550 5100 4550
Text GLabel 5050 4650 0    50   Output ~ 0
MWG
Wire Wire Line
	5100 4650 5050 4650
Text GLabel 5050 4750 0    50   Output ~ 0
MNISQ
Wire Wire Line
	5100 4750 5050 4750
Text GLabel 5050 4850 0    50   Output ~ 0
MREQIN
Wire Wire Line
	5100 4850 5050 4850
Text GLabel 5050 4950 0    50   Output ~ 0
MWATCH_n
Wire Wire Line
	5100 4950 5050 4950
Text GLabel 5050 5050 0    50   Input ~ 0
MLOAD
Wire Wire Line
	5050 5050 5100 5050
Text GLabel 5050 5150 0    50   Input ~ 0
MREAD
Wire Wire Line
	5050 5150 5100 5150
Text GLabel 5050 5250 0    50   Output ~ 0
MON800
Wire Wire Line
	5100 5250 5050 5250
Text GLabel 5050 5350 0    50   Output ~ 0
MPIPAL_n
Wire Wire Line
	5100 5350 5050 5350
$Comp
L agc_monitor:test_connector P1
U 8 1 5C34880A
P 6450 4550
F 0 "P1" H 6550 5350 50  0000 L CNN
F 1 "test_connector" H 6829 4455 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 6450 4550 50  0001 C CNN
F 3 "" H 6450 4550 50  0001 C CNN
	8    6450 4550
	1    0    0    -1  
$EndComp
Text GLabel 6250 4050 0    50   Input ~ 0
MSP803
Wire Wire Line
	6250 4050 6300 4050
Text GLabel 6250 4150 0    50   Output ~ 0
SIGNY
Wire Wire Line
	6250 4150 6300 4150
Text GLabel 6250 4250 0    50   Input ~ 0
MSP805
Wire Wire Line
	6250 4250 6300 4250
Text GLabel 6250 4350 0    50   Input ~ 0
MSP806
Wire Wire Line
	6250 4350 6300 4350
Text GLabel 6250 4450 0    50   Input ~ 0
MSP807
Wire Wire Line
	6250 4450 6300 4450
Text GLabel 6250 4550 0    50   Output ~ 0
MSCDBL_n
Wire Wire Line
	6300 4550 6250 4550
Text GLabel 6250 4650 0    50   Input ~ 0
NHALGA
Wire Wire Line
	6250 4650 6300 4650
Text GLabel 6250 4750 0    50   Input ~ 0
DOSCAL
Wire Wire Line
	6250 4750 6300 4750
Text GLabel 6250 4850 0    50   Input ~ 0
DBLTST
Wire Wire Line
	6250 4850 6300 4850
Text GLabel 6250 4950 0    50   Output ~ 0
MWARNF_n
Wire Wire Line
	6300 4950 6250 4950
Text GLabel 6250 5050 0    50   Output ~ 0
OUTCOM
Wire Wire Line
	6300 5050 6250 5050
Text GLabel 6250 5150 0    50   Output ~ 0
MSCAFL_n
Wire Wire Line
	6300 5150 6250 5150
Text GLabel 6250 5250 0    50   Output ~ 0
MOSCAL_n
Wire Wire Line
	6300 5250 6250 5250
Text GLabel 6250 5350 0    50   Output ~ 0
MVFAIL_n
Wire Wire Line
	6300 5350 6250 5350
Text GLabel 7450 3950 0    50   Input ~ 0
MSP902
Wire Wire Line
	7450 3950 7500 3950
Text GLabel 7450 4150 0    50   Input ~ 0
MSP904
Wire Wire Line
	7450 4150 7500 4150
Text GLabel 7450 4750 0    50   Input ~ 0
MSP910
Wire Wire Line
	7450 4750 7500 4750
Text GLabel 7450 4550 0    50   Input ~ 0
MSP908
Wire Wire Line
	7450 4550 7500 4550
Text GLabel 7450 4350 0    50   Input ~ 0
MAMU
Wire Wire Line
	7450 4350 7500 4350
Text GLabel 7450 4950 0    50   Input ~ 0
MSP912
Wire Wire Line
	7450 4950 7500 4950
Text GLabel 7450 5150 0    50   Input ~ 0
MSP914
Wire Wire Line
	7450 5150 7500 5150
Text GLabel 7450 5350 0    50   Input ~ 0
MSP916
Wire Wire Line
	7450 5350 7500 5350
$Comp
L agc_monitor:BPLSSW #PWR0102
U 1 1 5C6901A9
P 6250 3800
F 0 "#PWR0102" H 6250 3650 50  0001 C CNN
F 1 "BPLSSW" H 6250 3950 50  0000 C CNN
F 2 "" H 6250 3800 50  0001 C CNN
F 3 "" H 6250 3800 50  0001 C CNN
	1    6250 3800
	1    0    0    -1  
$EndComp
Wire Wire Line
	6250 3800 6250 3850
Wire Wire Line
	6250 3850 6300 3850
$Comp
L agc_monitor:+4SW #PWR0103
U 1 1 5C6A3F1E
P 5950 3800
F 0 "#PWR0103" H 5950 3650 50  0001 C CNN
F 1 "+4SW" H 5950 3950 50  0000 C CNN
F 2 "" H 5950 3800 50  0001 C CNN
F 3 "" H 5950 3800 50  0001 C CNN
	1    5950 3800
	1    0    0    -1  
$EndComp
Wire Wire Line
	5950 3800 5950 3950
Wire Wire Line
	5950 3950 6300 3950
$EndSCHEMATC
