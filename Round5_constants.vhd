library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

package Round5_constants is  -- R5ND_1KEM_0C

	constant PolyDegree		: integer := 618;
	constant PolyDegreeLog2	: integer := 11;
	constant MessageLen		: integer := 128;
	constant q_bits			: integer := 11;
	constant p_bits			: integer := 8;
	constant t_bits			: integer := 4;
	constant NumOfMulUnits	: integer := PolyDegree;
    
    constant p_PolyMask	: std_logic_vector(q_bits-1 downto 0) := "00011111111";
	----- CONSTANTS FOR ROUNDING ------
	constant b_mask_enc1 	: std_logic_vector(q_bits-1 downto 0) := "00011111111";
	constant b_mask_enc2 	: std_logic_vector(p_bits-1 downto 0) := "00001111";
	constant b_mask_dec1 	: std_logic_vector(p_bits-1 downto 0) := "00000001";

	constant r_const_enc1 	: std_logic_vector(7 downto 0) := "00000100";
	constant r_const_enc2 	: std_logic_vector(7 downto 0) := "00000100";
	constant r_const_dec1 	: std_logic_vector(7 downto 0) := "01000100";

	----- CONSTANTS FOR ROUNDING ------

	type Trinomial is array(natural range<>) of std_logic_vector(1 downto 0);
	type q_bitsPoly is array(natural range<>) of std_logic_vector(q_bits-1 downto 0);
	type P_bitsPoly is array(natural range<>) of std_logic_vector(p_bits-1 downto 0);
	type t_bitsPoly	is array(natural range<>) of std_logic_vector(t_bits-1 downto 0);
    constant zero_fill      : std_logic_vector(q_bits-1 - 8 downto 0) := (others => '0');
    
    ----- CONSTANTS FOR AXI WRAPPER ----
    constant AXI_data_width : integer := 60; -- number of bits saved in one clock cycle
    constant PolyA_cycle 	: integer := 114; 	-- num of cycles needed for data load
    constant PolyB_cycle	: integer := 83;
    constant PolyR_cycle    : integer := 21;
    constant Message_cycle 	: integer := 3;
    constant ctV_cycle		: integer := 9;
    
    constant FirstPart_cycle    : integer := 89;
    constant SecondPart_cycle	: integer := 9;
    constant Dec_Msg_cycle 	    : integer := 3;
    
    constant Output_cycle       : integer := FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle;

end package;


--package Round5_constants is  -- R5ND_3KEM_0C

--	constant PolyDegree		: integer := 786;
--	constant PolyDegreeLog2	: integer := 11;
--	constant MessageLen		: integer := 192;
--	constant q_bits			: integer := 13;
--	constant p_bits			: integer := 9;
--	constant t_bits			: integer := 4;
--	constant NumOfMulUnits	: integer := PolyDegree;
    
--    constant p_PolyMask	: std_logic_vector(q_bits-1 downto 0) := "0000111111111";
--	----- CONSTANTS FOR ROUNDING ------
--	constant b_mask_enc1 	: std_logic_vector(q_bits-1 downto 0) := "0000111111111";
--	constant b_mask_enc2 	: std_logic_vector(p_bits-1 downto 0) := "000001111";
--	constant b_mask_dec1 	: std_logic_vector(p_bits-1 downto 0) := "000000001";

--	constant r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
--	constant r_const_enc2 	: std_logic_vector(7 downto 0) := "00001000";
--	constant r_const_dec1 	: std_logic_vector(7 downto 0) := "10001000";

--	----- CONSTANTS FOR ROUNDING ------

--	type Trinomial is array(natural range<>) of std_logic_vector(1 downto 0);
--	type q_bitsPoly is array(natural range<>) of std_logic_vector(q_bits-1 downto 0);
--	type P_bitsPoly is array(natural range<>) of std_logic_vector(p_bits-1 downto 0);
--	type t_bitsPoly	is array(natural range<>) of std_logic_vector(t_bits-1 downto 0);
--  constant zero_fill      : std_logic_vector(q_bits-1 - 8 downto 0) := (others => '0');

    ----- CONSTANTS FOR AXI WRAPPER ----
--    constant AXI_data_width : integer := 60; -- number of bits saved in one clock cycle
--    constant PolyA_cycle 	: integer := 114; 	-- num of cycles needed for data load
--    constant PolyB_cycle	: integer := 83;
--    constant PolyR_cycle    : integer := 21;
--    constant Message_cycle 	: integer := 3;
--    constant ctV_cycle		: integer := 9;
--    
--    constant FirstPart_cycle    : integer := 89;
--    constant SecondPart_cycle	: integer := 9;
--    constant Dec_Msg_cycle 	    : integer := 3;
--    
--    constant Output_cycle       : integer := FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle;

--end package;

--package Round5_constants is  -- R5ND_5KEM_0C
--
--	constant PolyDegree		: integer := 1018;
--	constant PolyDegreeLog2	: integer := 11;
--	constant MessageLen		: integer := 256;
--	constant q_bits			: integer := 14;
--	constant p_bits			: integer := 9;
--	constant t_bits			: integer := 4;
--	constant NumOfMulUnits	: integer := PolyDegree;
--    
--    constant p_PolyMask	: std_logic_vector(q_bits-1 downto 0) := "00000111111111";
--	----- CONSTANTS FOR ROUNDING ------
--	constant b_mask_enc1 	: std_logic_vector(q_bits-1 downto 0) := "00000111111111";
--	constant b_mask_enc2 	: std_logic_vector(p_bits-1 downto 0) := "000001111";
--	constant b_mask_dec1 	: std_logic_vector(p_bits-1 downto 0) := "000000001";
--
--	constant r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
--	constant r_const_enc2 	: std_logic_vector(7 downto 0) := "00010000";
--	constant r_const_dec1 	: std_logic_vector(7 downto 0) := "10000000";
--
--	----- CONSTANTS FOR ROUNDING ------
--
--	type Trinomial is array(natural range<>) of std_logic_vector(1 downto 0);
--	type q_bitsPoly is array(natural range<>) of std_logic_vector(q_bits-1 downto 0);
--	type P_bitsPoly is array(natural range<>) of std_logic_vector(p_bits-1 downto 0);
--	type t_bitsPoly	is array(natural range<>) of std_logic_vector(t_bits-1 downto 0);
--    constant zero_fill      : std_logic_vector(q_bits-1 - 8 downto 0) := (others => '0');

    ----- CONSTANTS FOR AXI WRAPPER ----
--    constant AXI_data_width : integer := 60; -- number of bits saved in one clock cycle
--    constant PolyA_cycle 	: integer := 114; 	-- num of cycles needed for data load
--    constant PolyB_cycle	: integer := 83;
--    constant PolyR_cycle    : integer := 21;
--    constant Message_cycle 	: integer := 3;
--    constant ctV_cycle		: integer := 9;
--    
--    constant FirstPart_cycle    : integer := 89;
--    constant SecondPart_cycle	: integer := 9;
--    constant Dec_Msg_cycle 	    : integer := 3;
--    
--    constant Output_cycle       : integer := FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle;


--end package;