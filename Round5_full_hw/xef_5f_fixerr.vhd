library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

library work;
use work.Round5_constants.all; 
use work.XEf_constants.all; 

entity xef_5f_fixerr is
	port (
		v 	: in std_logic_vector(0 to 255);
		R   : in RTab(9 downto 0);
		
		clk : in std_logic;
		
		v_res : out BitTab(31 downto 0)
	);
end entity;

architecture a1 of xef_5f_fixerr is
signal v_out : BitTab(255 downto 0);
begin


	g: for i in 0 to 255 generate
		xb: entity work.xef_5d_fixerr_bit port map(
			v 	=> v((i mod 32) to (i mod 32 + 7)),--v(conv_integer(wire_tab(i,0))*32 to conv_integer(wire_tab(i,0)*32+31)) ,
			R   => R,
			
			f_bit_sel => (wire_tab(i,0)),
			--r_0 : in std_logic_vector(5 downto 0);
			r_1 => (wire_tab(i,1)),
			r_2 => (wire_tab(i,2)),
			r_3 => (wire_tab(i,3)),
			r_4 => (wire_tab(i,4)),
			r_5 => (wire_tab(i,5)),
			r_6 => (wire_tab(i,6)),
			r_7 => (wire_tab(i,7)),
			r_8 => (wire_tab(i,8)),
			r_9 => (wire_tab(i,9)),
			
			i_and_7 => wire_tab(i,10),
			
			clk => clk,
			
			v_out => v_out(i)
		
		);

	end generate;
	
	x:for i in 0 to 31 generate
		v_res(i) <= (((v_out(8*i) xor v_out(8*i+1)) xor (v_out(8*i+2) xor v_out(8*i+3))) xor ((v_out(8*i+4) xor v_out(8*i+5)) xor (v_out(8*i+6) xor v_out(8*i+7)))) xor v(i*8 to i*8+7);
	end generate;



end a1;