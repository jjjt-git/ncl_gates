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

entity TH33w2n is
    port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           C : in STD_LOGIC;
           R : in STD_LOGIC;
           Z : out STD_LOGIC);
end TH33w2n;

architecture Structural of TH33w2n is
begin

	gate: entity ncl_gates.fb_3_rst
		generic map (
			RST_VALUE => '0',
			ASSERT_SET => (A5 and B5) or (A5 and C5)
		) port map (
			A => A,
			B => B,
			C => C,
			R => R,
			Z => Z
		);

end Structural;
