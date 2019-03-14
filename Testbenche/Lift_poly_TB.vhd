library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity Lift_poly_TB is
end entity;

architecture a1 of Lift_poly_TB is
component Lift_Poly is 
	port (
		PolyA	: in NTRUPoly(PolyDegree downto 0);
		clk 	: in std_logic;
		LongRes	: out NTRUPoly(PolyDegree downto 0);
		ShortRes: out ShortPoly(PolyDegree downto 0)
	);
end component;

signal clk : std_logic;
signal outDone	: std_logic;

constant CLK_PERIOD : time := 10 ps;
signal PolyA_tmp, long_Res : NTRUPoly(PolyDegree downto 0);
signal short_Res : ShortPoly(PolyDegree downto 0);
signal start_tmp : std_logic;
type input_array is array(PolyDegree downto 0) of integer;
begin 

   clk_process :process
   begin
        clk <= '0';
        wait for CLK_PERIOD/2;  --for half of clock period clk stays at '0'.
        clk <= '1';
        wait for CLK_PERIOD/2;  --for next half of clock period clk stays at '1'.
   end process;

   uut: Lift_Poly port map(
		PolyA	=> PolyA_tmp,
		clk 	=> clk,
		LongRes	=> long_Res,
		ShortRes => Short_Res
   );
   
process
	procedure check_lift( constant inV1	: in input_array; -- v1
							constant outLong	: in input_array) is
		variable res: input_array;
	begin
		GG: for i in PolyDegree downto 0 loop
			PolyA_tmp(i) <= std_logic_vector(to_unsigned(inV1(i), LongModLen-1));
		end loop GG;
		
		wait for CLK_PERIOD;
		start_tmp <= '1';
		wait for CLK_PERIOD*(PolyDegree+5);
		start_tmp <= '0';
		wait for  CLK_PERIOD;
		RR: for i in PolyDegree downto 0 loop
			res(i) := to_integer(unsigned(long_Res(i)));
		end loop RR;
		assert res = outLong
		report 	"Unexpected result: " --&
--				"IN1 = " & integer'image(in1) & "; " &
--				"IN2 = " & integer'image(in2) & "; " &
--				"MUL = " & integer'image(res) & "; " &
--				"MUL_expected = " & integer'image(res_ex)
		severity error;
	end procedure check_lift;
begin
	--check_lift((245, 152, 189, 108, 7, 13, 217, 209, 240, 142, 72, 184, 123, 101, 254,0), (11, 93, 219, 81, 101, 250, 52, 8, 225, 98, 70, 144, 61, 22, 103,0));
	--check_lift((1478, 1844, 1385, 1182, 1660, 1095, 891, 749, 2013, 58, 1123, 1810, 328, 820, 758,0),(570, 1682, 459, 203, 1570, 565, 204, 142, 784, 1955, 983, 1361, 1482, 1556, 62,0));
end process;
end a1;