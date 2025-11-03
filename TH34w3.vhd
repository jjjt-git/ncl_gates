----------------------------------------------------------------------------------
-- Exploring Implementations of Null Convention Logic on FPGAs
-- (c) Henry Mueller 2024
-- (c) Jacob Tilger 2025
-- This work is licensed under GPLv3.
-- File Part of Development Release 0.2.0
----------------------------------------------------------------------------------

library IEEE;
library UNISIM;

use IEEE.STD_LOGIC_1164.ALL;
use UNISIM.VComponents.all;

library ncl_gates;
use ncl_gates.MACRO_CONFIG.all;

entity TH34w3 is
    port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           C : in STD_LOGIC;
           D : in STD_LOGIC;
           Z : out STD_LOGIC);
end TH34w3;

architecture Structural of TH34w3 is
begin

	gate: entity ncl_gates.fb_4
		generic map (
			ASSERT_SET => A5 or (B5 and C5 and D5) 
		) port map (
			A => A,
			B => B,
			C => C,
			D => D,
			Z => Z
		);

end Structural;
