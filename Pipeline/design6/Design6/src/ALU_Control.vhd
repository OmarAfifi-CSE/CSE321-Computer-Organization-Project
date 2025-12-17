library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU_Control is
    Port ( 
        ALUOp : in  STD_LOGIC_VECTOR (1 downto 0);
        Funct : in  STD_LOGIC_VECTOR (5 downto 0);
        ALU_Control_Out : out  STD_LOGIC_VECTOR (3 downto 0)
    );
end ALU_Control;

architecture Behavioral of ALU_Control is
begin
    process(ALUOp, Funct)
    begin
        case ALUOp is
            when "00" => 
                ALU_Control_Out <= "0010"; -- Add
                
            when "01" => 
                ALU_Control_Out <= "0110"; -- Subtract

            when "10" => 
                case Funct is
                    when "100000" => ALU_Control_Out <= "0010"; -- add
                    when "100010" => ALU_Control_Out <= "0110"; -- sub
                    when "100100" => ALU_Control_Out <= "0000"; -- and
                    when "100101" => ALU_Control_Out <= "0001"; -- or
                    when "101010" => ALU_Control_Out <= "0111"; -- slt
                    when others => ALU_Control_Out <= "0000";
                end case;
                
            when others => ALU_Control_Out <= "0000";
        end case;
    end process;
end Behavioral;