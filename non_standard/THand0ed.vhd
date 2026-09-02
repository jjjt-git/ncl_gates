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

entity THand0ed is
    port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           C : in STD_LOGIC;
           D : in STD_LOGIC;
           E : in STD_LOGIC;
           R : in STD_LOGIC;
           Z : out STD_LOGIC);
end THand0ed;

architecture Structural of THand0ed is
begin

	gate: entity qdi_framework.fb_5_rst
		generic map (
			RST_VALUE => '1',
			ASSERT_SET => (A5 and B5 and C5) or (A5 and C5 and D5) or (A5 and B5 and E5)
		) port map (
			A => A,
			B => B,
			C => C,
			D => D,
			E => E,
			R => R,
			Z => Z
		);

end Structural;
