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

entity TH22n is
    port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           R : in STD_LOGIC;
           Z : out STD_LOGIC);
end TH22n;

architecture Structural of TH22n is

    signal output : std_logic;

begin

    Z <= output;
    
    NCL_GATE_FB2 : LUT4
    generic map (
        INIT => x"00E8")
    port map (
        O => output,
        I0 => A,
        I1 => B,
        I2 => output,
        I3 => R
    );

end Structural;
