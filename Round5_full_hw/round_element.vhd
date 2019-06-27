library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity round_element is	
	generic(
		InputWidth 	: integer := 11;
		OutputWidth	: integer := 8;
		b_mask		: std_logic_vector(natural range<>) := (others => '0');
		round_const	: integer := 4
	);
	port (
		InputElement	: in std_logic_vector(InputWidth-1 downto 0);
		clk				: in std_logic;
		OutputElement	: out std_logic_vector(OutputWidth-1 downto 0)
	
	);
end entity;


architecture a1 of round_element is
signal tmp_x 	: std_logic_vector(InputWidth-1 downto 0);
signal shift_x	: std_logic_vector(OutputWidth-1 downto 0);

begin

tmp_x <= InputElement + std_logic_vector(to_unsigned(round_const, InputWidth));
shift_x <= tmp_x(InputWidth-1 downto InputWidth-OutputWidth);

OutputElement <= shift_x and b_mask;

end a1;