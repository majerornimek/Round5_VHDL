-- =====================================================================
-- Copyright © 2010-2012 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

-- Possible generics values:
-- hs = {HASH_SIZE_256, HASH_SIZE_512}

library ieee;
use ieee.std_logic_1164.all;
use work.sha3_pkg.all;
use work.keccak_pkg.all;
use work.sha_tb_pkg.all;


entity keccak_top_wrapper is
generic (HS : integer := HASH_SIZE_256);
port (
		rst 			: in std_logic;
		clk 			: in std_logic;
		FIFO_wr_en		: in std_logic;
		FIFO_Full		: out std_logic;
		FIFO_rd_en		: in std_logic;
		FIFO_Empty		: out std_logic;
		FIFO_Din		: in std_logic_vector(63 downto 0);
		FIFO_Dout			: out std_logic_vector(63 downto 0)
	);
end keccak_top_wrapper;

architecture a1 of keccak_top_wrapper is

signal fifoin_read, fifoin_empty, fifoout_full, fifoout_write : std_logic;
signal idata, odata : std_logic_vector(63 downto 0);

begin

	fifoin: entity work.fifo(prefetch)   
	generic map ( fifo_mode=>fifo_mode, depth => depth, log2depth => log2depth, N => 64)
	port map (
		clk=>clk,
		rst=>rst,
		write=>FIFO_wr_en,
		read=>fifoin_read,
		din=>FIFO_Din,
		dout=>idata,
		full=>FIFO_Full,
		empty=>fifoin_empty);	 
		
	
	fifoout: entity work.fifo(prefetch) 
		generic map ( fifo_mode=>fifo_mode, depth => depth, log2depth => log2depth, N => 64)
		port map (
		clk=>clk,
		rst=>rst,
		write=>fifoout_write,
		read=>FIFO_rd_en,
		din=>odata,
		dout=> FIFO_Dout,
		full=>fifoout_full,
		empty=> FIFO_Empty);		
				
	
	kecc: entity work.keccak_top(structure) generic map(
		HS => 256
	) port map(
		rst 			=> rst,
		clk 			=> clk,
		src_ready 		=> fifoin_empty,
		src_read  		=> fifoin_read,
		dst_ready 		=> fifoout_full,
		dst_write 		=> fifoout_write,
		din				=> idata,
		dout			=> odata
	);


end a1;