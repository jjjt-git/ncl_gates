library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity fb_3 is
	generic (
		CLEAR_SET   : bit_vector(31 downto 0) := x"0000_0001";
		ASSERT_SET  : bit_vector(31 downto 0)
	);
	port (
		A, B, C : in std_logic;
		Z : out std_logic
	);
end fb_3;

architecture Structural of fb_3 is
	constant FB_VALUE     : bit_vector(15 downto 0) := x"FF00"; -- I3 is FB
	constant CLEAR_F_SET  : bit_vector(15 downto 0) := CLEAR_SET(7 downto 0) & CLEAR_SET(7 downto 0);
	constant ASSERT_F_SET : bit_vector(15 downto 0) := ASSERT_SET(7 downto 0) & ASSERT_SET(7 downto 0);
	
	constant CONFIG : bit_vector(15 downto 0) := ASSERT_F_SET or (not CLEAR_F_SET and FB_VALUE);
	
	signal output, output_p : std_logic;
begin

	Z <= output;
	output_p <= transport output after 1 ns;
	
	NCL_GATE_SIMPLE: LUT4
		generic map (
			INIT => CONFIG
		) port map (
			I0 => A,
			I1 => B,
			I2 => C,
			I3 => output_p,
			O  => output
		);
	
end Structural;
