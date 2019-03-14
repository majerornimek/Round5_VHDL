library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

library work;
use work.Round5_constants.all;

entity Mul_Poly_NTRU is 
	port (
		PolyA	: in NTRUPoly(PolyDegree downto 0);
		PolyB	: in Trinomial(PolyDegree downto 0);
		clk 	: in std_logic;
		Start	: in std_logic;
		Rst		: in std_logic;
		Done	: out std_logic;
		LongRes	: out NTRUPoly(PolyDegree downto 0);
		ShortRes: out ShortPoly(PolyDegree downto 0)
	);
end entity;

architecture a1 of Mul_Poly_NTRU is

component Mul_Poly_NTRU_tri_unit is 
	port (
		A		: in std_logic_vector(LongModLen-2 downto 0);
		B		: in std_logic_vector(1 downto 0);
		clk 	: in std_logic;
		Start	: in std_logic;
		Rst		: in std_logic;
		LongRes	: out std_logic_vector(LongModLen-2 downto 0);
		ShortRes: out std_logic_vector(ShortModLen-2 downto 0)
	);
end component;

signal shift_A : NTRUPoly(PolyDegree downto 0);		-- shift registers to store polynomials
signal shift_B : Trinomial(PolyDegree downto 0);		-- shift registers to store polynomials
signal result_poly		: NTRUPoly(PolyDegree downto 0);
signal Shift_counter	: std_logic_vector(PolyDegreeLog2-1 downto 0);

signal started	: std_logic; 									--indicate if multiplication started
signal Rst_mul 	: std_logic;

begin
	
PM: for i in 0 to PolyDegree generate
		Muli : Mul_Poly_NTRU_tri_unit 
			port map(
				A => shift_A(i),
				B => shift_B(i),
				clk => clk,
				Start => Start,
				Rst => Rst_mul,
				LongRes => LongRes(i),
				ShortRes => ShortRes(i)
			);
	end generate PM;
	

counter: process(Rst, clk)
begin
	if Rst = '1' then
		Shift_counter <= (others => '0');
		Done <= '0';
	elsif clk'event and clk = '1' then
		if Started = '1' then
			if unsigned(Shift_counter) /= PolyDegree then
				Shift_counter <= Shift_counter + '1';
				Done <= '0';
			else
				Done <= '1';
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
				shift_B <= shift_B(PolyDegree-1 downto 0) & shift_B(PolyDegree);
			end if;
		else
			shift_B <= (others=> (others=> '0'));
		end if;
	end if;
end process;

	
	
end a1;
