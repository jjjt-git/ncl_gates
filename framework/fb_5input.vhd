library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity fb_5input is
	generic (
		HAS_RESET   : boolean := false;
		RESET_VALUE : std_logic := 'X';
		CLEAR_SET   : bit_vector(31 downto 0) := x"0000_0001";
		ASSERT_SET  : bit_vector(31 downto 0)
	);
	port (
		R : in std_logic := 'X';
		A, B, C, D, E : in std_logic;
		Z : out std_logic
	);
end fb_5input;

architecture Structural of fb_5input is
	constant FB_VALUE     : bit_vector(63 downto 0) := x"FFFF_FFFF_0000_0000"; -- I5 is FB
	constant CLEAR_F_SET  : bit_vector(63 downto 0) := CLEAR_SET & CLEAR_SET;
	constant ASSERT_F_SET : bit_vector(63 downto 0) := ASSERT_SET & ASSERT_SET;
	
	constant CONFIG : bit_vector(63 downto 0) := (not CLEAR_F_SET and ASSERT_F_SET) or (not CLEAR_F_SET and not ASSERT_F_SET and FB_VALUE);
	
	signal output, output_i : std_logic;
begin

	Z <= transport output after 1 ns;
	
	WITH_RESET: if HAS_RESET generate
		assert RESET_VALUE = '1' or RESET_VALUE = '0' report "Please configure desired reset value" severity FAILURE;
		N: if RESET_VALUE = '0' generate
			latch : LDCE
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
		
		D: if RESET_VALUE = '1' generate
			latch : LDPE
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
	end generate;
	
	WITHOUT_RESET: if not HAS_RESET generate
		output <= output_i;
	end generate;
	
	NCL_GATE_FB5: LUT6
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
	
end Structural;