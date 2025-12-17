library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HazardDetectionUnit is
    Port ( 
 
        id_ex_mem_read : in STD_LOGIC;               
        id_ex_rt : in STD_LOGIC_VECTOR(4 downto 0);   
        
        if_id_rs : in STD_LOGIC_VECTOR(4 downto 0);   
        if_id_rt : in STD_LOGIC_VECTOR(4 downto 0);  
        
      
        pc_write : out STD_LOGIC;        
        if_id_write : out STD_LOGIC;     
        mux_hazard : out STD_LOGIC      
    );
end HazardDetectionUnit;

architecture Behavioral of HazardDetectionUnit is
begin
    process(id_ex_mem_read, id_ex_rt, if_id_rs, if_id_rt)
    begin
 
        if (id_ex_mem_read = '1' and 
           ((id_ex_rt = if_id_rs) or (id_ex_rt = if_id_rt))) then
            
            -- Stall Detected!  
            pc_write <= '0';       
            if_id_write <= '0';     
            mux_hazard <= '1';      
            
        else
            -- No Hazard  
            pc_write <= '1';         
            if_id_write <= '1';     
            mux_hazard <= '0';       
        end if;
    end process;
end Behavioral;