opt_design
place_design
report_clock_utilization -file $IMPL_DIR/clock_util.rpt
#
# Optionally run optimization if there are timing violations after placement
if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
	puts "Found setup timing violations => running physical optimization"
	phys_opt_design
}
write_checkpoint -force $IMPL_DIR/post_place.dcp
report_utilization -file $IMPL_DIR/post_place_util.rpt
report_timing_summary -file $IMPL_DIR/post_place_timing_summary.rpt
