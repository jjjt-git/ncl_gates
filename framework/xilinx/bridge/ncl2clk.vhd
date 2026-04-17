library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

library ncl_components;

entity ncl2clk is
	generic (
		width: integer := 2
	);
	port (
		clk, rst: in std_logic;
		di_0, di_1: in std_logic_vector(width - 1 downto 0);
		ko: out std_logic;
		valid: out std_logic;
		stall: in  std_logic;
		do: out std_logic_vector(width - 1 downto 0)
	);
end ncl2clk;

architecture Behavioural of ncl2clk is
	attribute NCL_WIRE_TYPE : string;
	attribute RLOC          : string;
	attribute DONT_TOUCH    : boolean;
	attribute ASYNC_REG     : boolean;
	
	signal ki, ki_p, ki_s, ki_sp : std_logic;
	
	attribute ASYNC_REG of ki_rm : label is true;
	attribute ASYNC_REG of ki_fs : label is true;
	attribute ASYNC_REG of ki_rs : label is true;
	
	attribute RLOC of ki_rm : label is "X0Y0";
	attribute RLOC of ki_fs : label is "X1Y0";
	
	signal ki_vec: std_logic_vector(width - 1 downto 0);
	
	signal ce, ko_int, valid_p: std_logic;
	
	attribute NCL_WIRE_TYPE of ko_mark : label is "NCL_CLK";
	attribute DONT_TOUCH    of ko_mark : label is true;
begin

	ki_vec <= di_0 or di_1;
	
	comp: entity ncl_components.completion_loop
		generic map (
			width => width
		) port map (
			ko_vector => ki_vec,
			ko => ki
		);
	
	di: process(clk) begin
		if rising_edge(clk) then
			if ki_s = '1' and ki_sp = '1' then
				do <= di_1;
			end if;
		end if;
	end process di;
	
	ki_rm: FDSE
		port map (
			S  => rst,
			C  => clk,
			CE => '1',
			
			D => ki,
			Q => ki_p
		);
	
	ki_fs: FDSE_1
		port map (
			S  => rst,
			C  => clk,
			CE => ce,
			
			D => ki_p,
			Q => ki_s
		);
		
	ki_rs: FDSE
		port map (
			S  => rst,
			C  => clk,
			CE => ce,
			
			D => ki_s,
			Q => ki_sp
		);
	
	ko_mark: LUT1
		generic map (
			INIT => "10"
		) port map (
			I0 => ko_int
		);
	
	ko_int <= ki_s and ki_sp;
	ko <= ko_int;
	
	ce <= not valid_p or not stall;
	
	valid <= valid_p;
	valid_p <= not ki_sp and ki_s;
end Behavioural;