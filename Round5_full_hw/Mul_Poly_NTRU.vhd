library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

library work;
use work.Round5_constants.all;

entity Mul_Poly_NTRU is 
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
end entity;
 
architecture a1 of Mul_Poly_NTRU is

component Mul_Poly_NTRU_tri_unit is 
	port (
		A		: in std_logic_vector(q_bits-1 downto 0);
		B		: in std_logic_vector(1 downto 0);
		clk 	: in std_logic;
		Start	: in std_logic;
		Rst		: in std_logic;
		LongRes	: out std_logic_vector(q_bits-1 downto 0)
	);
end component;

signal shift_A : q_bitsPoly(PolyDegree downto 0);		-- shift registers to store polynomials
signal shift_B : Trinomial(PolyDegree downto 0);		-- shift registers to store polynomials
signal result_poly		: q_bitsPoly(PolyDegree downto 0);
signal Shift_counter	: std_logic_vector(PolyDegreeLog2-1 downto 0);
signal LongResTmp   : q_bitsPoly(PolyDegree downto 0); 
signal started	: std_logic; 									--indicate if multiplication started
signal Rst_mul 	: std_logic;

signal LongResTmp2 : q_bitsPoly(PolyDegree downto 0);
signal ShortResTmp2 : p_bitsPoly(PolyDegree downto 0);
signal Start_mul, Start_mul1	: std_logic;

begin
	
PM: for i in 0 to PolyDegree generate
		Muli : Mul_Poly_NTRU_tri_unit 
			port map(
				A => shift_A(i),
				B => shift_B(i),
				clk => clk,
				Start => Start_mul,
				Rst => Rst_mul,
				LongRes => LongResTmp2(i)--((2*i) mod PolyDegree),
				--ShortRes => ShortResTmp2(i)--((2*i) mod PolyDegree)
			);
	end generate PM;
	
	
	oo: for i in 0 to PolyDegree generate
	   ol: if (i+i) < PolyDegree generate
	       LongRes(i+i+1) <= LongResTmp2(i);
	       --ShortRes(i+i+1)  <= ShortResTmp2(i);
	   end generate ol;
	   
	   oll: if (2*i) >= PolyDegree generate
	       LongRes(2*i - (PolyDegree)) <= LongResTmp2(i);
	       --ShortRes(2*i- (PolyDegree))  <= ShortResTmp2(i);
	   end generate oll;
	   
	end generate oo;

counter: process(Rst, clk)
begin
	if Rst = '1' then
		Shift_counter <= (others => '0');
		Done <= '0';
		Start_mul <= '0';
	elsif clk'event and clk = '1' then
		if Started = '1' then
			if unsigned(Shift_counter) /= PolyDegree+1 then
				Shift_counter <= Shift_counter + '1';
				Done <= '0';
				Start_mul <= '1';
			else
				Done <= '1';
				Start_mul <= '0';
			end if;
		else
			Shift_counter <= (others => '0');
			Done <= '0';
		end if;
	end if;
end process;
	
	
	
reset_mul: process(Rst, clk)
begin
	if Rst = '1' then
		Rst_mul <= '1';
	elsif clk'event and clk = '1' then
		if Start = '1' then
			Rst_mul <= '0';
		else
			Rst_mul <= '1';
		end if;
	end if;
end process;

	
	
SHift_poly_A: process(clk)
begin
	if clk'event and clk = '1' then
		if Start = '1' then
			if started = '0' then
				shift_A <= PolyA;
				started <= '1';
			else
				shift_A <= shift_A(PolyDegree-1 downto 0) & shift_A(PolyDegree);
			end if;
		else
			started <= '0';
			shift_A <= (others=> (others=> '0'));
		end if;
	end if;
end process;
	

SHift_poly_B: process(clk)
begin
	if clk'event and clk = '1' then
		if Start = '1' then
			if started = '0' then
				shift_B <= PolyB;
			else
				shift_B <= shift_B(0) & shift_B(PolyDegree downto 1);
			end if;
		else
			shift_B <= (others=> (others=> '0'));
		end if;
	end if;
end process;

--start_mul <= start_mul1 and start;	
	
end a1;
