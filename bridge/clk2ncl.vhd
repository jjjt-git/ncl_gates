library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package clk2ncl is
	component clk2ncl_dr
		generic (
			dr_width: integer := 2
		);
		port (
			clk, rst: in std_logic;
			dro_0, dro_1: out std_logic_vector(dr_width - 1 downto 0); -- dual rail encoded output
			ki: in std_logic;
			valid: in std_logic;
			stall: out std_logic;
			dri: in std_logic_vector(dr_width - 1 downto 0) -- inputs to be dual rail encoded
		);
	end component;
	
	component clk2ncl_qr
		generic (
			qr_width: integer := 2
		);
		port (
			clk, rst: in std_logic;
			qro_0, qro_1, qro_2, qro_3: out std_logic_vector(qr_width - 1 downto 0); -- quad rail encoded output
			ki: in std_logic;
			valid: in std_logic;
			stall: out std_logic;
			qri: in std_logic_vector(2 * qr_width - 1 downto 0) -- inputs to be quad rail encoded
		);
	end component;
	
	component clk2ncl_dr_qr
		generic (
			dr_width: integer := 2;
			qr_width: integer := 2
		);
		port (
			clk, rst: in std_logic;
			dro_0, dro_1: out std_logic_vector(dr_width - 1 downto 0); -- dual rail encoded output
			qro_0, qro_1, qro_2, qro_3: out std_logic_vector(qr_width - 1 downto 0); -- quad rail encoded output
			ki: in std_logic;
			valid: in std_logic;
			stall: out std_logic;
			dri: in std_logic_vector(dr_width - 1 downto 0); -- inputs to be dual rail encoded
			qri: in std_logic_vector(2 * qr_width - 1 downto 0) -- inputs to be quad rail encoded
		);
	end component;
end clk2ncl;
