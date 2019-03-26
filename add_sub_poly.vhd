library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity add_sub_poly is
	port(
		PolyA		: in ShortPoly(PolyDegree-1 downto 0);
		PolyB		: in ShortPoly(PolyDegree-1 downto 0);
		
		Operation: in std_logic;	-- 1 add, 0 sub
		clk		: in std_logic;
		
		PolyC		: out ShortPoly(PolyDegree-1 downto 0)
	);
end entity;

architecture a1 of add_sub_poly is

component add_sub_unit is
	port(
		A		: in std_logic_vector(ShortModLen-2 downto 0);
		B		: in std_logic_vector(ShortModLen-2 downto 0);
		
		Operation: in std_logic;	-- 1 add, 0 sub
		clk		: in std_logic;
		
		C		: out std_logic_vector(ShortModLen-2 downto 0)
	);
end component;

begin

	ag: for i in 0 to PolyDegree-1 generate
	
		as: add_sub_unit port map(
			A => PolyA(i),
			B => PolyB(i),
			Operation => Operation,
			clk => clk,
			C => PolyC(i)
		);
	
	end generate ag;



end a1;