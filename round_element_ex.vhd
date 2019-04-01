library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity round_element_ex is	
	port (
		InputElement		: in std_logic_vector(q_bits-1 downto 0);
		Const				: in std_logic_vector(7 downto 0);
		clk					: in std_logic;
		OutElement_enc1	: out std_logic_vector(p_bits-1 downto 0);
		OutElement_enc2	: out std_logic_vector(t_bits-1 downto 0);
		OutElement_dec1	: out std_logic--_vector(b_bits_dec1-1 downto 0)
	);
end entity;


architecture a1 of round_element_ex is
signal tmp_x 	: std_logic_vector(q_bits-1 downto 0) := (others => '0');
signal tmp_x_and: std_logic_vector(q_bits-1 downto 0);

begin

tmp_x <=  + InputElement + (zero_fill & Const);

OutElement_enc1 <= tmp_x(q_bits-1 downto q_bits-p_bits);
OutElement_enc2 <= tmp_x(p_bits-1 downto p_bits-t_bits);
OutElement_dec1 <= tmp_x(p_bits-1);-- downto a_bits_dec1-b_bits_dec1);


end a1;