library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity fb_5 is
	generic (
		CLEAR_SET   : bit_vector(31 downto 0) := x"0000_0001";
		ASSERT_SET  : bit_vector(31 downto 0)
	);
	port (
		A, B, C, D, E : in std_logic;
		Z : out std_logic
	);
end fb_5;

architecture Structural of fb_5 is
	constant FB_VALUE     : bit_vector(63 downto 0) := x"FFFF_FFFF_0000_0000"; -- I5 is FB
	constant CLEAR_F_SET  : bit_vector(63 downto 0) := CLEAR_SET & CLEAR_SET;
	constant ASSERT_F_SET : bit_vector(63 downto 0) := ASSERT_SET & ASSERT_SET;
	
	constant CONFIG : bit_vector(63 downto 0) := ASSERT_F_SET or (not CLEAR_F_SET and FB_VALUE);
	
	signal output, output_p : std_logic;
begin

	Z <= output;
	output_p <= transport output after 1 ns;
	
	NCL_GATE_SIMPLE: LUT6
		generic map (
			INIT => CONFIG
		) port map (
			I0 => A,
			I1 => B,
			I2 => C,
			I3 => D,
			I4 => E,
			I5 => output_p,
			O  => output
		);
	
end Structural;
