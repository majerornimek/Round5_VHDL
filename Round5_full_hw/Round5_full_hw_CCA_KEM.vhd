library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;
use work.sha_tb_pkg.all;
use work.sha3_pkg.all;
use work.keccak_pkg.all;

entity Round5_full_hw_CCA_KEM is	
	port (
		--arithm_clk	: in std_logic;
		--hash_clk	: in std_logic;
		--aead_clk	: in std_logic;
		clk	: in std_logic;
		rst : in std_logic;
		------- PUBLI IN
		pdi_data	: in std_logic_vector(63 downto 0);
		pdi_valid	: in std_logic;
		pdi_ready	: out std_logic;
		
		------- SECRET IN
		sdi_data	: in std_logic_vector(63 downto 0);
		sdi_valid	: in std_logic;
		sdi_ready	: out std_logic;
		
		
		------- RANDOM IN
		rdi_data	: in std_logic_vector(63 downto 0);
		rdi_valid	: in std_logic;
		rdi_ready	: out std_logic;
		
		
		------- PUBLIC OUT
		pdo_data	: out std_logic_vector(63 downto 0);
		pdo_valid	: out std_logic;
		pdo_ready	: in std_logic;
		
		
		------- SECRET OUT
		sdo_data	: out std_logic_vector(63 downto 0);
		sdo_valid	: out std_logic;
		sdo_ready	: in std_logic
		
	);
end entity;

architecture a1 of Round5_full_hw_CCA_KEM is 


signal din_arithm, din_hash, din_controller	: std_logic_vector(63 downto 0);

signal dout_hash, dout_arithm, dout_aead, dout_ctrl, out_idata, out_odata : std_logic_vector(63 downto 0);
signal dout_bus		: std_logic_vector(63 downto 0);


signal  demux_controller_ctrl : std_logic;
signal  mem_FIFO_Din, mem_FIFO_Dout : std_logic_vector(63 downto 0);
signal 	mem_FIFO_Empty, mem_FIFO_Full, mem_FIFO_rd_en, mem_FIFO_wr_en : std_logic;


		
			 
signal arithm_FIFO_din,arithm_FIFO_dout : std_logic_vector(63 downto 0);
signal arithm_FIFO_wr_en, arithm_FIFO_Empty, arithm_FIFO_rd_en, arithm_FIFO_Full, arithm_reset : std_logic;

signal hash_FIFO_din, hash_FIFO_dout : std_logic_vector(63 downto 0);
signal hash_FIFO_wr_en, hash_FIFO_Empty, hash_FIFO_rd_en, hash_FIFO_Full : std_logic;

signal aead_FIFO_wr_en, aead_FIFO_Empty, aead_FIFO_Full, aead_FIFO_rd_en : std_logic;
signal out_fifoout_write, out_fifoin_read, out_fifoin_empty, out_fifoout_full : std_logic;

---- Reset signals
signal arithm_rst, hash_rst, aead_rst : std_logic;
SIGNAL hash_clk, aead_clk, arithm_clk : std_logic;

signal pdo_bus, sdo_bus : std_logic_vector(63 downto 0);
signal demux_hash_ctrl, demux_arithm_ctrl, demux_mem_ctrl : std_logic_vector(1 downto 0);
signal pdo_demux_ctrl, sdo_demux_ctrl  : std_logic_vector(2 downto 0);


--signal mem_FIFO_Din, mem_FIFO_Dout : std_logic_vector(63 downto 0);
--signal mem_FIFO_Empty, mem_FIFO_Full, mem_FIFO_rd_en, mem_FIFO_wr_en : std_logic;

begin

hash_clk <= clk;
aead_clk <= clk;
arithm_clk <= clk;


	arithm: entity work.Round5_enc_arith_wrapper(R5ND_1PKE_0d)
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
		
	ctrl: entity work.Round5_top_controller_CCA_KEM
		port map(
			clk				=> clk,
			rst				=> rst,
			
			rst_hash		=> hash_rst,
			rst_arithm		=> arithm_rst,
			rst_aead		=> aead_rst,
			
			---- 	INPUT CONTROLL
			pdi_data		=> pdi_data,
			pdi_valid		=> pdi_valid,			
			pdi_ready		=> pdi_ready,
			
			sdi_data		=> sdi_data,
			sdi_valid		=> sdi_valid,
			sdi_ready		=> sdi_ready,
			
			rdi_data		=> rdi_data,
			rdi_valid		=> rdi_valid,
			rdi_ready		=> rdi_ready,
			
			----	OUTPUT CONTROL
			pdo_ready		=> pdo_ready,
			pdo_valid		=> pdo_valid,
			sdo_ready		=> sdo_ready,
			sdo_valid		=> sdo_valid,

			
						
			---- INPUT/OUTPUT COMMAND
			dout 			=> dout_ctrl,
			pdo_demux_ctrl	=> pdo_demux_ctrl,
			sdo_demux_ctrl	=> sdo_demux_ctrl,
		
			---- ARITHM CONTROL SIGNALS
			arithm_FIFO_Empty 	=> arithm_FIFO_Empty,
			arithm_FIFO_Full 	=> arithm_FIFO_Full,
			arithm_FIFO_rd_en 	=> arithm_FIFO_rd_en,
			arithm_FIFO_wr_en	=> arithm_FIFO_wr_en,
			demux_arithm		=> demux_arithm_ctrl,
			
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
			aead_FIFO_Empty		=> aead_FIFO_Empty,
			
			
			----- MEMORY CONTROL
			mem_FIFO_wr_en		=> mem_FIFO_wr_en,
			mem_FIFO_rd_en		=> mem_FIFO_rd_en,
			mem_FIFO_Full		=> mem_FIFO_Full,
			mem_FIFO_Empty		=> mem_FIFO_Empty,
			demux_mem 			=> demux_mem_ctrl
		);
		
		
		fifoin: entity work.fifo(prefetch)   
			generic map ( fifo_mode=>fifo_mode, depth => depth, log2depth => log2depth, N => 64)
			port map (
				clk=>clk,
				rst=>rst,
				write=>mem_FIFO_wr_en,
				read=>mem_FIFO_rd_en,
				din=> pdo_bus,
				dout=>mem_FIFO_Dout,
				full=>mem_FIFO_Full,
				empty=>mem_FIFO_Empty
			);	 
		
		
	-- aes: entity work.AEAD_PKI_wrapper(a1) 	
		-- port map(
			-- rst 			=> aead_rst,
			-- clk 			=> aead_clk,
			-- FIFO_wr_en		=> aead_FIFO_wr_en,
			-- FIFO_Full		=> aead_FIFO_Full,
			-- FIFO_rd_en		=> aead_FIFO_rd_en,
			-- FIFO_Empty		=> aead_FIFO_Empty,
			-- FIFO_Din		=> dout_bus,
			-- FIFO_Dout		=> dout_aead
		-- );


	
pdo_data <= pdo_bus;
sdo_data <= sdo_bus;

--- PDO DEMUX CONTROL
process(clk)
begin
	if clk'event and clk = '1' then
		case pdo_demux_ctrl is 
			when "001" => pdo_bus  <= dout_hash;
			when "010" => pdo_bus  <= dout_arithm;
			when "011" => pdo_bus  <= dout_aead;
			when "100" => pdo_bus  <= mem_FIFO_Dout;
			when others => pdo_bus <= dout_ctrl;
		end case;
	end if;
end process;

--- SDO DEMUX CONTROL
process(clk)
begin
	if clk'event and clk = '1' then
		case sdo_demux_ctrl is 
			when "001" => sdo_bus  <= dout_hash;
			when "010" => sdo_bus  <= dout_arithm;
			when "011" => sdo_bus  <= dout_aead;
			when "100" => sdo_bus  <= mem_FIFO_Dout;
			when others => sdo_bus <= dout_ctrl;
		end case;
	end if;
end process;


----- HASH DEMUX IN CTRL
process(clk)
begin
	if clk'event and clk = '1' then
		case demux_hash_ctrl is
			when "01" => din_hash <= rdi_data;
			when "10" => din_hash <= sdi_data;
			when "11" => din_hash <= pdi_data;
			when others => din_hash <= pdo_bus;
		end case;
	end if;
end process;


----- Arithm DEMUX IN CTRL
process(clk)
begin
	if clk'event and clk = '1' then
		case demux_arithm_ctrl is
			when "01" => din_arithm <= rdi_data;
			when "10" => din_arithm <= sdi_data;
			when "11" => din_arithm <= pdi_data;
			when others => din_arithm <= pdo_bus;
		end case;
	end if;
end process;

----- Memory DEMUX IN CTRL
process(clk)
begin
	if clk'event and clk = '1' then
		case demux_mem_ctrl is
			when "01" => mem_FIFO_Din <= rdi_data;
			when "10" => mem_FIFO_Din <= sdi_data;
			when "11" => mem_FIFO_Din <= pdi_data;
			when others => mem_FIFO_Din <= pdo_bus;
		end case;
	end if;
end process;



end a1;