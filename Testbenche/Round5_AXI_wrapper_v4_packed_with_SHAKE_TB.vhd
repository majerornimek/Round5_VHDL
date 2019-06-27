library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;
use work.sha3_pkg.all;
use work.sha_tb_pkg.all;

entity Round5_AXI_wrapper_v4_packed_with_SHAKE_TB is	
	end entity;
	
architecture a1 of Round5_AXI_wrapper_v4_packed_with_SHAKE_TB is 

component Round5_AXI_wrapper_v4_packed_with_SHAKE is	
	port(
	rst 		: in std_logic;
	clk			: in std_logic;
	-- FIFO WRITE
	FIFO_Full	: out std_logic;
	FIFO_din	: in std_logic_vector(63 downto 0);
	FIFO_wr_en	: in std_logic;
	-- FIFO READ
	FIFO_Empty	: out std_logic;
	FIFO_dout	: out std_logic_vector(63 downto 0);
	FIFO_rd_en	: in std_logic
	);
end component;

signal FIFO_Full_tmp, FIFO_wr_en_tmp, FIFO_Empty_tmp, FIFO_rd_en_tmp : std_logic;
signal FIFO_din_tmp, FIFO_dout_tmp : std_logic_vector(63 downto 0); 

signal start_module, reset_module, done_module 	: std_logic;
signal op_module	: std_logic;
signal op_selected  : std_logic;


------	DATA REGISTERS
signal PolyA_tmp 	: std_logic_vector(PolyA_cycle*AXI_data_width-1 downto 0); 	-- register to store input data to arithm module with overhead to store full input words
signal PolyB_tmp 	: std_logic_vector(PolyB_cycle*AXI_data_width-1 downto 0);
signal PolyR_tmp 	: std_logic_vector(PolyR_cycle*AXI_data_width-1 downto 0);
signal Message_tmp 	: std_logic_vector(Message_cycle*AXI_data_width-1 downto 0);
signal ctV_tmp		: std_logic_vector(ctV_cycle*AXI_data_width-1 downto 0);

signal FirstPart_tmp	: std_logic_vector(FirstPart_cycle*AXI_data_width-1 downto 0);
signal SecondPart_tmp	: std_logic_vector(SecondPart_cycle*AXI_data_width-1 downto 0);
signal Dec_Msg_tmp		: std_logic_vector(MessageLen-1 downto 0);

------	ADDRES POINTERS/COUNTERS
signal PolyA_count	: std_logic_vector(7 downto 0); -- point the region in PolyA_tmp register to write
signal PolyB_count	: std_logic_vector(7 downto 0); 
signal PolyR_count	: std_logic_vector(7 downto 0); 
signal Message_count	: std_logic_vector(3 downto 0); 
signal ctV_count	: std_logic_vector(7 downto 0);

--signal FirstPart_count 	: std_logic_vector(7 downto 0);
--signal SecondPart_count : std_logic_vector(7 downto 0);
--signal Dec_Msg_count 	: std_logic_vector(3 downto 0);
signal Output_count	: std_logic_vector(7 downto 0);
signal Out_saved 	: std_logic;	

------- POLYNOMIALS
signal PolyA_poly  : q_bitsPoly(PolyDegree-1 downto 0);
signal PolyB_poly  : p_bitsPoly(PolyDegree downto 0);
signal PolyR_poly  : Trinomial(PolyDegree-1 downto 0);
signal ctV_poly    : t_bitsPoly(PolyDegree-1 downto 0);
signal FirstPart_poly : p_bitsPoly(PolyDegree-1 downto 0);
signal SecondPart_poly: t_bitsPoly(MessageLen-1 downto 0);


------	DATA FLAGS
constant PolyA_addr 	: std_logic_vector(3 downto 0) := "0001";
constant PolyB_addr 	: std_logic_vector(3 downto 0) := "0010";
constant PolyR_addr 	: std_logic_vector(3 downto 0) := "0011";
constant Message_addr 	: std_logic_vector(3 downto 0) := "0100";
constant ctV_addr 		: std_logic_vector(3 downto 0) := "0101";

constant FirstPart_addr	: std_logic_vector(3 downto 0) := "0001";
constant SecondPart_addr: std_logic_vector(3 downto 0) := "0010";
constant Dec_Msg_addr	: std_logic_vector(3 downto 0) := "0011";

------------------------
signal input_pointer 		: std_logic_vector(9 downto 0) := (others => '0');
signal input_pointer_max	: std_logic_vector(9 downto 0) := (others => '0');
signal output_pointer		: std_logic_vector(7 downto 0) := (others => '0');
signal output_pointer_max	: std_logic_vector(7 downto 0) := (others => '0');

signal COMMAND			: std_logic_vector(7 downto 0) := (others => '0');
--	COMMAND FORMAT:  start|done|error|dec/end(0/1)|A|B|R|msg/ctv
signal RECIVED_CMD		: std_logic := '0';

signal clk : std_logic;
constant CLK_PERIOD : time := 10 ps;
signal random_data_counter : std_logic_vector(63 downto 0);
signal started, rst_tmp : std_logic;
constant Zero_fill : std_logic_vector(55 downto 0) := (others => '0');
begin

	clk_process :process
	begin
        clk <= '0';
        wait for CLK_PERIOD/2;  --for half of clock period clk stays at '0'.
        clk <= '1';
        wait for CLK_PERIOD/2;  --for next half of clock period clk stays at '1'.
	end process;

	uut: Round5_AXI_wrapper_v4_packed_with_SHAKE port map(
		rst => rst_tmp,
		clk			=> clk,
	-- FIFO WRITE
		FIFO_Full	=> FIFO_Full_tmp,
		FIFO_din	=> FIFO_din_tmp,
		FIFO_wr_en	=> FIFO_wr_en_tmp,
		-- FIFO READ
		FIFO_Empty	=> FIFO_Empty_tmp,
		FIFO_dout	=> FIFO_dout_tmp,
		FIFO_rd_en	=> FIFO_rd_en_tmp	
	);

		
process(clk)
begin
	if clk'event and clk = '1' then
		if started = '1' then
			random_data_counter <= random_data_counter + '1';
		else
			random_data_counter <= (others => '0');
		end if;
	end if;
end process;
		
		
working: process
begin
	started <= '0';
	rst_tmp <= '1';
	
	wait for CLK_PERIOD;
	rst_tmp <= '0';
	started <= '1';
	COMMAND <= "00011000";
	wait for CLK_PERIOD;
	
	FIFO_din_tmp <= COMMAND & Zero_fill;
	FIFO_wr_en_tmp <= '1';
	
	for i in Sigma_cycle_start to Sigma_cycle_end loop
		wait for CLK_PERIOD;
		FIFO_din_tmp <= random_data_counter;
	end loop;
	wait for CLK_PERIOD;
	FIFO_wr_en_tmp <= '0';
	COMMAND <= "00010100";
	wait for CLK_PERIOD;
	
	FIFO_wr_en_tmp <= '1';
	
	FIFO_din_tmp <= COMMAND & Zero_fill;
	for i in PolyB_cycle_start to PolyB_cycle_end loop
		wait for CLK_PERIOD;
		FIFO_din_tmp <= random_data_counter;
	end loop;
	wait for CLK_PERIOD;
	FIFO_wr_en_tmp <= '0';
	COMMAND <= "00010010";
	wait for CLK_PERIOD;
	
	FIFO_wr_en_tmp <= '1';
	
	FIFO_din_tmp <= COMMAND & Zero_fill;
	for i in Rho_cycle_start to Rho_cycle_end loop
		wait for CLK_PERIOD;
		FIFO_din_tmp <= random_data_counter;
	end loop;
	wait for CLK_PERIOD;
	FIFO_wr_en_tmp <= '0';
	COMMAND <= "00010001";
	wait for CLK_PERIOD;
	
	FIFO_wr_en_tmp <= '1';
	
	FIFO_din_tmp <= COMMAND & Zero_fill;
	for i in Message_cycle_start to Message_cycle_end loop
		wait for CLK_PERIOD;
		FIFO_din_tmp <= random_data_counter;
	end loop;
	wait for CLK_PERIOD;
	FIFO_wr_en_tmp <= '0';
	COMMAND <= "10010000";
	wait for CLK_PERIOD;
	
	wait for CLK_PERIOD;
	FIFO_wr_en_tmp <= '1';
	FIFO_din_tmp <= COMMAND & Zero_fill;
	wait for CLK_PERIOD;
	FIFO_wr_en_tmp <= '0';
	
	
	wait until FIFO_Empty_tmp = '1';
	wait for CLK_PERIOD*6;
	
	if FIFO_Empty_tmp = '1' then
		for i in FirstPart_cycle_start to SecondPart_cycle_end loop
			FIFO_rd_en_tmp <= '1';
			wait for CLK_PERIOD;
		end loop;
	end if;
	
	
	
	---- DECIPHER DATA:
	FIFO_wr_en_tmp <= '0';
	COMMAND <= "00000001";
	wait for CLK_PERIOD;
	
	FIFO_wr_en_tmp <= '1';
	
	FIFO_din_tmp <= COMMAND & Zero_fill;
	for i in Message_cycle_start to Message_cycle_end loop
		wait for CLK_PERIOD;
		FIFO_din_tmp <= random_data_counter;
	end loop;
	wait for CLK_PERIOD;
	FIFO_wr_en_tmp <= '0';

	COMMAND <= "10000000"; --DECIP_START
	wait for CLK_PERIOD;
	
	wait for CLK_PERIOD;
	FIFO_wr_en_tmp <= '1';
	FIFO_din_tmp <= COMMAND & Zero_fill;
	wait for CLK_PERIOD;
	FIFO_wr_en_tmp <= '0';
	
	
end process;


-- process(clk)
-- begin
	-- if clk'event and clk = '1' then
		-- if FIFO_wr_en = '1' then
			-- if RECIVED_CMD = '0' then
				-- case FIFO_din(61 downto 56) is
					-- --ENC
					-- when "11000" => 		-- Encryption, PolyA
						-- input_pointer 		<= std_logic_vector(to_unsigned(PolyA_cycle_start,10));
						-- input_pointer_max 	<= std_logic_vector(to_unsigned(PolyA_cycle_end,10));
					-- when "10100" => 		-- Encryption, PolyB`
						-- input_pointer 		<= std_logic_vector(to_unsigned(PolyB_cycle_start,10));
						-- input_pointer_max 	<= std_logic_vector(to_unsigned(PolyB_cycle_end,10));
					-- when "10010" => 		-- Encryption, PolyR
						-- input_pointer 		<= std_logic_vector(to_unsigned(PolyR_cycle_start,10));
						-- input_pointer_max 	<= std_logic_vector(to_unsigned(PolyR_cycle_end,10));
					-- when "10001" => 		-- Encryption, Msg
						-- input_pointer 		<= std_logic_vector(to_unsigned(Message_cycle_start,10));
						-- input_pointer_max 	<= std_logic_vector(to_unsigned(Message_cycle_end,10));
					
					-- -- DEC
					-- when "00100" => 		-- Decryption, PolyB
						-- input_pointer 		<= std_logic_vector(to_unsigned(PolyB_dec_cycle_start,10));
						-- input_pointer_max 	<= std_logic_vector(to_unsigned(PolyB_dec_cycle_end,10));
					-- when "00010" => 		-- Decryption, PolyR
						-- input_pointer 		<= std_logic_vector(to_unsigned(PolyR_dec_cycle_start,10));
						-- input_pointer_max 	<= std_logic_vector(to_unsigned(PolyR_dec_cycle_end,10));
					-- when "00001" => 		-- Decryption, ctV
						-- input_pointer 		<= std_logic_vector(to_unsigned(ctV_cycle_start,10));
						-- input_pointer_max 	<= std_logic_vector(to_unsigned(ctV_cycle_end,10));
					-- when others => 
				-- end case;
				-- RECIVED_CMD <= '1';
				-- COMMAND <= FIFO_din(63 downto 56);
			-- else
				-- if input_pointer < input_pointer_max then
					-- input_pointer <= input_pointer + '1';
				-- else
					-- RECIVED_CMD <= '0';
				-- end if;
			
			-- end if;
		-- else
			-- RECIVED_CMD <= '0';
		-- end if;
	-- end if;
-- end process;
		
		
		
		
-- process(clk)
-- begin
	-- if clk'event and clk = '1' then 
		-- if FIFO_rd_en = '1' then 
			-- if output_pointer < output_pointer_max then
				-- output_pointer <= output_pointer + '1';
				-- FIFO_Empty <= '1';
			-- else
					-- FIFO_Empty <= '0';
			-- end if;
		-- else
			-- if op_module = '0' then --dec
				-- output_pointer 		<= std_logic_vector(to_unsigned(dec_msg_cycle_start,8));
				-- output_pointer_max 	<= std_logic_vector(to_unsigned(dec_msg_cycle_end,8));
			-- else -- enc
				-- output_pointer 		<= std_logic_vector(to_unsigned(FirstPart_cycle_start,8));
				-- output_pointer_max 	<= std_logic_vector(to_unsigned(SecondPart_cycle_end,8));
			-- end if;
			
			-- if done_module = '1' then
				-- FIFO_Empty <= '1'; 		--- NOT SURE IF CORRECT SIGNAL
			-- else
				-- FIFO_Empty <= '0';
			-- end if;
			
		-- end if;
	-- end if;
-- end process;



process(clk)
begin
	if clk'event and clk = '1' then
	
	
	end if;
end process;









end a1;
