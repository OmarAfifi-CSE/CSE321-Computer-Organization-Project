library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux4x1 is
    Port ( 
        sel : in  STD_LOGIC_VECTOR (1 downto 0);
        in0 : in  STD_LOGIC_VECTOR (31 downto 0); -- (00) Original from RegFile
        in1 : in  STD_LOGIC_VECTOR (31 downto 0); -- (01) Forward form MEM/WB
        in2 : in  STD_LOGIC_VECTOR (31 downto 0); -- (10) Forward from EX/MEM
        in3 : in  STD_LOGIC_VECTOR (31 downto 0); -- (11) Not used
        output : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end Mux4x1;

architecture Behavioral of Mux4x1 is
begin
    with sel select
        output <= in0 when "00",
                  in1 when "01",
                  in2 when "10",
                  (others => '0') when others;
end Behavioral;	