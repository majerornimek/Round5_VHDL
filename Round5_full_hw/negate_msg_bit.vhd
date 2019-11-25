library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;  
use work.Round5_constants.all;


entity negate_msg_bit is
	port(
		BitIn		: in std_logic;
		IntValue	: in std_logic_vector(0 to 3);
		
		clk	: in std_logic;
		
		BitOut	: out std_logic
	);
end entity;


architecture with_clk of negate_msg_bit is
signal IntVal : unsigned; 
begin

IntVal <= unsigned(IntValue);

process(clk)
begin
	if clk'event and clk = '1' then
			if IntVal >= 6 then
				BitOut <= not BitIn;
			else
				BitOut <= BitIn;
			end if;
	end if;
end process;


end architecture with_clk;

architecture without_clk of negate_msg_bit is
signal IntVal : integer; 
begin
IntVal <= conv_integer(IntValue);

with IntVal select BitOut <=
	not BitIn when 7,
	not BitIn when 8,
	not BitIn when 9,
	not BitIn when 10,
	BitIn when others;

end architecture without_clk;