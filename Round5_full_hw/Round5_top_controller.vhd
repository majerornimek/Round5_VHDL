library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;
use work.sha_tb_pkg.all;



entity Round5_top_controller is
		port (
			clk				: in std_logic;
			rst				: in std_logic;
			
			rst_hash		: out std_logic;
			rst_arithm		: out std_logic;
			rst_aead		: out std_logic;
			
			---- FIFO CONTROLL
			FIFO_rd_en		: out std_logic;
			FIFO_wr_en		: out std_logic;
			FIFO_Empty		: in std_logic;
			FIFO_Full		: in std_logic;
			
			
			
			---- INPUT/OUTPUT COMMAND
			din				: in std_logic_vector(63 downto 0);
			dout 			: out std_logic_vector(63 downto 0);
			demux_ctrl		: out std_logic;
			dout_demux_ctrl	: out std_logic_vector(1 downto 0);
			
		
			---- ARITHM CONTROL SIGNALS
			
			arithm_FIFO_Empty 	: in std_logic;
			arithm_FIFO_Full 	: in std_logic;
			arithm_FIFO_rd_en 	: out std_logic;
			arithm_FIFO_wr_en	: out std_logic;
			
			start_arithm	: out std_logic;
			demux_arithm	: out std_logic;
			
			---- HASH CONTROL SIGNALS
			hash_FIFO_wr_en : out std_logic;
			hash_FIFO_rd_en : out std_logic;
			hash_FIFO_Full 	: in std_logic;
			hash_FIFO_Empty : in std_logic;
			demux_hash		: out std_logic;
			
			---- AEAD CONTROL SIGNALS
			aead_FIFO_wr_en		: out std_logic;
			aead_FIFO_Full		: in std_logic;
			aead_FIFO_rd_en		: out std_logic;
			aead_FIFO_Empty		: in std_logic
			
		);
end entity;


architecture a1 of Round5_top_controller is 

type GlobalStateMachine is (idle, CPA_PKE, CPA_KEM, CCA_KEM, CCA_PKE, test_hash, test_arithm);
type CPA_PKE_StateMachine is (idle,x1,x2, done);
type CPA_KEM_StateMachine is (idle,Gen_A_from_sigma, Move_polyA_to_arithm, generate_command_to_store_B, load_B, read_MSG, move_rho_to_arithm, sec_hash, Gen_RHO, encrypt, decrypt, dec_hash, done);
type CCA_KEM_StateMachine is (idle,x2,done);
type CCA_PKE_StateMachine is (idle,Gen_A_from_sigma, Move_polyA_to_arithm, generate_command_to_store_B, load_B, read_MSG, move_rho_to_arithm, sec_hash, Gen_RHO, encrypt, decrypt, dec_hash, aes, done);


signal G_FSM 		: GlobalStateMachine := idle;
signal CPA_PKE_FSM 	: CPA_PKE_StateMachine := idle;	 
signal CPA_KEM_FSM 	: CPA_KEM_StateMachine := idle;
signal CCA_KEM_FSM	: CCA_KEM_StateMachine := idle;
signal CCA_PKE_FSM 	: CCA_PKE_StateMachine := idle;
signal test_hash_FSM : CPA_PKE_StateMachine := idle;
signal test_arithm_FSM : CPA_PKE_StateMachine := idle;



signal control_counter 	: std_logic_vector(15 downto 0) := (others => '0');
--signal CPA_KEM_WRITE_SEC_HASH_RESULT_CLOCK_CYCLES, CPA_KEM_PolyA_cycle_move, CPA_KEM_Move_RHO_clock_cycles,CPA_KEM_SIGMA_LOAD_CYCLES, CPA_KEM_PubB_data_load,CPA_KEM_RHO_LOAD_CYCLES, CPA_KEM_MSG_LOAD_CYCLES,CPA_KEM_MOVE_ENC_RESULT_CLOCK_CYCLES : std_logic_vector(15 downto 0) := (others => '0');
signal control_enable_tick, CPA_PKE_counter_enable, CPA_KEM_counter_enable, CCA_PKE_counter_enable, CCA_KEM_counter_enable : std_logic; 
signal reset_counter, CPA_PKE_counter_reset, CPA_KEM_counter_reset, CCA_PKE_counter_reset, CCA_KEM_counter_reset : std_logic; 

signal CPA_KEM_dout, CCA_PKE_dout, STORE_B_COMMAND : std_logic_vector(63 downto 0);

signal CPA_KEM_FIFO_wr_en, main_FIFO_rd_en, CPA_KEM_FIFO_rd_en, CCA_PKE_FIFO_rd_en : std_logic;
--- COMMMAND FORMAT:
 --		FIRST 8 MSF bits saved for commands to other modules
 ---	55 downto 48:   CPA_PKE | CPA_KEM | CCA_PKE | CCA_KEM |0000
signal PKE_arithm_FIFO_rd_en, PKE_arithm_FIFO_wr_en, KEM_arithm_FIFO_rd_en,CCA_PKE_FIFO_wr_en, KEM_arithm_FIFO_wr_en, KEM_demux_arithm, KEM_demux_ctrl, KEM_demux_hash, KEM_hash_FIFO_rd_en, KEM_hash_FIFO_wr_en, PKE_demux_arithm, PKE_demux_ctrl, PKE_demux_hash, PKE_hash_FIFO_rd_en, PKE_hash_FIFO_wr_en : std_logic;
signal PKE_dout_demux_ctrl, KEM_dout_demux_ctrl, test_hash_dout_demux_ctrl, test_arithm_dout_demux_ctrl : std_logic_vector(1 downto 0);


signal test_hash_FIFO_rd_en, test_hash_FIFO_wr_en, test_hash_arithm_FIFO_rd_en, main_demux_ctrl, test_hash_arithm_FIFO_wr_en, test_hash_counter_enable, test_hash_demux_arithm, test_hash_demux_ctrl, test_hash_demux_hash, test_hash_hash_FIFO_rd_en, test_hash_hash_FIFO_wr_en, test_hash_reset : std_logic := '0';
signal test_arithm_FIFO_rd_en, test_arithm_FIFO_wr_en, test_arithm_arithm_FIFO_rd_en, test_arithm_arithm_FIFO_wr_en, test_arithm_counter_enable, test_arithm_demux_arithm, test_arithm_demux_ctrl, test_arithm_demux_hash, test_arithm_hash_FIFO_rd_en, test_arithm_hash_FIFO_wr_en, test_arithm_reset : std_logic := '0';

begin


process(rst, clk) 
begin
	if rst = '1' then
		G_FSM <= idle;
	elsif clk'event and clk = '1' then
		case G_FSM is 
			when idle =>
				if FIFO_Empty /= '1' then
					main_FIFO_rd_en <= '1';
					--if din(55) = '1' then
					--	G_FSM <= CPA_PKE;
						
					if din(54) = '1' then
						G_FSM <= CPA_KEM;
						dout <= CPA_KEM_dout;
					elsif din(53) = '1' then 
						G_FSM <= CCA_PKE;
						dout <= CCA_PKE_dout;
					elsif din(52) = '1' then
						G_FSM <= test_arithm;
					--elsif din(52) = '1' then
						--G_FSM <= CCA_KEM;
					elsif din(51) = '1' then
						G_FSM <= test_hash;
					end if;
					rst_hash <= '1';
					rst_aead <= '1';
					rst_arithm <= '1';
				else
					main_FIFO_rd_en <= '0';
				end if;
			when others =>
				if CPA_PKE_FSM = done or CPA_KEM_FSM = done or CCA_PKE_FSM = done or CCA_KEM_FSM = done or test_hash_FSM = done or test_arithm_FSM = done then
					G_FSM <= idle;
					main_FIFO_rd_en <= '0';
					rst_hash <= '0';
					rst_aead <= '0';
					rst_arithm <= '0';
				end if;
		end case;
		main_demux_ctrl <= '0';
	end if;
end process;

------	GLOBAL COUNTER
process(rst, clk)
begin
	if rst = '1' then
		control_counter <= (others => '0');
	elsif clk'event and clk = '1' then
		if control_enable_tick = '1' then
			control_counter <= control_counter + '1';
		elsif reset_counter = '1' then
			control_counter <= (others => '0');
		else
			control_counter <= control_counter;
		end if;
	end if;
end process;

control_enable_tick <= CPA_KEM_counter_enable or CCA_PKE_counter_enable  or test_hash_counter_enable or test_arithm_counter_enable; 
reset_counter <= CPA_KEM_counter_reset or CCA_PKE_counter_reset or test_hash_reset or test_arithm_reset; 


FIFO_rd_en <= main_FIFO_rd_en or CPA_KEM_FIFO_rd_en or test_hash_FIFO_rd_en or CCA_PKE_FIFO_rd_en or test_arithm_FIFO_rd_en;
FIFO_wr_en <= CPA_KEM_FIFO_wr_en or CCA_PKE_FIFO_wr_en or test_hash_FIFO_wr_en or test_arithm_FIFO_wr_en;
demux_hash <= KEM_demux_hash or PKE_demux_hash or test_hash_demux_hash or test_arithm_demux_hash;
demux_arithm <= KEM_demux_arithm or PKE_demux_arithm or test_hash_demux_arithm or test_arithm_demux_arithm;
demux_ctrl <= KEM_demux_ctrl or PKE_demux_ctrl or test_hash_demux_ctrl or main_demux_ctrl or test_arithm_demux_ctrl;
dout_demux_ctrl <= KEM_dout_demux_ctrl or PKE_dout_demux_ctrl or test_hash_dout_demux_ctrl, test_arithm_dout_demux_ctrl ;
hash_FIFO_wr_en <= KEM_hash_FIFO_wr_en or PKE_hash_FIFO_wr_en or test_hash_hash_FIFO_wr_en or test_arithm_hash_FIFO_wr_en;
hash_FIFO_rd_en <= KEM_hash_FIFO_rd_en or PKE_hash_FIFO_rd_en or test_hash_hash_FIFO_rd_en or test_arithm_hash_FIFO_rd_en;
arithm_FIFO_wr_en <= KEM_arithm_FIFO_wr_en or PKE_arithm_FIFO_wr_en or test_hash_arithm_FIFO_wr_en or test_arithm_arithm_FIFO_wr_en;
arithm_FIFO_rd_en <= KEM_arithm_FIFO_rd_en or PKE_arithm_FIFO_rd_en or test_hash_arithm_FIFO_rd_en or test_arithm_arithm_FIFO_rd_en;





--- CPA_KEM command | 

--- CPA_KEM
process(rst,clk)
begin
	if rst = '1' then
		CPA_KEM_FSM <= idle;
		CPA_KEM_counter_enable <= '0';
	elsif clk'event and clk = '1' then
		case CPA_KEM_FSM is
			when idle =>
				if G_FSM = CPA_KEM then
					CPA_KEM_FSM <= Gen_A_from_sigma;
					KEM_demux_hash <= '1';
					KEM_hash_FIFO_wr_en <= '1';
					CPA_KEM_FIFO_rd_en <= '1';
				else
					KEM_demux_arithm <= '0';
					KEM_arithm_FIFO_rd_en <= '0';
					KEM_arithm_FIFO_wr_en <= '0';
					KEM_hash_FIFO_rd_en <= '0';
					KEM_hash_FIFO_wr_en <= '0';
					KEM_dout_demux_ctrl <= "00";
					KEM_demux_ctrl <= '0';
					KEM_demux_hash <= '0';
					CPA_KEM_counter_reset <= '0';	 
					CPA_KEM_counter_enable <= '0';
					CPA_KEM_FSM <= idle;
					CPA_KEM_counter_enable <= '0';
					CPA_KEM_dout <= (others => '0');
				end if;
			
			when Gen_A_from_sigma =>
				if control_counter = CPA_KEM_SIGMA_LOAD_CYCLES then -- NEXT MSG
					CPA_KEM_counter_enable <= '0';
					CPA_KEM_counter_reset <= '1';
					
					CPA_KEM_FSM <= generate_command_to_store_B;
					KEM_demux_hash <= '0';
					KEM_hash_FIFO_wr_en <= '0';
					CPA_KEM_FIFO_rd_en <= '0';
					KEM_demux_arithm <= '0';	-- Read from internal bud
					KEM_dout_demux_ctrl <= "00";
				else
					CPA_KEM_FIFO_rd_en <= '1';
					KEM_hash_FIFO_wr_en <= '1';
					KEM_demux_hash <= '1';
					CPA_KEM_counter_enable <= '1';
				end if;
			
			when generate_command_to_store_B =>
				CPA_KEM_dout <= x"c400000000000000";---STORE_B_COMMAND;
				CPA_KEM_FSM <= load_B;
				KEM_demux_arithm <= '1';
				KEM_arithm_FIFO_wr_en <= '1';
				
			when load_B =>
				if control_counter = CPA_KEM_PubB_data_load then
					CPA_KEM_counter_enable <= '0';
					CPA_KEM_counter_reset <= '1';  
					KEM_demux_arithm <= '0';
					KEM_arithm_FIFO_wr_en <= '0';
					KEM_dout_demux_ctrl <= "01";
					CPA_KEM_FSM <=  Move_polyA_to_arithm;--Gen_RHO;
					CPA_KEM_FIFO_rd_en <= '0';
				else
					CPA_KEM_FIFO_rd_en <= '1';
					KEM_demux_arithm <= '1';
					KEM_arithm_FIFO_wr_en <= '1';
					CPA_KEM_counter_enable <= '1';
					CPA_KEM_counter_reset <= '0'; 
				end if;
				
			when Move_polyA_to_arithm =>
				if hash_FIFO_Empty /= '1' then
					if control_counter = CPA_KEM_PolyA_cycle_move then
						CPA_KEM_counter_enable <= '0';
						CPA_KEM_counter_reset <= '1';
						CPA_KEM_FSM <= Gen_RHO;
						KEM_hash_FIFO_rd_en <= '0';
						KEM_demux_hash <= '1';
						KEM_arithm_FIFO_wr_en <= '0';
					else
						KEM_arithm_FIFO_wr_en <= '1';
						CPA_KEM_counter_enable <= '1';
						CPA_KEM_counter_reset <= '0'; 
						KEM_hash_FIFO_rd_en <= '1';
						KEM_demux_arithm <= '0';
					end if;
				end if;
			when Gen_RHO => 
			
				if control_counter = CPA_KEM_RHO_LOAD_CYCLES then -- NEXT MSG
					CPA_KEM_counter_enable <= '0';
					CPA_KEM_counter_reset <= '1';
					CPA_KEM_FIFO_rd_en <= '0';
					CPA_KEM_FSM <= read_MSG;
					KEM_demux_hash <= '0';
					KEM_hash_FIFO_wr_en <= '0';
					KEM_demux_arithm <= '1';
				else
					KEM_demux_hash <= '1';
					KEM_hash_FIFO_wr_en <= '1';
					CPA_KEM_FIFO_rd_en <= '1';
					CPA_KEM_counter_enable <= '1';
					CPA_KEM_counter_reset <= '0';  
				end if;
				
			when read_MSG => 
				if control_counter = CPA_KEM_MSG_LOAD_CYCLES then -- NEXT MSG
					CPA_KEM_counter_enable <= '0';
					CPA_KEM_counter_reset <= '1';
					CPA_KEM_FIFO_rd_en <= '0';
					CPA_KEM_FSM <= move_rho_to_arithm;
					KEM_demux_hash <= '0';
					KEM_hash_FIFO_rd_en <= '1';
				else
					CPA_KEM_FIFO_rd_en <= '1';
					KEM_arithm_FIFO_wr_en <= '1';
					CPA_KEM_counter_enable <= '1';
					CPA_KEM_counter_reset <= '0';
				end if;
			
			when move_rho_to_arithm =>
				if hash_FIFO_Empty /= '1' then
					if control_counter = CPA_KEM_Move_RHO_clock_cycles then	
						CPA_KEM_FSM <= encrypt;
						KEM_hash_FIFO_rd_en <= '0';
						KEM_arithm_FIFO_wr_en <= '0';
						KEM_dout_demux_ctrl <= "01";
						CPA_KEM_counter_enable <= '0';
						CPA_KEM_counter_reset <= '1';
					else
						CPA_KEM_counter_enable <= '1';
						CPA_KEM_counter_reset <= '0';
						KEM_hash_FIFO_rd_en <= '1';
						KEM_demux_arithm <= '0';
						KEM_dout_demux_ctrl <= "01";
						KEM_arithm_FIFO_wr_en <= '1';
					end if;
				
				end if;
			
			
			when encrypt  => 		-- RESULT SHOULD GO TO HASH + OUTSIDE
				if arithm_FIFO_Empty /= '1' then
					CPA_KEM_counter_enable <= '1';
					CPA_KEM_counter_reset <= '0';
					KEM_arithm_FIFO_rd_en <= '1';
					KEM_dout_demux_ctrl <= "10";
					KEM_demux_hash <= '0';
					KEM_hash_FIFO_wr_en <= '1';
					CPA_KEM_FIFO_wr_en <= '1';
					
				elsif control_counter = CPA_KEM_MOVE_ENC_RESULT_CLOCK_CYCLES then
					KEM_dout_demux_ctrl <= "00";
					KEM_arithm_FIFO_rd_en <= '0';
					KEM_hash_FIFO_wr_en <= '0';
					CPA_KEM_FIFO_wr_en <= '0';
					CPA_KEM_counter_enable <= '0';
					CPA_KEM_counter_reset <= '1';
					CPA_KEM_FSM <= sec_hash;
				end if;
			
			when sec_hash =>
				if hash_FIFO_Empty /= '1' then
					CPA_KEM_counter_enable <= '1';
					CPA_KEM_counter_reset <= '0';
					KEM_arithm_FIFO_rd_en <= '0';
					KEM_dout_demux_ctrl <= "01";
					CPA_KEM_FIFO_wr_en <= '1';
					KEM_hash_FIFO_rd_en <= '1';
					
				elsif control_counter = CPA_KEM_WRITE_SEC_HASH_RESULT_CLOCK_CYCLES then
					KEM_dout_demux_ctrl <= "01";
					KEM_arithm_FIFO_rd_en <= '0';
					KEM_hash_FIFO_rd_en <= '0';
					CPA_KEM_FIFO_wr_en <= '0';
					CPA_KEM_counter_enable <= '0';
					CPA_KEM_counter_reset <= '1';
					CPA_KEM_FSM <= done;
				end if;
			
			when decrypt =>
			
			when dec_hash =>
			
			
			when done =>
				KEM_demux_arithm <= '0';
				KEM_arithm_FIFO_rd_en <= '0';
				KEM_arithm_FIFO_wr_en <= '0';
				KEM_hash_FIFO_rd_en <= '0';
				KEM_hash_FIFO_wr_en <= '0';
				KEM_dout_demux_ctrl <= "00";
				KEM_demux_ctrl <= '0';
				KEM_demux_hash <= '0';
				CPA_KEM_counter_reset <= '0';	 
				CPA_KEM_counter_enable <= '0';
				CPA_KEM_FSM <= idle;
				CPA_KEM_counter_enable <= '0';
				CPA_KEM_dout <= (others => '0');
			when others =>
				KEM_demux_arithm <= '0';
				KEM_arithm_FIFO_rd_en <= '0';
				KEM_arithm_FIFO_wr_en <= '0';
				KEM_hash_FIFO_rd_en <= '0';
				KEM_hash_FIFO_wr_en <= '0';
				KEM_dout_demux_ctrl <= "00";
				KEM_demux_ctrl <= '0';
				KEM_demux_hash <= '0';
				CPA_KEM_counter_reset <= '0';	 
				CPA_KEM_counter_enable <= '0';
				CPA_KEM_FSM <= idle;
				CPA_KEM_counter_enable <= '0';
				CPA_KEM_dout <= (others => '0');
		end case;
	end if;
end process;



process(rst,clk)
begin
	if rst = '1' then
		CCA_PKE_FSM <= idle;
		CCA_PKE_counter_enable <= '0';
	elsif clk'event and clk = '1' then
		case CCA_PKE_FSM is
			when idle =>
				if G_FSM = CCA_PKE then
					CCA_PKE_FSM <= Gen_A_from_sigma;
					PKE_demux_hash <= '1';
					PKE_hash_FIFO_wr_en <= '1';
					CCA_PKE_FIFO_rd_en <= '1';
				else
					PKE_demux_arithm <= '0';
					PKE_arithm_FIFO_rd_en <= '0';
					PKE_arithm_FIFO_wr_en <= '0';
					PKE_hash_FIFO_rd_en <= '0';
					PKE_hash_FIFO_wr_en <= '0';
					PKE_dout_demux_ctrl <= "00";
					PKE_demux_ctrl <= '0';
					PKE_demux_hash <= '0';
					CCA_PKE_counter_reset <= '0';	 
					CCA_PKE_counter_enable <= '0';
					CCA_PKE_dout <= (others => '0');
				end if;
			
			when Gen_A_from_sigma =>
				if control_counter = CPA_KEM_SIGMA_LOAD_CYCLES then -- NEXT MSG
					CCA_PKE_counter_enable <= '0';
					CCA_PKE_counter_reset <= '1';
					CCA_PKE_FIFO_rd_en <= '0';
					CCA_PKE_FSM <= generate_command_to_store_B;
					PKE_demux_hash <= '0';
					PKE_hash_FIFO_wr_en <= '0';
					PKE_demux_arithm <= '0';	-- Read from internal bud
					PKE_dout_demux_ctrl <= "00";
				else
					CCA_PKE_FIFO_rd_en <= '1';
					PKE_hash_FIFO_wr_en <= '1';
					PKE_demux_hash <= '1';
					CCA_PKE_counter_enable <= '1';
				end if;
			
			when generate_command_to_store_B =>
				CCA_PKE_dout <= x"c400000000000000";
				CCA_PKE_FSM <= load_B;
				PKE_demux_arithm <= '1';
				PKE_arithm_FIFO_wr_en <= '1';
				
			when load_B =>
				if control_counter = CPA_KEM_PubB_data_load then
					CCA_PKE_counter_enable <= '0';
					CCA_PKE_counter_reset <= '1';  
					PKE_demux_arithm <= '0';
					PKE_arithm_FIFO_wr_en <= '0';
					PKE_dout_demux_ctrl <= "01";
					CCA_PKE_FSM <=  Move_polyA_to_arithm;--Gen_RHO;
					CCA_PKE_FIFO_rd_en <= '0';
				else
					CCA_PKE_FIFO_rd_en <= '1';
					PKE_demux_arithm <= '1';
					PKE_arithm_FIFO_wr_en <= '1';
					CCA_PKE_counter_enable <= '1';
					CCA_PKE_counter_reset <= '0'; 
				end if;
				
			when Move_polyA_to_arithm =>
				if hash_FIFO_Empty /= '1' then
					if control_counter = CPA_KEM_PolyA_cycle_move then
						CCA_PKE_counter_enable <= '0';
						CCA_PKE_counter_reset <= '1';
						CCA_PKE_FSM <= Gen_RHO;
						PKE_hash_FIFO_rd_en <= '0';
						PKE_demux_hash <= '1';
						
					else
						CCA_PKE_counter_enable <= '1';
						CCA_PKE_counter_reset <= '0'; 
						PKE_hash_FIFO_rd_en <= '1';
						PKE_demux_arithm <= '0';
					end if;
				end if;
			when Gen_RHO => 
			
				if control_counter = CPA_KEM_RHO_LOAD_CYCLES then -- NEXT MSG
					CCA_PKE_counter_enable <= '0';
					CCA_PKE_counter_reset <= '1';
					CCA_PKE_FIFO_rd_en <= '0';
					CCA_PKE_FSM <= read_MSG;
					PKE_demux_hash <= '0';
					PKE_hash_FIFO_wr_en <= '0';
					PKE_demux_arithm <= '1';
				else
					PKE_demux_hash <= '1';
					PKE_hash_FIFO_wr_en <= '1';
					CCA_PKE_FIFO_rd_en <= '1';
					CCA_PKE_counter_enable <= '1';
					CCA_PKE_counter_reset <= '0';  
				end if;
				
			when read_MSG => 
				if control_counter = CPA_KEM_MSG_LOAD_CYCLES then -- NEXT MSG
					CCA_PKE_counter_enable <= '0';
					CCA_PKE_counter_reset <= '1';
					
					CCA_PKE_FSM <= move_rho_to_arithm;
					PKE_demux_hash <= '0';
					PKE_hash_FIFO_rd_en <= '1';
					CCA_PKE_FIFO_rd_en <= '0';
				else
					CCA_PKE_FIFO_rd_en <= '1';
					PKE_arithm_FIFO_wr_en <= '1';
					CCA_PKE_counter_enable <= '1';
					CCA_PKE_counter_reset <= '0';
				end if;
			
			when move_rho_to_arithm =>
				if hash_FIFO_Empty /= '1' then
					if control_counter = CPA_KEM_Move_RHO_clock_cycles then	
						CCA_PKE_FSM <= encrypt;
						PKE_hash_FIFO_rd_en <= '0';
						PKE_arithm_FIFO_wr_en <= '0';
						PKE_dout_demux_ctrl <= "01";
						CCA_PKE_counter_enable <= '0';
						CCA_PKE_counter_reset <= '1';
					else
						CCA_PKE_counter_enable <= '1';
						CCA_PKE_counter_reset <= '0';
						PKE_hash_FIFO_rd_en <= '1';
						PKE_demux_arithm <= '0';
						PKE_dout_demux_ctrl <= "01";
						PKE_arithm_FIFO_wr_en <= '1';
					end if;
				
				end if;
			
			
			when encrypt  => 		-- RESULT SHOULD GO TO HASH + OUTSIDE
				if arithm_FIFO_Empty /= '1' then
					CCA_PKE_counter_enable <= '1';
					CCA_PKE_counter_reset <= '0';
					PKE_arithm_FIFO_rd_en <= '1';
					PKE_dout_demux_ctrl <= "10";
					PKE_demux_hash <= '0';
					PKE_hash_FIFO_wr_en <= '1';
					CCA_PKE_FIFO_wr_en <= '1';
					
				elsif control_counter = CPA_KEM_MOVE_ENC_RESULT_CLOCK_CYCLES then
					PKE_dout_demux_ctrl <= "00";
					PKE_arithm_FIFO_rd_en <= '0';
					PKE_hash_FIFO_wr_en <= '0';
					CCA_PKE_FIFO_wr_en <= '0';
					CCA_PKE_counter_enable <= '0';
					CCA_PKE_counter_reset <= '1';
					CCA_PKE_FSM <= sec_hash;
				end if;
			
			when sec_hash =>
				if hash_FIFO_Empty /= '1' then
					CCA_PKE_counter_enable <= '1';
					CCA_PKE_counter_reset <= '0';
					PKE_arithm_FIFO_rd_en <= '0';
					PKE_dout_demux_ctrl <= "01";
					aead_FIFO_wr_en <= '1';
					PKE_hash_FIFO_rd_en <= '1';
					
				elsif control_counter = CPA_KEM_WRITE_SEC_HASH_RESULT_CLOCK_CYCLES then
					PKE_dout_demux_ctrl <= "11";
					PKE_arithm_FIFO_rd_en <= '0';
					PKE_hash_FIFO_rd_en <= '0';
					aead_FIFO_wr_en <= '0';
					CCA_PKE_counter_enable <= '0';
					CCA_PKE_counter_reset <= '1';
					CCA_PKE_FSM <= aes;
				end if;
			
			when aes =>
				if aead_FIFO_Empty /='1' then
					aead_FIFO_rd_en <= '1';
					PKE_dout_demux_ctrl <= "11";
					CCA_PKE_FIFO_wr_en <= '1';
					CCA_PKE_counter_enable <= '0';
					CCA_PKE_counter_reset <= '1';
					
				elsif control_counter = CPA_KEM_WRITE_SEC_HASH_RESULT_CLOCK_CYCLES then
					aead_FIFO_rd_en <= '0';
					PKE_dout_demux_ctrl <= "00";
					CCA_PKE_FIFO_wr_en <= '0';
					CCA_PKE_counter_enable <= '0';
					CCA_PKE_counter_reset <= '1';
					CCA_PKE_FSM<= done;	
				end if;
			
			when decrypt =>
			
			when dec_hash =>
			
			
			when done =>
				CCA_PKE_FSM <= idle;
				CCA_PKE_counter_reset <= '0';
			when others =>
					CCA_PKE_FSM <= idle;
					PKE_demux_arithm <= '0';
					PKE_arithm_FIFO_rd_en <= '0';
					PKE_arithm_FIFO_wr_en <= '0';
					PKE_hash_FIFO_rd_en <= '0';
					PKE_hash_FIFO_wr_en <= '0';
					PKE_dout_demux_ctrl <= "00";
					PKE_demux_ctrl <= '0';
					PKE_demux_hash <= '0';
					CCA_PKE_counter_reset <= '0';	 
					CCA_PKE_counter_enable <= '0';
					CCA_PKE_dout <= (others => '0');
		end case;
	end if;
end process;

process(rst,clk)
begin
	if rst = '1' then
		test_hash_FSM <= idle;
		test_hash_counter_enable <= '0';
	elsif clk'event and clk = '1' then
		case test_hash_FSM is
			when idle =>
				if G_FSM = test_hash then
					test_hash_FSM <= x1;
					test_hash_demux_hash <= '1';
					test_hash_hash_FIFO_wr_en <= '1';
					test_hash_FIFO_rd_en <= '1';
					test_hash_counter_enable <= '1';
				else
					test_hash_FIFO_rd_en <= '0';
					test_hash_FIFO_wr_en <= '0';
					test_hash_arithm_FIFO_rd_en <= '0';
					test_hash_arithm_FIFO_wr_en <= '0';
					test_hash_counter_enable <= '0';
					test_hash_demux_arithm <= '0';
					test_hash_demux_ctrl <= '0';
					test_hash_demux_hash <= '0';
					test_hash_hash_FIFO_rd_en <= '0';
					test_hash_hash_FIFO_wr_en <= '0';
					test_hash_counter_enable <= '0';
					test_hash_reset <= '0';
				end if;
			when x1 =>
				if control_counter = CPA_KEM_WRITE_SEC_HASH_RESULT_CLOCK_CYCLES then
					test_hash_FSM <= x2;
					test_hash_demux_hash <= '0';
					test_hash_hash_FIFO_wr_en <= '0';
					test_hash_FIFO_rd_en <= '0';
					test_hash_counter_enable <= '0';
					test_hash_reset <= '1';
				end if;
			
			when x2 =>
				if control_counter = CPA_KEM_WRITE_SEC_HASH_RESULT_CLOCK_CYCLES then
					test_hash_FSM <= done;
					test_hash_demux_hash <= '0';
					test_hash_hash_FIFO_rd_en <= '0';
					test_hash_FIFO_wr_en <= '0';
					test_hash_counter_enable <= '0';
					test_hash_reset <= '1';
				else
					test_hash_dout_demux_ctrl <= "01";
					test_hash_demux_hash <= '0';
					test_hash_hash_FIFO_rd_en <= '1';
					test_hash_FIFO_wr_en <= '1';
					test_hash_counter_enable <= '1';
					test_hash_reset <= '0';
				end if;
			when done =>
				test_hash_reset <= '0';
				test_hash_FSM <= idle;
			when others =>
				test_hash_FSM <= idle;
				test_hash_FIFO_rd_en <= '0';
				test_hash_FIFO_wr_en <= '0';
				test_hash_arithm_FIFO_rd_en <= '0';
				test_hash_arithm_FIFO_wr_en <= '0';
				test_hash_counter_enable <= '0';
				test_hash_demux_arithm <= '0';
				test_hash_demux_ctrl <= '0';
				test_hash_demux_hash <= '0';
				test_hash_hash_FIFO_rd_en <= '0';
				test_hash_hash_FIFO_wr_en <= '0';
				test_hash_counter_enable <= '0';
				test_hash_reset <= '0';
		end case;
	end if;
end process;


process(rst,clk)
begin
	if rst = '1' then
		test_arithm_FSM <= idle;
		test_arithm_counter_enable <= '0';
	elsif clk'event and clk = '1' then
		case test_arithm_FSM is
			when idle =>
				if G_FSM = test_arithm then
					test_arithm_FSM <= x1;
					test_arithm_demux_arithm <= '1';
					test_arithm_arithm_FIFO_wr_en <= '1';
					test_arithm_FIFO_rd_en <= '1';
					test_arithm_counter_enable <= '1';
				else
					test_arithm_FIFO_rd_en <= '0';
					test_arithm_FIFO_wr_en <= '0';
					test_arithm_arithm_FIFO_rd_en <= '0';
					test_arithm_arithm_FIFO_wr_en <= '0';
					test_arithm_counter_enable <= '0';
					test_arithm_demux_arithm <= '0';
					test_arithm_demux_ctrl <= '0';
					test_arithm_demux_hash <= '0';
					test_arithm_hash_FIFO_rd_en <= '0';
					test_arithm_hash_FIFO_wr_en <= '0';
					test_arithm_counter_enable <= '0';
					test_arithm_reset <= '0';
				end if;
			when x1 =>
				if control_counter = CPA_KEM_PubB_data_load then
					test_arithm_FSM <= x2;
					test_arithm_demux_arithm <= '0';
					test_arithm_arithm_FIFO_wr_en <= '0';
					test_arithm_FIFO_rd_en <= '0';
					test_arithm_counter_enable <= '0';
					test_arithm_reset <= '1';
				else
					test_arithm_demux_arithm <= '1';
					test_arithm_arithm_FIFO_wr_en <= '1';
					test_arithm_FIFO_rd_en <= '1';
					test_arithm_counter_enable <= '1';					
				end if;
			
			when x2 =>
				if arithm_FIFO_Empty /= '1' then
					test_arithm_dout_demux_ctrl <= "10";
					test_arithm_demux_hash <= '0';
					test_arithm_arithm_FIFO_rd_en <= '1';
					test_arithm_FIFO_wr_en <= '1';
					test_arithm_counter_enable <= '1';
					test_arithm_reset <= '0';
					
				elsif control_counter = CPA_KEM_PubB_data_load then
					test_arithm_FSM <= done;
					test_arithm_demux_hash <= '0';
					test_arithm_arithm_FIFO_rd_en <= '0';
					test_arithm_FIFO_wr_en <= '0';
					test_arithm_counter_enable <= '0';
					test_arithm_reset <= '1';
				else
					test_arithm_counter_enable <= '1';
					test_arithm_reset <= '0';
				end if;
			when done =>
				test_arithm_reset <= '0';
				test_arithm_FSM <= idle;
			when others =>
				test_arithm_FSM <= idle;
				test_arithm_FIFO_rd_en <= '0';
				test_arithm_FIFO_wr_en <= '0';
				test_arithm_arithm_FIFO_rd_en <= '0';
				test_arithm_arithm_FIFO_wr_en <= '0';
				test_arithm_counter_enable <= '0';
				test_arithm_demux_arithm <= '0';
				test_arithm_demux_ctrl <= '0';
				test_arithm_demux_hash <= '0';
				test_arithm_hash_FIFO_rd_en <= '0';
				test_arithm_hash_FIFO_wr_en <= '0';
				test_arithm_counter_enable <= '0';
				test_arithm_reset <= '0';
		end case;
	end if;
end process;


end a1;

