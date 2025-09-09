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

entity TH22d_22d_SA_AA is
    port ( R : in STD_LOGIC;
           A : in STD_LOGIC;
           B1, B2 : in STD_LOGIC;
           Z1, Z2 : out STD_LOGIC);
end TH22d_22d_SA_AA;

architecture Structural of TH22d_22d_SA_AA is

    signal neg_R, output2_buf, output1, output2 : std_logic;
    
    constant LUT_nR  : bit_vector(63 downto 0) := x"FFFF_FFFF_0000_0000";
    constant LUT_A   : bit_vector(63 downto 0) := x"FFFF_0000_FFFF_0000";
    constant LUT_B1  : bit_vector(63 downto 0) := x"FF00_FF00_FF00_FF00";
    constant LUT_B2  : bit_vector(63 downto 0) := x"F0F0_F0F0_F0F0_F0F0";
    constant LUT_FB1 : bit_vector(63 downto 0) := x"CCCC_CCCC_CCCC_CCCC";
    constant LUT_FB2 : bit_vector(63 downto 0) := x"AAAA_AAAA_AAAA_AAAA";
    
    constant CLR_O1 : bit_vector(63 downto 0) := not LUT_A and not LUT_B1;
    constant CLR_O2 : bit_vector(63 downto 0) := not LUT_A and not LUT_B2;
    constant SET_O1 : bit_vector(63 downto 0) := LUT_A and LUT_B1;
    constant SET_O2 : bit_vector(63 downto 0) := LUT_A and LUT_B2;
    
    constant CONF_O1 : bit_vector(63 downto 0) := (not CLR_O1 and SET_O1) or (not CLR_O1 and not SET_O1 and LUT_FB1); -- CLR ? 0 : SET ? 1 : FB
    constant CONF_O2 : bit_vector(63 downto 0) := (not CLR_O2 and SET_O2) or (not CLR_O2 and not SET_O2 and LUT_FB2); -- CLR ? 0 : SET ? 1 : FB
    
    constant CONFIG : bit_vector(63 downto 0) := (LUT_nR and CONF_O1) or (not LUT_nR and CONF_O2); -- nR ? O1 : O2

begin

	process(R) begin
		if falling_edge(R) then
			assert A = '1' or B2 = '1' report "Either A or B2 must be '1' at the end of reset, to ensure correct operation" severity FAILURE;
		end if;
	end process;

	neg_R <= not R;

	Z1 <= transport output1 after 1 ns;
    
    Z2 <= transport output2 after 1 ns;
    
    NCL_GATE_MERGED_FB0_FB1: LUT6_2
		generic map (
			INIT => CONFIG
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
		
	NCL_MERGED_RST: LDPE
		generic map (
			INIT => '1'
		) port map (
			PRE => R,
			
			D => output2_buf,
			Q => output2,
			
			G  => '1',
			GE => '1'
		);

end Structural;