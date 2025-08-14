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

entity TH44w322n is
    port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           C : in STD_LOGIC;
           D : in STD_LOGIC;
           R : in STD_LOGIC;
           Z : out STD_LOGIC);
end TH44w322n;

architecture Structural of TH44w322n is

    signal output : std_logic;

begin

    Z <= transport output after 1 ns;
    
    NCL_GATE_FB4 : LUT6
    generic map (
        INIT => X"00000000FFFEEAE8")
    port map (
        O => output,
        I0 => A,
        I1 => B,
        I2 => C,
        I3 => D,
        I4 => output,
        I5 => R
    );

end Structural;
