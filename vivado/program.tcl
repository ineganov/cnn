open_hw
connect_hw_server
current_hw_target [lindex [get_hw_targets] 0]
open_hw_target 
set_property PROGRAM.FILE bitstream.bit [lindex [get_hw_devices] 0]
program_hw_devices [lindex [get_hw_devices] 0]
close_hw_target
disconnect_hw_server
close_hw

