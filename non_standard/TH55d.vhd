----------------------------------------------------------------------------------
-- Exploring Implementations of Null Convention Logic on FPGAs
-- (c) Henry Mueller 2024
-- This work is licensed under GPLv3.
-- File Part of Development Release 0.1.0
----------------------------------------------------------------------------------

library IEEE;
library UNISIM;

use IEEE.STD_LOGIC_1164.ALL;
use UNISIM.VComponents.all;

library ncl_gates;
use ncl_gates.MACRO_CONFIG.all;

entity TH55d is
    port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           C : in STD_LOGIC;
           D : in STD_LOGIC;
           E : in STD_LOGIC;
           R : in STD_LOGIC;
           Z : out STD_LOGIC);
end TH55d;

architecture Structural of TH55d is

    signal output, output_buf : std_logic;
    
    constant CLEAR_SET  : bit_vector(31 downto 0) := x"0000_0001";
    constant ASSERT_SET : bit_vector(31 downto 0) := A5 and B5 and C5 and D5 and E5;

	constant FB_VALUE     : bit_vector(63 downto 0) := x"FFFF_FFFF_0000_0000"; -- I5 is FB
	constant CLEAR_F_SET  : bit_vector(63 downto 0) := CLEAR_SET & CLEAR_SET;
	constant ASSERT_F_SET : bit_vector(63 downto 0) := ASSERT_SET & ASSERT_SET;
	
	constant CONFIG : bit_vector(63 downto 0) := (not CLEAR_F_SET and ASSERT_F_SET) or (not CLEAR_F_SET and not ASSERT_F_SET and FB_VALUE);
begin

	Z <= transport output after 1 ns;

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
			O  => output_buf
		);
		
	NCL_RST: LDPE
		generic map (
			INIT => '1'
		) port map (
			PRE => R,
			
			D => output_buf,
			Q => output,
			
			G  => '1',
			GE => '1'
		);

end Structural;
