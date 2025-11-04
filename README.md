# NCL gate library
## steps for installing

1. add the base directory to vivado design sources in library "ncl_gates"
2. add scripts/ncl.xdc as constraint source
3. run scripts/setup.tcl using Tools -> Run Tcl script

## usage information

every acknowledge path must be marked using a LUT1 buffer (config string "10")
* put attribute DONT_TOUCH onto the buffer
* put attribute NCL_WIRE_TYPE with value "ACK" onto the buffer

every datapath from ncl to clocked logic and clocked logic to ncl must be marked using a LUT1 buffer
* put attribute DONT_TOUCH onto the buffer
* put attribute NCL_WIRE_TYPE with value "NCL_CLK" onto the buffer
