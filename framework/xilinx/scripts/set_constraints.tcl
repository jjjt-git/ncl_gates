#write_checkpoint -force /tmp/checkpoint.dcp

set ack [get_cells -leaf -filter "NCL_WIRE_TYPE == ACK"]
set bridge [get_cells -leaf -filter "NCL_WIRE_TYPE == NCL_CLK"]

set inbridge_enc [get_cells -leaf -filter "NCL_WIRE_TYPE == IN_ENC"]

set ncl_gates [get_cells -hierarchical NCL_GATE*]

set comp_clk [get_cells -leaf -filter "NCL_WIRE_TYPE == COMP_CLK"]

set markers []

set fb_required_delay 2.0

foreach cc $ack {
	# find appropriate pins
	set mark [get_pins -of [get_cells $cc] -filter "DIRECTION == IN"]
	set net  [get_nets -segments -of $mark]
	
	set ack_src [get_pins -of $net -filter "IS_LEAF && DIRECTION == OUT"]
	
	set pc [get_cells -of $ack_src]
	set pfb [get_pins -of [get_nets -of $ack_src] -filter "DIRECTION == IN"]
	
	set ack_snk [get_pins -of $pc -filter "NAME != $pfb && DIRECTION == IN"]
	
	# add constraints
	
	set_min_delay $fb_required_delay -from $ack_src -to $ack_snk
	
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
	set_multicycle_path 2 -setup -to $data_pin
	group_path -name "NCL_INBRIDGE_ENC" -to $data_pin
}

foreach cc $comp_clk {
	set bridge [get_property PARENT $cc]
	
	set ki_clk [get_nets -of [get_pins -filter "DIRECTION == OUT" -of $cc]]
	set ki_net [get_nets -segments -of [get_pins -filter "DIRECTION == IN" -of $cc]]
	
	set ki_pin [get_pins -filter "IS_LEAF && DIRECTION == OUT" -of $ki_net]
	set ki_vec_marks [get_cells -leaf -filter "NCL_WIRE_TYPE == COMP_KI_VEC && PARENT == $bridge"]
	set ki_or [get_cells -leaf -of [get_pins -of [get_nets -segments -of $ki_vec_marks] -filter "IS_LEAF && DIRECTION == OUT"] -filter "PARENT == $bridge"]
	
	set di_reg [get_cells -leaf -filter "NCL_WIRE_TYPE == COMP_DI_REG && PARENT == $bridge"]
	set src_pins [get_pins -filter "IS_LEAF && DIRECTION == OUT" -of [get_nets -segments -of [get_pins -filter "DIRECTION == IN" -of $ki_or]]]
	
	set_min_delay 2.5 -from $src_pins -to $ki_pin
	set_max_delay 2.0 -from $src_pins -to $di_reg
	
	group_path -name "NCL_BRIDGE_KI_CLK" -from $src_pins
	
	create_clock -period 5.0 $ki_clk
	
	set cdc_sync [get_cells -filter "ASYNC_REG && PARENT == $bridge" -leaf]
	
	set_false_path -from [get_clocks -of $ki_clk] -to $cdc_sync
	
	set_max_delay -datapath_only [expr [get_property PERIOD [get_clocks -of $cdc_sync]] * 0.75] -from $di_reg	

	# remove marker
	lappend markers {*}[list $ki_vec_marks]
}

set_property DONT_TOUCH false $markers
remove_cell $markers
