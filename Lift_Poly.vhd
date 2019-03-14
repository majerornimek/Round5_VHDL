library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity Lift_Poly is 
	port (
		PolyA	: in NTRUPoly(PolyDegree downto 0);
		clk 	: in std_logic;
		LongRes	: out NTRUPoly(PolyDegree downto 0);
		ShortRes: out ShortPoly(PolyDegree downto 0)
	);
end entity;

architecture a1 of Lift_Poly is
signal Long_tmp : std_logic_vector(LongModLen-2 downto 0);
signal ShortResTmp : NTRUPoly(PolyDegree downto 0);
begin
	Long_tmp <= not PolyA(PolyDegree) + '1';
	
	LongRes(PolyDegree) <= Long_tmp;
	ShortRes(PolyDegree) <= Long_tmp(ShortModLen-2 downto 0);

	GG: for i in PolyDegree-1 downto 1 generate
		LongRes(i) <= PolyA(i+1) - PolyA(i);--(LongModLen-2 downto 0);
		ShortResTmp(i) <= PolyA(i+1) - PolyA(i);--(ShortModLen-2 downto 0);
		ShortRes(i) <= ShortResTmp(i)(ShortModLen-2 downto 0);
	end generate GG;

	LongRes(0) <= PolyA(1)(LongModLen-2 downto 0);
	ShortRes(0) <= PolyA(1)(ShortModLen-2 downto 0);

end a1;