library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity EX_MEM_Register is
    Port ( 
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        
        -- Control Signals (Input)
        wb_reg_write_in : in STD_LOGIC;
        wb_mem_to_reg_in : in STD_LOGIC;
        mem_read_in : in STD_LOGIC;
        mem_write_in : in STD_LOGIC;
        
        -- Data Inputs (From Execute Stage)
        alu_result_in : in STD_LOGIC_VECTOR(31 downto 0);
        write_data_in : in STD_LOGIC_VECTOR(31 downto 0);  
        write_reg_addr_in : in STD_LOGIC_VECTOR(4 downto 0);  
        
        -- Outputs (To Memory Stage)
        wb_reg_write_out : out STD_LOGIC;
        wb_mem_to_reg_out : out STD_LOGIC;
        mem_read_out : out STD_LOGIC;
        mem_write_out : out STD_LOGIC;
        
        alu_result_out : out STD_LOGIC_VECTOR(31 downto 0);
        write_data_out : out STD_LOGIC_VECTOR(31 downto 0);
        write_reg_addr_out : out STD_LOGIC_VECTOR(4 downto 0)
    );
end EX_MEM_Register;

architecture Behavioral of EX_MEM_Register is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            wb_reg_write_out <= '0'; wb_mem_to_reg_out <= '0';
            mem_read_out <= '0'; mem_write_out <= '0';
            alu_result_out <= (others => '0');
            write_data_out <= (others => '0');
            write_reg_addr_out <= (others => '0');
        elsif rising_edge(clk) then
            -- Pass Data
            wb_reg_write_out <= wb_reg_write_in;
            wb_mem_to_reg_out <= wb_mem_to_reg_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            
            alu_result_out <= alu_result_in;
            write_data_out <= write_data_in;
            write_reg_addr_out <= write_reg_addr_in;
        end if;
    end process;
end Behavioral;