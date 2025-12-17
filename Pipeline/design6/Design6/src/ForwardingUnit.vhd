library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ForwardingUnit is
    Port ( 
 
        id_ex_rs : in STD_LOGIC_VECTOR(4 downto 0);
        id_ex_rt : in STD_LOGIC_VECTOR(4 downto 0);
        
 
        ex_mem_rd : in STD_LOGIC_VECTOR(4 downto 0);
        ex_mem_reg_write : in STD_LOGIC; 
        
        mem_wb_rd : in STD_LOGIC_VECTOR(4 downto 0);
        mem_wb_reg_write : in STD_LOGIC;
 
        forward_a : out STD_LOGIC_VECTOR(1 downto 0);
        forward_b : out STD_LOGIC_VECTOR(1 downto 0)
    );
end ForwardingUnit;

architecture Behavioral of ForwardingUnit is
begin
    process(id_ex_rs, id_ex_rt, ex_mem_rd, ex_mem_reg_write, mem_wb_rd, mem_wb_reg_write)
    begin
        forward_a <= "00";
        forward_b <= "00";
        
        
        -- (EX Hazard)

        if (ex_mem_reg_write = '1' and ex_mem_rd /= "00000" and ex_mem_rd = id_ex_rs) then
            forward_a <= "10";
            
        -- (MEM Hazard)
        elsif (mem_wb_reg_write = '1' and mem_wb_rd /= "00000" and mem_wb_rd = id_ex_rs) then
            forward_a <= "01";
        end if;
		
		
        if (ex_mem_reg_write = '1' and ex_mem_rd /= "00000" and ex_mem_rd = id_ex_rt) then
            forward_b <= "10";
            
        elsif (mem_wb_reg_write = '1' and mem_wb_rd /= "00000" and mem_wb_rd = id_ex_rt) then
            forward_b <= "01";
        end if;
        
    end process;
end Behavioral;