library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MIPS_TB is

end MIPS_TB;

architecture Behavioral of MIPS_TB is

    component MIPS_TopLevel
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC );
    end component;

    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    
    --  (Clock Period)
    constant clk_period : time := 10 ns;

begin

    uut: MIPS_TopLevel port map (
        clk => clk,
        rst => rst
    );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin		

        rst <= '1';
        wait for 20 ns;	
        rst <= '0';
        

        wait for 200 ns;

        wait;
    end process;

end Behavioral;