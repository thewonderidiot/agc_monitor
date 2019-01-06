
set_property PACKAGE_PIN Y6 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]
create_clock -period 16.667 -name clkout -waveform {0.000 8.334} [get_ports clkout]
set_property IOSTANDARD LVCMOS33 [get_ports {data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports clkout]
set_property IOSTANDARD LVCMOS33 [get_ports oe_n]
set_property IOSTANDARD LVCMOS33 [get_ports rd_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rxf_n]
set_property IOSTANDARD LVCMOS33 [get_ports siwu]
set_property IOSTANDARD LVCMOS33 [get_ports txe_n]
set_property IOSTANDARD LVCMOS33 [get_ports wr_n]
set_property PACKAGE_PIN U20 [get_ports oe_n]
set_property PACKAGE_PIN L18 [get_ports clkout]
set_property PACKAGE_PIN Y20 [get_ports rd_n]
set_property PACKAGE_PIN L21 [get_ports rst_n]
set_property PACKAGE_PIN W20 [get_ports rxf_n]
set_property PACKAGE_PIN V20 [get_ports siwu]
set_property PACKAGE_PIN Y21 [get_ports txe_n]
set_property PACKAGE_PIN W21 [get_ports wr_n]

set_property PACKAGE_PIN T22 [get_ports {data[0]}]
set_property PACKAGE_PIN T21 [get_ports {data[1]}]
set_property PACKAGE_PIN U22 [get_ports {data[2]}]
set_property PACKAGE_PIN U21 [get_ports {data[3]}]
set_property PACKAGE_PIN V22 [get_ports {data[4]}]
set_property PACKAGE_PIN W22 [get_ports {data[5]}]
set_property PACKAGE_PIN AA22 [get_ports {data[6]}]
set_property PACKAGE_PIN AB22 [get_ports {data[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {mt[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mt[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mt[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mt[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mt[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mt[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mt[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mt[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mt[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mt[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mt[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mt[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[16]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {mwl[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports mwzg]
set_property IOSTANDARD LVCMOS33 [get_ports mnhnc]
set_property IOSTANDARD LVCMOS33 [get_ports monwt]
set_property IOSTANDARD LVCMOS33 [get_ports mwyg]
set_property IOSTANDARD LVCMOS33 [get_ports mrgg]
set_property IOSTANDARD LVCMOS33 [get_ports mwag]
set_property IOSTANDARD LVCMOS33 [get_ports mwbbeg]
set_property IOSTANDARD LVCMOS33 [get_ports mwbg]
set_property IOSTANDARD LVCMOS33 [get_ports mwfbg]
set_property IOSTANDARD LVCMOS33 [get_ports mwebg]
set_property IOSTANDARD LVCMOS33 [get_ports mwg]
set_property IOSTANDARD LVCMOS33 [get_ports mwlg]
set_property IOSTANDARD LVCMOS33 [get_ports mwqg]
set_property IOSTANDARD LVCMOS33 [get_ports mwsg]
set_property PACKAGE_PIN A19 [get_ports {mt[1]}]
set_property PACKAGE_PIN A18 [get_ports {mt[2]}]
set_property PACKAGE_PIN B17 [get_ports {mt[3]}]
set_property PACKAGE_PIN B16 [get_ports {mt[4]}]
set_property PACKAGE_PIN A17 [get_ports {mt[5]}]
set_property PACKAGE_PIN A16 [get_ports {mt[6]}]
set_property PACKAGE_PIN E16 [get_ports {mt[7]}]
set_property PACKAGE_PIN F16 [get_ports {mt[8]}]
set_property PACKAGE_PIN B15 [get_ports {mt[9]}]
set_property PACKAGE_PIN C15 [get_ports {mt[10]}]
set_property PACKAGE_PIN E18 [get_ports {mt[11]}]
set_property PACKAGE_PIN F18 [get_ports {mt[12]}]
set_property PACKAGE_PIN F22 [get_ports {mwl[1]}]
set_property PACKAGE_PIN F21 [get_ports {mwl[2]}]
set_property PACKAGE_PIN A22 [get_ports {mwl[3]}]
set_property PACKAGE_PIN A21 [get_ports {mwl[4]}]
set_property PACKAGE_PIN C22 [get_ports {mwl[5]}]
set_property PACKAGE_PIN D22 [get_ports {mwl[6]}]
set_property PACKAGE_PIN C20 [get_ports {mwl[7]}]
set_property PACKAGE_PIN D20 [get_ports {mwl[8]}]
set_property PACKAGE_PIN B22 [get_ports {mwl[9]}]
set_property PACKAGE_PIN B21 [get_ports {mwl[10]}]
set_property PACKAGE_PIN C19 [get_ports {mwl[11]}]
set_property PACKAGE_PIN D18 [get_ports {mwl[12]}]
set_property PACKAGE_PIN B20 [get_ports {mwl[13]}]
set_property PACKAGE_PIN B19 [get_ports {mwl[14]}]
set_property PACKAGE_PIN C18 [get_ports {mwl[15]}]
set_property PACKAGE_PIN C17 [get_ports {mwl[16]}]
set_property PACKAGE_PIN Y16 [get_ports mnhnc]
set_property PACKAGE_PIN U9 [get_ports monwt]
set_property PACKAGE_PIN U6 [get_ports mrgg]
set_property PACKAGE_PIN T6 [get_ports mwag]
set_property PACKAGE_PIN G19 [get_ports mwbbeg]
set_property PACKAGE_PIN P18 [get_ports mwbg]
set_property PACKAGE_PIN F19 [get_ports mwebg]
set_property PACKAGE_PIN D16 [get_ports mwfbg]
set_property PACKAGE_PIN J22 [get_ports mwg]
set_property PACKAGE_PIN T4 [get_ports mwlg]
set_property PACKAGE_PIN J16 [get_ports mwqg]
set_property PACKAGE_PIN F17 [get_ports mwsg]
set_property PACKAGE_PIN J17 [get_ports mwyg]
set_property PACKAGE_PIN G17 [get_ports mwzg]
