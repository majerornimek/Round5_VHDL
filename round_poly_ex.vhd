library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;


entity round_poly_ex is
	port(
		PolyA		: in q_bitsPoly(PolyDegree downto 0);
		InputConst	: in std_logic_vector(7 downto 0);
		clk 		: in std_logic;
		PolyEnc1	: out P_bitsPoly(PolyDegree downto 0);
		PolyEnc2	: out t_bitsPoly(PolyDegree downto 0);
		PolyDec1	: out std_logic_vector(PolyDegree downto 0)--t_bitsPoly(PolyDegree-1 downto 0)
	);
	
end entity;


architecture a1 of round_poly_ex is
component round_element_ex is	

	port (
		InputElement	: in std_logic_vector(q_bits-1 downto 0);
		Const		    : in std_logic_vector(7 downto 0);
		clk				: in std_logic;
		OutElement_enc1	: out std_logic_vector(p_bits-1 downto 0);
		OutElement_enc2	: out std_logic_vector(t_bits-1 downto 0);
		OutElement_dec1	: out std_logic--_vector(b_bits_dec1-1 downto 0)
	);
end component;

begin
	ro: for i in 0 to PolyDegree generate
		re: round_element_ex
			port map(
				InputElement => PolyA(i),
				Const => InputConst,
				clk => clk,
				OutElement_enc1 => PolyEnc1(i),
				OutElement_enc2 => PolyEnc2(i),
				OutElement_dec1 => PolyDec1(i)
			);
	end generate ro;

end a1;