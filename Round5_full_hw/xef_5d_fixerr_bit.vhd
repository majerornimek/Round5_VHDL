library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

library work;
--use work.Round5_constants.all; 
use work.XEf_constants.all; 

entity xef_5d_fixerr_bit is
	port(
		v 	: in std_logic_vector(7 downto 0);
		
		f_bit_sel : in std_logic;
		--r_0 : in std_logic_vector(5 downto 0);
		r_1 : in std_logic;
		r_2 : in std_logic;
		r_3 : in std_logic;
		r_4 : in std_logic;
		r_5 : in std_logic;
		r_6 : in std_logic;
		r_7 : in std_logic;
		r_8 : in std_logic;
		r_9 : in std_logic;
		
		--r1 : in natural;
		--r2 : in natural;
		--r3 : in natural;
		--r4 : in natural;
		--r5 : in natural;
		--r6 : in natural;
		--r7 : in natural;
		
		
		i_and_7 : in std_logic_vector(5 downto 0);
		
		clk : in std_logic;
		
		v_out : out std_logic_vector(7 downto 0)
	);
end entity;

architecture a1 of xef_5d_fixerr_bit is
signal th   : std_logic_vector(7 downto 0);
signal th_3 : std_logic_vector(7 downto 0);
signal th_left : std_logic_vector(7 downto 0);
signal th1: std_logic;
signal rv : std_logic_vector(9 downto 0);

begin

th_3 <= "000" & th(7 downto 3);

th_left <= std_logic_vector(shift_left(unsigned(th_3), to_integer(unsigned((i_and_7)))));

v_out <= v xor th_left;

th1 <= f_bit_sel;



--	rv(0) <= R(1)(conv_integer(r_1));	
--	rv(1) <= R(2)(conv_integer(r_2));
--	rv(2) <= R(3)(conv_integer(r_3));
--	rv(3) <= R(4)(conv_integer(r_4));
--	rv(4) <= R(5)(conv_integer(r_5));
--	rv(5) <= R(6)(conv_integer(r_6));
--	rv(6) <= R(7)(conv_integer(r_7));
--	rv(7) <= R(8)(conv_integer(r_8));	
--	rv(8) <= R(9)(conv_integer(r_9));

process(clk) -- count
begin
	if clk'event and clk = '1' then
		th <= "00000010" + r_1 + r_2 + r_3 + r_4 + r_5 + r_6 + r_7 + r_8 + r_9 + th1;
	end if;
end process;







end a1;