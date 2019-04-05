--------------
-- 	Author: 	Michal Andrzejczak
-- 	Mail:		michal.r.andrzejczak@gmail.com
--	
--	Desc:		Round5_arithmtic module frapper. Connect the module with SoC via AXI bus.
--	Info:
--				Round5_arithm has following data ports:
--					INPUT:			DATA WIDTH (bits)		R5ND_1KEM
--						PolyA	- PolyDegree * q_bits			6798
--						PolyB	- PolyDegree * p_bits			4944
--						PolyR	- PolyDegree * 2				1236
--						Message - MessageLen					128
--						ctV		- MessageLen * t_bits			512
--					
--					OUTPU:
--						FirstPart 	- 	PolyDegree * p_bits
--						SecondPart 	- 	MessageLen * t_bits
--						Dec_Msg		- 	MessageLen
-- TODO:
--		- manage start, reset module
--		- manage operation selection
-- 		- manage handling fifo read signal etc

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity Round5_AXI_wrapper is	
	port(
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
end entity;


architecture a1 of Round5_AXI_wrapper is 

component Round5_enc_arith is	
	port (
		PolyA			: in q_bitsPoly(PolyDegree-1 downto 0);  --W enc: A
		PolyB			: in p_bitsPoly(PolyDegree downto 0);	--W enc: polyB,   W dec: polyU
		PolyR			: in Trinomial(PolyDegree-1 downto 0); --W enc: poly R   W dec: polyS
		Message		    : in std_logic_vector(MessageLen-1 downto 0);
		ctV             : in t_bitsPoly(MessageLen-1  downto 0);
        
        
		clk			: in std_logic;
		Start			: in std_logic;
		Reset			: in std_logic;
		Operation	: in std_logic;  -- 1 enc, 0 dec
		Done        : out std_logic;
		
		FirstPart	: out p_bitsPoly(PolyDegree-1 downto 0);
		SecondPart	: out t_bitsPoly(MessageLen-1  downto 0);
        
		Dec_Msg		: out std_logic_vector(MessageLen-1 downto 0)
		
	);
end component;

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

--signal OutputTmp		: std_logic_vector((FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width-1 downto 0);
--signal Output_Reg       : std_logic_vector((FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width-1 downto 0);
--signal Encrypted_Reg	: std_logic_vector((FirstPart_cycle+SecondPart_cycle)*AXI_data_width-1 downto 0);

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

signal Round5_status	: std_logic_vector(63 downto AXI_data_width) := (others => '0');
------------------------
signal input_pointer 		: std_logic_vector(9 downto 0) := (others => '0');
signal input_pointer_max	: std_logic_vector(9 downto 0) := (others => '0');
signal output_pointer		: std_logic_vector(7 downto 0) := (others => '0');
signal output_pointer_max	: std_logic_vector(7 downto 0) := (others => '0');

signal COMMAND			: std_logic_vector(7 downto 0) := (others => '0');
--	COMMAND FORMAT:  start|done|error|dec/end(0/1)|A|B|R|msg/ctv
signal RECIVED_CMD		: std_logic := '0';
begin

	arit: Round5_enc_arith port map(
		PolyA			=> PolyA_poly(PolyDegree-1 downto 0),
		PolyB			=> PolyB_poly(PolyDegree downto 0),
		PolyR			=> PolyR_poly(PolyDegree-1 downto 0),
		Message		    => Message_tmp(MessageLen-1 downto 0),
		ctV             => ctV_poly(MessageLen-1 downto 0),
        
        
		clk			=> clk,
		Start		=> start_module,
		Reset		=> reset_module,
		Operation	=> op_module,
		Done		=> done_module,
		
		FirstPart	=> FirstPart_poly,
        --OutputTmp((SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width-1+PolyDegree*p_bits downto (SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width),
		--FirstPart_tmp(PolyDegree*p_bits-1 downto 0),
		SecondPart	=> SecondPart_poly,
        --OutputTmp(Dec_Msg_cycle*AXI_data_width-1+MessageLen*t_bits downto (Dec_Msg_cycle)*AXI_data_width),
		--SecondPart_tmp(MessageLen*t_bits-1 downto 0),
        
		Dec_Msg		=> Dec_Msg_tmp(MessageLen-1 downto 0)
		--OutputTmp(MessageLen-1 downto 0)
	);
    
--------------------------------- RAW DATA TO POLYNOMIALS 
PA: for i in 0 to PolyDegree-1 generate
    PolyA_poly(i) <= PolyA_tmp((i+1)*q_bits-1 downto i*q_bits);
    PolyR_poly(i) <= PolyR_tmp((i+1)*2-1 downto i*2);
end generate PA;

PB: for i in 0 to PolyDegree generate
    PolyB_poly(i) <= PolyB_tmp((i+1)*p_bits-1 downto i*p_bits);
end generate PB;

ctvgen: for i in 0 to MessageLen-1 generate
    ctV_poly(i) <= ctV_tmp((i+1)*t_bits-1 downto i*t_bits);
end generate ctvgen;

--------------------------------- POLYNOMIALS TO RAW DATA
FP_tmp: for i in 0 to PolyDegree-1 generate
    FirstPart_tmp((i+1)*q_bits-1 downto i*q_bits) <= FirstPart_poly(i);
end generate FP_tmp;

SP_tmp: for i in 0 to MessageLen-1 generate
    SecondPart_tmp((i+1)*t_bits-1 downto i*t_bits) <= SecondPart_poly(i); 
end generate SP_tmp;

----------------------------------- ENC/DEC selection and MODULE START SIGNAL OPERATING

		
		
process(clk)
begin
	if clk'event and clk = '1' then
		if FIFO_wr_en = '1' then
			if RECIVED_CMD = '0' then
				case FIFO_din(61 downto 56) is
					--ENC
					when "11000" => 		-- Encryption, PolyA
						input_pointer 		<= std_logic_vector(to_unsigned(PolyA_cycle_start,10));
						input_pointer_max 	<= std_logic_vector(to_unsigned(PolyA_cycle_end,10));
					when "10100" => 		-- Encryption, PolyB`
						input_pointer 		<= std_logic_vector(to_unsigned(PolyB_cycle_start,10));
						input_pointer_max 	<= std_logic_vector(to_unsigned(PolyB_cycle_end,10));
					when "10010" => 		-- Encryption, PolyR
						input_pointer 		<= std_logic_vector(to_unsigned(PolyR_cycle_start,10));
						input_pointer_max 	<= std_logic_vector(to_unsigned(PolyR_cycle_end,10));
					when "10001" => 		-- Encryption, Msg
						input_pointer 		<= std_logic_vector(to_unsigned(Message_cycle_start,10));
						input_pointer_max 	<= std_logic_vector(to_unsigned(Message_cycle_end,10));
					
					-- DEC
					when "00100" => 		-- Decryption, PolyB
						input_pointer 		<= std_logic_vector(to_unsigned(PolyB_dec_cycle_start,10));
						input_pointer_max 	<= std_logic_vector(to_unsigned(PolyB_dec_cycle_end,10));
					when "00010" => 		-- Decryption, PolyR
						input_pointer 		<= std_logic_vector(to_unsigned(PolyR_dec_cycle_start,10));
						input_pointer_max 	<= std_logic_vector(to_unsigned(PolyR_dec_cycle_end,10));
					when "00001" => 		-- Decryption, ctV
						input_pointer 		<= std_logic_vector(to_unsigned(ctV_cycle_start,10));
						input_pointer_max 	<= std_logic_vector(to_unsigned(ctV_cycle_end,10));
					when others => 
				end case;
				RECIVED_CMD <= '1';
				COMMAND <= FIFO_din(63 downto 56);
			else
				if input_pointer < input_pointer_max then
					input_pointer <= input_pointer + '1';
				else
					RECIVED_CMD <= '0';
				end if;
			
			end if;
		else
			RECIVED_CMD <= '0';
		end if;
	end if;
end process;
		
		
		
		
process(clk)
begin
	if clk'event and clk = '1' then 
		if FIFO_rd_en = '1' then 
			if output_pointer < output_pointer_max then
				output_pointer <= output_pointer + '1';
			else
					-- FIFO_Empty
			end if;
		else
			if op_module = '0' then --dec
				output_pointer 		<= std_logic_vector(to_unsigned(dec_msg_cycle_start,8));
				output_pointer_max 	<= std_logic_vector(to_unsigned(dec_msg_cycle_end,8));
			else -- enc
				output_pointer 		<= std_logic_vector(to_unsigned(FirstPart_cycle_start,8));
				output_pointer_max 	<= std_logic_vector(to_unsigned(SecondPart_cycle_end,8));
			end if;
			
		end if;
	end if;
end process;

	



---	Process handling saving data from arithm module to outpu reg and manage the pointer value
--- NOTE: Too big process, should be divided in 2-3 smaller processes.
--process(clk)
--begin
--	if clk'event and clk = '1' then 
--		if Out_saved = '0' then
--			if done_module = '1' then 
--				Out_saved <= '1';
				-- if op_module = '1' then
					-- Output_Reg((FirstPart_cycle+SecondPart_cycle)*AXI_data_width-1 downto 0) <= Encrypted_Reg;
					-- Output_Reg((FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width-1 downto (FirstPart_cycle+SecondPart_cycle)*AXI_data_width) <= (others =>'0');
					-- Output_count <= std_logic_vector(to_unsigned(Dec_Msg_cycle,8))  + '1';  -- set the pointer to encryption results
				-- else
					-- Output_Reg(MessageLen-1 downto 0) <= Dec_Msg_tmp;
					-- Output_Reg((FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width-1 downto MessageLen) <= (others =>'0');
					-- Output_count <= (others => '0');	-- set the pointer to decryption results
				-- end if;
				-- FIFO_Full <= '1';
			-- else
				
			-- end if;
		-- else	
			-- if Output_count = Dec_Msg_cycle or Output_count = Output_cycle then
				-- Out_saved <= '0';
				-- FIFO_Full <= '0';
			-- else
				-- Output_count <= Output_count + '1';
				-- Output_Reg <= Output_Reg(63 downto 0) & Output_Reg((FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width-1 downto 64);
			-- end if;
		-- end if;
	-- end if;
-- end process;


--- output demux
process(clk)
begin
	if clk'event and clk = '1' then
		case output_pointer is
			when "00000000" => 
		FIFO_dout <= FirstPart_tmp(63 downto 0);
			when "00000001" => 
		FIFO_dout <= FirstPart_tmp(127 downto 64);
			when "00000010" => 
		FIFO_dout <= FirstPart_tmp(191 downto 128);
			when "00000011" => 
		FIFO_dout <= FirstPart_tmp(255 downto 192);
			when "00000100" => 
		FIFO_dout <= FirstPart_tmp(319 downto 256);
			when "00000101" => 
		FIFO_dout <= FirstPart_tmp(383 downto 320);
			when "00000110" => 
		FIFO_dout <= FirstPart_tmp(447 downto 384);
			when "00000111" => 
		FIFO_dout <= FirstPart_tmp(511 downto 448);
			when "00001000" => 
		FIFO_dout <= FirstPart_tmp(575 downto 512);
			when "00001001" => 
		FIFO_dout <= FirstPart_tmp(639 downto 576);
			when "00001010" => 
		FIFO_dout <= FirstPart_tmp(703 downto 640);
			when "00001011" => 
		FIFO_dout <= FirstPart_tmp(767 downto 704);
			when "00001100" => 
		FIFO_dout <= FirstPart_tmp(831 downto 768);
			when "00001101" => 
		FIFO_dout <= FirstPart_tmp(895 downto 832);
			when "00001110" => 
		FIFO_dout <= FirstPart_tmp(959 downto 896);
			when "00001111" => 
		FIFO_dout <= FirstPart_tmp(1023 downto 960);
			when "00010000" => 
		FIFO_dout <= FirstPart_tmp(1087 downto 1024);
			when "00010001" => 
		FIFO_dout <= FirstPart_tmp(1151 downto 1088);
			when "00010010" => 
		FIFO_dout <= FirstPart_tmp(1215 downto 1152);
			when "00010011" => 
		FIFO_dout <= FirstPart_tmp(1279 downto 1216);
			when "00010100" => 
		FIFO_dout <= FirstPart_tmp(1343 downto 1280);
			when "00010101" => 
		FIFO_dout <= FirstPart_tmp(1407 downto 1344);
			when "00010110" => 
		FIFO_dout <= FirstPart_tmp(1471 downto 1408);
			when "00010111" => 
		FIFO_dout <= FirstPart_tmp(1535 downto 1472);
			when "00011000" => 
		FIFO_dout <= FirstPart_tmp(1599 downto 1536);
			when "00011001" => 
		FIFO_dout <= FirstPart_tmp(1663 downto 1600);
			when "00011010" => 
		FIFO_dout <= FirstPart_tmp(1727 downto 1664);
			when "00011011" => 
		FIFO_dout <= FirstPart_tmp(1791 downto 1728);
			when "00011100" => 
		FIFO_dout <= FirstPart_tmp(1855 downto 1792);
			when "00011101" => 
		FIFO_dout <= FirstPart_tmp(1919 downto 1856);
			when "00011110" => 
		FIFO_dout <= FirstPart_tmp(1983 downto 1920);
			when "00011111" => 
		FIFO_dout <= FirstPart_tmp(2047 downto 1984);
			when "00100000" => 
		FIFO_dout <= FirstPart_tmp(2111 downto 2048);
			when "00100001" => 
		FIFO_dout <= FirstPart_tmp(2175 downto 2112);
			when "00100010" => 
		FIFO_dout <= FirstPart_tmp(2239 downto 2176);
			when "00100011" => 
		FIFO_dout <= FirstPart_tmp(2303 downto 2240);
			when "00100100" => 
		FIFO_dout <= FirstPart_tmp(2367 downto 2304);
			when "00100101" => 
		FIFO_dout <= FirstPart_tmp(2431 downto 2368);
			when "00100110" => 
		FIFO_dout <= FirstPart_tmp(2495 downto 2432);
			when "00100111" => 
		FIFO_dout <= FirstPart_tmp(2559 downto 2496);
			when "00101000" => 
		FIFO_dout <= FirstPart_tmp(2623 downto 2560);
			when "00101001" => 
		FIFO_dout <= FirstPart_tmp(2687 downto 2624);
			when "00101010" => 
		FIFO_dout <= FirstPart_tmp(2751 downto 2688);
			when "00101011" => 
		FIFO_dout <= FirstPart_tmp(2815 downto 2752);
			when "00101100" => 
		FIFO_dout <= FirstPart_tmp(2879 downto 2816);
			when "00101101" => 
		FIFO_dout <= FirstPart_tmp(2943 downto 2880);
			when "00101110" => 
		FIFO_dout <= FirstPart_tmp(3007 downto 2944);
			when "00101111" => 
		FIFO_dout <= FirstPart_tmp(3071 downto 3008);
			when "00110000" => 
		FIFO_dout <= FirstPart_tmp(3135 downto 3072);
			when "00110001" => 
		FIFO_dout <= FirstPart_tmp(3199 downto 3136);
			when "00110010" => 
		FIFO_dout <= FirstPart_tmp(3263 downto 3200);
			when "00110011" => 
		FIFO_dout <= FirstPart_tmp(3327 downto 3264);
			when "00110100" => 
		FIFO_dout <= FirstPart_tmp(3391 downto 3328);
			when "00110101" => 
		FIFO_dout <= FirstPart_tmp(3455 downto 3392);
			when "00110110" => 
		FIFO_dout <= FirstPart_tmp(3519 downto 3456);
			when "00110111" => 
		FIFO_dout <= FirstPart_tmp(3583 downto 3520);
			when "00111000" => 
		FIFO_dout <= FirstPart_tmp(3647 downto 3584);
			when "00111001" => 
		FIFO_dout <= FirstPart_tmp(3711 downto 3648);
			when "00111010" => 
		FIFO_dout <= FirstPart_tmp(3775 downto 3712);
			when "00111011" => 
		FIFO_dout <= FirstPart_tmp(3839 downto 3776);
			when "00111100" => 
		FIFO_dout <= FirstPart_tmp(3903 downto 3840);
			when "00111101" => 
		FIFO_dout <= FirstPart_tmp(3967 downto 3904);
			when "00111110" => 
		FIFO_dout <= FirstPart_tmp(4031 downto 3968);
			when "00111111" => 
		FIFO_dout <= FirstPart_tmp(4095 downto 4032);
			when "01000000" => 
		FIFO_dout <= FirstPart_tmp(4159 downto 4096);
			when "01000001" => 
		FIFO_dout <= FirstPart_tmp(4223 downto 4160);
			when "01000010" => 
		FIFO_dout <= FirstPart_tmp(4287 downto 4224);
			when "01000011" => 
		FIFO_dout <= FirstPart_tmp(4351 downto 4288);
			when "01000100" => 
		FIFO_dout <= FirstPart_tmp(4415 downto 4352);
			when "01000101" => 
		FIFO_dout <= FirstPart_tmp(4479 downto 4416);
			when "01000110" => 
		FIFO_dout <= FirstPart_tmp(4543 downto 4480);
			when "01000111" => 
		FIFO_dout <= FirstPart_tmp(4607 downto 4544);
			when "01001000" => 
		FIFO_dout <= FirstPart_tmp(4671 downto 4608);
			when "01001001" => 
		FIFO_dout <= FirstPart_tmp(4735 downto 4672);
			when "01001010" => 
		FIFO_dout <= FirstPart_tmp(4799 downto 4736);
			when "01001011" => 
		FIFO_dout <= FirstPart_tmp(4863 downto 4800);
			when "01001100" => 
		FIFO_dout <= FirstPart_tmp(4927 downto 4864);
			when "01001101" => 
		FIFO_dout <= FirstPart_tmp(4991 downto 4928);
			when "01001110" => 
		FIFO_dout <= FirstPart_tmp(5055 downto 4992);
			when "01001111" => 
		FIFO_dout <= FirstPart_tmp(5119 downto 5056);
			when "01010000" => 
		FIFO_dout <= FirstPart_tmp(5183 downto 5120);
			when "01010001" => 
		FIFO_dout <= FirstPart_tmp(5247 downto 5184);
			when "01010010" => 
		FIFO_dout <= FirstPart_tmp(5311 downto 5248);
			when "01010011" => 
		FIFO_dout <= FirstPart_tmp(5375 downto 5312);
			when "01010100" => 
		FIFO_dout <= FirstPart_tmp(5439 downto 5376);
			when "01010101" => 
		FIFO_dout <= FirstPart_tmp(5503 downto 5440);
			when "01010110" => 
		FIFO_dout <= FirstPart_tmp(5567 downto 5504);
		end case;
	end if;
end process;


---- INPUT mux
process(clk)
begin
	if clk'event and clk = '1' then 
	case input_pointer is
		when "0000000000" => 
	PolyA_tmp(63 downto 0) <= FIFO_din;
		when "0000000001" => 
	PolyA_tmp(127 downto 64) <= FIFO_din;
		when "0000000010" => 
	PolyA_tmp(191 downto 128) <= FIFO_din;
		when "0000000011" => 
	PolyA_tmp(255 downto 192) <= FIFO_din;
		when "0000000100" => 
	PolyA_tmp(319 downto 256) <= FIFO_din;
		when "0000000101" => 
	PolyA_tmp(383 downto 320) <= FIFO_din;
		when "0000000110" => 
	PolyA_tmp(447 downto 384) <= FIFO_din;
		when "0000000111" => 
	PolyA_tmp(511 downto 448) <= FIFO_din;
		when "0000001000" => 
	PolyA_tmp(575 downto 512) <= FIFO_din;
		when "0000001001" => 
	PolyA_tmp(639 downto 576) <= FIFO_din;
		when "0000001010" => 
	PolyA_tmp(703 downto 640) <= FIFO_din;
		when "0000001011" => 
	PolyA_tmp(767 downto 704) <= FIFO_din;
		when "0000001100" => 
	PolyA_tmp(831 downto 768) <= FIFO_din;
		when "0000001101" => 
	PolyA_tmp(895 downto 832) <= FIFO_din;
		when "0000001110" => 
	PolyA_tmp(959 downto 896) <= FIFO_din;
		when "0000001111" => 
	PolyA_tmp(1023 downto 960) <= FIFO_din;
		when "0000010000" => 
	PolyA_tmp(1087 downto 1024) <= FIFO_din;
		when "0000010001" => 
	PolyA_tmp(1151 downto 1088) <= FIFO_din;
		when "0000010010" => 
	PolyA_tmp(1215 downto 1152) <= FIFO_din;
		when "0000010011" => 
	PolyA_tmp(1279 downto 1216) <= FIFO_din;
		when "0000010100" => 
	PolyA_tmp(1343 downto 1280) <= FIFO_din;
		when "0000010101" => 
	PolyA_tmp(1407 downto 1344) <= FIFO_din;
		when "0000010110" => 
	PolyA_tmp(1471 downto 1408) <= FIFO_din;
		when "0000010111" => 
	PolyA_tmp(1535 downto 1472) <= FIFO_din;
		when "0000011000" => 
	PolyA_tmp(1599 downto 1536) <= FIFO_din;
		when "0000011001" => 
	PolyA_tmp(1663 downto 1600) <= FIFO_din;
		when "0000011010" => 
	PolyA_tmp(1727 downto 1664) <= FIFO_din;
		when "0000011011" => 
	PolyA_tmp(1791 downto 1728) <= FIFO_din;
		when "0000011100" => 
	PolyA_tmp(1855 downto 1792) <= FIFO_din;
		when "0000011101" => 
	PolyA_tmp(1919 downto 1856) <= FIFO_din;
		when "0000011110" => 
	PolyA_tmp(1983 downto 1920) <= FIFO_din;
		when "0000011111" => 
	PolyA_tmp(2047 downto 1984) <= FIFO_din;
		when "0000100000" => 
	PolyA_tmp(2111 downto 2048) <= FIFO_din;
		when "0000100001" => 
	PolyA_tmp(2175 downto 2112) <= FIFO_din;
		when "0000100010" => 
	PolyA_tmp(2239 downto 2176) <= FIFO_din;
		when "0000100011" => 
	PolyA_tmp(2303 downto 2240) <= FIFO_din;
		when "0000100100" => 
	PolyA_tmp(2367 downto 2304) <= FIFO_din;
		when "0000100101" => 
	PolyA_tmp(2431 downto 2368) <= FIFO_din;
		when "0000100110" => 
	PolyA_tmp(2495 downto 2432) <= FIFO_din;
		when "0000100111" => 
	PolyA_tmp(2559 downto 2496) <= FIFO_din;
		when "0000101000" => 
	PolyA_tmp(2623 downto 2560) <= FIFO_din;
		when "0000101001" => 
	PolyA_tmp(2687 downto 2624) <= FIFO_din;
		when "0000101010" => 
	PolyA_tmp(2751 downto 2688) <= FIFO_din;
		when "0000101011" => 
	PolyA_tmp(2815 downto 2752) <= FIFO_din;
		when "0000101100" => 
	PolyA_tmp(2879 downto 2816) <= FIFO_din;
		when "0000101101" => 
	PolyA_tmp(2943 downto 2880) <= FIFO_din;
		when "0000101110" => 
	PolyA_tmp(3007 downto 2944) <= FIFO_din;
		when "0000101111" => 
	PolyA_tmp(3071 downto 3008) <= FIFO_din;
		when "0000110000" => 
	PolyA_tmp(3135 downto 3072) <= FIFO_din;
		when "0000110001" => 
	PolyA_tmp(3199 downto 3136) <= FIFO_din;
		when "0000110010" => 
	PolyA_tmp(3263 downto 3200) <= FIFO_din;
		when "0000110011" => 
	PolyA_tmp(3327 downto 3264) <= FIFO_din;
		when "0000110100" => 
	PolyA_tmp(3391 downto 3328) <= FIFO_din;
		when "0000110101" => 
	PolyA_tmp(3455 downto 3392) <= FIFO_din;
		when "0000110110" => 
	PolyA_tmp(3519 downto 3456) <= FIFO_din;
		when "0000110111" => 
	PolyA_tmp(3583 downto 3520) <= FIFO_din;
		when "0000111000" => 
	PolyA_tmp(3647 downto 3584) <= FIFO_din;
		when "0000111001" => 
	PolyA_tmp(3711 downto 3648) <= FIFO_din;
		when "0000111010" => 
	PolyA_tmp(3775 downto 3712) <= FIFO_din;
		when "0000111011" => 
	PolyA_tmp(3839 downto 3776) <= FIFO_din;
		when "0000111100" => 
	PolyA_tmp(3903 downto 3840) <= FIFO_din;
		when "0000111101" => 
	PolyA_tmp(3967 downto 3904) <= FIFO_din;
		when "0000111110" => 
	PolyA_tmp(4031 downto 3968) <= FIFO_din;
		when "0000111111" => 
	PolyA_tmp(4095 downto 4032) <= FIFO_din;
		when "0001000000" => 
	PolyA_tmp(4159 downto 4096) <= FIFO_din;
		when "0001000001" => 
	PolyA_tmp(4223 downto 4160) <= FIFO_din;
		when "0001000010" => 
	PolyA_tmp(4287 downto 4224) <= FIFO_din;
		when "0001000011" => 
	PolyA_tmp(4351 downto 4288) <= FIFO_din;
		when "0001000100" => 
	PolyA_tmp(4415 downto 4352) <= FIFO_din;
		when "0001000101" => 
	PolyA_tmp(4479 downto 4416) <= FIFO_din;
		when "0001000110" => 
	PolyA_tmp(4543 downto 4480) <= FIFO_din;
		when "0001000111" => 
	PolyA_tmp(4607 downto 4544) <= FIFO_din;
		when "0001001000" => 
	PolyA_tmp(4671 downto 4608) <= FIFO_din;
		when "0001001001" => 
	PolyA_tmp(4735 downto 4672) <= FIFO_din;
		when "0001001010" => 
	PolyA_tmp(4799 downto 4736) <= FIFO_din;
		when "0001001011" => 
	PolyA_tmp(4863 downto 4800) <= FIFO_din;
		when "0001001100" => 
	PolyA_tmp(4927 downto 4864) <= FIFO_din;
		when "0001001101" => 
	PolyA_tmp(4991 downto 4928) <= FIFO_din;
		when "0001001110" => 
	PolyA_tmp(5055 downto 4992) <= FIFO_din;
		when "0001001111" => 
	PolyA_tmp(5119 downto 5056) <= FIFO_din;
		when "0001010000" => 
	PolyA_tmp(5183 downto 5120) <= FIFO_din;
		when "0001010001" => 
	PolyA_tmp(5247 downto 5184) <= FIFO_din;
		when "0001010010" => 
	PolyA_tmp(5311 downto 5248) <= FIFO_din;
		when "0001010011" => 
	PolyA_tmp(5375 downto 5312) <= FIFO_din;
		when "0001010100" => 
	PolyA_tmp(5439 downto 5376) <= FIFO_din;
		when "0001010101" => 
	PolyA_tmp(5503 downto 5440) <= FIFO_din;
		when "0001010110" => 
	PolyA_tmp(5567 downto 5504) <= FIFO_din;
		when "0001010111" => 
	PolyA_tmp(5631 downto 5568) <= FIFO_din;
		when "0001011000" => 
	PolyA_tmp(5695 downto 5632) <= FIFO_din;
		when "0001011001" => 
	PolyA_tmp(5759 downto 5696) <= FIFO_din;
		when "0001011010" => 
	PolyA_tmp(5823 downto 5760) <= FIFO_din;
		when "0001011011" => 
	PolyA_tmp(5887 downto 5824) <= FIFO_din;
		when "0001011100" => 
	PolyA_tmp(5951 downto 5888) <= FIFO_din;
		when "0001011101" => 
	PolyA_tmp(6015 downto 5952) <= FIFO_din;
		when "0001011110" => 
	PolyA_tmp(6079 downto 6016) <= FIFO_din;
		when "0001011111" => 
	PolyA_tmp(6143 downto 6080) <= FIFO_din;
		when "0001100000" => 
	PolyA_tmp(6207 downto 6144) <= FIFO_din;
		when "0001100001" => 
	PolyA_tmp(6271 downto 6208) <= FIFO_din;
		when "0001100010" => 
	PolyA_tmp(6335 downto 6272) <= FIFO_din;
		when "0001100011" => 
	PolyA_tmp(6399 downto 6336) <= FIFO_din;
		when "0001100100" => 
	PolyA_tmp(6463 downto 6400) <= FIFO_din;
		when "0001100101" => 
	PolyA_tmp(6527 downto 6464) <= FIFO_din;
		when "0001100110" => 
	PolyA_tmp(6591 downto 6528) <= FIFO_din;
		when "0001100111" => 
	PolyA_tmp(6655 downto 6592) <= FIFO_din;
		when "0001101000" => 
	PolyA_tmp(6719 downto 6656) <= FIFO_din;
		when "0001101001" => 
	PolyA_tmp(6783 downto 6720) <= FIFO_din;
		when "0001101010" => 
	PolyA_tmp(6847 downto 6784) <= FIFO_din;
		when "0001101011" => 
	PolyB_tmp(6911 downto 6848) <= FIFO_din;
		when "0001101100" => 
	PolyB_tmp(6975 downto 6912) <= FIFO_din;
		when "0001101101" => 
	PolyB_tmp(7039 downto 6976) <= FIFO_din;
		when "0001101110" => 
	PolyB_tmp(7103 downto 7040) <= FIFO_din;
		when "0001101111" => 
	PolyB_tmp(7167 downto 7104) <= FIFO_din;
		when "0001110000" => 
	PolyB_tmp(7231 downto 7168) <= FIFO_din;
		when "0001110001" => 
	PolyB_tmp(7295 downto 7232) <= FIFO_din;
		when "0001110010" => 
	PolyB_tmp(7359 downto 7296) <= FIFO_din;
		when "0001110011" => 
	PolyB_tmp(7423 downto 7360) <= FIFO_din;
		when "0001110100" => 
	PolyB_tmp(7487 downto 7424) <= FIFO_din;
		when "0001110101" => 
	PolyB_tmp(7551 downto 7488) <= FIFO_din;
		when "0001110110" => 
	PolyB_tmp(7615 downto 7552) <= FIFO_din;
		when "0001110111" => 
	PolyB_tmp(7679 downto 7616) <= FIFO_din;
		when "0001111000" => 
	PolyB_tmp(7743 downto 7680) <= FIFO_din;
		when "0001111001" => 
	PolyB_tmp(7807 downto 7744) <= FIFO_din;
		when "0001111010" => 
	PolyB_tmp(7871 downto 7808) <= FIFO_din;
		when "0001111011" => 
	PolyB_tmp(7935 downto 7872) <= FIFO_din;
		when "0001111100" => 
	PolyB_tmp(7999 downto 7936) <= FIFO_din;
		when "0001111101" => 
	PolyB_tmp(8063 downto 8000) <= FIFO_din;
		when "0001111110" => 
	PolyB_tmp(8127 downto 8064) <= FIFO_din;
		when "0001111111" => 
	PolyB_tmp(8191 downto 8128) <= FIFO_din;
		when "0010000000" => 
	PolyB_tmp(8255 downto 8192) <= FIFO_din;
		when "0010000001" => 
	PolyB_tmp(8319 downto 8256) <= FIFO_din;
		when "0010000010" => 
	PolyB_tmp(8383 downto 8320) <= FIFO_din;
		when "0010000011" => 
	PolyB_tmp(8447 downto 8384) <= FIFO_din;
		when "0010000100" => 
	PolyB_tmp(8511 downto 8448) <= FIFO_din;
		when "0010000101" => 
	PolyB_tmp(8575 downto 8512) <= FIFO_din;
		when "0010000110" => 
	PolyB_tmp(8639 downto 8576) <= FIFO_din;
		when "0010000111" => 
	PolyB_tmp(8703 downto 8640) <= FIFO_din;
		when "0010001000" => 
	PolyB_tmp(8767 downto 8704) <= FIFO_din;
		when "0010001001" => 
	PolyB_tmp(8831 downto 8768) <= FIFO_din;
		when "0010001010" => 
	PolyB_tmp(8895 downto 8832) <= FIFO_din;
		when "0010001011" => 
	PolyB_tmp(8959 downto 8896) <= FIFO_din;
		when "0010001100" => 
	PolyB_tmp(9023 downto 8960) <= FIFO_din;
		when "0010001101" => 
	PolyB_tmp(9087 downto 9024) <= FIFO_din;
		when "0010001110" => 
	PolyB_tmp(9151 downto 9088) <= FIFO_din;
		when "0010001111" => 
	PolyB_tmp(9215 downto 9152) <= FIFO_din;
		when "0010010000" => 
	PolyB_tmp(9279 downto 9216) <= FIFO_din;
		when "0010010001" => 
	PolyB_tmp(9343 downto 9280) <= FIFO_din;
		when "0010010010" => 
	PolyB_tmp(9407 downto 9344) <= FIFO_din;
		when "0010010011" => 
	PolyB_tmp(9471 downto 9408) <= FIFO_din;
		when "0010010100" => 
	PolyB_tmp(9535 downto 9472) <= FIFO_din;
		when "0010010101" => 
	PolyB_tmp(9599 downto 9536) <= FIFO_din;
		when "0010010110" => 
	PolyB_tmp(9663 downto 9600) <= FIFO_din;
		when "0010010111" => 
	PolyB_tmp(9727 downto 9664) <= FIFO_din;
		when "0010011000" => 
	PolyB_tmp(9791 downto 9728) <= FIFO_din;
		when "0010011001" => 
	PolyB_tmp(9855 downto 9792) <= FIFO_din;
		when "0010011010" => 
	PolyB_tmp(9919 downto 9856) <= FIFO_din;
		when "0010011011" => 
	PolyB_tmp(9983 downto 9920) <= FIFO_din;
		when "0010011100" => 
	PolyB_tmp(10047 downto 9984) <= FIFO_din;
		when "0010011101" => 
	PolyB_tmp(10111 downto 10048) <= FIFO_din;
		when "0010011110" => 
	PolyB_tmp(10175 downto 10112) <= FIFO_din;
		when "0010011111" => 
	PolyB_tmp(10239 downto 10176) <= FIFO_din;
		when "0010100000" => 
	PolyB_tmp(10303 downto 10240) <= FIFO_din;
		when "0010100001" => 
	PolyB_tmp(10367 downto 10304) <= FIFO_din;
		when "0010100010" => 
	PolyB_tmp(10431 downto 10368) <= FIFO_din;
		when "0010100011" => 
	PolyB_tmp(10495 downto 10432) <= FIFO_din;
		when "0010100100" => 
	PolyB_tmp(10559 downto 10496) <= FIFO_din;
		when "0010100101" => 
	PolyB_tmp(10623 downto 10560) <= FIFO_din;
		when "0010100110" => 
	PolyB_tmp(10687 downto 10624) <= FIFO_din;
		when "0010100111" => 
	PolyB_tmp(10751 downto 10688) <= FIFO_din;
		when "0010101000" => 
	PolyB_tmp(10815 downto 10752) <= FIFO_din;
		when "0010101001" => 
	PolyB_tmp(10879 downto 10816) <= FIFO_din;
		when "0010101010" => 
	PolyB_tmp(10943 downto 10880) <= FIFO_din;
		when "0010101011" => 
	PolyB_tmp(11007 downto 10944) <= FIFO_din;
		when "0010101100" => 
	PolyB_tmp(11071 downto 11008) <= FIFO_din;
		when "0010101101" => 
	PolyB_tmp(11135 downto 11072) <= FIFO_din;
		when "0010101110" => 
	PolyB_tmp(11199 downto 11136) <= FIFO_din;
		when "0010101111" => 
	PolyB_tmp(11263 downto 11200) <= FIFO_din;
		when "0010110000" => 
	PolyB_tmp(11327 downto 11264) <= FIFO_din;
		when "0010110001" => 
	PolyB_tmp(11391 downto 11328) <= FIFO_din;
		when "0010110010" => 
	PolyB_tmp(11455 downto 11392) <= FIFO_din;
		when "0010110011" => 
	PolyB_tmp(11519 downto 11456) <= FIFO_din;
		when "0010110100" => 
	PolyB_tmp(11583 downto 11520) <= FIFO_din;
		when "0010110101" => 
	PolyB_tmp(11647 downto 11584) <= FIFO_din;
		when "0010110110" => 
	PolyB_tmp(11711 downto 11648) <= FIFO_din;
		when "0010110111" => 
	PolyB_tmp(11775 downto 11712) <= FIFO_din;
		when "0010111000" => 
	PolyB_tmp(11839 downto 11776) <= FIFO_din;
		when "0010111001" => 
	PolyB_tmp(11903 downto 11840) <= FIFO_din;
		when "0010111010" => 
	PolyB_tmp(11967 downto 11904) <= FIFO_din;
		when "0010111011" => 
	PolyB_tmp(12031 downto 11968) <= FIFO_din;
		when "0010111100" => 
	PolyB_tmp(12095 downto 12032) <= FIFO_din;
		when "0010111101" => 
	PolyB_tmp(12159 downto 12096) <= FIFO_din;
		when "0010111110" => 
	PolyB_tmp(12223 downto 12160) <= FIFO_din;
		when "0010111111" => 
	PolyB_tmp(12287 downto 12224) <= FIFO_din;
		when "0011000000" => 
	PolyB_tmp(12351 downto 12288) <= FIFO_din;
		when "0011000001" => 
	PolyB_tmp(12415 downto 12352) <= FIFO_din;
		when "0011000010" => 
	PolyB_tmp(12479 downto 12416) <= FIFO_din;
		when "0011000011" => 
	PolyR_tmp(12543 downto 12480) <= FIFO_din;
		when "0011000100" => 
	PolyR_tmp(12607 downto 12544) <= FIFO_din;
		when "0011000101" => 
	PolyR_tmp(12671 downto 12608) <= FIFO_din;
		when "0011000110" => 
	PolyR_tmp(12735 downto 12672) <= FIFO_din;
		when "0011000111" => 
	PolyR_tmp(12799 downto 12736) <= FIFO_din;
		when "0011001000" => 
	PolyR_tmp(12863 downto 12800) <= FIFO_din;
		when "0011001001" => 
	PolyR_tmp(12927 downto 12864) <= FIFO_din;
		when "0011001010" => 
	PolyR_tmp(12991 downto 12928) <= FIFO_din;
		when "0011001011" => 
	PolyR_tmp(13055 downto 12992) <= FIFO_din;
		when "0011001100" => 
	PolyR_tmp(13119 downto 13056) <= FIFO_din;
		when "0011001101" => 
	PolyR_tmp(13183 downto 13120) <= FIFO_din;
		when "0011001110" => 
	PolyR_tmp(13247 downto 13184) <= FIFO_din;
		when "0011001111" => 
	PolyR_tmp(13311 downto 13248) <= FIFO_din;
		when "0011010000" => 
	PolyR_tmp(13375 downto 13312) <= FIFO_din;
		when "0011010001" => 
	PolyR_tmp(13439 downto 13376) <= FIFO_din;
		when "0011010010" => 
	PolyR_tmp(13503 downto 13440) <= FIFO_din;
		when "0011010011" => 
	PolyR_tmp(13567 downto 13504) <= FIFO_din;
		when "0011010100" => 
	PolyR_tmp(13631 downto 13568) <= FIFO_din;
		when "0011010101" => 
	PolyR_tmp(13695 downto 13632) <= FIFO_din;
		when "0011010110" => 
	PolyR_tmp(13759 downto 13696) <= FIFO_din;
		when "0011010111" => 
	Message_tmp(13823 downto 13760) <= FIFO_din;
		when "0011011000" => 
	Message_tmp(13887 downto 13824) <= FIFO_din;
	------------------==========   INPUT DEC  ================
		when "0011011001" => 
	PolyB_tmp(13951 downto 13888) <= FIFO_din;
		when "0011011010" => 
	PolyB_tmp(14015 downto 13952) <= FIFO_din;
		when "0011011011" => 
	PolyB_tmp(14079 downto 14016) <= FIFO_din;
		when "0011011100" => 
	PolyB_tmp(14143 downto 14080) <= FIFO_din;
		when "0011011101" => 
	PolyB_tmp(14207 downto 14144) <= FIFO_din;
		when "0011011110" => 
	PolyB_tmp(14271 downto 14208) <= FIFO_din;
		when "0011011111" => 
	PolyB_tmp(14335 downto 14272) <= FIFO_din;
		when "0011100000" => 
	PolyB_tmp(14399 downto 14336) <= FIFO_din;
		when "0011100001" => 
	PolyB_tmp(14463 downto 14400) <= FIFO_din;
		when "0011100010" => 
	PolyB_tmp(14527 downto 14464) <= FIFO_din;
		when "0011100011" => 
	PolyB_tmp(14591 downto 14528) <= FIFO_din;
		when "0011100100" => 
	PolyB_tmp(14655 downto 14592) <= FIFO_din;
		when "0011100101" => 
	PolyB_tmp(14719 downto 14656) <= FIFO_din;
		when "0011100110" => 
	PolyB_tmp(14783 downto 14720) <= FIFO_din;
		when "0011100111" => 
	PolyB_tmp(14847 downto 14784) <= FIFO_din;
		when "0011101000" => 
	PolyB_tmp(14911 downto 14848) <= FIFO_din;
		when "0011101001" => 
	PolyB_tmp(14975 downto 14912) <= FIFO_din;
		when "0011101010" => 
	PolyB_tmp(15039 downto 14976) <= FIFO_din;
		when "0011101011" => 
	PolyB_tmp(15103 downto 15040) <= FIFO_din;
		when "0011101100" => 
	PolyB_tmp(15167 downto 15104) <= FIFO_din;
		when "0011101101" => 
	PolyB_tmp(15231 downto 15168) <= FIFO_din;
		when "0011101110" => 
	PolyB_tmp(15295 downto 15232) <= FIFO_din;
		when "0011101111" => 
	PolyB_tmp(15359 downto 15296) <= FIFO_din;
		when "0011110000" => 
	PolyB_tmp(15423 downto 15360) <= FIFO_din;
		when "0011110001" => 
	PolyB_tmp(15487 downto 15424) <= FIFO_din;
		when "0011110010" => 
	PolyB_tmp(15551 downto 15488) <= FIFO_din;
		when "0011110011" => 
	PolyB_tmp(15615 downto 15552) <= FIFO_din;
		when "0011110100" => 
	PolyB_tmp(15679 downto 15616) <= FIFO_din;
		when "0011110101" => 
	PolyB_tmp(15743 downto 15680) <= FIFO_din;
		when "0011110110" => 
	PolyB_tmp(15807 downto 15744) <= FIFO_din;
		when "0011110111" => 
	PolyB_tmp(15871 downto 15808) <= FIFO_din;
		when "0011111000" => 
	PolyB_tmp(15935 downto 15872) <= FIFO_din;
		when "0011111001" => 
	PolyB_tmp(15999 downto 15936) <= FIFO_din;
		when "0011111010" => 
	PolyB_tmp(16063 downto 16000) <= FIFO_din;
		when "0011111011" => 
	PolyB_tmp(16127 downto 16064) <= FIFO_din;
		when "0011111100" => 
	PolyB_tmp(16191 downto 16128) <= FIFO_din;
		when "0011111101" => 
	PolyB_tmp(16255 downto 16192) <= FIFO_din;
		when "0011111110" => 
	PolyB_tmp(16319 downto 16256) <= FIFO_din;
		when "0011111111" => 
	PolyB_tmp(16383 downto 16320) <= FIFO_din;
		when "0100000000" => 
	PolyB_tmp(16447 downto 16384) <= FIFO_din;
		when "0100000001" => 
	PolyB_tmp(16511 downto 16448) <= FIFO_din;
		when "0100000010" => 
	PolyB_tmp(16575 downto 16512) <= FIFO_din;
		when "0100000011" => 
	PolyB_tmp(16639 downto 16576) <= FIFO_din;
		when "0100000100" => 
	PolyB_tmp(16703 downto 16640) <= FIFO_din;
		when "0100000101" => 
	PolyB_tmp(16767 downto 16704) <= FIFO_din;
		when "0100000110" => 
	PolyB_tmp(16831 downto 16768) <= FIFO_din;
		when "0100000111" => 
	PolyB_tmp(16895 downto 16832) <= FIFO_din;
		when "0100001000" => 
	PolyB_tmp(16959 downto 16896) <= FIFO_din;
		when "0100001001" => 
	PolyB_tmp(17023 downto 16960) <= FIFO_din;
		when "0100001010" => 
	PolyB_tmp(17087 downto 17024) <= FIFO_din;
		when "0100001011" => 
	PolyB_tmp(17151 downto 17088) <= FIFO_din;
		when "0100001100" => 
	PolyB_tmp(17215 downto 17152) <= FIFO_din;
		when "0100001101" => 
	PolyB_tmp(17279 downto 17216) <= FIFO_din;
		when "0100001110" => 
	PolyB_tmp(17343 downto 17280) <= FIFO_din;
		when "0100001111" => 
	PolyB_tmp(17407 downto 17344) <= FIFO_din;
		when "0100010000" => 
	PolyB_tmp(17471 downto 17408) <= FIFO_din;
		when "0100010001" => 
	PolyB_tmp(17535 downto 17472) <= FIFO_din;
		when "0100010010" => 
	PolyB_tmp(17599 downto 17536) <= FIFO_din;
		when "0100010011" => 
	PolyB_tmp(17663 downto 17600) <= FIFO_din;
		when "0100010100" => 
	PolyB_tmp(17727 downto 17664) <= FIFO_din;
		when "0100010101" => 
	PolyB_tmp(17791 downto 17728) <= FIFO_din;
		when "0100010110" => 
	PolyB_tmp(17855 downto 17792) <= FIFO_din;
		when "0100010111" => 
	PolyB_tmp(17919 downto 17856) <= FIFO_din;
		when "0100011000" => 
	PolyB_tmp(17983 downto 17920) <= FIFO_din;
		when "0100011001" => 
	PolyB_tmp(18047 downto 17984) <= FIFO_din;
		when "0100011010" => 
	PolyB_tmp(18111 downto 18048) <= FIFO_din;
		when "0100011011" => 
	PolyB_tmp(18175 downto 18112) <= FIFO_din;
		when "0100011100" => 
	PolyB_tmp(18239 downto 18176) <= FIFO_din;
		when "0100011101" => 
	PolyB_tmp(18303 downto 18240) <= FIFO_din;
		when "0100011110" => 
	PolyB_tmp(18367 downto 18304) <= FIFO_din;
		when "0100011111" => 
	PolyB_tmp(18431 downto 18368) <= FIFO_din;
		when "0100100000" => 
	PolyB_tmp(18495 downto 18432) <= FIFO_din;
		when "0100100001" => 
	PolyB_tmp(18559 downto 18496) <= FIFO_din;
		when "0100100010" => 
	PolyB_tmp(18623 downto 18560) <= FIFO_din;
		when "0100100011" => 
	PolyB_tmp(18687 downto 18624) <= FIFO_din;
		when "0100100100" => 
	PolyB_tmp(18751 downto 18688) <= FIFO_din;
		when "0100100101" => 
	PolyB_tmp(18815 downto 18752) <= FIFO_din;
		when "0100100110" => 
	PolyB_tmp(18879 downto 18816) <= FIFO_din;
		when "0100100111" => 
	PolyB_tmp(18943 downto 18880) <= FIFO_din;
		when "0100101000" => 
	PolyB_tmp(19007 downto 18944) <= FIFO_din;
		when "0100101001" => 
	PolyB_tmp(19071 downto 19008) <= FIFO_din;
		when "0100101010" => 
	PolyB_tmp(19135 downto 19072) <= FIFO_din;
		when "0100101011" => 
	PolyB_tmp(19199 downto 19136) <= FIFO_din;
		when "0100101100" => 
	PolyB_tmp(19263 downto 19200) <= FIFO_din;
		when "0100101101" => 
	PolyB_tmp(19327 downto 19264) <= FIFO_din;
		when "0100101110" => 
	PolyB_tmp(19391 downto 19328) <= FIFO_din;
		when "0100101111" => 
	PolyB_tmp(19455 downto 19392) <= FIFO_din;
		when "0100110000" => 
	PolyB_tmp(19519 downto 19456) <= FIFO_din;
		when "0001011000" => 
	PolyR_tmp(5695 downto 5632) <= FIFO_din;
		when "0001011001" => 
	PolyR_tmp(5759 downto 5696) <= FIFO_din;
		when "0001011010" => 
	PolyR_tmp(5823 downto 5760) <= FIFO_din;
		when "0001011011" => 
	PolyR_tmp(5887 downto 5824) <= FIFO_din;
		when "0001011100" => 
	PolyR_tmp(5951 downto 5888) <= FIFO_din;
		when "0001011101" => 
	PolyR_tmp(6015 downto 5952) <= FIFO_din;
		when "0001011110" => 
	PolyR_tmp(6079 downto 6016) <= FIFO_din;
		when "0001011111" => 
	PolyR_tmp(6143 downto 6080) <= FIFO_din;
		when "0001100000" => 
	PolyR_tmp(6207 downto 6144) <= FIFO_din;
		when "0001100001" => 
	PolyR_tmp(6271 downto 6208) <= FIFO_din;
		when "0001100010" => 
	PolyR_tmp(6335 downto 6272) <= FIFO_din;
		when "0001100011" => 
	PolyR_tmp(6399 downto 6336) <= FIFO_din;
		when "0001100100" => 
	PolyR_tmp(6463 downto 6400) <= FIFO_din;
		when "0001100101" => 
	PolyR_tmp(6527 downto 6464) <= FIFO_din;
		when "0001100110" => 
	PolyR_tmp(6591 downto 6528) <= FIFO_din;
		when "0001100111" => 
	PolyR_tmp(6655 downto 6592) <= FIFO_din;
		when "0001101000" => 
	PolyR_tmp(6719 downto 6656) <= FIFO_din;
		when "0001101001" => 
	PolyR_tmp(6783 downto 6720) <= FIFO_din;
		when "0001101010" => 
	PolyR_tmp(6847 downto 6784) <= FIFO_din;
		when "0001101011" => 
	PolyR_tmp(6911 downto 6848) <= FIFO_din;
		when "0001101100" => 
	ctV_tmp(6975 downto 6912) <= FIFO_din;
		when "0001101101" => 
	ctV_tmp(7039 downto 6976) <= FIFO_din;
		when "0001101110" => 
	ctV_tmp(7103 downto 7040) <= FIFO_din;
		when "0001101111" => 
	ctV_tmp(7167 downto 7104) <= FIFO_din;
		when "0001110000" => 
	ctV_tmp(7231 downto 7168) <= FIFO_din;
		when "0001110001" => 
	ctV_tmp(7295 downto 7232) <= FIFO_din;
		when "0001110010" => 
	ctV_tmp(7359 downto 7296) <= FIFO_din;
		when "0001110011" => 
	ctV_tmp(7423 downto 7360) <= FIFO_din;
	end case;	
	
	end if;
end process;



end a1;
