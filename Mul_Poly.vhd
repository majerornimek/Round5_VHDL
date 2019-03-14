library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

library work;
use work.Round5_constants.all;

entity Mul_Poly is 
	port (
		PolyA	: in NTRUPoly(PolyDegree-1 downto 0);
		PolyB	: in Trinomial(PolyDegree-1 downto 0); 
		clk		: in std_logic;
		Start	: in std_logic;
		Rst		: in std_logic;
		Done	: out std_logic;
		LongRes	: out NTRUPoly(PolyDegree-1 downto 0);
		ShortRes: out ShortPoly(PolyDegree-1 downto 0)
	);
end entity;


architecture a1 of Mul_Poly is
component Mul_Poly_NTRU is 
	port (
		PolyA	: in NTRUPoly(PolyDegree-1 downto 0);
		PolyB	: in Trinomial(PolyDegree-1 downto 0);
		clk 	: in std_logic;
		Start	: in std_logic;
		Rst		: in std_logic;
		Done	: out std_logic;
		LongRes	: out NTRUPoly(PolyDegree-1 downto 0);
		ShortRes: out ShortPoly(PolyDegree-1 downto 0)
	);
end component;

component Lift_Poly is 
	port (
		PolyA	: in NTRUPoly(PolyDegree-1 downto 0);
		clk 	: in std_logic;
		LongRes	: out NTRUPoly(PolyDegree-1 downto 0);
		ShortRes: out ShortPoly(PolyDegree-1 downto 0)
	);
end component;

 


begin

	Done <= '0';

end a1;