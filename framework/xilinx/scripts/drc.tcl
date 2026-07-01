# create DRCs
create_drc_ruledeck qdi

proc gateRoutingChecker {} {
	set delay_limit 1500
	set vios {}
	foreach cc [get_cells -hierarchical NCL_GATE*] {
		set opin [get_pins -of $cc -filter "DIRECTION == OUT"]
		set ipin [get_pins -of [get_nets -of $opin] -filter "DIRECTION == IN && PARENT_CELL == $cc"]
		set net  [get_nets -of $opin]

		set delay [get_net_delays -of $net -filter "TO_PIN == $ipin"]

		if {[get_property SLOW_MAX $delay] > $delay_limit} {
			lappend vios [ create_drc_violation -name {QDICHK-1} -msg "The feedback delay for cell %ELG is too high." $cc ]
		}
	}

	if {[llength $vios] > 0} {
		return -code error $vios
	} else {
		return {}
	}
}

create_drc_check -name {QDICHK-1} -hiername {Implementation.Routing} -desc {QDI feedback delay} -rule_body gateRoutingChecker -severity {Critical Warning}
add_drc_checks -ruledeck qdi {QDICHK-1}
