source ../TCL/init.tcl

open_saif ../PRE_SYNTH/rtl.saif

log_saif [get_object /$TESTBENCH/DUV/*]
#run 33 ms
run all
close_saif
#quit
