library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ControlUnit is
    Port ( 
        Opcode : in  STD_LOGIC_VECTOR (5 downto 0);
        
        -- EX Stage Signals
        RegDst   : out STD_LOGIC;
        ALUSrc   : out STD_LOGIC;
        ALUOp    : out STD_LOGIC_VECTOR (1 downto 0); 
        
        -- MEM Stage Signals
        Branch   : out STD_LOGIC;
        MemRead  : out STD_LOGIC;
        MemWrite : out STD_LOGIC;
        
        -- WB Stage Signals
        RegWrite : out STD_LOGIC;
        MemtoReg : out STD_LOGIC;
		
        Jump     : out STD_LOGIC 
    );
end ControlUnit;

architecture Behavioral of ControlUnit is
begin
    process(Opcode)
    begin
        -- Default Values (Reset signals to 0 to avoid latches)
        RegDst <= '0'; ALUSrc <= '0'; ALUOp <= "00";
        Branch <= '0'; MemRead <= '0'; MemWrite <= '0';
        RegWrite <= '0'; MemtoReg <= '0';
        
        Jump <= '0'; 

        case Opcode is
            -- R-Type Instruction (Opcode = 000000)
            when "000000" => 
                RegDst <= '1';
                RegWrite <= '1';
                ALUOp <= "10"; 

            -- lw Instruction (Opcode = 100011 -> 35 decimal)
            when "100011" => 
                ALUSrc <= '1';
                MemtoReg <= '1';
                RegWrite <= '1';
                MemRead <= '1';
                ALUOp <= "00"; 

            -- sw Instruction (Opcode = 101011 -> 43 decimal)
            when "101011" => 
                ALUSrc <= '1';
                MemWrite <= '1';
                ALUOp <= "00"; 

            -- beq Instruction (Opcode = 000100 -> 4 decimal)
            when "000100" => 
                Branch <= '1';
                ALUOp <= "01"; 
                
            -- addi Instruction (Opcode = 001000 -> 8 decimal)
            when "001000" => 
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "00"; 

            -- Jump Instruction (Opcode = 000010 -> 2 decimal)
            when "000010" => 
                Jump <= '1';

            when others => 
                -- NOP signals
                null;
        end case;
    end process;
end Behavioral;