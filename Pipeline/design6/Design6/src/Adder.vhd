library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Adder is
    Port ( 
        in0 : in  STD_LOGIC_VECTOR (31 downto 0);
        in1 : in  STD_LOGIC_VECTOR (31 downto 0);
        output : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end Adder;

architecture Behavioral of Adder is
begin
    output <= in0 + in1;
end Behavioral;