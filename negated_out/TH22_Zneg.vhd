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

entity TH22_Zneg is
    port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           Z : out STD_LOGIC);
end TH22_Zneg;

architecture Structural of TH22_Zneg is

    signal output : std_logic;

begin

    Z <= transport output after 1 ns;
    
    NCL_GATE_FB2 : LUT3
    generic map (
        INIT => X"71")
    port map (
        O => output,
        I0 => A,
        I1 => B,
        I2 => output
    );

end Structural;
