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

entity TH54w22 is
    port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           C : in STD_LOGIC;
           D : in STD_LOGIC;
           Z : out STD_LOGIC);
end TH54w22;

architecture Structural of TH54w22 is

    signal output : std_logic;

begin

    Z <= output;
    
    NCL_GATE_FB4 : LUT5
    generic map (
        INIT => X"FFFE8880")
    port map (
        O => output,
        I0 => A,
        I1 => B,
        I2 => C,
        I3 => D,
        I4 => output
    );

end Structural;