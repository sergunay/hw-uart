source ../TCL/init.tcl

exec xvlog -work gate $VIVADO_PATH/data/verilog/src/glbl.v

foreach file [glob -nocomplain $BHV_DIR/*.vhd] {
    exec xvhdl -work gate $file
}

exec xvlog -work gate $SYNTH_DIR/$TOP_MODULE.v -L unisims_ver -L simprims_ver
#exec xvhdl -work gate $RTL_DIR/freak_pkg.vhd
exec xvhdl -work gate $TB_DIR/$TB_GATE_FILE

exec xelab \
-debug typical \
--relax \
--mt 2 \
-L gate \
-L simprims_ver \
-L unisims_ver \
-timescale 1ps/1ps \
-sdfroot $SYNTH_DIR/${TOP_MODULE}_synth.sdf \
gate.glbl \
gate.$TESTBENCH \
--snapshot top_sim

exec xsim top_sim \
-gui \
-t $TCL_DIR/xsim_post_synth.tcl \
-view $SYNTH_DIR/sim_post_synth.wcfg \
-log $SYNTH_DIR/sim_post_synth.log 
#--onfinish quit \
#--onerror quit \
