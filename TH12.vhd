----------------------------------------------------------------------------------
-- Exploring Implementations of Null Convention Logic on FPGAs
-- (c) Henry Mueller 2024
-- This work is licensed under GPLv3.
-- File Part of Development Release 0.1.0
----------------------------------------------------------------------------------

library IEEE;
library UNISIM;

use IEEE.STD_LOGIC_1164.ALL;
use UNISIM.VComponents.all;

entity TH12 is
    port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           Z : out STD_LOGIC);
end TH12;

architecture Structural of TH12 is

    signal output : std_logic;

begin

    Z <= output;
    
    NCL_GATE : LUT2
    generic map (
        INIT => X"E")
    port map (
        O => output,
        I0 => A,
        I1 => B
    );

end Structural;
