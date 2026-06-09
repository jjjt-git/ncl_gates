
library IEEE;
library ncl_gates;
library ncl_components;

use IEEE.STD_LOGIC_1164.ALL;

entity completion is
	generic(
		max_gate_inputs : integer := 5;
		width : integer := 1;
		HAS_DIRECT_KO : boolean := false;
		direct_ko_width : integer := 1
	);
	port (
		ko_vec : in std_logic_vector(direct_ko_width - 1 downto 0) := (others => 'X');
		kd_0, kd_1 : in std_logic_vector(width - 1 downto 0);
		ko : out std_logic
	);
end completion;

architecture Structural of completion is
	constant owidth : integer := (width - (width mod 2)) / 2 + (width mod 2);
	constant ngates : integer := (width - (width mod 2)) / 2;
	
	signal next_stage : std_logic_vector(owidth - 1 downto 0);
begin

	stage_direct: if HAS_DIRECT_KO generate
		signal vec : std_logic_vector(direct_ko_width + owidth - 1 downto 0);
	begin
		l: entity ncl_components.completion_loop
			generic map (
				width => owidth + direct_ko_width
			) port map (
				ko_vector => vec,
				ko => ko
			);
		vec <= ko_vec & next_stage;
	end generate;
	
	stage_nodirect: if not HAS_DIRECT_KO generate
		l: entity ncl_components.completion_loop
			generic map (
				max_gate_inputs => max_gate_inputs,
				width => owidth
			) port map (
				ko_vector => next_stage,
				ko => ko
			);
	end generate;
	
	multi: for ii in 0 to ngates - 1 generate
		g: entity ncl_gates.TH24cmp
			port map (
				A => kd_0(2 * ii),
				B => kd_1(2 * ii),
				C => kd_0(2 * ii + 1),
				D => kd_1(2 * ii + 1),
				Z => next_stage(ii)
			);
	end generate;
	
	remainder: if width mod 2 = 1 generate
		g: entity ncl_gates.TH12
			port map (
				A => kd_0(width - 1),
				B => kd_1(width - 1),
				Z => next_stage(owidth - 1)
			);
	end generate;
	
end Structural;
