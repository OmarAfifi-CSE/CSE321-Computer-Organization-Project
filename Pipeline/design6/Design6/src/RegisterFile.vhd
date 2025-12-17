library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterFile is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           reg_write : in STD_LOGIC;
           read_reg1 : in STD_LOGIC_VECTOR (4 downto 0);
           read_reg2 : in STD_LOGIC_VECTOR (4 downto 0);
           write_reg : in STD_LOGIC_VECTOR (4 downto 0);
           write_data : in STD_LOGIC_VECTOR (31 downto 0);
           read_data1 : out STD_LOGIC_VECTOR (31 downto 0);
           read_data2 : out STD_LOGIC_VECTOR (31 downto 0));
end RegisterFile;

architecture Behavioral of RegisterFile is
    type reg_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal registers : reg_array := (others => (others => '0'));
begin

     process(clk, rst)
    begin
        if rst = '1' then
            registers <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if reg_write = '1' and write_reg /= "00000" then
                registers(to_integer(unsigned(write_reg))) <= write_data;
            end if;
        end if;
    end process;

    -- Internal Forwarding Logic:
 
    process(read_reg1, write_reg, reg_write, write_data, registers)
    begin
        if (read_reg1 = write_reg) and (reg_write = '1') and (write_reg /= "00000") then
            read_data1 <= write_data;  -- Bypass 
        else
            read_data1 <= registers(to_integer(unsigned(read_reg1)));  
        end if;
    end process;

    process(read_reg2, write_reg, reg_write, write_data, registers)
    begin
        if (read_reg2 = write_reg) and (reg_write = '1') and (write_reg /= "00000") then
            read_data2 <= write_data;  -- Bypass 
        else
            read_data2 <= registers(to_integer(unsigned(read_reg2)));  
        end if;
    end process;

end Behavioral;