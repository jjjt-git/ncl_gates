# init DRC ruledeck

# create dummy check to allow safe deletion
create_drc_check -name QDICHK-10000 -rule_body {}

foreach cc [get_drc_checks QDICHK-*] {
	delete_drc_check $cc
}

create_drc_ruledeck qdi

# create DRCs
proc drc_qdichk1_gateRoutingChecker {} {
	set delay_limit 1500
	set vios {}

	foreach cc [get_cells -hierarchical NCL_GATE*] {
		set opin [get_pins -of $cc -filter "DIRECTION == OUT"]
		set ipin [get_pins -of [get_nets -of $opin] -filter "DIRECTION == IN && PARENT_CELL == $cc"]
		set net  [get_nets -of $opin]

		set delay [get_net_delays -of $net -filter "TO_PIN == $ipin"]

		if {[get_property SLOW_MAX $delay] > $delay_limit} {
			lappend vios [create_drc_violation -name {QDICHK-1} -msg "The feedback delay for cell %ELG is too high." $cc ]
		}
	}

	if {[llength $vios] > 0} {
		return -code error $vios
	} else {
		return {}
	}
}

create_drc_check -name {QDICHK-1} -hiername {Implementation.Routing} -desc {QDI feedback delay} -rule_body drc_qdichk1_gateRoutingChecker -severity {Critical Warning}

proc drc_qdichk2_isoforkChecker {} {
	set skew_limit 1500
	set vios {}
	array unset grps

	set idmax -1
	foreach pp [get_pins -filter "QDI_ISOFORK" -hierarchical *] {
		set grp [get_property QDI_ISOFORK_GRPS $pp]
		if {$grp > $idmax} {set idmax $grp}
		lappend grps($grp) $pp
	}

	for {set ii 0} {$ii <= $idmax} {incr ii} {
		set max 0
		set min infinity
		foreach pp $grps($ii) {
			set delay [get_property SLOW_MAX [get_net_delays -of [get_nets -of $pp] -filter "TO_PIN == $pp"]]
			if {$delay < $min} {set min $delay}
			if {$delay > $max} {set max $delay}
		}
		if {[expr $max - $min] > $skew_limit} {
			lappend vios [create_drc_violation -name {QDICHK-2} -msg "Skew of isochronicity group with pin %ELG is too high." [lindex $grps($ii) 0]]
		}
	}

	if {[llength $vios] > 0} {
		return -code error $vios
	} else {
		return {}
	}
}

create_drc_check -name {QDICHK-2} -hiername {Implementation.Placement} -desc {QDI isochronic regions} -rule_body drc_qdichk2_isoforkChecker -severity {Critical Warning}

add_drc_checks -ruledeck qdi {QDICHK-1 QDICHK-2}
