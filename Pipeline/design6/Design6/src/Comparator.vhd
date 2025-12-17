library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Comparator is
    Port ( 
        in1 : in  STD_LOGIC_VECTOR (31 downto 0);
        in2 : in  STD_LOGIC_VECTOR (31 downto 0);
        equal : out  STD_LOGIC
    );
end Comparator;

architecture Behavioral of Comparator is
begin
    equal <= '1' when in1 = in2 else '0';
end Behavioral;