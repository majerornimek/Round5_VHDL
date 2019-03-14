library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

package Round5_constants is
	constant LongModLen		: integer := 12;
	constant ShortModLen	: integer := 9;
	constant PolyDegree		: integer := 618;--618;
	constant PolyDegreeLog2	: integer := 11;
	
	constant NumOfMulUnits	: integer := PolyDegree;
	constant ShortPolyMask	: std_logic_vector(LongModLen-2 downto 0) := "00011111111";
	----- CONSTANTS FOR ROUNDING ------
	constant a_bits_enc1 	: integer := 11;
	constant a_bits_enc2 	: integer := 8;
	constant a_bits_dec1 	: integer := 8;
	
	constant b_bits_enc1 	: integer := 8;
	constant b_bits_enc2 	: integer := 4;
	constant b_bits_dec1 	: integer := 1;
	
	constant b_mask_enc1 	: std_logic_vector(b_bits_enc1-1 downto 0) := (others => '1');
	constant b_mask_enc2 	: std_logic_vector(b_bits_enc2-1 downto 0) := (others => '1');
	constant b_mask_dec1 	: std_logic_vector(b_bits_dec1-1 downto 0) := (others => '1');
	
	constant r_const_enc1 	: integer := 4;
	constant r_const_enc2 	: integer := 4;
	constant r_const_dec1 	: integer := 68;
	----- CONSTANTS FOR ROUNDING ------
	
	
	type Trinomial is array(natural range<>) of std_logic_vector(1 downto 0);
	type NTRUPoly	is array(natural range<>) of std_logic_vector(LongModLen-2 downto 0);
	type ShortPoly	is array(natural range<>) of std_logic_vector(ShortModLen-2 downto 0);

    --type bus_array is array(natural range <>) of std_logic_vector;
	

end package;