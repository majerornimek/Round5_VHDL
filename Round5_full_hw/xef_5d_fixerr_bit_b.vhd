library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

library work;
--use work.Round5_constants.all; 
use work.XEf_constants.all; 

entity xef_5d_fixerr_bit_b is
	port(
		v 	: in std_logic_vector(7 downto 0);
		R   : in RTab(9 downto 0);
		
		index : in std_logic_vector(7 downto 0);
		--f_bit_sel : in std_logic_vector(5 downto 0);
		--r_0 : in std_logic_vector(5 downto 0);
		--r_1 : in std_logic_vector(5 downto 0);
		--r_2 : in std_logic_vector(5 downto 0);
		--r_3 : in std_logic_vector(5 downto 0);
		--r_4 : in std_logic_vector(5 downto 0);
		--r_5 : in std_logic_vector(5 downto 0);
		--r_6 : in std_logic_vector(5 downto 0);
		--r_7 : in std_logic_vector(5 downto 0);
		--r_8 : in std_logic_vector(5 downto 0);
		--r_9 : in std_logic_vector(5 downto 0);
		
		--r1 : in natural;
		--r2 : in natural;
		--r3 : in natural;
		--r4 : in natural;
		--r5 : in natural;
		--r6 : in natural;
		--r7 : in natural;
		
		
		--i_and_7 : in std_logic_vector(5 downto 0);
		
		clk : in std_logic;
		
		v_out : out std_logic_vector(7 downto 0)
	);
end entity;

architecture a1 of xef_5d_fixerr_bit_b is
signal th   : std_logic_vector(7 downto 0);
signal th_3 : std_logic_vector(7 downto 0);
signal th_left : std_logic_vector(7 downto 0);
signal th1: std_logic;
signal rv : std_logic_vector(9 downto 0);

begin

th_3 <= "000" & th(7 downto 3);

th_left <= std_logic_vector(shift_left(unsigned(th_3), to_integer(unsigned((wire_tab(conv_integer(index),10))))));

v_out <= v xor th_left;

th1 <= R(0)(conv_integer(wire_tab(conv_integer(index),0)));



rv(0) <= R(1)(conv_integer(wire_tab(conv_integer(index),1)));	
rv(1) <= R(2)(conv_integer(wire_tab(conv_integer(index),2)));
rv(2) <= R(3)(conv_integer(wire_tab(conv_integer(index),3)));
rv(3) <= R(4)(conv_integer(wire_tab(conv_integer(index),4)));
rv(4) <= R(5)(conv_integer(wire_tab(conv_integer(index),5)));
rv(5) <= R(6)(conv_integer(wire_tab(conv_integer(index),6)));
rv(6) <= R(7)(conv_integer(wire_tab(conv_integer(index),7)));
rv(7) <= R(8)(conv_integer(wire_tab(conv_integer(index),8)));	
rv(8) <= R(9)(conv_integer(wire_tab(conv_integer(index),9)));

process(clk) -- count
begin
	if clk'event and clk = '1' then
		th <= "00000010" + rv(0) + rv(1) + rv(2) + rv(3) + rv(4) + rv(5) + rv(6) + rv(7) + rv(8) + rv(9) + th1;
	end if;
end process;







end a1;