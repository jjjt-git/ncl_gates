#write_checkpoint -force /tmp/checkpoint.dcp

set ack [get_cells -leaf -filter "NCL_WIRE_TYPE == ACK"]
set bridge [get_cells -leaf -filter "NCL_WIRE_TYPE == NCL_CLK"]

set inbridge_enc [get_cells -leaf -filter "NCL_WIRE_TYPE == IN_ENC"]

set ncl_gates [get_cells -hierarchical NCL_GATE*]

set markers []

foreach cc $ack {
	# find appropriate pins
	set mark [get_pins -of [get_cells $cc] -filter "DIRECTION == IN"]
	set net  [get_nets -segments -of $mark]
	
	set ack_src [get_pins -of $net -filter "IS_LEAF && DIRECTION == OUT"]
	
	set pc [get_cells -of $ack_src]
	set pfb [get_pins -of [get_nets -of $ack_src] -filter "DIRECTION == IN"]
	
	set ack_snk [get_pins -of $pc -filter "NAME != $pfb && DIRECTION == IN"]
	
	# add constraints
	
	set_min_delay 2.0 -from $ack_src -to $ack_snk
	
	group_path -name "NCL_ACK_FB" -from $ack_src -to $ack_snk
	
	# remove marker
	lappend markers $cc
}

foreach cc $bridge {
	# find appropriate pins
	set mark [get_pins -of [get_cells $cc] -filter "DIRECTION == IN"]
	set net  [get_nets -of $mark]
	
	if {[llength $net]} {
		set_false_path -setup -hold -rise -fall -through $net
	}
	
	# remove marker
	lappend markers $cc
}

foreach cc $inbridge_enc {
	set valid_pin [get_pins -of $cc -filter "REF_PIN_NAME == I0"]
	set data_pin  [get_pins -of $cc -filter "REF_PIN_NAME == I1"]
	
	set_data_check -rise_from $valid_pin -to $data_pin -setup 0
	set_data_check -fall_from $valid_pin -to $data_pin -hold  0
	
	group_path -name "NCL_INBRIDGE_ENC" -to $data_pin
}

set_property DONT_TOUCH false $markers
remove_cell $markers
