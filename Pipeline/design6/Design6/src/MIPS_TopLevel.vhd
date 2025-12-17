library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPS_TopLevel is
    Port ( 
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC
    );
end MIPS_TopLevel;

architecture Behavioral of MIPS_TopLevel is

    -- 1. Component Declarations
   
    component PC_Register
        Port ( clk, rst, PC_Write : in STD_LOGIC;
               pc_in : in STD_LOGIC_VECTOR(31 downto 0);
               pc_out : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component Adder
        Port ( in0, in1 : in STD_LOGIC_VECTOR(31 downto 0);
               output : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component Mux2x1
        Port ( sel : in STD_LOGIC;
               in0, in1 : in STD_LOGIC_VECTOR(31 downto 0);
               output : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component InstructionMemory
        Port ( address : in STD_LOGIC_VECTOR(31 downto 0);
               instruction : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component IF_ID_Register
        Port ( clk, rst, flush, write_en : in STD_LOGIC;
               pc_plus4_in, instruction_in : in STD_LOGIC_VECTOR(31 downto 0);
               pc_plus4_out, instruction_out : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component ControlUnit
        Port ( Opcode : in STD_LOGIC_VECTOR(5 downto 0);
               RegDst, ALUSrc : out STD_LOGIC;
               ALUOp : out STD_LOGIC_VECTOR(1 downto 0);
               Branch, MemRead, MemWrite, RegWrite, MemtoReg : out STD_LOGIC;
               Jump : out STD_LOGIC);  
    end component;

    component RegisterFile
        Port ( clk, rst, reg_write : in STD_LOGIC;
               read_reg1, read_reg2, write_reg : in STD_LOGIC_VECTOR(4 downto 0);
               write_data : in STD_LOGIC_VECTOR(31 downto 0);
               read_data1, read_data2 : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component SignExtender
        Port ( input_16 : in STD_LOGIC_VECTOR(15 downto 0);
               output_32 : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component Comparator
        Port ( in1, in2 : in STD_LOGIC_VECTOR(31 downto 0);
               equal : out STD_LOGIC);
    end component;
    
    component HazardDetectionUnit
        Port ( 
            id_ex_mem_read : in STD_LOGIC;
            id_ex_rt : in STD_LOGIC_VECTOR(4 downto 0);
            if_id_rs : in STD_LOGIC_VECTOR(4 downto 0);
            if_id_rt : in STD_LOGIC_VECTOR(4 downto 0);
            pc_write : out STD_LOGIC;
            if_id_write : out STD_LOGIC;
            mux_hazard : out STD_LOGIC
        );
    end component;

    component ForwardingUnit
        Port (
            id_ex_rs : in STD_LOGIC_VECTOR(4 downto 0);
            id_ex_rt : in STD_LOGIC_VECTOR(4 downto 0);
            ex_mem_rd : in STD_LOGIC_VECTOR(4 downto 0);
            mem_wb_rd : in STD_LOGIC_VECTOR(4 downto 0);
            ex_mem_reg_write : in STD_LOGIC;
            mem_wb_reg_write : in STD_LOGIC;
            forward_a : out STD_LOGIC_VECTOR(1 downto 0);
            forward_b : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    component ID_EX_Register
        Port ( 
            clk, rst : in STD_LOGIC;
            wb_reg_write_in, wb_mem_to_reg_in : in STD_LOGIC;
            mem_read_in, mem_write_in : in STD_LOGIC;
            ex_reg_dst_in, ex_alu_src_in : in STD_LOGIC;
            ex_alu_op_in : in STD_LOGIC_VECTOR(1 downto 0);
            pc_plus4_in, read_data1_in, read_data2_in, sign_ext_imm_in : in STD_LOGIC_VECTOR(31 downto 0);
            rs_addr_in, rt_addr_in, rd_addr_in : in STD_LOGIC_VECTOR(4 downto 0);
            
            wb_reg_write_out, wb_mem_to_reg_out : out STD_LOGIC;
            mem_read_out, mem_write_out : out STD_LOGIC;
            ex_reg_dst_out, ex_alu_src_out : out STD_LOGIC;
            ex_alu_op_out : out STD_LOGIC_VECTOR(1 downto 0);
            pc_plus4_out, read_data1_out, read_data2_out, sign_ext_imm_out : out STD_LOGIC_VECTOR(31 downto 0);
            rs_addr_out, rt_addr_out, rd_addr_out : out STD_LOGIC_VECTOR(4 downto 0)
        );
    end component;

    component ALU_Control
        Port ( ALUOp : in STD_LOGIC_VECTOR(1 downto 0);
               Funct : in STD_LOGIC_VECTOR(5 downto 0);
               ALU_Control_Out : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

    component ALU
        Port ( A, B : in STD_LOGIC_VECTOR(31 downto 0);
               ALU_Control : in STD_LOGIC_VECTOR(3 downto 0);
               ALU_Result : out STD_LOGIC_VECTOR(31 downto 0);
               Zero : out STD_LOGIC);
    end component;
    
    component EX_MEM_Register
        Port ( 
            clk, rst : in STD_LOGIC;
            wb_reg_write_in, wb_mem_to_reg_in : in STD_LOGIC;
            mem_read_in, mem_write_in : in STD_LOGIC;
            alu_result_in, write_data_in : in STD_LOGIC_VECTOR(31 downto 0);
            write_reg_addr_in : in STD_LOGIC_VECTOR(4 downto 0);
            
            wb_reg_write_out, wb_mem_to_reg_out : out STD_LOGIC;
            mem_read_out, mem_write_out : out STD_LOGIC;
            alu_result_out, write_data_out : out STD_LOGIC_VECTOR(31 downto 0);
            write_reg_addr_out : out STD_LOGIC_VECTOR(4 downto 0)
        );
    end component;

    component DataMemory
        Port ( clk : in STD_LOGIC;
               address, write_data : in STD_LOGIC_VECTOR(31 downto 0);
               mem_write, mem_read : in STD_LOGIC;
               read_data : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    component MEM_WB_Register
        Port ( 
            clk, rst : in STD_LOGIC;
            wb_reg_write_in, wb_mem_to_reg_in : in STD_LOGIC;
            read_data_in, alu_result_in : in STD_LOGIC_VECTOR(31 downto 0);
            write_reg_addr_in : in STD_LOGIC_VECTOR(4 downto 0);
            
            wb_reg_write_out, wb_mem_to_reg_out : out STD_LOGIC;
            read_data_out, alu_result_out : out STD_LOGIC_VECTOR(31 downto 0);
            write_reg_addr_out : out STD_LOGIC_VECTOR(4 downto 0)
        );
    end component;

 
    -- 2. Signal Declarations
 
     -- IF Stage
    signal pc_current, pc_next, pc_plus4 : STD_LOGIC_VECTOR(31 downto 0);
    signal instr_fetched : STD_LOGIC_VECTOR(31 downto 0);
    
 
    signal pc_after_branch : STD_LOGIC_VECTOR(31 downto 0);
    
    -- IF/ID Output
    signal if_id_pc_plus4, if_id_instr : STD_LOGIC_VECTOR(31 downto 0);
    signal if_id_flush : STD_LOGIC;
    
    -- ID Stage
    signal read_data1, read_data2 : STD_LOGIC_VECTOR(31 downto 0);
    signal sign_ext_imm : STD_LOGIC_VECTOR(31 downto 0);
    signal branch_target_address, shifted_imm : STD_LOGIC_VECTOR(31 downto 0);
    signal branch_decision, branch_taken_flag : STD_LOGIC;
    
    --  Jump  
    signal jump_ctrl : STD_LOGIC;
    signal jump_address : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Control Signals (ID) - Raw Signals from Control Unit
    signal reg_dst_ctrl, alu_src_ctrl : STD_LOGIC;
    signal alu_op_ctrl : STD_LOGIC_VECTOR(1 downto 0);
    signal branch_ctrl, mem_read_ctrl, mem_write_ctrl, reg_write_ctrl, mem_to_reg_ctrl : STD_LOGIC;

    -- Control Signals (ID) - Safe Signals after Hazard Mux (Bubbles)
    signal safe_reg_dst, safe_alu_src : STD_LOGIC;
    signal safe_alu_op : STD_LOGIC_VECTOR(1 downto 0);
    signal safe_mem_read, safe_mem_write : STD_LOGIC;
    signal safe_reg_write, safe_mem_to_reg : STD_LOGIC;

    -- ID/EX Output (EX Input)
    signal id_ex_wb_reg_write, id_ex_wb_mem_to_reg : STD_LOGIC;
    signal id_ex_mem_read, id_ex_mem_write : STD_LOGIC;
    signal id_ex_reg_dst, id_ex_alu_src : STD_LOGIC;
    signal id_ex_alu_op : STD_LOGIC_VECTOR(1 downto 0);
    signal id_ex_pc_plus4, id_ex_read_data1, id_ex_read_data2, id_ex_sign_ext : STD_LOGIC_VECTOR(31 downto 0);
    signal id_ex_rs, id_ex_rt, id_ex_rd : STD_LOGIC_VECTOR(4 downto 0);
    
    -- EX Stage Internal
    signal alu_control_signal : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_input_b, alu_result_out : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_zero_out : STD_LOGIC;
    signal write_reg_dest_5bit : STD_LOGIC_VECTOR(4 downto 0);

    -- [NEW] Forwarding Signals
    signal forward_a_sel, forward_b_sel : STD_LOGIC_VECTOR(1 downto 0);
    signal alu_in_a_final, alu_in_b_forwarded : STD_LOGIC_VECTOR(31 downto 0);

    -- EX/MEM Output (MEM Input)
    signal ex_mem_wb_reg_write, ex_mem_wb_mem_to_reg : STD_LOGIC;
    signal ex_mem_mem_read, ex_mem_mem_write : STD_LOGIC;
    signal ex_mem_alu_result, ex_mem_write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal ex_mem_write_reg : STD_LOGIC_VECTOR(4 downto 0);
    
    -- MEM Stage Internal
    signal mem_read_data : STD_LOGIC_VECTOR(31 downto 0); 

    -- MEM/WB Output (WB Input)
    signal mem_wb_wb_reg_write, mem_wb_wb_mem_to_reg : STD_LOGIC;
    signal mem_wb_read_data, mem_wb_alu_result : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_wb_write_reg : STD_LOGIC_VECTOR(4 downto 0);

    -- FINAL FEEDBACK SIGNALS
    signal final_write_data : STD_LOGIC_VECTOR(31 downto 0); 

    -- Hazard Signals
    signal pc_write_enable : STD_LOGIC;      -- Driven by Hazard Unit
    signal if_id_write_enable : STD_LOGIC;   -- Driven by Hazard Unit
    signal hazard_stall_flag : STD_LOGIC;    -- Output of Hazard Unit (Select for Bubble Mux)
    
begin

    -- 3. Port Mapping

    -- >>> IF STAGE <<<
    -- pc_after_branch
    Branch_Mux: Mux2x1 port map (sel => branch_decision, in0 => pc_plus4, in1 => branch_target_address, output => pc_after_branch);
    
    -- Jump
    Jump_Mux:   Mux2x1 port map (sel => jump_ctrl, in0 => pc_after_branch, in1 => jump_address, output => pc_next);

    PC: PC_Register port map (clk => clk, rst => rst, PC_Write => pc_write_enable, pc_in => pc_next, pc_out => pc_current);
    PC_Adder: Adder port map (in0 => pc_current, in1 => x"00000004", output => pc_plus4);
    IMem: InstructionMemory port map (address => pc_current, instruction => instr_fetched);

    -- >>> IF/ID REGISTER <<<
    -- Flush
    if_id_flush <= branch_decision or jump_ctrl;
    
    Pipe_IF_ID: IF_ID_Register port map (
        clk => clk, rst => rst, flush => if_id_flush, write_en => if_id_write_enable,
        pc_plus4_in => pc_plus4, instruction_in => instr_fetched,
        pc_plus4_out => if_id_pc_plus4, instruction_out => if_id_instr
    );

    -- >>> ID STAGE <<<
    jump_address <= if_id_pc_plus4(31 downto 28) & if_id_instr(25 downto 0) & "00";

    Control: ControlUnit port map (
        Opcode => if_id_instr(31 downto 26),
        RegDst => reg_dst_ctrl, ALUSrc => alu_src_ctrl, ALUOp => alu_op_ctrl,
        Branch => branch_ctrl, MemRead => mem_read_ctrl, MemWrite => mem_write_ctrl,
        RegWrite => reg_write_ctrl, MemtoReg => mem_to_reg_ctrl,
        Jump => jump_ctrl  
    );

    RegFile: RegisterFile port map (
        clk => clk, rst => rst, 
        reg_write => mem_wb_wb_reg_write, 
        read_reg1 => if_id_instr(25 downto 21), read_reg2 => if_id_instr(20 downto 16),
        write_reg => mem_wb_write_reg,      
        write_data => final_write_data,     
        read_data1 => read_data1, read_data2 => read_data2
    );

    SignExt: SignExtender port map (input_16 => if_id_instr(15 downto 0), output_32 => sign_ext_imm);
    Branch_Comp: Comparator port map (in1 => read_data1, in2 => read_data2, equal => branch_taken_flag);
    shifted_imm <= sign_ext_imm(29 downto 0) & "00";
    Branch_Adder: Adder port map (in0 => if_id_pc_plus4, in1 => shifted_imm, output => branch_target_address);
    branch_decision <= branch_ctrl and branch_taken_flag;

    -- >>> HAZARD DETECTION UNIT <<<
    HazardUnit: HazardDetectionUnit port map (
        id_ex_mem_read => id_ex_mem_read,
        id_ex_rt => id_ex_rt,
        if_id_rs => if_id_instr(25 downto 21),
        if_id_rt => if_id_instr(20 downto 16),
        pc_write => pc_write_enable,
        if_id_write => if_id_write_enable,
        mux_hazard => hazard_stall_flag
    );

    -- >>> CONTROL MUX (THE BUBBLE LOGIC) <<<
    -- If hazard_stall_flag = 1, force all controls to 0 (NOP)
    safe_reg_dst   <= '0' when hazard_stall_flag = '1' else reg_dst_ctrl;
    safe_alu_src   <= '0' when hazard_stall_flag = '1' else alu_src_ctrl;
    safe_alu_op    <= "00" when hazard_stall_flag = '1' else alu_op_ctrl;
    safe_mem_read  <= '0' when hazard_stall_flag = '1' else mem_read_ctrl;
    safe_mem_write <= '0' when hazard_stall_flag = '1' else mem_write_ctrl;
    safe_reg_write <= '0' when hazard_stall_flag = '1' else reg_write_ctrl;
    safe_mem_to_reg<= '0' when hazard_stall_flag = '1' else mem_to_reg_ctrl;

    -- >>> ID/EX REGISTER (Updated to use SAFE signals) <<<
    Pipe_ID_EX: ID_EX_Register port map (
        clk => clk, rst => rst,
        -- Use Safe signals here instead of raw Control output
        wb_reg_write_in => safe_reg_write, wb_mem_to_reg_in => safe_mem_to_reg,
        mem_read_in => safe_mem_read, mem_write_in => safe_mem_write,
        ex_reg_dst_in => safe_reg_dst, ex_alu_src_in => safe_alu_src, ex_alu_op_in => safe_alu_op,
        
        pc_plus4_in => if_id_pc_plus4, read_data1_in => read_data1, read_data2_in => read_data2, sign_ext_imm_in => sign_ext_imm,
        rs_addr_in => if_id_instr(25 downto 21), rt_addr_in => if_id_instr(20 downto 16), rd_addr_in => if_id_instr(15 downto 11),
        wb_reg_write_out => id_ex_wb_reg_write, wb_mem_to_reg_out => id_ex_wb_mem_to_reg,
        mem_read_out => id_ex_mem_read, mem_write_out => id_ex_mem_write,
        ex_reg_dst_out => id_ex_reg_dst, ex_alu_src_out => id_ex_alu_src, ex_alu_op_out => id_ex_alu_op,
        read_data1_out => id_ex_read_data1, read_data2_out => id_ex_read_data2, sign_ext_imm_out => id_ex_sign_ext,
        rs_addr_out => id_ex_rs, rt_addr_out => id_ex_rt, rd_addr_out => id_ex_rd
    );

    -- >>> EX STAGE (UPDATED WITH FORWARDING) <<<

    -- 1. Forwarding Unit Instance
    FwdUnit: ForwardingUnit port map (
        id_ex_rs => id_ex_rs,
        id_ex_rt => id_ex_rt,
        ex_mem_rd => ex_mem_write_reg,      
        mem_wb_rd => mem_wb_write_reg,     
        ex_mem_reg_write => ex_mem_wb_reg_write,
        mem_wb_reg_write => mem_wb_wb_reg_write,
        forward_a => forward_a_sel,
        forward_b => forward_b_sel
    );

    -- 2. Forwarding Mux A (Logic for Input A)
    with forward_a_sel select
        alu_in_a_final <= id_ex_read_data1      when "00", -- No forwarding
                          ex_mem_alu_result     when "10", -- Forward from EX/MEM
                          final_write_data      when "01", -- Forward from MEM/WB
                          id_ex_read_data1      when others;

    -- 3. Forwarding Mux B (Logic for Input B before immediate Mux)
    with forward_b_sel select
        alu_in_b_forwarded <= id_ex_read_data2      when "00", -- No forwarding
                              ex_mem_alu_result     when "10", -- Forward from EX/MEM
                              final_write_data      when "01", -- Forward from MEM/WB
                              id_ex_read_data2      when others;

    -- 4. ALU Source Mux (Selects between Forwarded Register and Immediate)
    ALU_Input_Mux: Mux2x1 port map (
        sel => id_ex_alu_src, 
        in0 => alu_in_b_forwarded,  -- Modified to take forwarded data
        in1 => id_ex_sign_ext, 
        output => alu_input_b
    );

    -- 5. ALU Control & Main ALU
    ALU_Ctrl_Unit: ALU_Control port map (ALUOp => id_ex_alu_op, Funct => id_ex_sign_ext(5 downto 0), ALU_Control_Out => alu_control_signal);
    
    write_reg_dest_5bit <= id_ex_rt when id_ex_reg_dst = '0' else id_ex_rd;
    
    Main_ALU: ALU port map (
        A => alu_in_a_final,        -- Modified to take forwarded data
        B => alu_input_b, 
        ALU_Control => alu_control_signal, 
        ALU_Result => alu_result_out, 
        Zero => alu_zero_out
    );

    -- >>> EX/MEM REGISTER <<<
    Pipe_EX_MEM: EX_MEM_Register port map (
        clk => clk, rst => rst,
        wb_reg_write_in => id_ex_wb_reg_write, wb_mem_to_reg_in => id_ex_wb_mem_to_reg,
        mem_read_in => id_ex_mem_read, mem_write_in => id_ex_mem_write,
        alu_result_in => alu_result_out, 
        write_data_in => alu_in_b_forwarded,  
        write_reg_addr_in => write_reg_dest_5bit,
        wb_reg_write_out => ex_mem_wb_reg_write, wb_mem_to_reg_out => ex_mem_wb_mem_to_reg,
        mem_read_out => ex_mem_mem_read, mem_write_out => ex_mem_mem_write,
        alu_result_out => ex_mem_alu_result, write_data_out => ex_mem_write_data,
        write_reg_addr_out => ex_mem_write_reg
    );

    -- >>> MEM STAGE <<<
    DataMem: DataMemory port map (
        clk => clk, address => ex_mem_alu_result, write_data => ex_mem_write_data,
        mem_write => ex_mem_mem_write, mem_read => ex_mem_mem_read, read_data => mem_read_data
    );

    -- >>> MEM/WB REGISTER <<<
    Pipe_MEM_WB: MEM_WB_Register port map (
        clk => clk, rst => rst,
        wb_reg_write_in => ex_mem_wb_reg_write, wb_mem_to_reg_in => ex_mem_wb_mem_to_reg,
        read_data_in => mem_read_data, alu_result_in => ex_mem_alu_result,
        write_reg_addr_in => ex_mem_write_reg,
        wb_reg_write_out => mem_wb_wb_reg_write, wb_mem_to_reg_out => mem_wb_wb_mem_to_reg,
        read_data_out => mem_wb_read_data, alu_result_out => mem_wb_alu_result,
        write_reg_addr_out => mem_wb_write_reg
    );

    -- >>> WB STAGE (Write Back Mux) <<<
    final_write_data <= mem_wb_read_data when mem_wb_wb_mem_to_reg = '1' else mem_wb_alu_result;

end Behavioral;