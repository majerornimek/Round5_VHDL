library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

library work;
--use work.Round5_constants.all; 
use work.XEf_constants.all; 

entity xef_5d_fixerr_bit is
	generic(
		f_bit_sel :  integer := 1;
		r_1 : integer := 1;
		r_2 : integer := 1;
		r_3 : integer := 1;
		r_4 : integer := 1;
		r_5 :  integer := 1;
		r_6 :  integer := 1;
		r_7 :  integer := 1;
		r_8 :  integer := 1;
		r_9 :  integer := 1;
		i_and_7 :integer := 1
	);
	port(
		v 	: in std_logic_vector(7 downto 0);
		R 	: in RTab;
		
		--r_0 : in std_logic_vector(5 downto 0)
		--r1 : in natural;
		--r2 : in natural;
		--r3 : in natural;
		--r4 : in natural;
		--r5 : in natural;
		--r6 : in natural;
		--r7 : in natural;
		
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

process(clk)
begin
	if clk'event and clk = '1' then
		th_left <= std_logic_vector(shift_left(unsigned(th_3), (i_and_7)));
	end if;
end process;

v_out <= v xor th_left;

th1 <= R(0)(f_bit_sel);



	rv(0) <= R(1)(r_1);	
	rv(1) <= R(2)(r_2);
	rv(2) <= R(3)(r_3);
	rv(3) <= R(4)(r_4);
	rv(4) <= R(5)(r_5);
	rv(5) <= R(6)(r_6);
	rv(6) <= R(7)(r_7);
	rv(7) <= R(8)(r_8);	
	rv(8) <= R(9)(r_9);

process(clk) -- count
begin
	if clk'event and clk = '1' then
		th <= "00000010" + rv(0) + rv(1) + rv(2) + rv(3) + rv(4) + rv(5) + rv(6) + rv(7) + rv(8) + th1;
	end if;
end process;







end a1;