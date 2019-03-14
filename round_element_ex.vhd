library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity round_element_ex is	
	generic(
		InputWidth 	: integer := 11;
		OutputWidth	: integer := 8
	);
	port (
		InputElement	: in std_logic_vector(InputWidth-1 downto 0);
		Mask		: in std_logic_vector(InputWidth-1 downto 0);
		Const		: in std_logic_vector(3 downto 0);
		clk				: in std_logic;
		OutElement_enc1	: out std_logic_vector(b_bits_enc1-1 downto 0);
		OutElement_enc2	: out std_logic_vector(b_bits_enc2-1 downto 0);
		OutElement_dec1	: out std_logic_vector(b_bits_dec1-1 downto 0)
	);
end entity;


architecture a1 of round_element_ex is
signal tmp_x 	: std_logic_vector(InputWidth-1 downto 0);
signal tmp_x_and: std_logic_vector(InputWidth-1 downto 0);
signal shift_x	: std_logic_vector(OutputWidth-1 downto 0);

begin

tmp_x <= InputElement + Const;
tmp_x_and <= tmp_x and Mask;

OutElement_enc1 <= tmp_x_and(a_bits_enc1-1 downto a_bits_enc1-b_bits_enc1);
OutElement_enc2 <= tmp_x_and(a_bits_enc2-1 downto a_bits_enc2-b_bits_enc2);
OutElement_dec1 <= tmp_x_and(a_bits_dec1-1 downto a_bits_dec1-b_bits_dec1);


end a1;