library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IF_ID_Register is
    Port ( 
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        flush : in STD_LOGIC;     
        write_en : in STD_LOGIC;   
        
  
        pc_plus4_in : in  STD_LOGIC_VECTOR (31 downto 0);
        instruction_in : in  STD_LOGIC_VECTOR (31 downto 0);
        

        pc_plus4_out : out  STD_LOGIC_VECTOR (31 downto 0);
        instruction_out : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end IF_ID_Register;

architecture Behavioral of IF_ID_Register is

    signal pc_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal instr_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin

    process(clk, rst)
    begin
        if rst = '1' then
            pc_reg <= (others => '0');
            instr_reg <= (others => '0');
            
        elsif rising_edge(clk) then

            if flush = '1' then
                pc_reg <= (others => '0');
                instr_reg <= (others => '0'); -- NOP Instruction
                

            elsif write_en = '1' then
                pc_reg <= pc_plus4_in;
                instr_reg <= instruction_in;
            end if;
        
        end if;
    end process;

    pc_plus4_out <= pc_reg;
    instruction_out <= instr_reg;

end Behavioral;