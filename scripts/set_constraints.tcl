set markers [get_cells -leaf -filter "NCL_WIRE_TYPE == ACK"]

set ack_src [get_pins -of $markers -filter "DIRECTION == OUT"]

foreach src $ack_src {
	set ack_snk [get_pins -of [get_nets -segments -of $src] -filter "IS_LEAF && DIRECTION == IN"]
	set data_src [get_pins -of [get_cells -of $ack_snk] -filter "DIRECTION == OUT"]
	
	set_min_delay 1.2 -from $data_src -to $ack_snk
	
	group_path -name "NCL_STAGE" -from $data_src -to $ack_snk
}

foreach cc $markers {
	set fani [get_nets -of [get_pins -of $cc -filter "DIRECTION ==  IN"]]
	set fano [get_nets -of [get_pins -of $cc -filter "DIRECTION == OUT"]]
	set fani_pins [get_pins -of $fani -filter "PARENT_CELL != $cc"]
	
	remove_net $fani
	connect_net -net $fano -objects $fani_pins
	
	set_property DONT_TOUCH false $cc
	remove_cell $cc
}