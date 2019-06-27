library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity Lift_Poly is 
	port (
		PolyA	: in q_bitsPoly(PolyDegree downto 0);
		clk 	: in std_logic;
		LongRes	: out q_bitsPoly(PolyDegree downto 0);
		ShortRes: out p_bitsPoly(PolyDegree downto 0)
	);
end entity;

architecture a1 of Lift_Poly is
signal Long_tmp     : std_logic_vector(q_bits-1 downto 0);
signal ShortResTmp  : q_bitsPoly(PolyDegree downto 0);

begin
	Long_tmp <= not PolyA(PolyDegree) + '1';
	
	LongRes(PolyDegree) <= Long_tmp;
	ShortRes(PolyDegree) <= Long_tmp(p_bits-1 downto 0);

	GG: for i in PolyDegree-1 downto 1 generate
		LongRes(i) <= PolyA(i+1) - PolyA(i);--(LongModLen-2 downto 0);
		ShortResTmp(i) <= PolyA(i+1) - PolyA(i);--(ShortModLen-2 downto 0);
		ShortRes(i) <= ShortResTmp(i)(p_bits-1 downto 0);
	end generate GG;

	LongRes(0) <= PolyA(1)(q_bits-1 downto 0);
	ShortRes(0) <= PolyA(1)(p_bits-1 downto 0);

end a1;