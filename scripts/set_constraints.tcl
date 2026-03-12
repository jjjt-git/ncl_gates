#write_checkpoint -force /tmp/checkpoint.dcp

set ack [get_cells -leaf -filter "NCL_WIRE_TYPE == ACK"]
set bridge [get_cells -leaf -filter "NCL_WIRE_TYPE == NCL_CLK"]

set ncl_gates [get_cells -hierarchical NCL_GATE*]

foreach cc $ack {
	# find appropriate pins
	set mark [get_pins -of $cc -filter "DIRECTION == IN"]
	set net  [get_nets -segments -of $mark]
	
	# remove marker
	set_property DONT_TOUCH false $cc
	remove_cell $cc
	
#	set ack_snk [get_pins -of $net -filter "IS_LEAF && DIRECTION == IN"]
	set ack_src [get_pins -of $net -filter "IS_LEAF && DIRECTION == OUT"]
	
	set pc [get_cells -of $ack_src]
	
	set ack_snk [get_pins -of $ncl_gates -filter "PARENT_CELL != $pc && DIRECTION == IN"]
	
	# add constraints 
	set_min_delay 1.5 -from $ack_src -to $ack_snk
	
	group_path -name "NCL_ACK_FB" -from $ack_src -to $ack_snk
}

foreach cc $bridge {
	# find appropriate pins
	set mark [get_pins -of $cc -filter "DIRECTION == IN"]
	set net  [get_nets -of $mark]
	
	# remove marker
	set_property DONT_TOUCH false $cc
	remove_cell $cc
	
	set_false_path -setup -hold -rise -fall -through $net
}
