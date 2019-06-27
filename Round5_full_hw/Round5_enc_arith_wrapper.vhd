library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity Round5_enc_arith_wrapper is	
	port(
	rst 		: in std_logic;
	clk			: in std_logic;
	-- FIFO WRITE
	FIFO_Full	: out std_logic;
	FIFO_din	: in std_logic_vector(63 downto 0);
	FIFO_wr_en	: in std_logic;
	-- FIFO READ
	FIFO_Empty	: out std_logic;
	FIFO_dout	: out std_logic_vector(63 downto 0);
	FIFO_rd_en	: in std_logic
	);
end entity;
