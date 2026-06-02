library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;

library UNISIM;
use UNISIM.VComponents.all;

entity clk2ncl_fnull_dr is
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
end clk2ncl_fnull_dr;

architecture Behavioural of clk2ncl_fnull_dr is
	attribute NCL_WIRE_TYPE : string;
	attribute HLUTNM        : string;
	attribute DONT_TOUCH    : boolean;
	attribute ASYNC_REG     : boolean;

	signal d_r, do_0m, do_1m : std_logic_vector(dr_width - 1 downto 0);
	
	signal written, read : std_logic;
	signal sync_meta, sync_stable : std_logic;
	
	signal stall_int : std_logic;
	
	attribute ASYNC_REG of sync_meta   : signal is true;
	attribute ASYNC_REG of sync_stable : signal is true;
begin

	dro_0 <= do_0m;
	dro_1 <= do_1m;
	
	stall <= stall_int;
	
	stall_int <= written xor sync_stable;
	
	handshake_ncl: process(ki, rst) begin
		if rst = '1' then
			read <= '0';
		elsif falling_edge(ki) then
			read <= not read;
		end if;
	end process handshake_ncl;
	
	handshake_clk: process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				written <= '0';
			elsif valid = '1' and stall_int = '0' then
				written <= not written;
			end if;
		end if;
	end process handshake_clk;
	
	di: process(clk) begin
		if rising_edge(clk) then
			if valid = '1' and stall_int = '0' then
				d_r <= dri;
			end if;
		end if;
	end process di;

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
	
	encode: for ii in 0 to dr_width - 1 generate
		constant WRITTEN_BITS : bit_vector(15 downto 0) := "1010101010101010";
		constant DATA_BITS    : bit_vector(15 downto 0) := "1100110011001100";
		constant READ_BITS    : bit_vector(15 downto 0) := "1111000011110000";
		constant KI_BITS      : bit_vector(15 downto 0) := "1111111100000000";
		
		attribute NCL_WIRE_TYPE of d0 : label is "IN_ENC";
		attribute NCL_WIRE_TYPE of d1 : label is "IN_ENC";
		
		attribute HLUTNM of d0 : label is "enc" & integer'image(ii);
		attribute HLUTNM of d1 : label is "enc" & integer'image(ii);
	begin
		d0: LUT4
			generic map (
				INIT => KI_BITS and (READ_BITS xor WRITTEN_BITS) and not DATA_BITS
			) port map (
				I0 => written,
				I1 => d_r(ii),
				I2 => read,
				I3 => ki,
				
				O => do_0m(ii)
			);
		
		d1: LUT4
			generic map (
				INIT => KI_BITS and (READ_BITS xor WRITTEN_BITS) and DATA_BITS
			) port map (
				I0 => written,
				I1 => d_r(ii),
				I2 => read,
				I3 => ki,
				
				O => do_1m(ii)
			);
	end generate encode;
	
	sync: process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
				sync_meta   <= '0';
				sync_stable <= '0';
			else
				sync_meta   <= read;
				sync_stable <= sync_meta;
			end if;
		end if;
	end process sync;
	
end Behavioural;