library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

library ncl_gates;

entity ncl2clk_fifo_dr is
	generic (
		dr_width: integer := 2
	);
	port (
		clk, rst: in std_logic;
		dri_0, dri_1: in std_logic_vector(dr_width - 1 downto 0);
		ko: out std_logic;
		valid: out std_logic;
		stall: in  std_logic;
		dro: out std_logic_vector(dr_width - 1 downto 0)
	);
end ncl2clk_fifo_dr;

architecture Behavioural of ncl2clk_fifo_dr is
	attribute NCL_WIRE_TYPE : string;
	attribute DONT_TOUCH    : boolean;
	attribute ASYNC_REG     : boolean;
	
	signal ki_vec : std_logic_vector(dr_width - 1 downto 0);
	
	signal ki, ko_int : std_logic;
	
	signal empty, full : std_logic;
	
	type buf_t is array (0 to 3) of std_logic_vector(dr_width - 1 downto 0);
	signal buf : buf_t;
	
	signal w_ptr, r_ptr : std_logic_vector(1 downto 0);
	signal sync_meta, sync_stable : std_logic_vector(1 downto 0);
	
	signal valid_int : std_logic;
	
	attribute NCL_WIRE_TYPE of ko_mark : label is "NCL_CLK";
	attribute DONT_TOUCH    of ko_mark : label is true;
	
	attribute ASYNC_REG of sync_meta   : signal is true;
	attribute ASYNC_REG of sync_stable : signal is true;
begin

	ki_vec <= dri_0 or dri_1;
	
	valid_int <= not empty;
	valid <= valid_int;
	
	empty <=
		'1' when sync_stable = r_ptr else
		'0';
		
	full <=
		'1' when w_ptr(0) & not w_ptr(1) = r_ptr else
		'0';
	
	ko <= ko_int;
	ko_int <= not full and ki;
	
	dro <= buf(to_integer(unsigned(r_ptr)));
	
	ko_mark: LUT1
		generic map (
			INIT => "10"
		) port map (
			I0 => ko_int
		);
	
	comp: entity ncl_gates.completion_loop
		generic map (
			width => dr_width,
			negated_out => false
		) port map (
			ko_vector => ki_vec,
			ko => ki
		);

	sync: process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				sync_meta   <= "00";
				sync_stable <= "00";
			else
				sync_meta   <= w_ptr;
				sync_stable <= sync_meta;
			end if;
		end if;
	end process sync;
	
	di: process(ki) begin
		if rising_edge(ki) then
			buf(to_integer(unsigned(w_ptr))) <= dri_1;
		end if;
	end process di;
	
	handshake_ncl: process(ki, rst) begin
		if rst = '1' then
			w_ptr <= (others => '0');
		elsif rising_edge(ki) then
			w_ptr <= w_ptr(0) & not w_ptr(1);
		end if;
	end process handshake_ncl;
	
	handshake_clk: process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				r_ptr <= (others => '0');
			elsif valid_int = '1' and stall = '0' then
				r_ptr <= r_ptr(0) & not r_ptr(1);
			end if;
		end if;
	end process handshake_clk;
		
end Behavioural;
