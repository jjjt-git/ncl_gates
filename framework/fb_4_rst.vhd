library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity fb_4_rst is
	generic (
		RST_VALUE   : bit;
		CLEAR_SET   : bit_vector(31 downto 0) := x"0000_0001";
		ASSERT_SET  : bit_vector(31 downto 0)
	);
	port (
		A, B, C, D, R : in std_logic;
		Z : out std_logic
	);
end fb_4_rst;

architecture Structural of fb_4_rst is
	constant FB_VALUE     : bit_vector(31 downto 0) := x"FFFF_0000"; -- I4 is FB
	constant CLEAR_F_SET  : bit_vector(31 downto 0) := CLEAR_SET(15 downto 0) & CLEAR_SET(15 downto 0);
	constant ASSERT_F_SET : bit_vector(31 downto 0) := ASSERT_SET(15 downto 0) & ASSERT_SET(15 downto 0);
	
	constant RST_VEC : bit_vector(31 downto 0) := (others => RST_VALUE);
	
	constant FUNC : bit_vector(31 downto 0) := (not CLEAR_F_SET and ASSERT_F_SET) or (not CLEAR_F_SET and not ASSERT_F_SET and FB_VALUE);
	
	constant CONFIG : bit_vector(63 downto 0) := RST_VEC & FUNC;
	
	signal output : std_logic;
begin

	Z <= transport output after 1 ns;
	
	NCL_GATE_SIMPLE: LUT6
		generic map (
			INIT => CONFIG
		) port map (
			I0 => A,
			I1 => B,
			I2 => C,
			I3 => D,
			I4 => output,
			I5 => R,
			O  => output
		);
	
end Structural;
