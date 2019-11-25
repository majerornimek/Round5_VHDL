library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;


entity shift_register is
	generic(
		register_len : natural := 16;
		shift_value  : natural := 16
	);
	port(
		DataIN : in std_logic_vector(0 to register_len-1);
	
		rst 	: in std_logic;
		clk 	: in std_logic;
		start	: in std_logic;
	
		DataOUT : out std_logic_vector(0 to register_len-1)
	);
end entity;


architecture a1 of shift_register is
signal reg : std_logic_vector(0 to register_len-1);
signal saved : std_logic := '0';
begin

process(rst, clk)
begin
	if rst = '1' then
		reg <= (others => '0');
		saved <= '0';
	elsif clk'event and clk = '1' then
		if start = '1' and saved = '0' then
			saved <= '1';
			reg <= DataIN;
		elsif start = '1' and saved = '1' then
			reg <= reg(shift_value to register_len-1) & reg(0 to shift_value-1);
		end if;
	end if;
end process;

DataOUT <= reg;

end a1;
	