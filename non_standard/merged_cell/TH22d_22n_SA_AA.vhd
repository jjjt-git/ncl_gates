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

entity TH22d_22n_SA_AA is
    port ( R : in STD_LOGIC;
           A : in STD_LOGIC;
           B1, B2 : in STD_LOGIC;
           Z1, Z2 : out STD_LOGIC);
end TH22d_22n_SA_AA;

architecture Structural of TH22d_22n_SA_AA is

    signal neg_R, output2_buf, output1, output2 : std_logic;

begin

	process(R) begin
		if falling_edge(R) then
			assert A = '0' or B2 = '0' report "A or B2 must be '0' at the end of reset, to ensure correct operation" severity FAILURE;
		end if;
	end process;

	neg_R <= not R;
	
	Z1 <= transport not output1 after 1 ns;
    
    Z2 <= transport output2 after 1 ns;
    
    NCL_GATE_MERGED_FB0_FB1: LUT6_2
		generic map (
			INIT => X"00CCCCFFFAFAA0A0"
		) port map (
			I5 => neg_R,
			I4 => A,
			I3 => B1,
			I2 => B2,
			I1 => output1,
			I0 => output2,
			
			O6 => output1,
			O5 => output2_buf
		);
		
	NCL_MERGED_RST_2: LDCE
		generic map (
			INIT => '1'
		) port map (
			CLR => R,
			
			D => output2_buf,
			Q => output2,
			
			G  => '1',
			GE => '1'
		);

end Structural;