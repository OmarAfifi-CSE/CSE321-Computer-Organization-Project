library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataMemory is
    Port ( 
        clk : in STD_LOGIC;
        address : in  STD_LOGIC_VECTOR (31 downto 0); 
        write_data : in  STD_LOGIC_VECTOR (31 downto 0); 
        mem_write : in  STD_LOGIC;
        mem_read : in  STD_LOGIC;
        read_data : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end DataMemory;

architecture Behavioral of DataMemory is
 
    type ram_type is array (0 to 255) of STD_LOGIC_VECTOR(7 downto 0);
    signal RAM : ram_type := (others => x"00");
begin

    process(clk)
        variable addr_int : integer;
    begin
        if rising_edge(clk) then
            if mem_write = '1' then
                addr_int := to_integer(unsigned(address));
                if addr_int <= 252 then
                    -- Big Endian Write
                    RAM(addr_int)   <= write_data(31 downto 24);
                    RAM(addr_int+1) <= write_data(23 downto 16);
                    RAM(addr_int+2) <= write_data(15 downto 8);
                    RAM(addr_int+3) <= write_data(7 downto 0);
                end if;
            end if;
        end if;
    end process;

    process(mem_read, address, RAM)
        variable addr_int : integer;
    begin
        if mem_read = '1' then
            addr_int := to_integer(unsigned(address));
            if addr_int <= 252 then
                -- Big Endian Read
                read_data <= RAM(addr_int) & RAM(addr_int+1) & RAM(addr_int+2) & RAM(addr_int+3);
            else
                read_data <= (others => '0');
            end if;
        else
            read_data <= (others => '0');
        end if;
    end process;

end Behavioral;