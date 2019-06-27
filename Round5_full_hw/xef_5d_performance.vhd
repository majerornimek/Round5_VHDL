library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

library work;
use work.Round5_constants.all;  

entity xef_5d_performance is
	port (
		DIN		: in std_logic_vector(R5_MessageLen-1 downto 0);
		
		clk		: in std_logic;
		Start	: in std_logic;
		Reset	: in std_logic;
		
		Done	: out std_logic;
		DOUT	: out std_logic_vector(R5_MessageLen-1 downto 0)
	);
end entity;



architecture a1 of xef_5d_performance is
signal counter : std_logic_vector(4 downto 0) := (others => '0');

signal t, t1, t2, t3 : std_logic_vector(7 downto 0) := (others => '0');
begin

t1(7 downto 4) <= t(7 downto 4);
t1(3 downto 0) <= t(7 downto 4) xor t(3 downto 0);

t2(7 downto 6) <= t1p(7 downto 6);
t2(5 downto 0) <= t1p(5 downto 0) xor t1p(7 downto 2);

t3(7) <= t2p(7);
t3(6 downto 0) <= t2p(6 downto 0) xor t2p(7 downto 1);

--t2(7 downto 6) <= t1(7 downto 6);
--t2(5 downto 0) <= t1(5 downto 0) xor t1(7 downto 2);

--t3(7) <= t2(7);
--t3(6 downto 0) <= t2(6 downto 0) xor t2(7 downto 1);

process(clk)
begin
	if clk'event and clk = '1' then 
		if Start = '1' then
			t1p <= t1;
			t2p <= t2;
		end if;
	end if;
end process;


with counter select t <=
	DIN(255 downto 248) when "00000",
	DIN(247 downto 240) when "00001",
	DIN(239 downto 232) when "00010",
	DIN(231 downto 224) when "00011",
	DIN(223 downto 216) when "00100",
	DIN(215 downto 208) when "00101",
	DIN(207 downto 200) when "00110",
	DIN(199 downto 192) when "00111",
	DIN(191 downto 184) when "01000",
	DIN(183 downto 176) when "01001",
	DIN(175 downto 168) when "01010",
	DIN(167 downto 160) when "01011",
	DIN(159 downto 152) when "01100",
	DIN(151 downto 144) when "01101",
	DIN(143 downto 136) when "01110",
	DIN(135 downto 128) when "01111",
	DIN(127 downto 120) when "10000",
	DIN(119 downto 112) when "10001",
	DIN(111 downto 104) when "10010",
	DIN(103 downto 96) when "10011",
	DIN(95 downto 88) when "10100",
	DIN(87 downto 80) when "10101",
	DIN(79 downto 72) when "10110",
	DIN(71 downto 64) when "10111",
	DIN(63 downto 56) when "11000",
	DIN(55 downto 48) when "11001",
	DIN(47 downto 40) when "11010",
	DIN(39 downto 32) when "11011",
	DIN(31 downto 24) when "11100",
	DIN(23 downto 16) when "11101",
	DIN(15 downto 8) when "11110",
	DIN(7 downto 0) when others;



proc_count: process(clk)
begin
	if reset = '1' then
		counter <= (others => '0');
	elsif clk'event and clk = '1' then
		if Start = '1' then
			counter <= counter + '1';
		else	
			counter <= (others => '0');
		end if;
	end if;
end process;




end a1;