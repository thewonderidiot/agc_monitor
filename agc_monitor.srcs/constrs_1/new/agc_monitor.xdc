create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

set_property PACKAGE_PIN J22 [get_ports led]
set_property PACKAGE_PIN Y6 [get_ports clk]
set_property PACKAGE_PIN L21 [get_ports rstn]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports rstn]
set_property PULLUP true [get_ports rstn]
