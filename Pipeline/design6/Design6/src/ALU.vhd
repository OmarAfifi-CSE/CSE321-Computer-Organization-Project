library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( 
        A : in  STD_LOGIC_VECTOR (31 downto 0);
        B : in  STD_LOGIC_VECTOR (31 downto 0);
        ALU_Control : in  STD_LOGIC_VECTOR (3 downto 0); -- 4-bit Control
        ALU_Result : out  STD_LOGIC_VECTOR (31 downto 0);
        Zero : out  STD_LOGIC
    );
end ALU;

architecture Behavioral of ALU is
    signal result : STD_LOGIC_VECTOR (31 downto 0);
begin
    process(A, B, ALU_Control)
    begin
        case ALU_Control is
            when "0010" => result <= A + B;       -- Add
            when "0110" => result <= A - B;       -- Subtract
            when "0000" => result <= A AND B;     -- AND
            when "0001" => result <= A OR B;      -- OR
            when "0111" => -- SLT (Set on Less Than)
                if A < B then result <= x"00000001";
                else result <= x"00000000";
                end if;
            when "1100" => result <= A NOR B;     -- NOR (Optional)
            when others => result <= (others => '0');
        end case;
    end process;

    ALU_Result <= result;
    Zero <= '1' when result = x"00000000" else '0';
end Behavioral;