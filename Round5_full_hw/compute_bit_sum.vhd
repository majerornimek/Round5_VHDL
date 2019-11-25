library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;  
use work.Round5_constants.all;

entity compute_bit_sum is
	port(
		DataIn 	: in std_logic_vector(0 to 9);
		
		clk		: in std_logic;
		
		DataOut	: out std_logic_vector(0 to 3)
	);
end entity;

architecture a1 of compute_bit_sum is

begin

process(clk)
begin
	if clk'event and clk = '1' then
		DataOut <= "0000" + DataIn(0) + DataIn(1) + DataIn(2) + DataIn(3) + DataIn(4) + DataIn(5) + DataIn(6) + DataIn(7) + DataIn(8) + DataIn(9); 
	end if;
end process;

end a1;
	
	
