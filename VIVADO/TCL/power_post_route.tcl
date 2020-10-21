source ../TCL/init.tcl

open_checkpoint -file $IMPL_DIR/post_route.dcp

report_operating_conditions -all

# Set specific device and environment operating conditions
set_operating_conditions -ambient 25
#set_operating_conditions -voltage {vccint 0.95 vccaux 1.71}

read_saif -out_file $IMPL_DIR/read_saif.rpt -file ../IMPL/post_impl.saif

report_power -verbose -file $IMPL_DIR/post_route_power_saif.rpt
