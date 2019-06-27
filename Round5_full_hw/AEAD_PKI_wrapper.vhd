-------------------------------------------------------------------------------
--! @file       AEAD_Arch.vhd
--! @brief      Architecture of authenticated encryption unit.
--!             Note: This file should not be modified by a user.
--! @project    CAESAR Candidate Evaluation
--! @author     Ekawat (ice) Homsirikamol
--! @copyright  Copyright (c) 2016 Cryptographic Engineering Research Group
--!             ECE Department, George Mason University Fairfax, VA, U.S.A.
--!             All rights Reserved.
--! @license    This project is released under the GNU Public License.
--!             The license and distribution terms for this file may be
--!             found in the file LICENSE in this distribution or at
--!             http://www.gnu.org/licenses/gpl-3.0.txt
--! @note       This is publicly available encryption source code that falls
--!             under the License Exception TSU (Technology and software-
--!             â€”unrestricted)
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use work.AEAD_pkg.all;

entity AEAD_PKI_wrapper is
	port(
		rst 			: in std_logic;
		clk 			: in std_logic;
		FIFO_wr_en		: in std_logic;
		FIFO_Full		: out std_logic;
		FIFO_rd_en		: in std_logic;
		FIFO_Empty		: out std_logic;
		FIFO_Din		: in std_logic_vector(63 downto 0);
		FIFO_Dout			: out std_logic_vector(63 downto 0)
	);
end entity;

architecture a1 of AEAD_PKI_wrapper is
component AEAD is
    generic (
        --! I/O width (bits)
        G_W             : integer := 32;    --! Public data input
        G_SW            : integer := 32;    --! Secret data input
        --! Reset behavior
        G_ASYNC_RSTN    : boolean := False; --! Async active low reset
        --! Special features parameters
        G_ENABLE_PAD    : boolean := False; --! Enable padding
        G_CIPH_EXP      : boolean := False; --! Ciphertext expansion
        G_REVERSE_CIPH  : boolean := False; --! Reversed ciphertext
        G_MERGE_TAG     : boolean := False; --! Merge tag with data segment
        --! Block size (bits)
        G_ABLK_SIZE     : integer := 128;   --! Associated data
        G_DBLK_SIZE     : integer := 128;   --! Data
        G_KEY_SIZE      : integer := 32;    --! Key
        G_TAG_SIZE      : integer := 128;   --! Tag
        --! Padding options
        G_PAD_STYLE     : integer := 0;     --! Pad style
        G_PAD_AD        : integer := 1;     --! Padding behavior for AD
        G_PAD_D         : integer := 1;     --! Padding behavior for Data
        --! Maximum supported AD/message/ciphertext length = 2^G_MAX_LEN-1
        G_MAX_LEN       : integer := SINGLE_PASS_MAX
    );
    port (
        --! Global ports
        clk             : in  std_logic;
        rst             : in  std_logic;
        --! Publica data ports
        pdi_data        : in  std_logic_vector(G_W              -1 downto 0);
        pdi_valid       : in  std_logic;
        pdi_ready       : out std_logic;
        --! Secret data ports
        sdi_data        : in  std_logic_vector(G_SW             -1 downto 0);
        sdi_valid       : in  std_logic;
        sdi_ready       : out std_logic;
        --! Data out ports
        do_data         : out std_logic_vector(G_W              -1 downto 0);
        do_ready        : in  std_logic;
        do_valid        : out std_logic
    );
end component;

signal counter, counter_lim 	: std_logic_vector(3 downto 0);
signal sdi_wr, pdi_wr, op_reciv : std_logic;
signal pdi_data, sdi_data, do_data : std_logic_vector(63 downto 0);
signal pdi_ready, pdi_valid, sdi_ready, sdi_valid, do_ready, do_valid : std_logic;
begin

	aes: AEAD
		generic map(
			        --! I/O width (bits)
			G_W             => 64,   --! Public data input
			G_SW            => 64,   --! Secret data input
			--! Reset behavior
			G_ASYNC_RSTN    => False, --! Async active low reset
			--! Special features parameters
			G_ENABLE_PAD    => False, --! Enable padding
			G_CIPH_EXP      => False, --! Ciphertext expansion
			G_REVERSE_CIPH  => False, --! Reversed ciphertext
			G_MERGE_TAG     => False, --! Merge tag with data segment
			--! Block size (bits)
			G_ABLK_SIZE     => 128,   --! Associated data
			G_DBLK_SIZE     => 128,   --! Data
			G_KEY_SIZE      => 32,    --! Key
			G_TAG_SIZE      => 128,   --! Tag
			--! Padding options
			G_PAD_STYLE     => 0,     --! Pad style
			G_PAD_AD        => 1,     --! Padding behavior for AD
			G_PAD_D         => 1,     --! Padding behavior for Data
			--! Maximum supported AD/message/ciphertext length = 2^G_MAX_LEN-1
			G_MAX_LEN       => SINGLE_PASS_MAX
		)
		port map(
			clk => clk,
			rst => rst,
			--! Publica data ports
			pdi_data        => pdi_data,
			pdi_valid       => pdi_valid,
			pdi_ready       => pdi_ready,
			--! Secret data ports
			sdi_data        => sdi_data,
			sdi_valid       => sdi_valid,
			sdi_ready       => sdi_ready,
			--! Data out ports
			do_data         => do_data,
			do_ready        => do_ready,
			do_valid        => do_valid
		);


process(clk)
begin
	if clk'event and clk = '1' then
		if op_reciv = '0' then
			if FIFO_wr_en = '1' then
				if FIFO_Din(63)= '1' then
					sdi_wr <= '1';
					pdi_wr <= '0';
					counter_lim <= "0100"; -- TMP VALUES
				else
					sdi_wr <= '1';
					pdi_wr <= '0';
					counter_lim <= "0010"; -- TMP VALUES
				end if;
				op_reciv <= '1';
				counter <= (others => '0');
			else
				op_reciv <= '0';
				pdi_wr <= '0';
				sdi_wr <= '0';
			end if;
		else
			if counter = counter_lim then
				op_reciv <= '0';
				counter <= (others => '0');
			else
				counter <= counter + '1';
			end if;
		end if;
	end if;
end process;

pdi_valid <= FIFO_wr_en and pdi_wr;
sdi_valid <= FIFO_wr_en and sdi_wr;


sdi_data <= FIFO_Din;
pdi_data <= FIFO_Din;
FIFO_Dout <= do_data; 

FIFO_Empty <= not do_valid;
do_ready <= FIFO_rd_en;


end a1;