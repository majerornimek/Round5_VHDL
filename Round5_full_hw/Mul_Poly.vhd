library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

library work;
use work.Round5_constants.all;
 
entity Mul_Poly is 
	port (
		PolyA	: in q_bitsPoly(PolyDegree downto 0);
		PolyB	: in Trinomial(PolyDegree downto 0); 
		clk		: in std_logic;
		Start	: in std_logic;
		Rst		: in std_logic;
		OpType	: in std_logic;
		Done	: out std_logic;
		LongRes	: out q_bitsPoly(PolyDegree downto 0)
	);
end entity;


architecture a1 of Mul_Poly is
component Mul_Poly_NTRU is 
	port (
		PolyA	: in q_bitsPoly(PolyDegree downto 0);
		PolyB	: in Trinomial(PolyDegree downto 0);
		clk 	: in std_logic;
		Start	: in std_logic;
		Rst		: in std_logic;
		Done	: out std_logic;
		LongRes	: out q_bitsPoly(PolyDegree downto 0)
		--ShortRes: out ShortPoly(PolyDegree downto 0)
	);
end component;

component Lift_Poly is 
	port (
		PolyA	: in q_bitsPoly(PolyDegree downto 0);
		clk 	: in std_logic;
		LongRes	: out q_bitsPoly(PolyDegree downto 0);
		ShortRes: out p_bitsPoly(PolyDegree downto 0)
	);
end component;

component Unlift_Poly is 
	port (
		PolyA	: in q_bitsPoly(PolyDegree downto 0);
		clk 	: in std_logic;
		Start	: in std_logic;
		Done 	: out std_logic;
		LongRes	: out q_bitsPoly(PolyDegree downto 0)
		--ShortRes: out ShortPoly(PolyDegree downto 0)
	);
end component;

signal Long_lifted, PolyA_to_mul, long_mul, to_unlift, Short_lifted_and, short_mul_and : q_bitsPoly(PolyDegree downto 0);
signal Short_lited, short_mul							: p_bitsPoly(PolyDegree downto 0);
signal done_mul, Start_unlift, start_mul, done_u : std_logic;
signal counter : std_logic_vector(3 downto 0);
begin

	lft: Lift_Poly port map(
		PolyA	=> PolyA,
		clk 	=> clk,
		LongRes	=> Long_lifted,
		ShortRes=> Short_lited
	);
	
	MP: Mul_Poly_NTRU port map(
		PolyA	=> PolyA_to_mul,
		PolyB	=> PolyB,
		clk 	=> clk,
		Start	=> start_mul,
		Rst		=> rst,
		Done	=> done_mul,
		LongRes	=> long_mul
		--ShortRes=> short_mul
	);
	
	unlft: Unlift_Poly port map(
		PolyA	=> to_unlift,
		clk 	=> clk,
		Start	=> Start_unlift,
		Done => Done_u,
		LongRes	=> LongRes
		--ShortRes=> ShortRes
	);
	
	liftand: for i in 0 to PolyDegree generate
		short_lifted_and(i) <= Long_lifted(i) and p_PolyMask;
		short_mul_and(i)	<= long_mul(i) and p_PolyMask;
	end generate liftand; 
	
	with OpType select PolyA_to_mul <=
		Long_lifted 		when '1',
		short_lifted_and 	when others;
	
	with OpType select to_unlift <=
		long_mul			when '1',
		short_mul_and		when others;
	
	
	ctr: process(clk)
	begin
		if clk'event and clk = '1' then
			if Start = '1' then
				if counter = 0 then
					counter <= "0001";
				elsif counter = "0001" then
					if done_mul = '1' then
						counter <= "0010";
					end if;
				elsif counter = "0010" then
					
				else
					
				end if;
			else
				counter <= (others => '0');
			end if;
		end if;
	end process;
	
	mul_ctr: process(rst, clk)
	begin
		if rst = '1' then 
			Start_mul <= '0';
		elsif clk'event and clk = '1' then
			if Start = '1' then
				if counter = 1 then --and done_mul /= '1' then
					Start_mul <= '1';
				end if;
			else
				Start_mul <= '0'; 
			end if;
		end if;
	end process;
	
	unlift_ctr: process(clk)
	begin
		if clk'event and clk = '1' then
			if Start = '1' then
				if counter >= 2 then
					start_unlift <= '1';
				else
					start_unlift <= '0';
				end if;
			else
				start_unlift <= '0';
			end if;
		end if;
	end process;
	
	Done <= done_u and start;

end a1;