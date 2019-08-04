library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

library work;
--use work.Round5_constants.all; 
use work.XEf_constants.all; 

entity xef_5d_unpack is
	port (
		v 	: in std_logic_vector(0 to 255);
		R   : in RTab(9 downto 0);
		
		clk : in std_logic;
		
		v_res : out BitTab(31 downto 0)
	);
end entity;

architecture a1 of xef_5d_unpack is


signal v_out : BitTab(255 downto 0);

begin


	for i in 0 to 10 generate
		up_el: entity work.XEf_unpack_Ri 
				generic map(
				
				
				)
				port map(
				v 	=> v,--v(conv_integer(fixerr_tab(i,0))*32 to conv_integer(fixerr_tab(i,0)*32+31)) ,
				

				clk => clk,
				
				R_out => R_out(i)
				);
	end generate;
				



end a1;