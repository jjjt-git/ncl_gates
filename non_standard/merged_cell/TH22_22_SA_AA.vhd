----------------------------------------------------------------------------------
-- Exploring Implementations of Null Convention Logic on FPGAs
-- Complex Special Purpose Gates
-- (c) Jacob Tilger 2025
-- This work is licensed under GPLv3.
-- File Part of Development Release 0.1.0
----------------------------------------------------------------------------------

library IEEE;
library UNISIM;

use IEEE.STD_LOGIC_1164.ALL;
use UNISIM.VComponents.all;

entity TH22_22_SA_AA is
    port ( A : in STD_LOGIC;
           B1, B2 : in STD_LOGIC;
           Z1, Z2 : out STD_LOGIC);
end TH22_22_SA_AA;

architecture Structural of TH22_22_SA_AA is

    signal output1, output2 : std_logic;

begin
    Z1 <= transport output1 after 1 ns;
    
    Z2 <= transport output2 after 1 ns;
    
    NCL_GATE_MERGED_FB0_FB1: LUT6_2
		generic map (
			INIT => X"FFCCCC00FAFAA0A0"
		) port map (
			I5 => '1',
			I4 => A,
			I3 => B1,
			I2 => B2,
			I1 => output1,
			I0 => output2,
			
			O6 => output1,
			O5 => output2
		);

end Structural;