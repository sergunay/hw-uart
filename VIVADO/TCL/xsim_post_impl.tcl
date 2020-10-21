source ../TCL/init.tcl

open_saif $IMPL_DIR/post_impl.saif

log_saif [get_object /$TESTBENCH/DUV/*]
#run 33 ms
run all
close_saif
#quit
