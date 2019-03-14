library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;


entity round_poly is
	generic(
		InputWidth 	: integer := a_bits_enc1;
		OutputWidth	: integer := b_bits_enc1;
		b_mask		: std_logic_vector := b_mask_enc1;
		round_const	: integer := r_const_enc1
	);
	port(
		PolyA		: in bus_array(PolyDegree-1 downto 0)(InputWidth-1 downto 0);
		clk 		: std_logic;
		PolyOut		: in bus_array(PolyDegree-1 downto 0)(OutputWidth-1 downto 0)
	);
	
end entity;


architecture a1 of round_poly is
component round_element is	
	generic(
		InputWidth 	: integer := 11;
		OutputWidth	: integer := 8;
		b_mask		: std_logic_vector(OutputWidth-1 downto 0) := x"fffffff";
		round_const	: integer := 4
	);
	port (
		InputElement	: std_logic_vector(InputWidth-1 downto 0);
		clk				: std_logic;
		OutputElement	: std_logic_vector(OutputWidth-1 downto 0)
	);
end component;

begin
	ro: for i in 0 to PolyDegree-1 generate
		re: round_element 
			generic map(
				InputWidth 	=> InputWidth,
				OutputWidth	=> OutputWidth,
				b_mask		=> b_mask,
				round_const	=> round_const
			)
			port map(
				InputElement => PolyA(i),
				clk => clk,
				OutputElement => PolyOut(i)
			);
	end generate ro;

end a1;