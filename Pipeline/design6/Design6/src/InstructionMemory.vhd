library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionMemory is
    Port ( 
        address : in  STD_LOGIC_VECTOR (31 downto 0);
        instruction : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end InstructionMemory;

architecture Behavioral of InstructionMemory is

    type memory_type is array (0 to 255) of STD_LOGIC_VECTOR(7 downto 0);
    
    signal RAM : memory_type := (
        -- ==========================================================
        -- 1. Data Setup
        -- ==========================================================
        -- Address 0: addi $1, $0, 10   -> $1 = 10
        0 => x"20", 1 => x"01", 2 => x"00", 3 => x"0A",
        
        -- Address 4: sw $1, 0($0)      -> Mem[0] = 10 (Store to memory for Load test)
        4 => x"AC", 5 => x"01", 6 => x"00", 7 => x"00",

        -- ==========================================================
        -- 2. Test Load Hazard (Load-Use Stall)
        -- ==========================================================
        -- Address 8: lw $2, 0($0)      -> $2 = 10 (Takes time to read from Mem)
        8 => x"8C", 9 => x"02", 10 => x"00", 11 => x"00",

        -- Address 12: add $3, $2, $1   -> $3 = 10 + 10 = 20
        -- (Hazard: Needs $2 immediately while LW is still in MEM stage)
        -- Expected: 1 Stall cycle, then Forwarding from WB to EX.
        12 => x"00", 13 => x"41", 14 => x"18", 15 => x"20",

        -- ==========================================================
        -- 3. Test Execute Hazard (Forwarding)
        -- ==========================================================
        -- Address 16: add $4, $1, $1   -> $4 = 10 + 10 = 20 (Producer)
        16 => x"00", 17 => x"21", 18 => x"20", 19 => x"20",

        -- Address 20: sub $5, $4, $1   -> $5 = 20 - 10 = 10 (Consumer)
        -- (Hazard: Needs $4 while it is still in EX stage)
        -- Expected: Forwarding from EX/MEM to EX (No Stall).
        20 => x"00", 21 => x"81", 22 => x"28", 23 => x"22",

        -- ==========================================================
        -- 4. Test Branch 1 (Safe with NOPs)
        -- ==========================================================
        -- NOP 1
        24 => x"00", 25 => x"00", 26 => x"00", 27 => x"00",
        -- NOP 2
        28 => x"00", 29 => x"00", 30 => x"00", 31 => x"00",

        -- Address 32: beq $1, $1, 2    (Taken)
        -- Is 10 == 10? Yes. Jump and skip 2 instructions.
        -- Target = PC+4 + (2*4) = 36 + 8 = Address 44
        32 => x"10", 33 => x"21", 34 => x"00", 35 => x"02",

        -- Address 36: addi $6, $0, 99  (Should be SKIPPED / FLUSHED)
        36 => x"20", 37 => x"06", 38 => x"00", 39 => x"63",

        -- Address 40: addi $7, $0, 99  (Should be SKIPPED / FLUSHED)
        40 => x"20", 41 => x"07", 42 => x"00", 43 => x"63",

        -- Address 44: addi $8, $0, 50  (Branch Target) -> $8 = 50
        44 => x"20", 45 => x"08", 46 => x"00", 47 => x"32",

        -- ==========================================================
        -- 5. Test JUMP (NEW) - With NOPs before it
        -- ==========================================================
        -- Address 48: NOP (Wait/Settle)
        48 => x"00", 49 => x"00", 50 => x"00", 51 => x"00",
        
        -- Address 52: NOP (Wait/Settle)
        52 => x"00", 53 => x"00", 54 => x"00", 55 => x"00",

        -- Address 56: J 18 (Jump to Address 72) 
        -- Calculation: 72 / 4 = 18. Hex: 0x12. Opcode J=2. 
        -- Binary: 000010 00000000000000000000010010 -> 08000012
        56 => x"08", 57 => x"00", 58 => x"00", 59 => x"12",

        -- Address 60: addi $9, $0, 66 (Should be SKIPPED by Jump)
        60 => x"20", 61 => x"09", 62 => x"00", 63 => x"42",

        -- Address 64: addi $9, $0, 66 (Should be SKIPPED by Jump)
        64 => x"20", 65 => x"09", 66 => x"00", 67 => x"42",
        
        -- Address 68: NOP (Just padding)
        68 => x"00", 69 => x"00", 70 => x"00", 71 => x"00",

        -- Address 72: addi $9, $0, 77 (Jump Target) -> $9 = 77
        -- This proves Jump worked!
        72 => x"20", 73 => x"09", 74 => x"00", 75 => x"4D",

        -- ==========================================================
        -- 6. Test Branch 2 (NEW) - With NOPs before it
        -- ==========================================================
        -- Address 76: NOP
        76 => x"00", 77 => x"00", 78 => x"00", 79 => x"00",

        -- Address 80: NOP
        80 => x"00", 81 => x"00", 82 => x"00", 83 => x"00",

        -- Address 84: beq $8, $8, 2 (Check if 50 == 50) -> Taken
        -- Target = PC+4 + (2*4) = 88 + 8 = Address 96
        84 => x"11", 85 => x"08", 86 => x"00", 87 => x"02",

        -- Address 88: addi $10, $0, 88 (Should be SKIPPED)
        88 => x"20", 89 => x"0A", 90 => x"00", 91 => x"58",

        -- Address 92: addi $10, $0, 99 (Should be SKIPPED)
        92 => x"20", 93 => x"0A", 94 => x"00", 95 => x"63",

        -- Address 96: addi $10, $0, 100 (Branch Target) -> $10 = 100
        -- This proves Branch 2 worked!
        96 => x"20", 97 => x"0A", 98 => x"00", 99 => x"64",

        others => x"00" 
    );
begin
    process(address)
        variable addr_int : integer;
    begin
        addr_int := to_integer(unsigned(address));
        
        -- Check address bounds (Updated to 252 to be safe)
        if addr_int >= 0 and addr_int <= 252 then 
            instruction <= RAM(addr_int) & RAM(addr_int+1) & RAM(addr_int+2) & RAM(addr_int+3);
        else
            instruction <= (others => '0');
        end if;
    end process;
end Behavioral;