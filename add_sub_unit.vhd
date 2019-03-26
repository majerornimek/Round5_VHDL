library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity add_sub_unit is
	port(
		A		: in std_logic_vector(ShortModLen-2 downto 0);
		B		: in std_logic_vector(ShortModLen-2 downto 0);
		
		Operation: in std_logic;	-- 1 add, 0 sub
		clk		: in std_logic;
		
		C		: out std_logic_vector(ShortModLen-2 downto 0)
	);
end entity;


architecture a1 of add_sub_unit is 

signal tmpB, tmpC : std_logic_vector(ShortModLen-2 downto 0);
begin

with Operation select tmpB <=
	B when '1',
	not B + '1' when others;

C <= tmpC(ShortModLen-2 downto 0);

process(clk)
begin
	if clk'event and clk = '1' then
		tmpC <= A + tmpB; 
	end if;
end process;


end a1;