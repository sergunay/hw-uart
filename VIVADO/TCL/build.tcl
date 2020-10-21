# STEP#1: define the output directory area.
source ../TCL/init.tcl
# STEP#2: setup design sources and constraints
read_vhdl [glob $RTL_DIR/*.vhd]
update_compile_order
read_xdc [glob $CONSTR_DIR/*.xdc]
#
# STEP#3: run synthesis, write design checkpoint, report timing,
# and utilization estimates
source $TCL_DIR/synth.tcl
#
# STEP#4: run logic optimization, placement and physical logic optimization,
# write design checkpoint, report utilization and timing estimates
#
source $TCL_DIR/place.tcl
# STEP#5: run the router, write the post-route design checkpoint, report the routing
# status, report timing, power, and DRC, and finally save the Verilog netlist.
#
source $TCL_DIR/route.tcl
#
# STEP#6: generate a bitstream
#
write_bitstream -force $IMPL_DIR/$TOP_MODULE.bit -bin_file