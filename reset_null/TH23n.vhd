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

entity TH23n is
    port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           C : in STD_LOGIC;
           R : in STD_LOGIC;
           Z : out STD_LOGIC);
end TH23n;

architecture Structural of TH23n is

    signal output : std_logic;

begin

    Z <= output;
    
    NCL_GATE_FB3 : LUT5
    generic map (
        INIT => X"0000FEE8")
    port map (
        O => output,
        I0 => A,
        I1 => B,
        I2 => C,
        I3 => output,
        I4 => R
    );

end Structural;
