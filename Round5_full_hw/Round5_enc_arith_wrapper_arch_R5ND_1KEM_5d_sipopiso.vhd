architecture R5ND_1KEM_5d_sipopiso of Round5_enc_arith_wrapper is 

component Round5_enc_arith_xef is	
	port (
		PolyA			: in q_bitsPoly(PolyDegree-1 downto 0);  --W enc: A
		PolyB			: in p_bitsPoly(PolyDegree downto 0);	--W enc: polyB,   W dec: polyU
		PolyR			: in Trinomial(PolyDegree-1 downto 0); --W enc: poly R   W dec: polyS
		Message		    : in std_logic_vector(MessageLen-1 downto 0);
		ctV             : in t_bitsPoly(MessageLen-1  downto 0);
      XEf_code_in	: in std_logic_vector(0 to code_len-1); 
        
		clk			: in std_logic;
		Start			: in std_logic;
		Reset			: in std_logic;
		Operation	: in std_logic;  -- 1 enc, 0 dec
		Done        : out std_logic;
        
		FirstPart	: out p_bitsPoly(PolyDegree-1 downto 0);
		SecondPart	: out t_bitsPoly(MessageLen-1  downto 0);
      Xef_code_out: out std_logic_vector(0 to code_len-1);
        
		Dec_Msg		: out std_logic_vector(MessageLen-1 downto 0)
	);
end component;

signal start_module, reset_module, done_module 	: std_logic;
signal op_module	: std_logic;
signal op_selected  : std_logic;


------	ADDRES POINTERS/COUNTERS	-- address pointers for FIFOs to count number of data packages
signal input_pointer 		: std_logic_vector(9 downto 0) := (others => '0');
signal input_pointer_max	: std_logic_vector(9 downto 0) := (others => '0');
signal output_pointer		: std_logic_vector(7 downto 0) := (others => '0');
signal output_pointer_max	: std_logic_vector(7 downto 0) := (others => '0');


------ CONSTANTS COMMANDS  -- the value of command signals for specific data
------
------	COMMAND FORM: start| done| error| enc/dec(1/0)| A | B/U(enc/dec)| R(enc/dec) | msg/ct.V(enc/dec)
constant input_A_cmd	 	: std_logic_vector(7 downto 0) := "00011000";
constant input_B_cmd 		: std_logic_vector(7 downto 0) := "00010100";
constant input_R_cmd	 	: std_logic_vector(7 downto 0) := "00010010";
constant input_msg_cmd 		: std_logic_vector(7 downto 0) := "00010001";
constant input_Bdec_cmd	 	: std_logic_vector(7 downto 0) := "00000100";
constant input_Rdec_cmd	 	: std_logic_vector(7 downto 0) := "00000010";
constant input_V_cmd	 	: std_logic_vector(7 downto 0) := "00000001";
constant input_X_cmd		: std_logic_vector(7 downto 0) := "00001000";



signal data_ready	: std_logic;

------	DATA REGISTERS
signal PolyA_tmp 	: std_logic_vector(PolyA_cycle*AXI_data_width-1 downto 0); 	-- register to store input data to arithm module with overhead to store full input words
signal PolyB_tmp 	: std_logic_vector(PolyB_cycle*AXI_data_width-1 downto 0);
signal PolyR_tmp 	: std_logic_vector(PolyR_cycle*AXI_data_width-1 downto 0);	-- filled by S_FIFO in enc and dec
signal Message_tmp 	: std_logic_vector(Message_cycle*AXI_data_width-1 downto 0);
signal ctV_tmp		: std_logic_vector(ctV_cycle*AXI_data_width-1 downto 0);
signal xef_in_tmp, xef_out_tmp : std_logic_vector(0 to XEf_cycle*AXI_data_width-1);


signal FirstPart_tmp	: std_logic_vector(FirstPart_cycle*AXI_data_width-1 downto 0);
signal SecondPart_tmp	: std_logic_vector(SecondPart_cycle*AXI_data_width-1 downto 0);
signal Dec_Msg_tmp		: std_logic_vector(MessageLen-1 downto 0);


signal PolyA_count	: std_logic_vector(7 downto 0); -- point the region in PolyA_tmp register to write
signal PolyB_count	: std_logic_vector(7 downto 0); 
signal PolyR_count	: std_logic_vector(7 downto 0); 
signal Message_count: std_logic_vector(3 downto 0); 
signal ctV_count	: std_logic_vector(7 downto 0);


signal Output_count	: std_logic_vector(7 downto 0);
signal Out_saved 	: std_logic;	

------- POLYNOMIALS
signal PolyA_poly  : q_bitsPoly(PolyDegree-1 downto 0);
signal PolyB_poly  : p_bitsPoly(PolyDegree downto 0);
signal PolyR_poly  : Trinomial(PolyDegree-1 downto 0);
signal ctV_poly    : t_bitsPoly(PolyDegree-1 downto 0);
signal FirstPart_poly : p_bitsPoly(PolyDegree-1 downto 0);
signal SecondPart_poly: t_bitsPoly(MessageLen-1 downto 0);
signal xef_input, xef_output : std_logic_vector(0 to code_len-1);

-------------------- SHAKE FIFO SIGNAL ETC
signal S_Reset, fifoin_read, fifoin_empty, fifoout_full, fifoout_write : std_logic;
signal odata, idata : std_logic_vector(63 downto 0); 
signal pass_data_to_S_FIFO : std_logic;
------------------------

signal input_A, input_B, input_R, input_M, input_V, input_X : std_logic;
signal data_in_enc_ready, data_in_dec_ready, data_out_enc_ready, data_out_dec_ready  : std_logic;

signal COMMAND			: std_logic_vector(7 downto 0) := (others => '0');
--	COMMAND FORMAT:  start|done|error|dec/end(0/1)|A|B|R|msg/ctv
signal RECIVED_CMD		: std_logic := '0';

begin 

--------  DEMUX CODE THERE.
	arit: Round5_enc_arith_xef port map(
		PolyA			=> PolyA_poly(PolyDegree-1 downto 0),
		PolyB			=> PolyB_poly(PolyDegree downto 0),
		PolyR			=> PolyR_poly(PolyDegree-1 downto 0),
		Message		    => Message_tmp(MessageLen-1 downto 0),
		ctV             => ctV_poly(MessageLen-1 downto 0),
      XEf_code_in		=> xef_input,  
        
		clk			=> clk,
		Start		=> start_module,
		Reset		=> reset_module,
		Operation	=> op_module,
		Done		=> done_module,
		
		FirstPart	=> FirstPart_poly,
		SecondPart	=> SecondPart_poly,
		XEf_code_out => xef_output,
  
		Dec_Msg		=> Dec_Msg_tmp(MessageLen-1 downto 0)
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
    FirstPart_tmp((i+1)*p_bits-1 downto i*p_bits) <= FirstPart_poly(i);
end generate FP_tmp;

SP_tmp: for i in 0 to MessageLen-1 generate
    SecondPart_tmp((i+1)*t_bits-1 downto i*t_bits) <= SecondPart_poly(i); 
end generate SP_tmp;

xef_input <= xef_in_tmp(0 to code_len-1);
xef_out_tmp(0 to code_len-1) <= xef_output;
xef_out_tmp(code_len to XEf_cycle*AXI_data_width-1) <= (others=> '0');		
		
process(clk)
begin
	if clk'event and clk = '1' then
		if FIFO_wr_en = '1' then
			if RECIVED_CMD = '0' then
				case FIFO_din(63 downto 56) is
					--ENC
					when input_A_cmd => 		-- Encryption, Sigma
						input_pointer 		<= std_logic_vector(to_unsigned(Sigma_cycle_start,10));
						input_pointer_max 	<= std_logic_vector(to_unsigned(Sigma_cycle_end,10));
						
					when input_B_cmd => 		-- Encryption, PolyB`
						input_pointer 		<= std_logic_vector(to_unsigned(PolyB_cycle_start,10));
						input_pointer_max 	<= std_logic_vector(to_unsigned(PolyB_cycle_end,10));
					when input_R_cmd => 		-- Encryption, RHO
						input_pointer 		<= std_logic_vector(to_unsigned(RHO_cycle_start,10));
						input_pointer_max 	<= std_logic_vector(to_unsigned(RHO_cycle_end,10));
					when input_msg_cmd => 		-- Encryption, Msg
						input_pointer 		<= std_logic_vector(to_unsigned(Message_cycle_start,10));
						input_pointer_max 	<= std_logic_vector(to_unsigned(Message_cycle_end,10));
					
					-- DEC
					when input_Bdec_cmd => 		-- Decryption, PolyB
						input_pointer 		<= std_logic_vector(to_unsigned(Sk_cycle_start,10));
						input_pointer_max 	<= std_logic_vector(to_unsigned(Sk_cycle_end,10));
					when input_Rdec_cmd => 		-- Decryption, PolyR
						input_pointer 		<= std_logic_vector(to_unsigned(PolyU_cycle_start,10));
						input_pointer_max 	<= std_logic_vector(to_unsigned(PolyU_cycle_end,10));
					when input_V_cmd => 		-- Decryption, ctV
						input_pointer 		<= std_logic_vector(to_unsigned(ctV_cycle_start,10));
						input_pointer_max 	<= std_logic_vector(to_unsigned(ctV_cycle_end,10));
					when input_X_cmd => 		-- Decryption, ctV
						input_pointer 		<= std_logic_vector(to_unsigned(XEf_cycle_start,10));
						input_pointer_max 	<= std_logic_vector(to_unsigned(XEf_cycle_end,10));	
						
					when others => 

				end case;
				RECIVED_CMD <= '1';
				COMMAND <= FIFO_din(63 downto 56);
			else
				if input_pointer < input_pointer_max then
					input_pointer <= input_pointer + '1';
					reset_module <= '1';
				else
					RECIVED_CMD <= '0';
					reset_module <= '0';
				end if;
			
			end if;
		else
			RECIVED_CMD <= '0';
			reset_module <= '0';
		end if;
	end if;
end process;
		


		
		
process(rst,clk)
begin
	if rst = '1' then
		output_pointer <= (others => '0');
		output_pointer_max <= (others => '0');
		FIFO_Empty <= '1';
		
	elsif clk'event and clk = '1' then 
		if FIFO_rd_en = '1' then 
			if output_pointer < output_pointer_max then
				output_pointer <= output_pointer + '1';
				FIFO_Empty <= '0';
			else
				FIFO_Empty <= '1';
			end if;
		else
			if op_module = '0' then --dec
				output_pointer 		<= std_logic_vector(to_unsigned(dec_msg_cycle_start,8));
				output_pointer_max 	<= std_logic_vector(to_unsigned(dec_msg_cycle_end,8));
			else -- enc
				output_pointer 		<= std_logic_vector(to_unsigned(FirstPart_cycle_start,8));
				output_pointer_max 	<= std_logic_vector(to_unsigned(SecondPart_cycle_end,8));
			end if;
			
			if done_module = '1' then
				FIFO_Empty <= '0'; 		--- NOT SURE IF CORRECT SIGNAL
				
			else
			
				FIFO_Empty <= '1';
			end if;
			
		end if;
	end if;
end process;

FIFO_Full <= '0';  ------????

process(clk)
begin
	if clk'event and clk = '1' then
			start_module <= COMMAND(7) and data_ready;
			op_module <= COMMAND(4);
	end if;
end process;

process(clk)
begin
	if clk'event and clk = '1' then
		if input_A = '1' then
			if input_pointer < input_pointer_max then
				PolyA_tmp <= FIFO_din & PolyA_tmp(PolyA_cycle*AXI_data_width-1 downto 64);
			else
				input_A <= '0';
			end if;
		elsif FIFO_din(63 downto 56) = input_A_cmd then
			input_A <= '1';
		end if;
	end if;
end process;

process(clk)
begin
	if clk'event and clk = '1' then
		if input_B = '1' then
			if input_pointer < input_pointer_max then
				PolyB_tmp <= FIFO_din & PolyB_tmp(PolyB_cycle*AXI_data_width-1 downto 64);
			else
				input_B <= '0';
			end if;
		elsif FIFO_din(63 downto 56) = input_B_cmd then
			input_B <= '1';
		end if;
	end if;
end process;

process(clk)
begin
	if clk'event and clk = '1' then
		if input_R = '1' then
			if input_pointer < input_pointer_max then
				PolyR_tmp <= FIFO_din & PolyR_tmp(PolyR_cycle*AXI_data_width-1 downto 64);
			else
				input_R <= '0';
			end if;
		elsif FIFO_din(63 downto 56) = input_R_cmd then
			input_R <= '1';
		end if;
	end if;
end process;

process(clk)
begin
	if clk'event and clk = '1' then
		if input_M = '1' then
			if input_pointer < input_pointer_max then
				Message_tmp <= FIFO_din & Message_tmp(Message_cycle*AXI_data_width-1 downto 64);
			else
				input_M <= '0';
				data_in_enc_ready <= '1';
			end if;
		elsif FIFO_din(63 downto 56) = input_msg_cmd then
			input_M <= '1';
		else
			data_in_enc_ready <= '0';
		end if;
	end if;
end process;

process(clk)
begin
	if clk'event and clk = '1' then
		if input_V = '1' then
			if input_pointer < input_pointer_max then
				ctV_tmp <= FIFO_din & ctV_tmp(ctV_cycle*AXI_data_width-1 downto 64);
			else
				input_V <= '0';
			end if;
		elsif FIFO_din(63 downto 56) = input_V_cmd then
			input_V <= '1';
		end if;
	end if;
end process;


process(clk)
begin
	if clk'event and clk = '1' then
		if input_X = '1' then
			if input_pointer < input_pointer_max then
				XEf_in_tmp <= FIFO_din & XEf_in_tmp(0 to xef_cycle*AXI_data_width-65);
			else
				input_X <= '0';
				data_in_dec_ready <= '1';
			end if;
		elsif FIFO_din(63 downto 56) = input_X_cmd then
			input_X <= '1';
		else
			data_in_dec_ready <= '0';  --- should be removed in other state
		end if;
	end if;
end process;



data_ready <= data_in_enc_ready or data_in_dec_ready;-- or data_out_enc_ready or data_out_dec_ready;


--process(clk)
--begin
--	if clk'event and clk = '1' then
--		
--	
--	end if;
--end process;
--
--with out_select select FIFO_dout =>
--	FirstPart_tmp(63 downto 0) when "00",
--	SecondPart_tmp(63 downto 0) when "01",
--	XEf_out_tmp(63 downto 0) when "10",
--	dec_msg_tmp(63 downto 0) when others;






---==========   OUTPUT  ================
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
FIFO_dout <= SecondPart_tmp(63 downto 0);
        when "00110111" => 
FIFO_dout <= SecondPart_tmp(127 downto 64);
        when "00111000" => 
FIFO_dout <= SecondPart_tmp(191 downto 128);
        when "00111001" => 
FIFO_dout <= SecondPart_tmp(255 downto 192);
        when "00111010" => 
FIFO_dout <= SecondPart_tmp(319 downto 256);
        when "00111011" => 
FIFO_dout <= SecondPart_tmp(383 downto 320);
        when "00111100" => 
FIFO_dout <= XEf_out_tmp(0 to 63);
        when "00111101" => 
FIFO_dout <= XEf_out_tmp(64 to 127);
        when "00111110" => 
FIFO_dout <= XEf_out_tmp(128 to 191);
        when "00111111" => 
FIFO_dout <= dec_msg_tmp(63 downto 0);
        when "01000000" => 
FIFO_dout <= dec_msg_tmp(127 downto 64);
         when others =>
     end case;
 end if;
end process;


end R5ND_1KEM_5d_sipopiso;