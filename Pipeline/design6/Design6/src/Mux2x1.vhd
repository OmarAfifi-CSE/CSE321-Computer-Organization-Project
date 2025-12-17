library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux2x1 is
    Port ( 
        sel : in  STD_LOGIC;
        in0 : in  STD_LOGIC_VECTOR (31 downto 0);
        in1 : in  STD_LOGIC_VECTOR (31 downto 0);
        output : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end Mux2x1;

architecture Behavioral of Mux2x1 is
begin
    output <= in0 when sel = '0' else in1;
end Behavioral;