library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity fb_5_rst is
	generic (
		RST_VALUE   : bit;
		CLEAR_SET   : bit_vector(31 downto 0) := x"0000_0001";
		ASSERT_SET  : bit_vector(31 downto 0)
	);
	port (
		A, B, C, D, E, R : in std_logic;
		Z : out std_logic
	);
end fb_5_rst;

architecture Structural of fb_5_rst is
	constant FB_VALUE     : bit_vector(63 downto 0) := x"FFFF_FFFF_0000_0000"; -- I5 is FB
	constant CLEAR_F_SET  : bit_vector(63 downto 0) := CLEAR_SET & CLEAR_SET;
	constant ASSERT_F_SET : bit_vector(63 downto 0) := ASSERT_SET & ASSERT_SET;
	
	constant CONFIG : bit_vector(63 downto 0) := (not CLEAR_F_SET and ASSERT_F_SET) or (not CLEAR_F_SET and not ASSERT_F_SET and FB_VALUE);
	
	signal output, output_i : std_logic;
	
	attribute RLOC : string;
	attribute RLOC of NCL_GATE_EXTRST : label is "X0Y0";
begin

	Z <= transport output after 1 ns;
	
	NCL_GATE_EXTRST: LUT6
		generic map (
			INIT => CONFIG
		) port map (
			I0 => A,
			I1 => B,
			I2 => C,
			I3 => D,
			I4 => E,
			I5 => output,
			O  => output_i
		);
	
	RST_N: if RST_VALUE = '0' generate
		attribute RLOC of NCL_EXTRST : label is "X0Y0";
	begin
		NCL_EXTRST: LDCE
			generic map (
				INIT => '0'
			) port map (
				CLR => R,

				D   => output_i,
				Q   => output,

				G   => '1',
				GE  => '1'
			);
	end generate;

	RST_D: if RST_VALUE = '1' generate
		attribute RLOC of NCL_EXTRST : label is "X0Y0";
	begin
		NCL_EXTRST: LDPE
			generic map (
				INIT => '1'
			) port map (
				PRE => R,

				D   => output_i,
				Q   => output,

				G   => '1',
				GE  => '1'
			);
	end generate;
	
end Structural;
