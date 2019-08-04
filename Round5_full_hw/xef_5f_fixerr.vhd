library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

library work;
--use work.Round5_constants.all; 
use work.XEf_constants.all; 
use work.XEf_constants_P5_5d.all;

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
		xb: entity work.xef_5d_fixerr_bit 
			generic map(
				f_bit_sel => fixerr_tab(i,0),
				r_1 => fixerr_tab(i,1),
				r_2 => fixerr_tab(i,2),
				r_3 => fixerr_tab(i,3),
				r_4 => fixerr_tab(i,4),
				r_5 => fixerr_tab(i,5),
				r_6 => fixerr_tab(i,6),
				r_7 => fixerr_tab(i,7),
				r_8 => fixerr_tab(i,8),
				r_9 => fixerr_tab(i,9),
				i_and_7 => fixerr_tab(i,10)
			)
			port map(
				v 	=> v((i mod 32) to (i mod 32 + 7)),--v(conv_integer(fixerr_tab(i,0))*32 to conv_integer(fixerr_tab(i,0)*32+31)) ,
				R   => R,
				
				--f_bit_sel => R(0)(conv_integer(fixerr_tab(i,0))),
				--r_0 : in std_logic_vector(5 downto 0);
				-- r_1 => R(1)(conv_integer(fixerr_tab(i,1))),
				-- r_2 => R(2)(conv_integer(fixerr_tab(i,2))),
				-- r_3 => R(3)(conv_integer(fixerr_tab(i,3))),
				-- r_4 => R(4)(conv_integer(fixerr_tab(i,4))),
				-- r_5 => R(5)(conv_integer(fixerr_tab(i,5))),
				-- r_6 => R(6)(conv_integer(fixerr_tab(i,6))),
				-- r_7 => R(7)(conv_integer(fixerr_tab(i,7))),
				-- r_8 => R(8)(conv_integer(fixerr_tab(i,8))),
				-- r_9 => R(9)(conv_integer(fixerr_tab(i,9))),
				
				-- i_and_7 => fixerr_tab(i,10),
				
				clk => clk,
				
				v_out => v_out(i)
			
			);

	end generate;
	
	x:for i in 0 to 31 generate
		v_res(i) <= (((v_out(8*i) xor v_out(8*i+1))) xor (v_out(8*i+2) xor v_out(8*i+3))) xor ((v_out(8*i+4) xor v_out(8*i+5)) xor (v_out(8*i+6) xor v_out(8*i+7))) xor v(i*8 to i*8+7) ;
	end generate;



end a1;