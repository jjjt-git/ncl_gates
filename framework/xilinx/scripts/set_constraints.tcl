#write_checkpoint -force /tmp/checkpoint.dcp

set ack [get_cells -leaf -filter "NCL_WIRE_TYPE == ACK"]
set bridge [get_cells -leaf -filter "NCL_WIRE_TYPE == NCL_CLK"]

set inbridge_enc [get_cells -leaf -filter "NCL_WIRE_TYPE == IN_ENC"]

set ncl_gates [get_cells -hierarchical NCL_GATE*]

set comp_clk_NCL2CLK [get_cells -leaf -filter "NCL_WIRE_TYPE == COMP_CLK_NCL2CLK"]

set comp_clk_CLK2NCL [get_cells -leaf -filter "NCL_WIRE_TYPE == COMP_CLK_CLK2NCL"]

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

foreach cc $comp_clk_NCL2CLK {
	set bridge [get_property PARENT $cc]

	set ki_clk [get_nets -of [get_pins -filter "DIRECTION == OUT" -of $cc]]
	set ki_net [get_nets -segments -of [get_pins -filter "DIRECTION == IN" -of $cc]]

	set ki_pin [get_pins -filter "IS_LEAF && DIRECTION == OUT" -of $ki_net]
	set ki_vec_marks [get_cells -leaf -filter "NCL_WIRE_TYPE == COMP_KI_VEC && PARENT == $bridge"]
	set ki_or [get_cells -leaf -of [get_pins -of [get_nets -segments -of $ki_vec_marks] -filter "IS_LEAF && DIRECTION == OUT"] -filter "PARENT == $bridge"]

	set di_mark [get_cells -leaf -filter "NCL_WIRE_TYPE == COMP_DI_REG && PARENT == $bridge"]
	set src_pins [get_pins -filter "IS_LEAF && DIRECTION == OUT" -of [get_nets -segments -of [get_pins -filter "DIRECTION == IN" -of $ki_or]]]

	set di_trg []
	set di_trg_wlist $di_mark
	while {[llength $di_trg_wlist] != 0} {
		set mm [lindex $di_trg_wlist 0]
		set di_trg_wlist [lreplace $di_trg_wlist 0 0]

		switch [get_property PRIMITIVE_GROUP $mm] {
			FLOP_LATCH - DMEM - BMEM {
				lappend di_trg $mm
			}
			LUT {
				lappend di_trg_wlist {*}[list [get_cells -of [get_pins -filter "IS_LEAF && DIRECTION == OUT" -of [get_nets -segments -of [get_pins -filter "DIRECTION == IN" -of $mm]]]]]
				if {[llength [get_nets -of [get_pins -filter "DIRECTION == OUT" -of $mm]]] == 0} { lappend markers $mm }
			}
		}
	}

	set_min_delay $fb_required_delay -from $src_pins -to $ki_pin
	set_max_delay [expr $fb_required_delay - 0.5] -from $src_pins -to $di_trg

	group_path -name "NCL_BRIDGE_KI_CLK" -from $src_pins

	create_clock -period [expr $fb_required_delay * 2] $ki_clk

	set cdc_sync [get_cells -filter "ASYNC_REG && PARENT == $bridge" -leaf]

	set_false_path -from [get_clocks -of $ki_clk] -to $cdc_sync

	set_max_delay -datapath_only [get_property PERIOD [get_clocks -of $cdc_sync]] -from $di_trg

	# remove marker
	lappend markers {*}[list $ki_vec_marks]
}

foreach cc $comp_clk_CLK2NCL {
	set bridge [get_property PARENT $cc]

	set ki_clk [get_nets -of [get_pins -filter "DIRECTION == OUT" -of $cc]]

	create_clock -period [expr $fb_required_delay * 2] $ki_clk

	set cdc_sync [get_cells -filter "ASYNC_REG && PARENT == $bridge" -leaf]

	set_false_path -from [get_clocks -of $ki_clk] -to $cdc_sync
}

foreach clk [get_clocks] {
	set clk_name [string map {"/" "_"} [get_property NAME $clk]]

	set edges [get_property WAVEFORM $clk]
	set cperiod [get_property PERIOD $clk]

	# init values (final times are smaller than 1 period)
	set T_rise_rise $cperiod
	set T_rise_fall $cperiod
	set T_fall_rise $cperiod
	set T_fall_fall $cperiod

	set nextrise [expr $cperiod + [lindex $edges 0]]
	set nextfall [expr $cperiod + [lindex $edges 1]]

	while {[llength $edges] >= 4} {
		set rr [expr [lindex $edges 2] - [lindex $edges 0]]
		set rf [expr [lindex $edges 1] - [lindex $edges 0]]
		set fr [expr [lindex $edges 2] - [lindex $edges 1]]
		set ff [expr [lindex $edges 3] - [lindex $edges 1]]

		if {$rr < $T_rise_rise} { set T_rise_rise $rr }
		if {$rf < $T_rise_fall} { set T_rise_fall $rf }
		if {$fr < $T_fall_rise} { set T_fall_rise $fr }
		if {$ff < $T_fall_fall} { set T_fall_fall $ff }

		set edges [lreplace $edges 0 1]
	}

	set rr [expr $nextrise         - [lindex $edges 0]]
	set rf [expr [lindex $edges 1] - [lindex $edges 0]]
	set fr [expr $nextrise         - [lindex $edges 1]]
	set ff [expr $nextfall         - [lindex $edges 1]]

	if {$rr < $T_rise_rise} { set T_rise_rise $rr }
	if {$rf < $T_rise_fall} { set T_rise_fall $rf }
	if {$fr < $T_fall_rise} { set T_fall_rise $fr }
	if {$ff < $T_fall_fall} { set T_fall_fall $ff }

	set clock_desc(rr,$clk_name) $T_rise_rise
	set clock_desc(rf,$clk_name) $T_rise_fall
	set clock_desc(fr,$clk_name) $T_fall_rise
	set clock_desc(ff,$clk_name) $T_fall_fall
}

# encoders
foreach cc $inbridge_enc {
	set bridge [get_property PARENT $cc]

	set clk_val_pin [get_pins -of $cc -filter "REF_PIN_NAME == [get_property NCL_IN_ENC_CLK_VALID_PIN $cc]"]
	set clk_dat_pin [get_pins -of $cc -filter "REF_PIN_NAME == [get_property NCL_IN_ENC_DATA_PIN $cc]"]

	set edge_conf [get_property NCL_IN_ENC_DATA2VALID_EDGES $cc]

	set opin [get_pins -filter "DIRECTION == OUT" -of $cc]

	set d_src []
	set d_src_wlist [get_cells -of [get_pins -of [get_nets -segments -of $clk_dat_pin] -filter "IS_LEAF && DIRECTION == OUT"]]
	while {[llength $d_src_wlist] != 0} {
		set mm [lindex $d_src_wlist 0]
		set d_src_wlist [lreplace $d_src_wlist 0 0]

		switch [get_property PRIMITIVE_GROUP $mm] {
			FLOP_LATCH - DMEM - BMEM {
				lappend d_src $mm
			}
			LUT {
				lappend d_src_wlist {*}[list [get_cells -of [get_pins -filter "IS_LEAF && DIRECTION == OUT" -of [get_nets -segments -of [get_pins -filter "DIRECTION == IN" -of $mm]]]]]
				if {[llength [get_nets -of [get_pins -filter "DIRECTION == OUT" -of $mm]]] == 0} { lappend markers $mm }
			}
		}
	}

	if {[llength $d_src] != 0} {
		set val_src [get_cells -filter "NCL_IN_ENC_REG == clk_valid && PARENT == $bridge" -leaf]

		set clk [get_clocks -of $d_src]
		set clk_name [string map {"/" "_"} [get_property NAME $clk]]

		set Treq $clock_desc($edge_conf,$clk_name)

		set_max_delay -datapath_only -from $d_src -to $clk_dat_pin $Treq

		group_path -name "NCL_IN_ENC" -to $clk_dat_pin
	}
}

set_property DONT_TOUCH false $markers
remove_cell $markers

