library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity Unlift_poly_TB is
end entity;

architecture a1 of Unlift_poly_TB is
component Unlift_Poly is 
	port (
		PolyA	: in NTRUPoly(PolyDegree downto 0);
		clk 	: in std_logic;
		Start	: in std_logic; 
		LongRes	: out NTRUPoly(PolyDegree downto 0);
		ShortRes: out ShortPoly(PolyDegree downto 0)
	);
end component;

signal clk : std_logic;

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

   uut: Unlift_Poly port map(
		PolyA	=> PolyA_tmp,
		clk 	=> clk,
		Start	=> start_tmp,
		LongRes	=> long_Res,
		ShortRes => Short_Res
   );
   
process
	procedure check_unlift( constant inV1	: in input_array; -- v1
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
	end procedure check_unlift;
begin
	--check_unlift((86, 750, 1749, 647, 811, 2000, 416, 60, 1799, 786, 564, 1152, 484, 178, 823,0), (1962, 1212, 1511, 864, 53, 101, 1733, 1673, 1922, 1136, 572, 1468, 984, 806, 2031,0));
	--check_unlift((18, 224, 180, 118, 5, 122, 108, 18, 228, 21, 146, 214, 106, 251, 3,0),(238, 14, 90, 228, 223, 101, 249, 231, 3, 238, 92, 134, 28, 33, 30,0));
end process;
end a1;