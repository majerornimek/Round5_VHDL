library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;
use work.sha_tb_pkg.all;



entity Round5_top_controller_CCA_PKE is
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
			pdo_demux_ctrl	: out std_logic_vector(2 downto 0);
			sdo_demux_ctrl	: out std_logic_vector(2 downto 0);
			
			
		
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
			aead_FIFO_Empty		: in std_logic;
			
			---- MEMORY CONTROL SIGNALS
			mem_FIFO_wr_en		: out std_logic;
			mem_FIFO_rd_en		: out std_logic;
			mem_FIFO_Full		: in std_logic;
			mem_FIFO_Empty		: in std_logic;
			demux_mem			: out std_logic_vector(1 downto 0)
			
			
		);
end entity;


architecture a1 of Round5_top_controller_CCA_PKE is 

type GlobalStateMachine is (idle, CPA_PKE, CPA_KEM, CCA_KEM, CCA_PKE, test_hash, test_arithm);
type CCA_KEM_StateMachine is (idle,MOVE_G, AEAD, Move_Sigma_From_MEM,Gen_from_RHO, DEC_Gen_S_from_sk,Gen_A_from_sigma,LoadB, MOVE_RHO, MoveA,CCA_KEM_First_Hash, Load_PK, Load_RHO, LOAD_MSG, ENCRYPT,LoadCTV, MoveSK, DECRYPT,ENCAPS_HASH, DECAPS_HASH,  x1,x2, done);
type CCA_PKE_StateMachine is (idle,Gen_A_from_sigma, Move_polyA_to_arithm, generate_command_to_store_B, load_B, read_MSG, move_rho_to_arithm, sec_hash, Gen_RHO, encrypt, decrypt, dec_hash, aes, done);


signal G_FSM 		: GlobalStateMachine := idle;
signal CCA_KEM_FSM	: CCA_KEM_StateMachine := idle;
signal CCA_PKE_FSM 	: CCA_PKE_StateMachine := idle;




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

control_enable_tick <= CCA_KEM_counter_enable; 
reset_counter <= CCA_KEM_counter_reset; 



process(rst,clk)
begin
	if rst = '1' then
		CCA_KEM_FSM <= idle;
		CCA_KEM_counter_enable <= '0';
		CCA_KEM_counter_reset <= '1';
	elsif clk'event and clk = '1' then
		case CCA_KEM_FSM is
			when idle =>
				if pdi_valid = '1' then
					pdi_ready <= '1';
					rst_arithm <= '0';
					rst_hash <= '0';
					rst_aead <= '0';
					CCA_KEM_counter_enable <= '0';
					CCA_KEM_counter_reset <= '0';
					if pdi_data(63 downto 60)  = "0100" then
						CCA_KEM_FSM <= Load_MSG;
					elsif pdi_data(63 downto 60) = "0101" then 
						CCA_KEM_FSM <= DEC_Gen_S_from_sk;
					else
						CCA_KEM_FSM <= Load_MSG;  ---- SHOULD BE ERROR HANDLING
					end if;
				else
					pdi_ready <= '0';
					rst_arithm <= '1';
					rst_hash <= '1';
					rst_aead <= '1';
					CCA_KEM_counter_enable <= '0';
					CCA_KEM_counter_reset <= '1';
				end if;
			
			
			when Load_MSG => 
				if control_counter = CCA_MSG_LOAD_CYCLES then
					arithm_FIFO_wr_en <= '0';
					hash_FIFO_wr_en <= '0';
					rdi_ready <= '0';
					CCA_KEM_FSM <= Load_PK;
					CCA_KEM_counter_enable <= '0';
					CCA_KEM_counter_reset <= '1';
				else
					if rdi_valid = '1' then
						demux_arithm <= "01";
						demux_hash <= "01";
						arithm_FIFO_wr_en <= '1';
						hash_FIFO_wr_en <= '1';
						rdi_ready <= '1';
						CCA_KEM_counter_enable <= '1';
						CCA_KEM_counter_reset <= '0';
					else
						arithm_FIFO_wr_en <= '0';
						hash_FIFO_wr_en <= '0';
						CCA_KEM_counter_enable <= '0';
						CCA_KEM_counter_reset <= '0';
					end if;
				end if;
			
			
			when Load_PK =>
				if control_counter = CCA_PK_LOAD_CYCLES then
					mem_FIFO_wr_en <= '0';
					arithm_FIFO_wr_en <= '0';
					hash_FIFO_wr_en <= '0';
					pdi_ready <= '0';
					CCA_KEM_FSM <= CCA_KEM_First_Hash;
					CCA_KEM_counter_enable <= '0';
					CCA_KEM_counter_reset <= '1';
				else
					if pdi_valid = '1' then
						if control_counter < CCA_SIGMA_LOAD_CYCLES then
							mem_FIFO_wr_en <= '1';
							arithm_FIFO_wr_en <= '0';
						else
							mem_FIFO_wr_en <= '0';
							arithm_FIFO_wr_en <= '1';
						end if;
						demux_mem <= "11";
						demux_arithm <= "11";
						demux_hash <= "11";
						
						hash_FIFO_wr_en <= '1';
						pdi_ready <= '1';
						CCA_KEM_counter_enable <= '1';
						CCA_KEM_counter_reset <= '0';
					else
						mem_FIFO_wr_en <= '0';
						arithm_FIFO_wr_en <= '0';
						hash_FIFO_wr_en <= '0';
						CCA_KEM_counter_enable <= '0';
						CCA_KEM_counter_reset <= '0';
					end if;
				end if;
			
			when CCA_KEM_First_Hash =>
				if hash_FIFO_Empty /= '1' then
					if control_counter < CCA_L_G_MOVE_CYCLES then
						mem_FIFO_wr_en <= '1';
						hash_FIFO_wr_en <= '0';
					else
						mem_FIFO_wr_en <= '0';
						hash_FIFO_wr_en <= '1';
					end if;
					
					hash_FIFO_rd_en <= '1';
					pdo_demux_ctrl <= "001";
					demux_hash <= "00";
					demux_mem <= "00";
					CCA_KEM_counter_enable <= '1';
					CCA_KEM_counter_reset <= '0';
				
				elsif control_counter = CCA_L_G_RHO_MOVE_CYCLES then
					CCA_KEM_FSM <= Gen_from_RHO;
					mem_FIFO_wr_en <= '0';
					hash_FIFO_wr_en <= '0';
					hash_FIFO_rd_en <= '0';
					CCA_KEM_counter_enable <= '0';
					CCA_KEM_counter_reset <= '1';
				end if;	
				
			when Gen_from_RHO =>
				if hash_FIFO_Empty /= '1' then
					arithm_FIFO_wr_en <= '1';
					hash_FIFO_rd_en <= '1';
					pdo_demux_ctrl <= "001";
					demux_arithm <= "00";
					CCA_KEM_counter_enable <= '1';
					CCA_KEM_counter_reset <= '0';
				
				elsif control_counter = CCA_L_G_RHO_MOVE_CYCLES then
					CCA_KEM_FSM <= Move_Sigma_From_MEM;
					arithm_FIFO_wr_en <= '0';
					mem_FIFO_wr_en <= '0';
					hash_FIFO_wr_en <= '0';
					hash_FIFO_rd_en <= '0';
					CCA_KEM_counter_enable <= '0';
					CCA_KEM_counter_reset <= '1';
				end if;	
			
			when Move_Sigma_From_MEM =>
				if control_counter < CCA_SIGMA_MOVE_CYCLES then
					hash_FIFO_wr_en <= '1';
					mem_FIFO_rd_en <= '1';
					demux_hash <= "00";
					pdo_demux_ctrl <= "100";
					CCA_KEM_counter_enable <= '1';
					CCA_KEM_counter_reset <= '0';
				else
					hash_FIFO_wr_en <= '0';
					mem_FIFO_rd_en <= '0';
					CCA_KEM_FSM <= Gen_A_from_sigma;
					CCA_KEM_counter_enable <= '0';
					CCA_KEM_counter_reset <= '1';
				end if;
			
			
			when Gen_A_from_sigma =>
				if hash_FIFO_Empty /= '1' then
					if control_counter = CCA_PolyA_MOVE_CYCLES then -- NEXT MSG			
						CCA_KEM_FSM <= ENCRYPT;					
						hash_FIFO_rd_en <= '0';
						arithm_FIFO_wr_en <= '0';
						CCA_KEM_counter_enable <= '0';
						CCA_KEM_counter_reset <= '1';
					else
						pdo_demux_ctrl <= "001";
						demux_arithm <= "00";
						hash_FIFO_rd_en <= '1';
						arithm_FIFO_wr_en <= '1';
						CCA_KEM_counter_enable <= '1';
						CCA_KEM_counter_reset <= '0';
					end if;
				else
					CCA_KEM_counter_enable <= '0';
					CCA_KEM_counter_reset <= '0';
				end if;
			
			
			when ENCRYPT =>  --- STORE OUTSIDE AND TO HASH
				if arithm_FIFO_Empty /= '1' then
					pdo_valid <= '1';
					if pdo_ready = '1' then 
						if control_counter = CCA_CT_LOAD_CYCLES then
							hash_FIFO_wr_en <= '0';
							arithm_FIFO_rd_en <= '0';
							CCA_KEM_FSM <= MOVE_G;
							CCA_KEM_counter_enable <= '0';
							CCA_KEM_counter_reset <= '1';
						else
							pdo_demux_ctrl <= "010";
							demux_hash <= "00"; 
							hash_FIFO_wr_en  <= '1';
							arithm_FIFO_rd_en <= '1';
							CCA_KEM_counter_enable <= '1';
							CCA_KEM_counter_reset <= '0';
						end if;
					end if;
				else
					---- MOVE L TO HASH
					if control_counter = CCA_KEM_L_MOVE_CYCLES then
						hash_FIFO_wr_en <= '1';
						mem_FIFO_rd_en  <= '1';
						pdo_demux_ctrl <= "100";
						demux_hash <= "00";
						CCA_KEM_counter_enable <= '1';
						CCA_KEM_counter_reset <= '0';
					else
						hash_FIFO_wr_en <= '0';
						mem_FIFO_rd_en  <= '0';
						CCA_KEM_counter_enable <= '0';
						CCA_KEM_counter_reset <= '1';
					end if;
					pdo_valid <= '0';
				end if;
			
			
			when MOVE_G =>
				if control_counter = CCA_KEM_L_MOVE_CYCLES then
					mem_FIFO_rd_en <= '0';
					hash_FIFO_wr_en <= '0';
					CCA_KEM_FSM <= ENCAPS_HASH;
					CCA_KEM_counter_enable <= '0';
					CCA_KEM_counter_reset <= '1';
				else
					mem_FIFO_rd_en <= '1';
					hash_FIFO_wr_en <= '1';
					demux_hash <= "00";
					pdo_demux_ctrl <= "100";
					CCA_KEM_counter_enable <= '1';
					CCA_KEM_counter_reset <= '0';
				end if;
				
			when ENCAPS_HASH => 
				if hash_FIFO_Empty /= '1' then
					sdo_valid <= '1';
					if sdo_ready = '1' then 
						if control_counter = CCA_KEM_ENCAPS_HASH_RESULT_LOAD_CYCLES then
							hash_FIFO_rd_en <= '0';
							CCA_KEM_FSM <= AEAD;
							CCA_KEM_counter_enable <= '0';
							CCA_KEM_counter_reset <= '1';
						else
							sdo_demux_ctrl <= "001";
							aead_FIFO_wr_en <= '1';
							hash_FIFO_rd_en <= '1';
							CCA_KEM_counter_enable <= '1';
							CCA_KEM_counter_reset <= '0';
						end if;
					end if;
				else
					hash_FIFO_rd_en <= '0';
					sdo_valid <= '0';
				end if;
			
			when AEAD => 
				if aead_FIFO_Empty /= '1' then
					sdo_valid <= '1';
					if sdo_ready = '1' then 
						if control_counter = CCA_KEM_ENCAPS_HASH_RESULT_LOAD_CYCLES then
							aead_FIFO_rd_en <= '0';
							CCA_KEM_FSM <= Done;
							CCA_KEM_counter_enable <= '0';
							CCA_KEM_counter_reset <= '1';
						else
							sdo_demux_ctrl <= "011";
							aead_FIFO_rd_en <= '1';
	
							CCA_KEM_counter_enable <= '1';
							CCA_KEM_counter_reset <= '0';
						end if;
					end if;
				else
					CCA_KEM_counter_enable <= '0';
					aead_FIFO_rd_en <= '0';
					sdo_valid <= '0';
				end if;
				
				
		
			
			---------------- DECAPS
			
			when DEC_Gen_S_from_sk => 
				if control_counter = CCA_SK_LOAD_CYCLES then
					CCA_KEM_FSM <= LoadCTV;					
					pdi_ready <= '0';
					hash_FIFO_wr_en <= '0';
					CCA_KEM_counter_enable <= '0';
					CCA_KEM_counter_reset <= '1';
				else
					if pdi_valid = '1' then		
						demux_hash <= "10";
						pdi_ready <= '1';
						hash_FIFO_wr_en <= '1';
						CCA_KEM_counter_enable <= '1';
						CCA_KEM_counter_reset <= '0';
					else
						CCA_KEM_counter_enable <= '0';
					end if;
				end if;
			
			when LoadCTV =>
				if control_counter = CCA_CTV_LOAD_CYCLES then
					CCA_KEM_FSM <= MoveSK;					
					pdi_ready <= '0';
					arithm_FIFO_wr_en <= '0';
					CCA_KEM_counter_enable <= '0';
					CCA_KEM_counter_reset <= '1';
				else
					if pdi_valid = '1' then		
						demux_arithm <= "11";
						pdi_ready <= '1';
						arithm_FIFO_wr_en <= '1';
						CCA_KEM_counter_enable <= '1';
						CCA_KEM_counter_reset <= '0';
					else
						CCA_KEM_counter_enable <= '0';
					end if;
				end if;
			
				
			when MoveSK =>
				if control_counter = CPA_PKE_PolyB_MOVE_CYCLES then
					CCA_KEM_FSM <= DECRYPT;					
					arithm_FIFO_wr_en <= '0';
					hash_FIFO_rd_en <= '0';
					CCA_KEM_counter_enable <= '0';
					CCA_KEM_counter_reset <= '1';
				else
					if hash_FIFO_Empty /= '1' then		
						demux_arithm <= "00";
						pdo_demux_ctrl <= "001";
						arithm_FIFO_wr_en <= '1';
						hash_FIFO_rd_en <= '1';
						CCA_KEM_counter_enable <= '1';
						CCA_KEM_counter_reset <= '0';
					else
						arithm_FIFO_wr_en <= '0';
						hash_FIFO_rd_en <= '0';
						CCA_KEM_counter_enable <= '0';
					end if;
				end if;
			
			when DECRYPT =>  --- MOVE OUT AND TO HASH
				if arithm_FIFO_Empty /= '1' then
					pdo_demux_ctrl <= "010";
					demux_hash <= "00";
					hash_FIFO_wr_en <= '1';
					arithm_FIFO_rd_en <= '1';
					CCA_KEM_counter_enable <= '1';
					CCA_KEM_counter_reset <= '0';
				else
					if control_counter = CCA_PKE_DEC_RESULT_LOAD_CYCLES then
						hash_FIFO_wr_en <= '0';
						arithm_FIFO_rd_en <= '0';
						CCA_KEM_FSM <= Load_PK;
						CCA_KEM_counter_enable <= '0';
						CCA_KEM_counter_reset <= '1';
					else
						hash_FIFO_wr_en <= '0';
						arithm_FIFO_rd_en <= '0';
						CCA_KEM_counter_enable <= '0';
					end if;					
				end if;
		
		
		

			when others =>
				CCA_KEM_FSM <= idle;
				arithm_FIFO_rd_en <= '0';
				arithm_FIFO_wr_en <= '0';
				hash_FIFO_rd_en <= '0';
				hash_FIFO_wr_en <= '0';
				CCA_KEM_counter_enable <= '0';
				CCA_KEM_counter_reset <= '1';
				
				
		end case;
	end if;
end process;




end a1;

