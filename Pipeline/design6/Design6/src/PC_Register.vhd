library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PC_Register is
    Port ( 
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        PC_Write : in STD_LOGIC; -- To freeze PC during hazards (Stall)
        pc_in : in  STD_LOGIC_VECTOR (31 downto 0);
        pc_out : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end PC_Register;

architecture Behavioral of PC_Register is
    signal current_pc : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            current_pc <= (others => '0');
        elsif rising_edge(clk) then
            if PC_Write = '1' then -- Only update if Hazard Unit allows
                current_pc <= pc_in;
            end if;
        end if;
    end process;

    pc_out <= current_pc;
end Behavioral;