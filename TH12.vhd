----------------------------------------------------------------------------------
-- Exploring Implementations of Null Convention Logic on FPGAs
-- (c) Henry Mueller 2024
-- (c) Jacob Tilger 2025
-- This work is licensed under GPLv3.
-- File Part of Development Release 0.2.0
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

    Z <= A or B;

end Structural;
