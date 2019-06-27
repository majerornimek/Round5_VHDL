-- Multiplication of coefficient in NTRU polynomial. One poly must be trinary
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

library work;
use work.Round5_constants.all;

entity Mul_Poly_NTRU_tri_unit is 
	port (
		A		: in std_logic_vector(q_bits-1 downto 0);
		B		: in std_logic_vector(1 downto 0);
		clk 	: in std_logic;
		Start	: in std_logic;
		Rst		: in std_logic;
		LongRes	: out std_logic_vector(q_bits-1 downto 0)
	);
end entity;
 

architecture a1 of Mul_Poly_NTRU_tri_unit is 



signal long_tmp_acc		: signed(q_bits downto 0);--signed(LongModLen downto 0);
signal short_tmp_acc	: signed(p_bits downto 0);
signal mul_res			: signed(q_bits-1 downto 0);

signal LongResTmp		: std_logic_vector(q_bits downto 0);
--signal ShortResTmp		: std_logic_vector(ShortModLen-2 downto 0);

constant ones	: std_logic_vector(q_bits-1 downto 0) := (others => '1');
constant zeros	: std_logic_vector(q_bits-1 downto 0) := (others => '0');
signal   B_mask : std_logic_vector(q_bits-1 downto 0);
signal   val_mask : std_logic_vector(q_bits-1 downto 0);

begin

with B(1) select B_mask <=
	not A + '1' when '1',
	A when others;
	
with B(0) select mul_res <=
	signed(B_mask) when '1',
	signed(zeros) when others;

process(Rst, clk)
begin
	if Rst = '1' then
		long_tmp_acc <= (others => '0');
	elsif clk'event and clk= '1' then
		if Start = '1' then
			long_tmp_acc <= long_tmp_acc + mul_res(q_bits-1 downto 0);
		end if;
	end if;
end process;

LongResTmp <= Std_logic_vector(long_tmp_acc);

LongRes <= LongResTmp(q_bits-1 downto 0);
--ShortRes <= LongResTmp(ShortModLen-2 downto 0);


end a1;