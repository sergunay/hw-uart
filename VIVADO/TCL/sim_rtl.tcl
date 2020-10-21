source ../TCL/init.tcl

foreach file [glob -nocomplain $RTL_DIR/*.vhd] {
    exec xvhdl -work rtl $file
}

foreach file [glob -nocomplain $BHV_DIR/*.vhd] {
    exec xvhdl -work rtl $file
}

exec xvhdl -work rtl $TB_DIR/$TESTBENCH.vhd

exec xelab -debug typical rtl.$TESTBENCH \
--snapshot top_sim

exec xsim top_sim \
-gui \
-t $TCL_DIR/xsim_rtl.tcl \
-view $PRE_SYNTH_DIR/sim_rtl.wcfg \
-log $PRE_SYNTH_DIR/sim_rtl.log 
#--onerror quit 
#--onfinish quit \
