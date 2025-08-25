# allow comb loop on NCL gates
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -of_objects [get_pins -of_objects [get_cells -hierarchical {NCL_GATE_FB*}]]]

set_disable_timing [get_cells -hierarchical {NCL_GATE_FB0}] -from I0 -to O
set_disable_timing [get_cells -hierarchical {NCL_GATE_FB1}] -from I1 -to O
set_disable_timing [get_cells -hierarchical {NCL_GATE_FB2}] -from I2 -to O
set_disable_timing [get_cells -hierarchical {NCL_GATE_FB3}] -from I3 -to O
set_disable_timing [get_cells -hierarchical {NCL_GATE_FB4}] -from I4 -to O
set_disable_timing [get_cells -hierarchical {NCL_GATE_FB5}] -from I5 -to O

set_max_delay 1.0 -to [get_pins -of_objects [get_cells -hierarchical {NCL_GATES_FB0}] -filter "REF_PIN_NAME=~I0"] -from [get_pins -of_objects [get_cells -hierarchical {NCL_GATES_FB0}] -filter "REF_PIN_NAME=~O"]
set_max_delay 1.0 -to [get_pins -of_objects [get_cells -hierarchical {NCL_GATES_FB1}] -filter "REF_PIN_NAME=~I1"] -from [get_pins -of_objects [get_cells -hierarchical {NCL_GATES_FB1}] -filter "REF_PIN_NAME=~O"]
set_max_delay 1.0 -to [get_pins -of_objects [get_cells -hierarchical {NCL_GATES_FB2}] -filter "REF_PIN_NAME=~I2"] -from [get_pins -of_objects [get_cells -hierarchical {NCL_GATES_FB2}] -filter "REF_PIN_NAME=~O"]
set_max_delay 1.0 -to [get_pins -of_objects [get_cells -hierarchical {NCL_GATES_FB3}] -filter "REF_PIN_NAME=~I3"] -from [get_pins -of_objects [get_cells -hierarchical {NCL_GATES_FB3}] -filter "REF_PIN_NAME=~O"]
set_max_delay 1.0 -to [get_pins -of_objects [get_cells -hierarchical {NCL_GATES_FB4}] -filter "REF_PIN_NAME=~I4"] -from [get_pins -of_objects [get_cells -hierarchical {NCL_GATES_FB4}] -filter "REF_PIN_NAME=~O"]
set_max_delay 1.0 -to [get_pins -of_objects [get_cells -hierarchical {NCL_GATES_FB5}] -filter "REF_PIN_NAME=~I5"] -from [get_pins -of_objects [get_cells -hierarchical {NCL_GATES_FB5}] -filter "REF_PIN_NAME=~O"]
