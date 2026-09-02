----------------------------------------------------------------------------------
-- Exploring Implementations of Null Convention Logic on FPGAs
-- (c) Henry Mueller 2024
-- (c) Jacob Tilger 2025
-- This work is licensed under GPLv3.
-- File Part of Development Release 0.2.0
----------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

library qdi_framework;
use qdi_framework.MACRO_CONFIG.all;

entity THxor0n is
    port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           C : in STD_LOGIC;
           D : in STD_LOGIC;
           R : in STD_LOGIC;
           Z : out STD_LOGIC);
end THxor0n;

architecture Structural of THxor0n is
begin

	gate: entity qdi_framework.fb_4_rst
		generic map (
			RST_VALUE => '0',
			ASSERT_SET => (A5 and B5) or (C5 and D5)
		) port map (
			A => A,
			B => B,
			C => C,
			D => D,
			R => R,
			Z => Z
		);

end Structural;
