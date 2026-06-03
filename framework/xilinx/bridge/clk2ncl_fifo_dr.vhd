library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;

library UNISIM;
use UNISIM.VComponents.all;

entity clk2ncl_fifo_dr is
	generic (
		dr_width: integer := 2
	);
	port (
		clk, rst: in std_logic;
		dro_0, dro_1: out std_logic_vector(dr_width - 1 downto 0);
		ki: in std_logic;
		valid: in std_logic;
		stall: out std_logic;
		dri: in std_logic_vector(dr_width - 1 downto 0)
	);
end clk2ncl_fifo_dr;

architecture Behavioural of clk2ncl_fifo_dr is
	attribute NCL_WIRE_TYPE : string;
	attribute HLUTNM        : string;
	attribute DONT_TOUCH    : boolean;
	attribute ASYNC_REG     : boolean;
	
	signal empty, full : std_logic;
	
	type buf_t is array (0 to 3) of std_logic_vector(dr_width - 1 downto 0);
	signal buf : buf_t;
	
	signal d_r, do_0m, do_1m : std_logic_vector(dr_width - 1 downto 0);
	
	signal w_ptr, r_ptr : std_logic_vector(1 downto 0);
	signal sync_meta, sync_stable : std_logic_vector(1 downto 0);
	
	signal stall_int : std_logic;
	
	attribute ASYNC_REG of sync_meta   : signal is true;
	attribute ASYNC_REG of sync_stable : signal is true;
begin

	dro_0 <= do_0m;
	dro_1 <= do_1m;
	
	stall <= stall_int;
	
	empty <=
		'1' when w_ptr = r_ptr else
		'0';
		
	full <=
		'1' when w_ptr(0) & not w_ptr(1) = sync_stable else
		'0';
		
	stall_int <= full;
	
	d_r <= buf(to_integer(unsigned(r_ptr)));
		 
	di: process(clk) begin
		if rising_edge(clk) then
			if valid = '1' and stall_int = '0' then
				buf(to_integer(unsigned(w_ptr))) <= dri;
			end if;
		end if;
	end process di;
	
	
	handshake_clk: process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				w_ptr <= (others => '0');
			elsif valid = '1' and stall_int = '0' then
				w_ptr <= w_ptr(0) & not w_ptr(1);
			end if;
		end if;
	end process handshake_clk;
	
	handshake_ncl: process(ki, rst) begin
		if rst = '1' then
			r_ptr <= (others => '0');
		elsif falling_edge(ki) then
			r_ptr <= r_ptr(0) & not r_ptr(1);
		end if;
	end process handshake_ncl;

	sync: process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				sync_meta   <= "00";
				sync_stable <= "00";
			else
				sync_meta   <= r_ptr;
				sync_stable <= sync_meta;
			end if;
		end if;
	end process sync;

	encode: for ii in 0 to dr_width - 1 generate
		constant EMPTY_BITS : bit_vector(7 downto 0) := "10101010";
		constant DATA_BITS  : bit_vector(7 downto 0) := "11001100";
		constant KI_BITS    : bit_vector(7 downto 0) := "11110000";
		
		attribute NCL_WIRE_TYPE of d0 : label is "IN_ENC";
		attribute NCL_WIRE_TYPE of d1 : label is "IN_ENC";
		
		attribute HLUTNM of d0 : label is "enc" & integer'image(ii);
		attribute HLUTNM of d1 : label is "enc" & integer'image(ii);
	begin
		d0: LUT3
			generic map (
				INIT => not EMPTY_BITS and KI_BITS and not DATA_BITS
			) port map (
				I0 => empty,
				I1 => d_r(ii),
				I2 => ki,
				
				O => do_0m(ii)
			);
		
		d1: LUT3
			generic map (
				INIT => not EMPTY_BITS and KI_BITS and DATA_BITS
			) port map (
				I0 => empty,
				I1 => d_r(ii),
				I2 => ki,
				
				O => do_1m(ii)
			);
	end generate encode;

	mark_d: for ii in 0 to dr_width - 1 generate
		attribute NCL_WIRE_TYPE of do0_cross : label is "NCL_CLK";
		attribute DONT_TOUCH    of do0_cross : label is true;
		
		attribute NCL_WIRE_TYPE of do1_cross : label is "NCL_CLK";
		attribute DONT_TOUCH    of do1_cross : label is true;
	begin
		do0_cross: LUT1
			generic map (
				INIT => "10"
			) port map (
				I0 => do_0m(ii)
			);
			
		do1_cross: LUT1
			generic map (
				INIT => "10"
			) port map (
				I0 => do_1m(ii)
			);
	end generate;
	
end Behavioural;