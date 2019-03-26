library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity Round5_enc_arith is	
	port (
		PolyA			: in q_bitsPoly(PolyDegree-1 downto 0);  --W enc: A
		PolyB			: in p_bitsPoly(PolyDegree downto 0);	--W enc: polyB,   W dec: polyU
		PolyR			: in Trinomial(PolyDegree-1 downto 0); --W enc: poly R   W dec: polyS
		Message		    : in std_logic_vector(MessageLen-1 downto 0);
		ctV             : in t_bitsPoly(PolyDegree-1 downto 0);
        
        
		clk			: in std_logic;
		Start			: in std_logic;
		Reset			: in std_logic;
		Operation	: in std_logic;  -- 1 enc, 0 dec
		
		FirstPart	: out p_bitsPoly(PolyDegree-1 downto 0);
		SecondPart	: out t_bitsPoly(PolyDegree-1 downto 0);
        
		Dec_Msg		: out std_logic_vector(MessageLen-1 downto 0)
		
	);
end entity;


architecture a1 of Round5_enc_arith is

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
	generic(
		InputWidth 	: integer := a_bits_enc1;
		OutputWidth	: integer := b_bits_enc1
	);
	port(
		PolyA		: in q_bitsPoly(PolyDegree-1 downto 0);
		InputConst	: in std_logic_vector(6 downto 0);
		clk 		: in std_logic;
		PolyEnc1	: out P_bitsPoly(PolyDegree-1 downto 0);
		PolyEnc2	: out t_bitsPoly(PolyDegree-1 downto 0);
		PolyDec1	: out std_logic_vector(PolyDegree-1 downto 0)--t_bitsPoly(PolyDegree-1 downto 0)
	);
	
end component;

signal Rounded_e1   : P_bitsPoly(PolyDegree-1 downto 0);
signal Rounded_e2	: t_bitsPoly(PolyDegree-1 downto 0);
signal Rounded_d1	: std_logic_vector(PolyDegree-1 downto 0);--t_bitsPoly(PolyDegree-1 downto 0)
signal Poly_2_round 	:  q_bitsPoly(PolyDegree downto 0);
signal polyA_2_mul 	: q_bitsPoly(PolyDegree downto 0);
signal PolyB_ext 	: q_bitsPoly(PolyDegree downto 0);
signal PolyR_ext	: Trinomial(PolyDegree downto 0);
signal mul_start, mul_type, mul_rst, mul_done : std_logic;
signal mul_res 		: q_bitsPoly(PolyDegree downto 0);
signal mul_res_short	: q_bitsPoly(PolyDegree-1 downto 0);
signal unpacked_v		: p_bitsPoly(PolyDegree-1 downto 0);
signal arithm_result : p_bitsPoly(PolyDegree-1 downto 0);
signal rounding_const : std_logic_vector(6 downto 0);
type FSM_type is (idle, init, first_mul_enc, first_round_enc, second_mul_enc, second_round_enc, after_encryption, mult_dec, sub_dec, round_dec, after_decryption);
signal FSM : FSM_type := idle;

signal AddedMessage	: t_bitsPoly(PolyDegree-1 downto 0);

signal p_bits_poly_memory_register_1 : P_bitsPoly(PolyDegree-1 downto 0);


begin

------------------------------------	STATE MACHINE ----------------
stm: process(clk)
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
				-- TO DO
				
			when others =>
				FSM <= idle;
		
		end case;
			
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
		
			polyA_2_mul <= PolyB_ext;
			mul_start <= '0';
			mul_rst <= '1';
		
		
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
			Poly_2_round(PolyDegree downto 1) <= mul_res(PolyDegree downto 1);
			Poly_2_round(0) <= (others => '0');
			rounding_const <= r_const_enc1;
		elsif  FSM = second_round_enc then	
			Poly_2_round(PolyDegree downto 1) <= mul_res_short;
			Poly_2_round(0) <= (others => '0');
			rounding_const <= r_const_enc2;
		elsif  FSM = round_dec then	
			Poly_2_round(PolyDegree downto 1) <= mul_res_short;--arithm_result;
			Poly_2_round(0) <= (others => '0');
			rounding_const <= r_const_dec1;
		end if;
	
	end if;
end process;

----------------  SHORTEN MUL RESULT

	ff: for i in PolyDegree-1 downto 0 generate
	
		mul_res_short(i)(q_bits-1 downto ShortModLen) <= (others => '0');
		mul_res_short(i)(p_bits downto 0) <= mul_res(i+1)(p_bits downto 0);
		
	end generate;
	
----------------	EXTEND POLY C

	f2: for i in PolyDegree downto 0 generate
		PolyB_ext(i)(q_bits-1 downto p_bits) <= "000";
		PolyB_ext(i)(p_bits-1 downto 0) <= PolyB(i);

	end generate;
	
----------------	MESSAGE ADDITION	
	AdMsg: for i in PolyDegree-1 downto 0 generate
		
		Xored: if i > PolyDegree-1-MessageLen generate
			AddedMessage(i-1)(t_bits-2 downto 0) <= rounded_e2(i-1)(t_bits-2 downto 0);
			AddedMessage(i-1)(t_bits-1) <= rounded_e2(i-1)(t_bits-1) xor Message(127 - (PolyDegree-1-i));
		end generate Xored;
		
		rest: if i<=  PolyDegree-1-MessageLen generate
			AddedMessage(i) <= rounded_e2(i);
		end generate rest;
		
	end generate;

---------------	POLY R EXTENSION
	
	PolyR_ext(PolyDegree downto 1) <=  PolyR;
	PolyR_ext(0) <= (others => '0');

------------------------	PUSH OUT RESULTS
	
	FirstPart <= p_bits_poly_memory_register_1;
	--SecondPart <= AddedMessage(PolyDegree-1 downto PolyDegree- MessageLen);
	SecondPart <= AddedMessage(PolyDegree-1 downto 0);
	
------------------------	MODULES INSTANTION	

	rp: round_poly_ex port map(
		PolyA		=> Poly_2_round(PolyDegree downto 1),
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
	
--	ar: work.add_sub_poly port map(
--		PolyA => upacked_v,
--		PolyB => mul_res_short,
--		Operation => '0',
--		clk 	=> clk,
--		PolyC => arithm_result
--	);

end a1;