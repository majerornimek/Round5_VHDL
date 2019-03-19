library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity Round5_enc_arith is	
	generic(
		
	);
	port (
		PolyA			: in NTRUPoly(PolyDegree-1 downto 0);  --nazwac poprawnie tak jak w kodzie
		PolyB			: in Trinomial(PolyDegree-1 downto 0);
		
		clk			: in std_logic;
		Start			: in std_logic;
		Reset			: in std_logic;
		Operation	: in std_logic;  -- 1 enc, 0 dec
		
		Result		: out NTRUPoly(PolyDegree-1 downto 0)
	);
end entity;


architecture a1 of Round5_enc_arith is


signal Rounded_e1 : bus_array(PolyDegree-1 downto 0)(b_bits_enc1-1 downto 0);
signal Rounded_e2	: bus_array(PolyDegree-1 downto 0)(b_bits_enc2-1 downto 0);
signal Rounded_d1	: bus_array(PolyDegree-1 downto 0)(b_bits_dec1-1 downto 0);
signal Poly_2_round 	: NTRUPoly(PolyDegree downto 0);

signal mul_start, mul_type, mul_rst, mul_done : std_logic;
signal mul_res 		: NTRUPoly(PolyDegree-1 downto 0);
signal mul_res_short	: ShortPoly(PolyDegree-1 downto 0);

type FSM_type is (idle, init, first_mul_enc, first_round_enc, second_mul_enc, second_round_enc, after_encryption, mult_dec, sub_dec, round_dec);
signal FSM : FSM_type := idle;

begin


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
			
			when second_mul_enc =>
				if mul_done = '1' then
					FSM <= second_round_enc;
				end if;
			
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


mulA: process(clk)
begin
	if clk'event and clk = '1' then
		if FSM = first_mul_enc then
		
			polyA_2_mul(PolyDegree) <= (others => '0');
			polyA_2_mul(PolyDegree-1 downto 0) <= PolyA;
			mul_start <= '1';
			mul_res <= '0';		
			
		elsif FSM = first_round_enc then
			
			mul_start <= '0';
			mul_res <= '1';
			
		elsif FSM = second_mul_enc then 
			
			polyA_2_mul(PolyDegree) <= (others => '0');
			polyA_2_mul(PolyDegree-1 downto 0) <= PolyA;
			mul_start <= '1';
			mul_res <= '0';	
	
	end if;
end process;


--------------------------

in_round: process(clk)
begin
	if clk'event and clk = '1' then
		if 
	
	end if;
end process;



process(clk)
begin
	if clk'event and clk = '1' then
		
	
	end if;
end process;



	rp: work.round_poly_ex port map(
		PolyA		=> Poly_2_round,
		InputConst	=> rounding_const,
		clk 		=> clk,
		PolyEnc1	=> Rounded_e1,
		PolyEnc2	=> Rounded_e2,
		PolyDec1	=> Rounded_d1
	);

	mp: work.Mul_poly port map(
		PolyA	=> polyA_2_mul,
		PolyB	=> PolyB,
		clk	=> clk,
		Start	=> mul_start,
		Rst		=> mul_rst,
		OpType	=> mul_type,
		Done	=> mul_done,
		LongRes	=> mul_res
	);

end a1;