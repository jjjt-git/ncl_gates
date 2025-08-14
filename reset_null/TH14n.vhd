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

entity TH14n is
    port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           C : in STD_LOGIC;
           D : in STD_LOGIC;
           R : in STD_LOGIC;
           Z : out STD_LOGIC);
end TH14n;

architecture Structural of TH14n is

    signal output : std_logic;

begin

    Z <= transport output after 1 ns;
    
    NCL_GATE : LUT5
    generic map (
        INIT => X"0000FFFE")
    port map (
        O => output,
        I0 => A,
        I1 => B,
        I2 => C,
        I3 => D,
        I4 => R
    );

end Structural;
