library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;


entity round_poly_ex is
	generic(
		InputWidth 	: integer := a_bits_enc1;
		OutputWidth	: integer := b_bits_enc1
	);
	port(
		PolyA		: in bus_array(PolyDegree-1 downto 0)(a_bits_enc1-1 downto 0);
		InputConst	: in std_logic_vector(3 downto 0);
		clk 		: in std_logic;
		PolyEnc1	: out bus_array(PolyDegree-1 downto 0)(b_bits_enc1-1 downto 0);
		PolyEnc2	: out bus_array(PolyDegree-1 downto 0)(b_bits_enc2-1 downto 0);
		PolyDec1	: out bus_array(PolyDegree-1 downto 0)(b_bits_dec1-1 downto 0)
	);
	
end entity;


architecture a1 of round_poly_ex is
component round_element_ex is	
	generic(
		InputWidth 	: integer := 11
	);
	port (
		InputElement	: in std_logic_vector(InputWidth-1 downto 0);
		Const		: in std_logic_vector(3 downto 0);
		clk				: in std_logic;
		OutElement_enc1	: out std_logic_vector(b_bits_enc1-1 downto 0);
		OutElement_enc2	: out std_logic_vector(b_bits_enc2-1 downto 0);
		OutElement_dec1	: out std_logic_vector(b_bits_dec1-1 downto 0)
	);
end component;

begin
	ro: for i in 0 to PolyDegree-1 generate
		re: round_element_ex
			generic map(
				InputWidth 	=> InputWidth
			)
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