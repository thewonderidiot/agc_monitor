webtalk_init -webtalk_dir /home/mike/agc_monitor/fpga/agc_monitor.sim/sim_1/behav/xsim/xsim.dir/agc_monitor_tb_behav/webtalk/
webtalk_register_client -client project
webtalk_add_data -client project -key date_generated -value "Mon Dec 31 17:18:46 2018" -context "software_version_and_target_device"
webtalk_add_data -client project -key product_version -value "XSIM v2018.3 (64-bit)" -context "software_version_and_target_device"
webtalk_add_data -client project -key build_version -value "2405991" -context "software_version_and_target_device"
webtalk_add_data -client project -key os_platform -value "LIN64" -context "software_version_and_target_device"
webtalk_add_data -client project -key registration_id -value "" -context "software_version_and_target_device"
webtalk_add_data -client project -key tool_flow -value "xsim_vivado" -context "software_version_and_target_device"
webtalk_add_data -client project -key beta -value "FALSE" -context "software_version_and_target_device"
webtalk_add_data -client project -key route_design -value "FALSE" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_family -value "not_applicable" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_device -value "not_applicable" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_package -value "not_applicable" -context "software_version_and_target_device"
webtalk_add_data -client project -key target_speed -value "not_applicable" -context "software_version_and_target_device"
webtalk_add_data -client project -key random_id -value "820da6ab-e588-43bb-a310-f915ada4326a" -context "software_version_and_target_device"
webtalk_add_data -client project -key project_id -value "1cf011e1970e49a2a5761c59c0adeeef" -context "software_version_and_target_device"
webtalk_add_data -client project -key project_iteration -value "10" -context "software_version_and_target_device"
webtalk_add_data -client project -key os_name -value "unknown" -context "user_environment"
webtalk_add_data -client project -key os_release -value "unknown" -context "user_environment"
webtalk_add_data -client project -key cpu_name -value "Intel(R) Core(TM) i7-8550U CPU @ 1.80GHz" -context "user_environment"
webtalk_add_data -client project -key cpu_speed -value "1011.457 MHz" -context "user_environment"
webtalk_add_data -client project -key total_processors -value "1" -context "user_environment"
webtalk_add_data -client project -key system_ram -value "16.000 GB" -context "user_environment"
webtalk_register_client -client xsim
webtalk_add_data -client xsim -key runall -value "true" -context "xsim\\command_line_options"
webtalk_add_data -client xsim -key runall -value "true" -context "xsim\\command_line_options"
webtalk_add_data -client xsim -key Command -value "xsim" -context "xsim\\command_line_options"
webtalk_add_data -client xsim -key trace_waveform -value "true" -context "xsim\\usage"
webtalk_add_data -client xsim -key runtime -value "3416715 ps" -context "xsim\\usage"
webtalk_add_data -client xsim -key iteration -value "0" -context "xsim\\usage"
webtalk_add_data -client xsim -key Simulation_Time -value "0.04_sec" -context "xsim\\usage"
webtalk_add_data -client xsim -key Simulation_Memory -value "115016_KB" -context "xsim\\usage"
webtalk_transmit -clientid 2657932693 -regid "" -xml /home/mike/agc_monitor/fpga/agc_monitor.sim/sim_1/behav/xsim/xsim.dir/agc_monitor_tb_behav/webtalk/usage_statistics_ext_xsim.xml -html /home/mike/agc_monitor/fpga/agc_monitor.sim/sim_1/behav/xsim/xsim.dir/agc_monitor_tb_behav/webtalk/usage_statistics_ext_xsim.html -wdm /home/mike/agc_monitor/fpga/agc_monitor.sim/sim_1/behav/xsim/xsim.dir/agc_monitor_tb_behav/webtalk/usage_statistics_ext_xsim.wdm -intro "<H3>XSIM Usage Report</H3><BR>"
webtalk_terminate
