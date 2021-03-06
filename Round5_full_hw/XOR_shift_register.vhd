library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;


entity XOR_shift_register is
	generic(
		register_len : natural := 17;
		shift_value  : natural := 16
	);
	port(
		DataIN : in std_logic_vector(0 to register_len-1);
		Previous_code : in std_logic_vector(0 to register_len-1);
		rst 	: in std_logic;
		clk 	: in std_logic;
		acc	: in std_logic;
		rotate: in std_logic;
	
		Computed_code	: out std_logic_vector(0 to register_len-1);
		DataOUT : out std_logic_vector(0 to shift_value-1)
	);
end entity;


architecture a1 of XOR_shift_register is
signal reg : std_logic_vector(0 to register_len-1);
begin

process(rst, clk)
begin
	if rst = '1' then
		reg <= (others => '0');
	elsif clk'event and clk = '1' then
		if acc = '1' and rotate = '1' then
			reg <= reg xor previous_code;
		elsif acc = '1' and rotate = '0' then
			reg <= reg xor DataIN;
		elsif rotate = '1' and acc = '0' then
			reg <= reg(shift_value to register_len-1) & reg(0 to shift_value-1);
		end if;
	end if;
end process;

DataOUT <= reg(0 to shift_value-1);

end a1;
	