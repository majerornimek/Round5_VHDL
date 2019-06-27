library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;
use work.sha_tb_pkg.all;



entity Round5_top_controller_CPA_PKE is
		port (
			clk				: in std_logic;
			rst				: in std_logic;
			
			rst_hash		: out std_logic;
			rst_arithm		: out std_logic;
			rst_aead		: out std_logic;
			
			---- INPUT DATA
			pdi_data	: in std_logic_vector(63 downto 0);
			pdi_valid	: in std_logic;
			pdi_ready	: out std_logic;
			
			sdi_data	: in std_logic_vector(63 downto 0);
			sdi_valid	: in std_logic;
			sdi_ready	: out std_logic;
			
			rdi_data	: in std_logic_vector(63 downto 0);
			rdi_valid	: in std_logic;
			rdi_ready	: out std_logic;
			
			------- OUTPUT DATA	
			pdo_valid	: out std_logic;
			pdo_ready	: in std_logic;
			sdo_valid	: out std_logic;
			sdo_ready	: in std_logic;
			
				
			---- INPUT/OUTPUT COMMAND
			dout 			: out std_logic_vector(63 downto 0);
			pdo_demux_ctrl	: out std_logic_vector(1 downto 0);
			sdo_demux_ctrl	: out std_logic_vector(1 downto 0);
			
			
		
			---- ARITHM CONTROL SIGNALS	
			arithm_FIFO_Empty 	: in std_logic;
			arithm_FIFO_Full 	: in std_logic;
			arithm_FIFO_rd_en 	: out std_logic;
			arithm_FIFO_wr_en	: out std_logic;
			demux_arithm	: out std_logic_vector(1 downto 0);
			
			---- HASH CONTROL SIGNALS
			hash_FIFO_wr_en : out std_logic;
			hash_FIFO_rd_en : out std_logic;
			hash_FIFO_Full 	: in std_logic;
			hash_FIFO_Empty : in std_logic;
			demux_hash		: out std_logic_vector(1 downto 0);
			
			---- AEAD CONTROL SIGNALS
			aead_FIFO_wr_en		: out std_logic;
			aead_FIFO_Full		: in std_logic;
			aead_FIFO_rd_en		: out std_logic;
			aead_FIFO_Empty		: in std_logic
			
		);
end entity;


architecture a1 of Round5_top_controller_CPA_PKE is 

type GlobalStateMachine is (idle, CPA_PKE, CPA_KEM, CCA_KEM, CCA_PKE, test_hash, test_arithm);
type CPA_PKE_StateMachine is (idle,DEC_Gen_S_from_sk,ENC_Gen_A_from_sigma,LoadB, MOVE_RHO, MoveA, Load_RHO, LOAD_MSG, ENCRYPT,LoadCTV, MoveSK, DECRYPT,  x1,x2, done);
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

control_enable_tick <= CPA_PKE_counter_enable; 
reset_counter <= CPA_PKE_counter_reset; 




--- CPA_KEM command | 

--- CPA_KEM
process(rst,clk)
begin
	if rst = '1' then
		CPA_PKE_FSM <= idle;
		CPA_PKE_counter_enable <= '0';
		CPA_PKE_counter_reset <= '1';
	elsif clk'event and clk = '1' then
		case CPA_PKE_FSM is
			when idle =>
				if pdi_valid = '1' then
					pdi_ready <= '1';
					rst_arithm <= '0';
					rst_hash <= '0';
					rst_aead <= '0';
					if pdi_data(63 downto 60)  = "0000" then
						CPA_PKE_FSM <= ENC_Gen_A_from_sigma;
						rst_arithm <= '0';
						rst_hash <= '0';
						rst_aead <= '0';
					elsif pdi_data(63 downto 60) = "0001" then 
						CPA_PKE_FSM <= DEC_Gen_S_from_sk;
					else
						---- DO NOTHING
					end if;
				else
					rst_arithm <= '1';
					rst_hash <= '1';
					rst_aead <= '1';
					CPA_PKE_counter_enable <= '0';
					CPA_PKE_counter_reset <= '1';
				end if;
			
			when ENC_Gen_A_from_sigma =>
				if pdi_valid = '1' then
					if control_counter = CPA_KEM_SIGMA_LOAD_CYCLES then -- NEXT MSG			
						CPA_PKE_FSM <= LoadB;					
						pdi_ready <= '0';
						hash_FIFO_wr_en <= '0';
						CPA_PKE_counter_enable <= '0';
						CPA_PKE_counter_reset <= '1';
					else
						demux_hash <= "11";
						pdi_ready <= '1';
						hash_FIFO_wr_en <= '1';
						CPA_PKE_counter_enable <= '1';
						CPA_PKE_counter_reset <= '0';
					end if;
				else
					CPA_PKE_counter_enable <= '0';
				end if;
			
			when LoadB =>
				if pdi_valid = '1' then
					if control_counter = CPA_KEM_POLY_B_LOAD_CYCLES then -- NEXT MSG			
						CPA_PKE_FSM <= MoveA;					
						pdi_ready <= '0';
						arithm_FIFO_wr_en <= '0';
						CPA_PKE_counter_enable <= '0';
						CPA_PKE_counter_reset <= '1';
					else
						demux_arithm <= "11";
						pdi_ready <= '1';
						arithm_FIFO_wr_en <= '1';
						CPA_PKE_counter_enable <= '1';
						CPA_PKE_counter_reset <= '0';
					end if;
				else
					CPA_PKE_counter_enable <= '0';
				end if;
				
			when MoveA =>
				if hash_FIFO_Empty /= '1' then
					hash_FIFO_rd_en <= '1';
					arithm_FIFO_wr_en <= '1';
					demux_arithm <= "00";
					pdo_demux_ctrl <= "01";
				else
					hash_FIFO_rd_en <= '0';
					arithm_FIFO_wr_en <= '0';
					CPA_PKE_FSM <= Load_RHO;
				end if;
			
			when Load_RHO =>
				if rdi_valid = '1' then
					if control_counter = CPA_RHO_LOAD_CYCLES then -- NEXT MSG			
						CPA_PKE_FSM <= LOAD_MSG;					
						rdi_ready <= '0';
						hash_FIFO_wr_en <= '0';
						CPA_PKE_counter_enable <= '0';
						CPA_PKE_counter_reset <= '1';
					else
						demux_hash <= "01";
						rdi_ready <= '1';
						hash_FIFO_wr_en <= '1';
						CPA_PKE_counter_enable <= '1';
						CPA_PKE_counter_reset <= '0';
					end if;
				else
					rdi_ready <= '0';
					CPA_PKE_counter_enable <= '0';
				end if;
				
			when LOAD_MSG =>
				if pdi_valid = '1' then
					if control_counter = CPA_KEM_MSG_LOAD_CYCLES then 		
						CPA_PKE_FSM <= Move_RHO;					
						pdi_ready <= '0';
						arithm_FIFO_wr_en <= '0';
						CPA_PKE_counter_enable <= '0';
						CPA_PKE_counter_reset <= '1';
					else
						demux_arithm <= "11";
						pdi_ready <= '1';
						arithm_FIFO_wr_en <= '1';
						CPA_PKE_counter_enable <= '1';
						CPA_PKE_counter_reset <= '0';
					end if;
				else
					pdi_ready <= '1';
					CPA_PKE_counter_enable <= '0';
				end if;
				
			when MOVE_RHO =>
				if hash_FIFO_Empty /= '1' then
					if control_counter = CPA_KEM_MOVE_RHO_LOAD_CYCLES then
						hash_FIFO_rd_en <= '0';
						arithm_FIFO_wr_en <= '0';
						demux_arithm <= "00";
						pdo_demux_ctrl <= "01";
						CPA_PKE_FSM <= ENCRYPT;
					else
						demux_arithm <= "00";
						pdo_demux_ctrl <= "01";
						hash_FIFO_rd_en <= '1';
						arithm_FIFO_wr_en <= '1';
						CPA_PKE_counter_enable <= '1';
						CPA_PKE_counter_reset <= '0';
					end if;
				end if;
				
			when ENCRYPT =>
				if arithm_FIFO_Empty /= '1' then
					pdo_valid <= '1';
					if pdo_ready = '1' then 
						if control_counter = CPA_KEM_RESULT_LOAD_CYCLES then
							arithm_FIFO_rd_en <= '0';
							CPA_PKE_FSM <= DONE;
							CPA_PKE_counter_enable <= '0';
							CPA_PKE_counter_reset <= '1';
						else
							pdo_demux_ctrl <= "10";
							arithm_FIFO_rd_en <= '1';
							CPA_PKE_counter_enable <= '1';
							CPA_PKE_counter_reset <= '0';
						end if;
					end if;
				else
					arithm_FIFO_rd_en <= '0';
					pdo_valid <= '0';
				end if;
				
				
			when DEC_Gen_S_from_sk => 
				if control_counter = CPA_PKE_SK_LOAD_CYCLES then
					CPA_PKE_FSM <= LoadCTV;					
					pdi_ready <= '0';
					hash_FIFO_wr_en <= '0';
					CPA_PKE_counter_enable <= '0';
					CPA_PKE_counter_reset <= '1';
				else
					if pdi_valid = '1' then		
						demux_hash <= "10";
						pdi_ready <= '1';
						hash_FIFO_wr_en <= '1';
						CPA_PKE_counter_enable <= '1';
						CPA_PKE_counter_reset <= '0';
					else
						CPA_PKE_counter_enable <= '0';
					end if;
				end if;
			
			when LoadCTV =>
				if control_counter = CPA_PKE_CTV_LOAD_CYCLES then
					CPA_PKE_FSM <= MoveSK;					
					pdi_ready <= '0';
					arithm_FIFO_wr_en <= '0';
					CPA_PKE_counter_enable <= '0';
					CPA_PKE_counter_reset <= '1';
				else
					if pdi_valid = '1' then		
						demux_arithm <= "11";
						pdi_ready <= '1';
						arithm_FIFO_wr_en <= '1';
						CPA_PKE_counter_enable <= '1';
						CPA_PKE_counter_reset <= '0';
					else
						CPA_PKE_counter_enable <= '0';
					end if;
				end if;
			
				
			when MoveSK =>
				if control_counter = CPA_PKE_PolyB_MOVE_CYCLES then
					CPA_PKE_FSM <= DECRYPT;					
					arithm_FIFO_wr_en <= '0';
					hash_FIFO_rd_en <= '0';
					CPA_PKE_counter_enable <= '0';
					CPA_PKE_counter_reset <= '1';
				else
					if hash_FIFO_Empty /= '1' then		
						demux_arithm <= "00";
						pdo_demux_ctrl <= "01";
						arithm_FIFO_wr_en <= '1';
						hash_FIFO_rd_en <= '1';
						CPA_PKE_counter_enable <= '1';
						CPA_PKE_counter_reset <= '0';
					else
						CPA_PKE_counter_enable <= '0';
					end if;
				end if;
			
			when DECRYPT =>
				if arithm_FIFO_Empty /= '1' then
					pdo_valid <= '1';
					if pdo_ready = '1' then 
						if control_counter = CPA_PKE_DEC_RESULT_LOAD_CYCLES then
							arithm_FIFO_rd_en <= '0';
							CPA_PKE_FSM <= DONE;
							CPA_PKE_counter_enable <= '0';
							CPA_PKE_counter_reset <= '1';
						else
							pdo_demux_ctrl <= "10";
							arithm_FIFO_rd_en <= '1';
							CPA_PKE_counter_enable <= '1';
							CPA_PKE_counter_reset <= '0';
						end if;
					end if;
				else
					arithm_FIFO_rd_en <= '0';
					pdo_valid <= '0';
				end if;
				
			

			when others =>
				CPA_PKE_FSM <= idle;
				arithm_FIFO_rd_en <= '0';
				arithm_FIFO_wr_en <= '0';
				hash_FIFO_rd_en <= '0';
				hash_FIFO_wr_en <= '0';
				CPA_PKE_counter_enable <= '0';
				CPA_PKE_counter_reset <= '1';
				
				
		end case;
	end if;
end process;




end a1;

