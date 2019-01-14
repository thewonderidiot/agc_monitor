EESchema Schematic File Version 4
LIBS:agc_monitor-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 3
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
P 2600 2200
F 0 "P1" H 2700 3000 50  0000 L CNN
F 1 "test_connector" H 2979 2105 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 2600 2200 50  0001 C CNN
F 3 "" H 2600 2200 50  0001 C CNN
	1    2600 2200
	1    0    0    -1  
$EndComp
$Comp
L agc_monitor:test_connector P1
U 2 1 5C34852D
P 3500 2200
F 0 "P1" H 3600 3000 50  0000 L CNN
F 1 "test_connector" H 3879 2105 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 3500 2200 50  0001 C CNN
F 3 "" H 3500 2200 50  0001 C CNN
	2    3500 2200
	1    0    0    -1  
$EndComp
$Comp
L agc_monitor:test_connector P1
U 3 1 5C348601
P 4350 2200
F 0 "P1" H 4450 3000 50  0000 L CNN
F 1 "test_connector" H 4729 2105 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 4350 2200 50  0001 C CNN
F 3 "" H 4350 2200 50  0001 C CNN
	3    4350 2200
	1    0    0    -1  
$EndComp
$Comp
L agc_monitor:test_connector P1
U 4 1 5C348607
P 5250 2200
F 0 "P1" H 5350 3000 50  0000 L CNN
F 1 "test_connector" H 5629 2105 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 5250 2200 50  0001 C CNN
F 3 "" H 5250 2200 50  0001 C CNN
	4    5250 2200
	1    0    0    -1  
$EndComp
$Comp
L agc_monitor:test_connector P1
U 5 1 5C3486F3
P 6050 2200
F 0 "P1" H 6150 3000 50  0000 L CNN
F 1 "test_connector" H 6429 2105 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 6050 2200 50  0001 C CNN
F 3 "" H 6050 2200 50  0001 C CNN
	5    6050 2200
	1    0    0    -1  
$EndComp
$Comp
L agc_monitor:test_connector P1
U 6 1 5C3487FE
P 3000 4100
F 0 "P1" H 3100 4900 50  0000 L CNN
F 1 "test_connector" H 3379 4005 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 3000 4100 50  0001 C CNN
F 3 "" H 3000 4100 50  0001 C CNN
	6    3000 4100
	1    0    0    -1  
$EndComp
$Comp
L agc_monitor:test_connector P1
U 7 1 5C348804
P 3900 4100
F 0 "P1" H 4000 4900 50  0000 L CNN
F 1 "test_connector" H 4279 4005 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 3900 4100 50  0001 C CNN
F 3 "" H 3900 4100 50  0001 C CNN
	7    3900 4100
	1    0    0    -1  
$EndComp
$Comp
L agc_monitor:test_connector P1
U 8 1 5C34880A
P 4750 4100
F 0 "P1" H 4850 4900 50  0000 L CNN
F 1 "test_connector" H 5129 4005 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 4750 4100 50  0001 C CNN
F 3 "" H 4750 4100 50  0001 C CNN
	8    4750 4100
	1    0    0    -1  
$EndComp
$Comp
L agc_monitor:test_connector P1
U 9 1 5C348810
P 5650 4100
F 0 "P1" H 5750 4900 50  0000 L CNN
F 1 "test_connector" H 6029 4005 50  0001 L CNN
F 2 "agc_monitor:test_connector" H 5650 4100 50  0001 C CNN
F 3 "" H 5650 4100 50  0001 C CNN
	9    5650 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	5500 3400 5450 3400
Wire Wire Line
	5450 3400 5450 3600
$Comp
L power:GND #PWR0101
U 1 1 5C348B58
P 5450 5000
F 0 "#PWR0101" H 5450 4750 50  0001 C CNN
F 1 "GND" H 5455 4827 50  0000 C CNN
F 2 "" H 5450 5000 50  0001 C CNN
F 3 "" H 5450 5000 50  0001 C CNN
	1    5450 5000
	1    0    0    -1  
$EndComp
Wire Wire Line
	5500 3600 5450 3600
Connection ~ 5450 3600
Wire Wire Line
	5450 3600 5450 3800
Wire Wire Line
	5500 3800 5450 3800
Connection ~ 5450 3800
Wire Wire Line
	5450 3800 5450 4000
Wire Wire Line
	5500 4000 5450 4000
Connection ~ 5450 4000
Wire Wire Line
	5450 4000 5450 4200
Wire Wire Line
	5500 4200 5450 4200
Connection ~ 5450 4200
Wire Wire Line
	5450 4200 5450 4400
Wire Wire Line
	5500 4400 5450 4400
Connection ~ 5450 4400
Wire Wire Line
	5450 4400 5450 4600
Wire Wire Line
	5500 4600 5450 4600
Connection ~ 5450 4600
Wire Wire Line
	5450 4600 5450 4800
Wire Wire Line
	5500 4800 5450 4800
Connection ~ 5450 4800
Wire Wire Line
	5450 4800 5450 5000
NoConn ~ 5500 4700
NoConn ~ 5500 4500
NoConn ~ 5500 4300
NoConn ~ 5500 4100
NoConn ~ 5500 4900
NoConn ~ 5500 3700
NoConn ~ 5500 3500
NoConn ~ 4600 3600
NoConn ~ 4600 3700
NoConn ~ 4600 3800
NoConn ~ 4600 3900
NoConn ~ 4600 4000
$EndSCHEMATC
