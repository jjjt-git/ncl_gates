set inbridge_enc [get_cells -leaf -filter "NCL_WIRE_TYPE == IN_ENC"]

foreach cc $inbridge_enc {
	set data_pin  [get_pins -of $cc -filter "REF_PIN_NAME == I1"]

	group_path -name "NCL_INBRIDGE_ENC" -to $data_pin
}