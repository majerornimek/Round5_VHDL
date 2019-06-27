library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;
use work.sha_tb_pkg.all;

entity Round5_full_hw_top is	
	port (
		--arithm_clk	: in std_logic;
		--hash_clk	: in std_logic;
		--aead_clk	: in std_logic;
		clk	: in std_logic;
		rst : in std_logic;
		------- FIFO IN
		FIFO_din	: in std_logic_vector(63 downto 0);
		FIFO_rd_en	: in std_logic;
		FIFO_Full	: out std_logic;
		
		------- FIFO OUT
		FIFO_dout	: out std_logic_vector(63 downto 0);
		FIFO_wr_en	: in std_logic;
		FIFO_Empty	: out std_logic
		
	);
end entity;

architecture a1 of Round5_full_hw_top is 


signal din_arithm, din_hash, din_controller	: std_logic_vector(63 downto 0);

signal dout_hash, dout_arithm, dout_aead, dout_ctrl, out_idata, out_odata : std_logic_vector(63 downto 0);
signal dout_bus		: std_logic_vector(63 downto 0);

signal  dout_demux_ctrl 	: std_logic_vector(1 downto 0);
signal demux_arithm_ctrl, demux_controller_ctrl, demux_hash_ctrl : std_logic;

		
			 
signal arithm_FIFO_din,arithm_FIFO_dout : std_logic_vector(63 downto 0);
signal arithm_FIFO_wr_en, arithm_FIFO_Empty, arithm_FIFO_rd_en, arithm_FIFO_Full, arithm_reset : std_logic;

signal hash_FIFO_din, hash_FIFO_dout : std_logic_vector(63 downto 0);
signal hash_FIFO_wr_en, hash_FIFO_Empty, hash_FIFO_rd_en, hash_FIFO_Full : std_logic;

signal aead_FIFO_wr_en, aead_FIFO_Empty, aead_FIFO_Full, aead_FIFO_rd_en : std_logic;
signal out_fifoout_write, out_fifoin_read, out_fifoin_empty, out_fifoout_full : std_logic;

---- Reset signals
signal arithm_rst, hash_rst, aead_rst : std_logic;
SIGNAL hash_clk, aead_clk, arithm_clk : std_logic;

begin

hash_clk <= clk;
aead_clk <= clk;
arithm_clk <= clk;

	fifoin: entity work.fifo(prefetch)   
	generic map ( fifo_mode=>fifo_mode, depth => depth, log2depth => log2depth, N => W)
	port map (
		clk=>clk,
		rst=>rst,
		write=>FIFO_wr_en,
		read=>out_fifoin_read,
		din=>FIFO_Din,
		dout=>out_idata,
		full=>FIFO_Full,
		empty=>out_fifoin_empty);	 
		
	
	fifoout: entity work.fifo(prefetch) 
		generic map ( fifo_mode=>fifo_mode, depth => depth, log2depth => log2depth, N => W)
		port map (
		clk=>clk,
		rst=>rst,
		write=>out_fifoout_write,
		read=>FIFO_rd_en,
		din=>out_odata,
		dout=> FIFO_Dout,
		full=>out_fifoout_full,
		empty=> FIFO_Empty);

	arithm: entity work.Round5_enc_arith_wrapper(R5ND_5KEM_0d)
		port map(
			clk => arithm_clk,
			rst => arithm_rst,
			
			-- FIFO WRITE
			FIFO_Full	=> arithm_FIFO_Full,
			FIFO_din	=> din_arithm,
			FIFO_wr_en	=> arithm_FIFO_wr_en,
			-- FIFO READ
			FIFO_Empty	=> arithm_FIFO_Empty,
			FIFO_dout	=> dout_arithm,
			FIFO_rd_en	=> arithm_FIFO_rd_en
	);
		
	hash: entity work.keccak_top_wrapper(a1) 
		generic map (HS => 256)
		port map (
			rst 			=> hash_rst,
			clk 			=> hash_clk,
			FIFO_wr_en		=> hash_FIFO_wr_en,
			FIFO_Full		=> hash_FIFO_Full,
			FIFO_rd_en		=> hash_FIFO_rd_en,
			FIFO_Empty		=> hash_FIFO_Empty,
			FIFO_Din		=> din_hash,
			FIFO_Dout		=> dout_hash
		);
		
	ctrl: entity work.Round5_top_controller 
		port map(
			clk				=> clk,
			rst				=> rst,
			
			rst_hash		=> hash_rst,
			rst_arithm		=> arithm_rst,
			rst_aead		=> aead_rst,
			
			---- FIFO CONTROLL
			FIFO_rd_en		=> out_fifoin_read,
			FIFO_wr_en		=> out_fifoout_write,
			FIFO_Empty		=> out_fifoin_empty,
			FIFO_Full		=> out_fifoout_full,
						
			---- INPUT/OUTPUT COMMAND
			din				=> din_controller,
			dout 			=> dout_ctrl,
			demux_ctrl		=> demux_controller_ctrl,
			dout_demux_ctrl	=> dout_demux_ctrl,
		
			---- ARITHM CONTROL SIGNALS
			
			arithm_FIFO_Empty 	=> arithm_FIFO_Empty,
			arithm_FIFO_Full 	=> arithm_FIFO_Full,
			arithm_FIFO_rd_en 	=> arithm_FIFO_rd_en,
			arithm_FIFO_wr_en	=> arithm_FIFO_wr_en,
			demux_arithm	=> demux_arithm_ctrl,
			
			
			
			
			---- HASH CONTROL SIGNALS
			hash_FIFO_wr_en => hash_FIFO_wr_en,
			hash_FIFO_rd_en => hash_FIFO_rd_en,
			hash_FIFO_Full 	=> hash_FIFO_Full,
			hash_FIFO_Empty => hash_FIFO_Empty,
			demux_hash		=> demux_hash_ctrl,
			
			---- AEAD CONTROL SIGNALS
			aead_FIFO_wr_en		=> aead_FIFO_wr_en,
			aead_FIFO_Full		=> aead_FIFO_Full,
			aead_FIFO_rd_en		=> aead_FIFO_rd_en,
			aead_FIFO_Empty		=> aead_FIFO_Empty
			
		);
		
	aes: entity work.AEAD_PKI_wrapper(a1) 	
		port map(
			rst 			=> aead_rst,
			clk 			=> aead_clk,
			FIFO_wr_en		=> aead_FIFO_wr_en,
			FIFO_Full		=> aead_FIFO_Full,
			FIFO_rd_en		=> aead_FIFO_rd_en,
			FIFO_Empty		=> aead_FIFO_Empty,
			FIFO_Din		=> dout_bus,
			FIFO_Dout		=> dout_aead
		);


-- with dout_demux_ctrl select dout_bus <=
	-- dout_hash 	when "01",
	-- dout_arithm	when "10",
	-- dout_aes	when "11",
	-- dout_ctrl 	when others;
	
	
	
out_odata <= dout_bus;
--- LAST DEMUX CONTROL
process(clk)
begin
	if clk'event and clk = '1' then
		case dout_demux_ctrl is 
			when "01" => dout_bus <= dout_hash;
			when "10" => dout_bus <= dout_arithm;
			when "11" => dout_bus <= dout_aead;
			when others => dout_bus <= dout_ctrl;
		end case;
	end if;
end process;

----- HASH DEMUX IN CTRL
process(clk)
begin
	if clk'event and clk = '1' then
		if demux_hash_ctrl = '0' then
			din_hash <= dout_bus;
		else
			din_hash <= out_idata;
		end if;
	end if;
end process;


----- Arithm DEMUX IN CTRL
process(clk)
begin
	if clk'event and clk = '1' then
		if demux_arithm_ctrl = '0' then
			din_arithm <= dout_bus;
		else
			din_arithm <= out_idata;
		end if;
	end if;
end process;


----- Controller DEMUX IN CTRL
process(clk)
begin
	if clk'event and clk = '1' then
		if demux_controller_ctrl = '1' then
			din_controller <= dout_bus;
		else
			din_controller <= out_idata;
		end if;
	end if;
end process;



end a1;