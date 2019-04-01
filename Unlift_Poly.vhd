library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity Unlift_Poly is 
	port (
		PolyA	: in q_bitsPoly(PolyDegree downto 0);
		clk 	: in std_logic;
		Start	: in std_logic;
		Done	: out std_logic;
		LongRes	: out q_bitsPoly(PolyDegree downto 0)
		--ShortRes: out ShortPoly(PolyDegree downto 0)
	);
end entity;

architecture a1 of Unlift_Poly is
signal Long_tmp     : std_logic_vector(q_bits-1 downto 0);
signal counter	    : std_logic_vector(PolyDegreeLog2-1 downto 0);
signal PolyA_tmp    : q_bitsPoly(PolyDegree downto 0);
signal CycPoly_tmp  : q_bitsPoly(PolyDegree downto 0);
signal tmp_res	    : std_logic_vector(q_bits-1 downto 0);

signal ShortPolyTmp : p_bitsPoly(PolyDegree downto 0);

signal done_tmp     : std_logic;
begin
	--Long_tmp <= not PolyA(0) + '1';
	
--	LongRes(0) <= Long_tmp;
--	ShortRes(0) <= Long_tmp(ShortModLen-2 downto 0);
--
--	GG: for i in 0 to PolyDegree generate
--		LongRes(i) <= PolyA(i-1) - PolyA(i);--(LongModLen-2 downto 0);
--		ShortPolyTmp(i) <= CycPoly_tmp(i)(ShortModLen-2 downto 0);
--	end generate GG;

--	LongRes(PolyDegree-1) <= PolyA(PolyDegree-2)(LongModLen-2 downto 0);
--	ShortRes(PolyDegree-1) <= PolyA(PolyDegree-2)(ShortModLen-2 downto 0);


	
arithm: process(clk)
begin
	if clk'event and clk = '1' then
		if Start = '1' then
			if counter = 0 then
				tmp_res <= (others => '0');
			elsif counter = "00000000001" then
				tmp_res <= not PolyA(PolyDegree) + '1';
			else --if counter > 2 then
				tmp_res <= ( tmp_res - PolyA_tmp(PolyDegree));
			end if;
		else
			tmp_res <= (others => '0');
		end if;
	end if;
end process;


shift_poly: process(clk)
begin
	if clk'event and clk = '1' then
		if Start = '1' then
			if counter = 0 then
				PolyA_tmp <= PolyA;
--			elsif counter = 1 then
				--PolyA_tmp <= tmp_res & CycPoly_tmp(PolyDegree-2 downto 0);
			elsif counter < PolyDegree+1 then
				PolyA_tmp <= PolyA_tmp(PolyDegree-1 downto 0) & PolyA_tmp(PolyDegree);
			end if;
		end if;
	end if;
end process;

shift_cyc: process(clk)
begin
	if clk'event and clk = '1' then
		if Start = '1' then
			if counter = 0 then
			elsif counter = 1 then
			elsif counter < PolyDegree+3 then
				CycPoly_tmp <= CycPoly_tmp(PolyDegree-1 downto 0) & tmp_res;
			end if;
		else
			CycPoly_tmp <= (others =>(others=>'0'));
		end if;
	end if;
end process;

	
	
	
count: process(clk)
begin
	if clk'event and clk = '1' then
		if Start = '1' then
			if counter < PolyDegree+3 then
				counter <= counter + '1';
				done_tmp <= '0';
			else
				LongRes <= CycPoly_tmp;
				done_tmp <= '1';
--				ShortRes <= ShortPolyTmp;
			end if;
		else
			counter <= (others => '0');
			done_tmp <= '0';
		end if;
	end if;
end process;

Done <= done_tmp and start;
	
	
end a1;

