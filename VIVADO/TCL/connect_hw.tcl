open_hw

if {[current_hw_server] ne ""} {disconnect_hw_server}
connect_hw_server
open_hw_target

current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]