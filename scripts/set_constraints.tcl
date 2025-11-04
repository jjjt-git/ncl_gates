#write_checkpoint -force /tmp/checkpoint.dcp

set ack [get_cells -leaf -filter "NCL_WIRE_TYPE == ACK"]
set bridge [get_cells -leaf -filter "NCL_WIRE_TYPE == NCL_CLK"]

foreach cc $ack {
	# find appropriate pins
	set mark_i [get_pins -of $cc -filter "DIRECTION == IN"]
	set mark_o [get_pins -of $cc -filter "DIRECTION == OUT"]
	
	set ack_snk [get_pins -of [get_nets -segments -of $mark_o] -filter "IS_LEAF && DIRECTION == IN"]
	set ack_src [get_pins -of [get_nets -segments -of $mark_i] -filter "IS_LEAF && DIRECTION == OUT"]
	
	# remove marker
	set fani [get_nets -of $mark_i]
	set fano [get_nets -of $mark_o]
	set fani_pins [get_pins -of $fani -filter "PARENT_CELL != $cc"]
	
	remove_net $fani
	connect_net -net $fano -objects $fani_pins
	
	set_property DONT_TOUCH false $cc
	remove_cell $cc
	
	# add constraints 
	set_min_delay 1.2 -from $ack_src -to $ack_snk
	
	group_path -name "NCL_STAGE" -from $ack_src -to $ack_snk
}

foreach cc $bridge {
	# find appropriate pins
	set mark_i [get_pins -of $cc -filter "DIRECTION == IN"]
	set mark_o [get_pins -of $cc -filter "DIRECTION == OUT"]
	
	# remove marker
	set fani [get_nets -of $mark_i]
	set fano [get_nets -of $mark_o]
	set fani_pins [get_pins -of $fani -filter "PARENT_CELL != $cc"]
	
	remove_net $fani
	connect_net -net $fano -objects $fani_pins
	
	set_property DONT_TOUCH false $cc
	remove_cell $cc
	
	set_false_path -setup -hold -rise -fall -through $fano
}