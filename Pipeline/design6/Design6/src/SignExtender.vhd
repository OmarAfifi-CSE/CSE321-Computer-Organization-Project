library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SignExtender is
    Port ( 
        input_16 : in  STD_LOGIC_VECTOR (15 downto 0);
        output_32 : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end SignExtender;

architecture Behavioral of SignExtender is
begin
	
    output_32 <= x"FFFF" & input_16 when input_16(15) = '1' else 
                 x"0000" & input_16;
end Behavioral;