package MACRO_CONFIG is
	constant A2 : bit_vector( 3 downto 0) := x"A";
	constant A3 : bit_vector( 7 downto 0) := x"AC";
	constant A4 : bit_vector(15 downto 0) := x"ACCC";
	constant A5 : bit_vector(31 downto 0) := x"ACCC_CCCC";

	constant B2 : bit_vector( 3 downto 0) := x"C";
	constant B3 : bit_vector( 7 downto 0) := x"CC";
	constant B4 : bit_vector(15 downto 0) := x"CCCC";
	constant B5 : bit_vector(31 downto 0) := x"CCCC_CCCC";
	
	constant C3 : bit_vector( 7 downto 0) := x"F0";
	constant C4 : bit_vector(15 downto 0) := x"F0F0";
	constant C5 : bit_vector(31 downto 0) := x"F0F0_F0F0";
	
	constant D4 : bit_vector(15 downto 0) := x"FF00";
	constant D5 : bit_vector(31 downto 0) := x"FF00_FF00";
	
	constant E5 : bit_vector(31 downto 0) := x"FFFF_0000";
end MACRO_CONFIG;
