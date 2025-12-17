library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ID_EX_Register is
    Port ( 
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        
        -- Control Signals (Inputs coming from Control Unit)
        -- WB Group
        wb_reg_write_in : in STD_LOGIC;
        wb_mem_to_reg_in : in STD_LOGIC;
        -- MEM Group
        mem_read_in : in STD_LOGIC;
        mem_write_in : in STD_LOGIC;
        -- EX Group
        ex_reg_dst_in : in STD_LOGIC;
        ex_alu_src_in : in STD_LOGIC;
        ex_alu_op_in : in STD_LOGIC_VECTOR(1 downto 0);
        
        -- Data Inputs (Coming from Register File & Sign Extender)
        pc_plus4_in : in STD_LOGIC_VECTOR(31 downto 0);
        read_data1_in : in STD_LOGIC_VECTOR(31 downto 0);
        read_data2_in : in STD_LOGIC_VECTOR(31 downto 0);
        sign_ext_imm_in : in STD_LOGIC_VECTOR(31 downto 0);
        
        -- Addresses (For Forwarding & Write Back)
        rs_addr_in : in STD_LOGIC_VECTOR(4 downto 0);
        rt_addr_in : in STD_LOGIC_VECTOR(4 downto 0);
        rd_addr_in : in STD_LOGIC_VECTOR(4 downto 0);
        
        -- Outputs (Going to Execute Stage & Next Pipeline Reg)		 
		
        wb_reg_write_out : out STD_LOGIC;
        wb_mem_to_reg_out : out STD_LOGIC;
        mem_read_out : out STD_LOGIC;
        mem_write_out : out STD_LOGIC;
        ex_reg_dst_out : out STD_LOGIC;
        ex_alu_src_out : out STD_LOGIC;
        ex_alu_op_out : out STD_LOGIC_VECTOR(1 downto 0);
        
        pc_plus4_out : out STD_LOGIC_VECTOR(31 downto 0);
        read_data1_out : out STD_LOGIC_VECTOR(31 downto 0);
        read_data2_out : out STD_LOGIC_VECTOR(31 downto 0);
        sign_ext_imm_out : out STD_LOGIC_VECTOR(31 downto 0);
        rs_addr_out : out STD_LOGIC_VECTOR(4 downto 0);
        rt_addr_out : out STD_LOGIC_VECTOR(4 downto 0);
        rd_addr_out : out STD_LOGIC_VECTOR(4 downto 0)
    );
end ID_EX_Register;

architecture Behavioral of ID_EX_Register is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            wb_reg_write_out <= '0'; wb_mem_to_reg_out <= '0';
            mem_read_out <= '0'; mem_write_out <= '0';
            ex_reg_dst_out <= '0'; ex_alu_src_out <= '0'; ex_alu_op_out <= "00";
            read_data1_out <= (others => '0'); read_data2_out <= (others => '0');
            sign_ext_imm_out <= (others => '0'); pc_plus4_out <= (others => '0');
            rs_addr_out <= (others => '0'); rt_addr_out <= (others => '0'); rd_addr_out <= (others => '0');
        elsif rising_edge(clk) then
            wb_reg_write_out <= wb_reg_write_in;
            wb_mem_to_reg_out <= wb_mem_to_reg_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            ex_reg_dst_out <= ex_reg_dst_in;
            ex_alu_src_out <= ex_alu_src_in;
            ex_alu_op_out <= ex_alu_op_in;
            
            pc_plus4_out <= pc_plus4_in;
            read_data1_out <= read_data1_in;
            read_data2_out <= read_data2_in;
            sign_ext_imm_out <= sign_ext_imm_in;
            rs_addr_out <= rs_addr_in;
            rt_addr_out <= rt_addr_in;
            rd_addr_out <= rd_addr_in;
        end if;
    end process;
end Behavioral;