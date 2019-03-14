library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

library work;
use work.Round5_constants.all;

entity Mul_Poly_TB is
end entity; 

architecture a1 of Mul_Poly_TB is 

signal  inA, inB, outC : NTRUPolynomial(PolynomialDegree-1 downto 0);
signal clk : std_logic;
constant CLK_PERIOD : time := 10 ps;
type input_array is array(PolynomialDegree-1 downto 0) of integer;

begin

 clk_process :process
   begin
        clk <= '0';
        wait for CLK_PERIOD/2;  --for half of clock period clk stays at '0'.
        clk <= '1';
        wait for CLK_PERIOD/2;  --for next half of clock period clk stays at '1'.
   end process;
   
process
	
	procedure check_poly_mul( 	constant PolyA	: in input_array; -- v1
								constant PolyB 	: in input_array; -- v2
								constant inN1	: in integer; -- norm of v1
								constant inN2	: in integer; -- norm of v2
								constant res_ex	: in input_array) is
		variable res: input_array;
	begin
		GG: for i in NUM_OF_ELEMENTS-1 downto 0 loop
			inA(i) <= std_logic_vector(to_signed(PolyA(i), NUM_BIT_LEN));
			inB(i) <= std_logic_vector(to_signed(PolyB(i), NUM_BIT_LEN));
		end loop GG;
		
		wait for CLK_PERIOD*15;
		
--		RR: for i in NUM_OF_ELEMENTS-1 downto 0 loop
--			res(i) = to_integer(signed(outC(i)));
--		end loop RR;
--		assert res = res_ex
--		report 	"Unexpected result: " --&
----				"IN1 = " & integer'image(in1) & "; " &
----				"IN2 = " & integer'image(in2) & "; " &
----				"MUL = " & integer'image(res) & "; " &
----				"MUL_expected = " & integer'image(res_ex)
--		severity error;
	end procedure check_poly_mul;
	
	
begin
	
end process;
   
   
   
end a1;