synth_design -top $TOP_MODULE -part $FPGA_PART
write_checkpoint -force $SYNTH_DIR/post_synth.dcp
report_timing_summary -file $SYNTH_DIR/post_synth_timing_summary.rpt
report_utilization -file $SYNTH_DIR/post_synth_util.rpt
report_clocks -file $SYNTH_DIR/clocks.rpt
write_sdf -force $SYNTH_DIR/${TOP_MODULE}_synth.sdf -mode timesim
write_verilog -force $SYNTH_DIR/$TOP_MODULE.v -mode timesim
# -sdf_anno true -sdf_file $SYNTH_DIR/$TOP_MODULE.sdf
#
# Run custom script to report critical timing paths
source $TCL_DIR/reportCriticalPaths.tcl
reportCriticalPaths $SYNTH_DIR/post_synth_critpath_report.csv