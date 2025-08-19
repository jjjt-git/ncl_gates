----------------------------------------------------------------------------------
-- Exploring Implementations of Null Convention Logic on FPGAs
-- (c) Henry Mueller 2024
-- This work is licensed under GPLv3.
-- File Part of Development Release 0.1.0
----------------------------------------------------------------------------------

library IEEE;
library ncl_gates;

use IEEE.STD_LOGIC_1164.ALL;

entity completion_unit is
Generic ( bit_width : integer := 1);
port ( input: in std_logic_vector (2*bit_width-1 downto 0);
       Ko : out std_logic);
end completion_unit;

architecture Structural of completion_unit is
    
    signal single_completion : std_logic_vector (bit_width-1 downto 0);
    signal single_completion_negated : std_logic_vector (bit_width-1 downto 0);
    
begin

    single_completion_chain: for i in bit_width-1 downto 0 generate
        single_completion_gate : entity ncl_gates.TH12 port map (
            A => input(2*i+1),
            B => input(2*i),
            Z => single_completion(i)
        );
    end generate;
    
    single_completion_negated <= not single_completion;
    
    completion_recursion : entity ncl_gates.NCL_completion_recursion_unit
    generic map ( width => bit_width )
    port map (  vector_input => single_completion_negated,
                result_output => Ko );

end Structural;
