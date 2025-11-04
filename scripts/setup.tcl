set dir [file dirname [file normalize [info script]]]

add_files -fileset utils_1 -norecurse $dir/set_constraints.tcl
add_files -fileset utils_1 -norecurse $dir/set_hardmask.tcl
set_property STEPS.INIT_DESIGN.TCL.POST [ get_files $dir/set_constraints.tcl -of [get_fileset utils_1] ] [current_run]
set_property STEPS.PLACE_DESIGN.TCL.POST [ get_files $dir/set_hardmask.tcl -of [get_fileset utils_1] ] [current_run]

