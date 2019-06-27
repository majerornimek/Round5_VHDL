library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity cbd_wrapper is
	port(
		rst	: in std_logic;
		clk	: in std_logic;
		
		FIFO_Dout	: out std_logic_vector(63 downto 0);
		FIFO_Din	: in std_logic_vector(63 downto 0);
		FIFO_wr_en	: in std_logic;
		FIFO_rd_en 	: in std_logic;
		FIFO_Full	: out std_logic;
		FIFO_Empty	: out std_logic
	);
end entity;


architecture a1 of cbd_wrapper is

component cbd is
	generic(
		to_cbd_size: integer := 80; --48, 64, 80
		s: integer := 4 --3, 4, 4 number of bits in one sample
	);
	port(
		data_in: in std_logic_vector(to_cbd_size/2-1 downto 0);
		data_out: out std_logic_vector(4*s-1 downto 0)
	);
end component;

signal to_cdb : std_logic_vector(63 downto 0);
signal from_cdb: 


begin


	


end a1;
