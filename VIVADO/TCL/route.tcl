route_design
write_checkpoint -force $IMPL_DIR/post_route.dcp
report_route_status -file $IMPL_DIR/post_route_status.rpt
report_timing_summary -file $IMPL_DIR/post_route_timing_summary.rpt
report_power -file $IMPL_DIR/post_route_power.rpt
report_drc -file $IMPL_DIR/post_imp_drc.rpt
write_verilog -force $IMPL_DIR/$TOP_MODULE.v -mode timesim
#  -sdf_anno true -sdf_file $IMPL_DIR/$TOP_MODULE.sdf
write_edif -force $IMPL_DIR/$TOP_MODULE.edf
write_sdf -force $IMPL_DIR/${TOP_MODULE}_impl.sdf -mode timesim