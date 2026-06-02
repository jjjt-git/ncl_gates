library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package ncl2clk is
	component ncl2clk_dr
		generic (
			dr_width: integer := 2
		);
		port (
			clk, rst: in std_logic;
			dri_0, dri_1: in std_logic_vector(dr_width - 1 downto 0); -- dual rail encoded output
			ko: out std_logic;
			valid: out std_logic;
			stall: in std_logic;
			dro: out std_logic_vector(dr_width - 1 downto 0) -- inputs to be dual rail encoded
		);
	end component;
	
	component ncl2clk_qr
		generic (
			qr_width: integer := 2
		);
		port (
			clk, rst: in std_logic;
			qri_0, qri_1, qri_2, qri_3: in std_logic_vector(qr_width - 1 downto 0); -- quad rail encoded output
			ko: out std_logic;
			valid: out std_logic;
			stall: in std_logic;
			qro: out std_logic_vector(2 * qr_width - 1 downto 0) -- inputs to be quad rail encoded
		);
	end component;
	
	component ncl2clk_dr_qr
		generic (
			dr_width: integer := 2;
			qr_width: integer := 2
		);
		port (
			clk, rst: in std_logic;
			dri_0, dri_1: in std_logic_vector(dr_width - 1 downto 0); -- dual rail encoded output
			qri_0, qri_1, qri_2, qri_3: in std_logic_vector(qr_width - 1 downto 0); -- quad rail encoded output
			ko: out std_logic;
			valid: out std_logic;
			stall: in std_logic;
			dro: out std_logic_vector(dr_width - 1 downto 0); -- inputs to be dual rail encoded
			qro: out std_logic_vector(2 * qr_width - 1 downto 0) -- inputs to be quad rail encoded
		);
	end component;
end ncl2clk;