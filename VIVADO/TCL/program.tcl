source ../TCL/init.tcl
source ../TCL/connect_hw.tcl

set_property PROGRAM.FILE $IMPL_DIR/$TOP_MODULE.bit [lindex [get_hw_devices] 0]
set_property PROBES.FILE {} [lindex [get_hw_devices] 0]

set starttime [clock seconds]
program_hw_devices [lindex [get_hw_devices] 0]
set stoptime [clock seconds]
set timeelapsed [expr $stoptime -$starttime]

puts "Programming elapsed time: $timeelapsed seconds"

refresh_hw_device [lindex [get_hw_devices] 0]