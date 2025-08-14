----------------------------------------------------------------------------------
-- Exploring Implementations of Null Convention Logic on FPGAs
-- (c) Henry Mueller 2024
-- This work is licensed under GPLv3.

-- File Part of Development Release 0.1.0
----------------------------------------------------------------------------------

library IEEE;
library ncl_xilinx_gates;

use IEEE.STD_LOGIC_1164.ALL;

entity NCL_completion_recursion_unit is
generic( width : integer := 1);
port (  vector_input : in std_logic_vector (width-1 downto 0);
        result_output : out std_logic
);
end NCL_completion_recursion_unit;

architecture Structural of NCL_completion_recursion_unit is

    signal intermediate_signal : std_logic_vector ((width/4) downto 0);

begin

    complete_4 : if width = 4 generate 
        single_gate : entity ncl_xilinx_gates.TH44 port map (A => vector_input(3), B => vector_input(2), C => vector_input(1), D => vector_input(0), Z => result_output);
    end generate;
        
    complete_3 : if width = 3 generate 
        single_gate : entity ncl_xilinx_gates.TH33 port map (A => vector_input(2), B => vector_input(1), C => vector_input(0), Z => result_output);
    end generate;
    
    complete_2 : if width = 2 generate 
        single_gate : entity ncl_xilinx_gates.TH22 port map (A => vector_input(1), B => vector_input(0), Z => result_output);
    end generate;
    
    complete_1 : if width = 1 generate 
        result_output <= vector_input(0);
    end generate;    
    
    continue_recursion : if (width > 4) generate
     
        four_input_gates : for i in (width/4) downto 1 generate
            unit: entity ncl_xilinx_gates.TH44 port map (   A => vector_input( width-( ((width/4)-i)*4 )-1), 
                                                            B => vector_input( width-( ((width/4)-i)*4 )-2), 
                                                            C => vector_input( width-( ((width/4)-i)*4 )-3), 
                                                            D => vector_input( width-( ((width/4)-i)*4 )-4), 
                                                            Z => intermediate_signal(i));
        end generate;
        
        -- ----------
            
        three_input_remainder_gate: if (width mod 4 = 3) generate
            three_input_unit: entity ncl_xilinx_gates.TH33 port map (  A => vector_input(2), 
                                                                       B => vector_input(1), 
                                                                       C => vector_input(0),
                                                                       Z => intermediate_signal(0));
        end generate;
        
        two_input_remainder_gate: if (width mod 4 = 2) generate
            two_input_unit: entity ncl_xilinx_gates.TH22 port map (   A => vector_input(1), 
                                                                       B => vector_input(0),
                                                                       Z => intermediate_signal(0));
        end generate;
        
        one_input_remainder_gate: if (width mod 4 = 1) generate
            intermediate_signal(0) <= vector_input(0);
        end generate;    
            
        -- ----------
        
        recursion_with_remainer : if (width mod 4 /= 0) generate    
            recursive_unit: entity ncl_xilinx_gates.NCL_completion_recursion_unit 
                    generic map ( width => width/4+1 )
                    port map (  vector_input => intermediate_signal,
                                result_output => result_output );
        end generate;
        
        recursion_no_remainer: if (width mod 4 = 0) generate                    
        recursive_unit: entity ncl_xilinx_gates.NCL_completion_recursion_unit 
                generic map ( width => width/4 )
                port map (  vector_input => intermediate_signal((width/4) downto 1),
                            result_output => result_output );
        end generate;                    
        
    end generate;
    
    
end Structural;
