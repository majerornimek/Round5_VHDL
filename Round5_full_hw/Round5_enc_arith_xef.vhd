library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity Round5_enc_arith_xef is	
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
end entity;


architecture a1 of Round5_enc_arith_xef is

component Mul_Poly is 
	port (
		PolyA	: in q_bitsPoly(PolyDegree downto 0);
		PolyB	: in Trinomial(PolyDegree downto 0); 
		clk		: in std_logic;
		Start		: in std_logic;
		Rst		: in std_logic;
		OpType	: in std_logic;
		Done		: out std_logic;
		LongRes	: out q_bitsPoly(PolyDegree downto 0)
	);
end component;

component round_poly_ex is
	port(
		PolyA		: in q_bitsPoly(PolyDegree downto 0);
		InputConst	: in std_logic_vector(7 downto 0);
		clk 		: in std_logic;
		PolyEnc1	: out P_bitsPoly(PolyDegree downto 0);
		PolyEnc2	: out t_bitsPoly(PolyDegree downto 0);
		PolyDec1	: out std_logic_vector(PolyDegree downto 0)--t_bitsPoly(PolyDegree-1 downto 0)
	);
	
end component;

component add_sub_poly is
	port(
		PolyA		: in p_bitsPoly(MessageLen-1 downto 0);
		PolyB		: in q_bitsPoly(MessageLen-1 downto 0);
		
		Operation   : in std_logic;	-- 1 add, 0 sub
		clk		    : in std_logic;
		
		PolyC		: out p_bitsPoly(MessageLen-1 downto 0)
	);
end component;

component XEf_codes is
	port(
		InputMsg			: in std_logic_vector(0 to MessageLen-1);
		InputCodeword  : in std_logic_vector(0 to code_len-1);
		mode				: in std_logic;
		rst 				: in std_logic;
		start				: in std_logic;
		clk 				: in std_logic;
		
		Code_computed	: out std_logic;
		Code_fixed		: out std_logic;
		
		OutputMsg : out std_logic_vector(0 to MessageLen-1);
		OutputCode: out std_logic_vector(0 to code_len-1)
	);
end component;

signal Rounded_e1   : P_bitsPoly(PolyDegree downto 0);
signal Rounded_e2	: t_bitsPoly(PolyDegree downto 0);
signal Rounded_d1	: std_logic_vector(PolyDegree downto 0);--t_bitsPoly(PolyDegree-1 downto 0)
signal Poly_2_round 	:  q_bitsPoly(PolyDegree downto 0);
signal polyA_2_mul 	: q_bitsPoly(PolyDegree downto 0);
signal PolyB_ext 	: q_bitsPoly(PolyDegree downto 0);
signal PolyR_ext	: Trinomial(PolyDegree downto 0);
signal mul_start, mul_type, mul_rst, mul_done : std_logic;
signal mul_res 		: q_bitsPoly(PolyDegree downto 0);
signal mul_res_short	: q_bitsPoly(PolyDegree downto 0);
signal unpacked_v		: p_bitsPoly(MessageLen-1 downto 0);
signal arithm_result : p_bitsPoly(MessageLen-1 downto 0);
signal arithm_result_q : q_bitsPoly(PolyDegree downto 0);

signal rounding_const : std_logic_vector(7 downto 0);
type FSM_type is (idle, init, first_mul_enc, first_round_enc, second_mul_enc, second_round_enc, after_encryption, mult_dec, sub_dec, round_dec, after_decryption,after_codes);
signal FSM : FSM_type := idle;

signal AddedMessage	: t_bitsPoly(MessageLen-1 downto 0);
signal Reversed_Messsage    : std_logic_vector(0 to MessageLen-1);
signal Ordered_Message      : std_logic_vector(0 to MessageLen-1);
signal p_bits_poly_memory_register_1 : P_bitsPoly(PolyDegree downto 0);
signal xef_mode, xef_start : std_logic;
signal code_computed_flag, code_fixed_flag : std_logic;
signal xef_message_out : std_logic_vector(0 to MessageLen-1);
signal Message_2_XEf : std_logic_vector(0 to MessageLen-1);
begin

------------------------------------	STATE MACHINE ----------------
stm: process(reset,clk)
begin
	if reset = '1' then
		FSM <= idle;
	elsif clk'event and clk = '1' then
		case FSM is
			when idle =>
				if start = '1' then
					if Operation = '1' then 
						FSM <= first_mul_enc;
						Mul_type <= '1';
					else
						FSM <= mult_dec;
					end if;
                    Done <= '0';
				end if;
			---- ENCRYPTION ------
			when first_mul_enc =>
				
				if mul_done = '1' then
					FSM <= first_round_enc;
				end if;
			
			when first_round_enc =>
				FSM <= second_mul_enc;
				Mul_type <= '0';
				p_bits_poly_memory_register_1 <= Rounded_e1;	-- Przechowanie wyniku zokraglania
				
			when second_mul_enc =>
				if mul_done = '1' then
					FSM <= second_round_enc;
				end if;
				p_bits_poly_memory_register_1 <= Rounded_e1;	-- Przechowanie wyniku zokraglania
			when second_round_enc =>
				FSM <= after_encryption;
			
			when after_encryption =>
                Done <= '1';
				-- TO DO
				
				
			---- DECRYPTION -------
			when mult_dec => 
				if mul_done = '1' then
					FSM <= sub_dec;
				end if;
			
			when sub_dec =>
				FSM <= round_dec;
			
			when round_dec => 
				FSM <= after_decryption;
			
			when after_decryption =>
				if code_fixed_flag = '1' then
					FSM <= after_codes;
				end if;
			when after_codes =>
				Dec_Msg <= XEf_message_out;
				Done <= '1';
			when others =>
				FSM <= idle;
		
		end case;
			
	end if;
end process;

---------------- SIGNALS TO XEF CODES --------------------------
xef_proces: process(clk)
begin
	if clk'event and clk = '1' then
		if FSM = first_mul_enc then
			xef_start <= '1';
			xef_mode <= '0';
			Message_2_XEf <= Message;
			
		elsif FSM = after_decryption then
			Message_2_XEf <=  Rounded_d1(PolyDegree downto PolyDegree-MessageLen+1);
			xef_mode <= '1';
			xef_start <= '1';
		else
			xef_start <= '0';
		end if;
	end if;
end process;




----------------	SIGNALS TO MULTIPLY	-------------------------

mulA: process(clk)
begin
	if clk'event and clk = '1' then
		if FSM = first_mul_enc then
		
			polyA_2_mul(0) <= (others => '0');
			polyA_2_mul(PolyDegree downto 1) <= PolyA;
			mul_start <= '1';
			mul_rst <= '0';		
			
		elsif (FSM = first_round_enc) then
			
			--polyA_2_mul(0) <= (others => '0');
			polyA_2_mul(PolyDegree  downto 0) <= PolyB_ext;
			mul_start <= '0';
			mul_rst <= '1';
			
		elsif FSM = second_mul_enc then 
			
			
			mul_start <= '1';
			mul_rst <= '0';	
	
		elsif (FSM = second_round_enc) or (FSM = sub_dec) then
			
			mul_start <= '0';
			mul_rst <= '1';
		
		elsif FSM = mult_dec then 
		
			polyA_2_mul(PolyDegree  downto 0) <= PolyB_ext;
			mul_start <= '1';
			mul_rst <= '0';
		
		
		else 
			mul_start <= '0';
			mul_rst <= '0';
		end if;
	end if;
end process;


--------------- SIGNALS TO ROUND

in_round: process(clk)
begin
	if clk'event and clk = '1' then
		if FSM = first_round_enc then 
			Poly_2_round(PolyDegree downto 0) <= mul_res;
			--Poly_2_round(0) <= (others => '0');
			rounding_const <= r_const_enc1;
		elsif  FSM = second_round_enc then	
			Poly_2_round(PolyDegree downto 0) <= mul_res_short;
			--Poly_2_round(0) <= (others => '0');
			rounding_const <= r_const_enc2;
		elsif  FSM = round_dec then	
			Poly_2_round(PolyDegree downto 0) <= arithm_result_q;
			--Poly_2_round(0) <= (others => '0');
			rounding_const <= r_const_dec1;
		end if;
	
	end if;
end process;

----------------  SHORTEN MUL RESULT

	ff: for i in PolyDegree downto 0 generate
	
		mul_res_short(i)(q_bits-1 downto p_bits+1) <= (others => '0');
		mul_res_short(i)(p_bits downto 0) <= mul_res(i)(p_bits downto 0);  --i+1
		
	end generate;
	
----------------	EXTEND POLY C

	f2: for i in PolyDegree downto 0 generate
		PolyB_ext(i)(q_bits-1 downto p_bits) <= (others => '0');
		PolyB_ext(i)(p_bits-1 downto 0) <= PolyB(i);

	end generate;
	
----------------	MESSAGE ADDITION	
    reve: for i in 0 to 127 generate
        Reversed_Messsage(i) <= Message(MessageLen-1 - i);
    end generate reve;
    

    
    rv: for i in 15 downto 0 generate
        Ordered_Message((15-i)*8 to (16 - i)*8-1 ) <= Reversed_Messsage(i*8 to (i+1)*8-1);
        
    end generate rv;
    

	AdMsg: for i in PolyDegree downto 0 generate
		
		Xored: if i >= PolyDegree-(MessageLen-1) generate
			AddedMessage(MessageLen-1 - (PolyDegree-i))(t_bits-2 downto 0) <= rounded_e2(i)(t_bits-2 downto 0);
			AddedMessage(MessageLen-1 - (PolyDegree-i))(t_bits-1) <= rounded_e2(i)(t_bits-1) xor Ordered_Message(MessageLen-1 - (PolyDegree-i));
		end generate Xored;
		
	end generate;
    
--------------- POLY V DECOMPRESSION

    decompres: for i in MessageLen-1 downto 0 generate
        unpacked_v(i)(p_bits-1 downto p_bits-t_bits) <= ctV(i);
        unpacked_v(i)(p_bits-1-t_bits downto 0) <= (others => '0');
    
    end generate decompres;

-------------- SUBSTRACTION RESULT EXTENSION TO Q_bits

    ext_decompres: for i in MessageLen-1 downto 0 generate
        arithm_result_q(PolyDegree-MessageLen+i+1)(p_bits-1 downto 0) <= arithm_result(i);
        arithm_result_q(PolyDegree-MessageLen+i+1)(q_bits-1 downto p_bits) <= (others => '0');
    end generate ext_decompres;
    
    ext_decompres2: for i in PolyDegree-MessageLen downto 0 generate
        arithm_result_q(i) <= (others => '0');
    end generate ext_decompres2;
    
---------------	POLY R EXTENSION
	
	PolyR_ext(PolyDegree downto 1) <=  PolyR;
	PolyR_ext(0) <= (others => '0');

------------------------	PUSH OUT RESULTS
	
	FirstPart <= p_bits_poly_memory_register_1(PolyDegree downto 1);
	pushsec: for i in 0 to MessageLen/2 -1 generate
        SecondPart(2*i) <=   AddedMessage((2*i+1));
        SecondPart(2*i+1) <= AddedMessage((2*i));
    end generate pushsec;
------------------------	MODULES INSTANTION	

	rp: round_poly_ex port map(
		PolyA		=> Poly_2_round(PolyDegree downto 0),
		InputConst	=> rounding_const,
		clk 		=> clk,
		PolyEnc1	=> Rounded_e1,   -- prawdopodobnie out, U
		PolyEnc2	=> Rounded_e2,
		PolyDec1	=> Rounded_d1
	);

	mp: Mul_poly port map(
		PolyA	=> polyA_2_mul,
		PolyB	=> PolyR_ext,
		clk	=> clk,
		Start	=> mul_start,
		Rst		=> mul_rst,
		OpType	=> mul_type,
		Done	=> mul_done,
		LongRes	=> mul_res --(PolyDegree downto 1)
	);
	
	ar: add_sub_poly port map(
		PolyA => unpacked_v,
		PolyB => mul_res_short(PolyDegree downto PolyDegree-MessageLen+1),
		Operation => '0',
		clk 	=> clk,
		PolyC => arithm_result
	);
	
	xfc: XEf_codes port map(
		InputMsg			=> Message_2_XEf,
		InputCodeword  => XEf_code_in,
		mode				=> xef_mode,
		rst 				=> reset,
		start				=> xef_start,
		clk 				=> clk,
		
		Code_computed	=> code_computed_flag,
		Code_fixed		=> code_fixed_flag,
		
		OutputMsg 		=> XEf_message_out,
		OutputCode		=> XEf_code_out
	);


end a1;