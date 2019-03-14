-- Multiplication of coefficient in NTRU polynomial. One poly must be trinary
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

library work;
use work.Round5_constants.all;

entity Mul_Poly_NTRU_tri_unit is 
	port (
		A		: in std_logic_vector(LongModLen-2 downto 0);
		B		: in std_logic_vector(1 downto 0);
		clk 	: in std_logic;
		Start	: in std_logic;
		Rst		: in std_logic;
		LongRes	: out std_logic_vector(LongModLen-2 downto 0);
		ShortRes: out std_logic_vector(ShortModLen-2 downto 0)
	);
end entity;


architecture a1 of Mul_Poly_NTRU_tri_unit is 



signal long_tmp_acc		: signed(LongModLen downto 0);--signed(LongModLen downto 0);
signal short_tmp_acc	: signed(ShortModLen downto 0);
signal mul_res			: signed(LongModLen downto 0);

signal LongResTmp		: std_logic_vector(LongModLen downto 0);
signal ShortResTmp		: std_logic_vector(ShortModLen-2 downto 0);
begin


mul_res <= signed(A) * signed(B);


process(Rst, clk)
begin
	if Rst = '1' then
		long_tmp_acc <= (others => '0');
	elsif clk'event and clk= '1' then
		if Start = '1' then
			long_tmp_acc <= long_tmp_acc + mul_res(LongModLen-2 downto 0);
		end if;
	end if;
end process;
LongResTmp <= Std_logic_vector(long_tmp_acc);

LongRes <= LongResTmp(LongModLen-2 downto 0);
ShortRes <= LongResTmp(ShortModLen-2 downto 0);


end a1;