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
	---- CONSTANTS FOR ROUNDING ------
	constant b_mask_enc1 	: std_logic_vector(q_bits-1 downto 0) := "00011111111";
	constant b_mask_enc2 	: std_logic_vector(p_bits-1 downto 0) := "00001111";
	constant b_mask_dec1 	: std_logic_vector(p_bits-1 downto 0) := "00000001";

	constant r_const_enc1 	: std_logic_vector(7 downto 0) := "00000100";
	constant r_const_enc2 	: std_logic_vector(7 downto 0) := "00000100";
	constant r_const_dec1 	: std_logic_vector(7 downto 0) := "01000100";

	---- CONSTANTS FOR ROUNDING ------

	type Trinomial is array(natural range<>) of std_logic_vector(1 downto 0);
	type q_bitsPoly is array(natural range<>) of std_logic_vector(q_bits-1 downto 0);
	type P_bitsPoly is array(natural range<>) of std_logic_vector(p_bits-1 downto 0);
	type t_bitsPoly	is array(natural range<>) of std_logic_vector(t_bits-1 downto 0);
    constant zero_fill      : std_logic_vector(q_bits-1 - 8 downto 0) := (others => '0');
    
    ---- CONSTANTS FOR AXI WRAPPER ----
    constant AXI_data_width : integer := 64; -- number of bits saved in one clock cycle
   
    
    --These constants describe the number of AXI clock cycles needed for sending the whole data.
	--Data is being sent without any empty bits (data is packed)
	
	constant Sigma_cycle	: integer := 2;   -- num of bits / 64
	constant PolyA_cycle	: integer := 107;
	constant PolyB_cycle	: integer := 78;  -- ceiling((PolyDegree+1)*p_bits))/64)
	constant PolyR_cycle	: integer := 20;
	constant RHO_cycle		: integer := 2;
    constant Message_cycle 	: integer := 2;
	constant Sk_cycle		: integer := 2;
	constant PolyU_cycle	: integer := 78; --ceiling (PolyDegree*p_bits/64)
	constant ctV_cycle		: integer := 8;  --ceiling (t_bits*MessageLen/64)
	
    constant FirstPart_cycle    : integer := 78;
    constant SecondPart_cycle	: integer := 8;
    constant Dec_Msg_cycle 	    : integer := 2;
	
	--ENC WR
	constant Sigma_cycle_start  : integer := 0;
	constant Sigma_cycle_end 	: integer := Sigma_cycle;
	constant PolyB_cycle_start  : integer := Sigma_cycle_end+1;
	constant PolyB_cycle_end 	: integer := PolyB_cycle_start + PolyB_cycle;
	constant RHO_cycle_start  	: integer := PolyB_cycle_end+1;
	constant RHO_cycle_end 		: integer := RHO_cycle_start + RHO_cycle;
	constant Message_cycle_start: integer := RHO_cycle_end+1;
	constant Message_cycle_end 	: integer := Message_cycle_start + Message_cycle;
	--DEC WR
	constant Sk_cycle_start  	: integer := Message_cycle_end+1;
	constant Sk_cycle_end 		: integer := Sk_cycle_start + Sk_cycle;
	constant PolyU_cycle_start  : integer := Sk_cycle_end+1;
	constant PolyU_cycle_end 	: integer := PolyU_cycle_start + PolyU_cycle;
	constant ctV_cycle_start 	: integer := PolyU_cycle_end + 1;
	constant ctV_cycle_end		: integer := ctV_cycle_start + ctV_cycle;
	
	
	
	--ENC RD
	constant FirstPart_cycle_start	: integer := 0;
	constant FirstPart_cycle_end	: integer := FirstPart_cycle_start+FirstPart_cycle;
	constant SecondPart_cycle_start : integer := FirstPart_cycle_end; -- continious data read
	constant SecondPart_cycle_end	: integer := SecondPart_cycle_start+SecondPart_cycle;	
	--DEC RD
	constant Dec_Msg_cycle_start 	: integer := SecondPart_cycle_end+1;
	constant Dec_Msg_cycle_end		: integer := Dec_Msg_cycle_start+Dec_Msg_cycle;
	
	
    --SHAKE constant
	constant SHAKE_output_sk_cycle			: integer := PolyR_cycle;-- ceiling(PolyDegree * 2 / 64)
	constant SHAKE_output_sigma_cycle		: integer := PolyA_cycle;
	constant SHAKE_output_rho_cycle			: integer := PolyR_cycle;
	
	constant SHAKE_output_sk_cycle_start 	: integer := 0;
	constant SHAKE_output_sk_cycle_end   	: integer := SHAKE_output_sk_cycle;
	constant SHAKE_output_sigma_cycle_start : integer := 0;--SHAKE_output_sk_cycle_end + 1;
	constant SHAKE_output_sigma_cycle_end 	: integer := SHAKE_output_sigma_cycle_start + SHAKE_output_sigma_cycle;
	constant SHAKE_output_rho_cycle_start 	: integer := 0;--SHAKE_output_sigma_cycle_end + 1;
	constant SHAKE_output_rho_cycle_end 	: integer := SHAKE_output_rho_cycle_start + SHAKE_output_rho_cycle;
	
	constant SHAKE_input_sigma_cmd			: std_logic_vector(63 downto 0) := X"C000004000001a8e";
	constant SHAKE_input_rho_cmd			: std_logic_vector(63 downto 0) := X"C0000040000004d4";
	
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

--- CONSTANTS FOR AXI WRAPPER ----
    -- constant AXI_data_width : integer := 64; -- number of bits saved in one clock cycle
   
    -- --These constants describe the number of AXI clock cycles needed for sending the whole data.
	-- --Data is being sent without any empty bits (data is packed)
	
	-- constant Sigma_cycle	: integer := 3;   -- num of bits / 64
	-- constant PolyA_cycle	: integer := 160;
	-- constant PolyB_cycle	: integer := 111;  -- ceiling((PolyDegree+1)*p_bits))/64)
	-- constant PolyR_cycle	: integer := 25;
	-- constant RHO_cycle		: integer := 3;
    -- constant Message_cycle 	: integer := 3;
	-- constant Sk_cycle		: integer := 3;
	-- constant PolyU_cycle	: integer := 111; --ceiling (PolyDegree*p_bits/64)
	-- constant ctV_cycle		: integer := 12;  --ceiling (t_bits*MessageLen/64)
	
    -- constant FirstPart_cycle    : integer := 111;
    -- constant SecondPart_cycle	: integer := 12;
    -- constant Dec_Msg_cycle 	    : integer := 3;
	
	-- --ENC WR
	-- constant Sigma_cycle_start  : integer := 0;
	-- constant Sigma_cycle_end 	: integer := Sigma_cycle;
	-- constant PolyB_cycle_start  : integer := Sigma_cycle_end+1;
	-- constant PolyB_cycle_end 	: integer := PolyB_cycle_start + PolyB_cycle;
	-- constant RHO_cycle_start  	: integer := PolyB_cycle_end+1;
	-- constant RHO_cycle_end 		: integer := RHO_cycle_start + RHO_cycle;
	-- constant Message_cycle_start: integer := RHO_cycle_end+1;
	-- constant Message_cycle_end 	: integer := Message_cycle_start + Message_cycle;
	-- --DEC WR
	-- constant Sk_cycle_start  	: integer := Message_cycle_end+1;
	-- constant Sk_cycle_end 		: integer := Sk_cycle_start + Sk_cycle;
	-- constant PolyU_cycle_start  : integer := Sk_cycle_end+1;
	-- constant PolyU_cycle_end 	: integer := PolyU_cycle_start + PolyU_cycle;
	-- constant ctV_cycle_start 	: integer := PolyU_cycle_end + 1;
	-- constant ctV_cycle_end		: integer := ctV_cycle_start + ctV_cycle;
	
	
	
	-- --ENC RD
	-- constant FirstPart_cycle_start	: integer := 0;
	-- constant FirstPart_cycle_end	: integer := FirstPart_cycle_start+FirstPart_cycle;
	-- constant SecondPart_cycle_start : integer := FirstPart_cycle_end; -- continious data read
	-- constant SecondPart_cycle_end	: integer := SecondPart_cycle_start+SecondPart_cycle;	
	-- --DEC RD
	-- constant Dec_Msg_cycle_start 	: integer := SecondPart_cycle_end+1;
	-- constant Dec_Msg_cycle_end		: integer := Dec_Msg_cycle_start+Dec_Msg_cycle;
	
	
    -- --SHAKE constant
	-- constant SHAKE_output_sk_cycle			: integer := PolyR_cycle;-- ceiling(PolyDegree * 2 / 64)
	-- constant SHAKE_output_sigma_cycle		: integer := PolyA_cycle;
	-- constant SHAKE_output_rho_cycle			: integer := PolyR_cycle;
	
	-- constant SHAKE_output_sk_cycle_start 	: integer := 0;
	-- constant SHAKE_output_sk_cycle_end   	: integer := SHAKE_output_sk_cycle;
	-- constant SHAKE_output_sigma_cycle_start : integer := 0;--SHAKE_output_sk_cycle_end + 1;
	-- constant SHAKE_output_sigma_cycle_end 	: integer := SHAKE_output_sigma_cycle_start + SHAKE_output_sigma_cycle;
	-- constant SHAKE_output_rho_cycle_start 	: integer := 0;--SHAKE_output_sigma_cycle_end + 1;
	-- constant SHAKE_output_rho_cycle_end 	: integer := SHAKE_output_rho_cycle_start + SHAKE_output_rho_cycle;
	-- constant SHAKE_input_sigma_cmd			: std_logic_vector(63 downto 0) := X"C0000080000027ea";
	-- constant SHAKE_input_rho_cmd			: std_logic_vector(63 downto 0) := X"C000008000000624";
	
    -- constant Output_cycle       : integer := FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle;
-- end package;

--package Round5_constants is  -- R5ND_5KEM_0C

--	constant PolyDegree		: integer := 1018;
--	constant PolyDegreeLog2	: integer := 11;
--	constant MessageLen		: integer := 256;
--	constant q_bits			: integer := 14;
--	constant p_bits			: integer := 9;
--	constant t_bits			: integer := 4;
--	constant NumOfMulUnits	: integer := PolyDegree;
   
--   constant p_PolyMask	: std_logic_vector(q_bits-1 downto 0) := "00000111111111";
--	----- CONSTANTS FOR ROUNDING ------
--	constant b_mask_enc1 	: std_logic_vector(q_bits-1 downto 0) := "00000111111111";
--	constant b_mask_enc2 	: std_logic_vector(p_bits-1 downto 0) := "000001111";
--	constant b_mask_dec1 	: std_logic_vector(p_bits-1 downto 0) := "000000001";

--	constant r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
--	constant r_const_enc2 	: std_logic_vector(7 downto 0) := "00010000";
--	constant r_const_dec1 	: std_logic_vector(7 downto 0) := "10000000";

--	----- CONSTANTS FOR ROUNDING ------

--	type Trinomial is array(natural range<>) of std_logic_vector(1 downto 0);
--	type q_bitsPoly is array(natural range<>) of std_logic_vector(q_bits-1 downto 0);
--	type P_bitsPoly is array(natural range<>) of std_logic_vector(p_bits-1 downto 0);
--	type t_bitsPoly	is array(natural range<>) of std_logic_vector(t_bits-1 downto 0);
--   constant zero_fill      : std_logic_vector(q_bits-1 - 8 downto 0) := (others => '0');

--    -- CONSTANTS FOR AXI WRAPPER ----
--    constant AXI_data_width : integer := 64; -- number of bits saved in one clock cycle
   
--    --These constants describe the number of AXI clock cycles needed for sending the whole data.
--	--Data is being sent without any empty bits (data is packed)
	
--	constant Sigma_cycle	: integer := 4;   -- num of bits / 64
--	constant PolyA_cycle	: integer := 223;
--	constant PolyB_cycle	: integer := 144;  -- ceiling((PolyDegree+1)*p_bits))/64)
--	constant PolyR_cycle	: integer := 32;
--	constant RHO_cycle		: integer := 4;
--    constant Message_cycle 	: integer := 4;
--	constant Sk_cycle		: integer := 4;
--	constant PolyU_cycle	: integer := 144; --ceiling (PolyDegree*p_bits/64)
--	constant ctV_cycle		: integer := 16;  --ceiling (t_bits*MessageLen/64)
	
--    constant FirstPart_cycle    : integer := 144;
--    constant SecondPart_cycle	: integer := 16;
--    constant Dec_Msg_cycle 	    : integer := 4;
	
--	--ENC WR
--	constant Sigma_cycle_start  : integer := 0;
--	constant Sigma_cycle_end 	: integer := Sigma_cycle;
--	constant PolyB_cycle_start  : integer := Sigma_cycle_end+1;
--	constant PolyB_cycle_end 	: integer := PolyB_cycle_start + PolyB_cycle;
--	constant RHO_cycle_start  	: integer := PolyB_cycle_end+1;
--	constant RHO_cycle_end 		: integer := RHO_cycle_start + RHO_cycle;
--	constant Message_cycle_start: integer := RHO_cycle_end+1;
--	constant Message_cycle_end 	: integer := Message_cycle_start + Message_cycle;
--	--DEC WR
--	constant Sk_cycle_start  	: integer := Message_cycle_end+1;
--	constant Sk_cycle_end 		: integer := Sk_cycle_start + Sk_cycle;
--	constant PolyU_cycle_start  : integer := Sk_cycle_end+1;
--	constant PolyU_cycle_end 	: integer := PolyU_cycle_start + PolyU_cycle;
--	constant ctV_cycle_start 	: integer := PolyU_cycle_end + 1;
--	constant ctV_cycle_end		: integer := ctV_cycle_start + ctV_cycle;
	
	
	
--	--ENC RD
--	constant FirstPart_cycle_start	: integer := 0;
--	constant FirstPart_cycle_end	: integer := FirstPart_cycle_start+FirstPart_cycle;
--	constant SecondPart_cycle_start : integer := FirstPart_cycle_end; -- continious data read
--	constant SecondPart_cycle_end	: integer := SecondPart_cycle_start+SecondPart_cycle;	
--	--DEC RD
--	constant Dec_Msg_cycle_start 	: integer := SecondPart_cycle_end+1;
--	constant Dec_Msg_cycle_end		: integer := Dec_Msg_cycle_start+Dec_Msg_cycle;
	
	
--    --SHAKE constant
--	constant SHAKE_output_sk_cycle			: integer := PolyR_cycle;-- ceiling(PolyDegree * 2 / 64)
--	constant SHAKE_output_sigma_cycle		: integer := PolyA_cycle;
--	constant SHAKE_output_rho_cycle			: integer := PolyR_cycle;
	
--	constant SHAKE_output_sk_cycle_start 	: integer := 0;
--	constant SHAKE_output_sk_cycle_end   	: integer := SHAKE_output_sk_cycle;
--	constant SHAKE_output_sigma_cycle_start 	: integer := 0;--SHAKE_output_sk_cycle_end + 1;
--	constant SHAKE_output_sigma_cycle_end 	: integer := SHAKE_output_sigma_cycle_start + SHAKE_output_sigma_cycle;
--	constant SHAKE_output_rho_cycle_start 	: integer := 0;--SHAKE_output_sigma_cycle_end + 1;
--	constant SHAKE_output_rho_cycle_end 		: integer := SHAKE_output_rho_cycle_start + SHAKE_output_rho_cycle;
--	constant SHAKE_input_sigma_cmd			: std_logic_vector(63 downto 0) := X"C0000100000037ac";
--	constant SHAKE_input_rho_cmd				: std_logic_vector(63 downto 0) := X"C0000100000007f4";
	
--    constant Output_cycle       : integer := FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle;
--end package;

-- package Round5_constants is  -- R5ND_5PKE_0d

	-- constant PolyDegree		: integer := 1170;
	-- constant PolyDegreeLog2	: integer := 12;
	-- constant MessageLen		: integer := 256;
	-- constant q_bits			: integer := 13;
	-- constant p_bits			: integer := 9;
	-- constant t_bits			: integer := 5;
	-- constant NumOfMulUnits	: integer := PolyDegree;
   
   -- constant p_PolyMask	: std_logic_vector(q_bits-1 downto 0) := "0000111111111";
	-- ----- CONSTANTS FOR ROUNDING ------
	-- constant b_mask_enc1 	: std_logic_vector(q_bits-1 downto 0) := "0000111111111";
	-- constant b_mask_enc2 	: std_logic_vector(p_bits-1 downto 0) := "000001111";
	-- constant b_mask_dec1 	: std_logic_vector(p_bits-1 downto 0) := "000000001";

	-- constant r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
	-- constant r_const_enc2 	: std_logic_vector(7 downto 0) := "00010000";
	-- constant r_const_dec1 	: std_logic_vector(7 downto 0) := "10000000";

	-- ----- CONSTANTS FOR ROUNDING ------

	-- type Trinomial is array(natural range<>) of std_logic_vector(1 downto 0);
	-- type q_bitsPoly is array(natural range<>) of std_logic_vector(q_bits-1 downto 0);
	-- type P_bitsPoly is array(natural range<>) of std_logic_vector(p_bits-1 downto 0);
	-- type t_bitsPoly	is array(natural range<>) of std_logic_vector(t_bits-1 downto 0);
   -- constant zero_fill      : std_logic_vector(q_bits-1 - 8 downto 0) := (others => '0');

    -- -- CONSTANTS FOR AXI WRAPPER ----
    -- constant AXI_data_width : integer := 64; -- number of bits saved in one clock cycle
   
    -- --These constants describe the number of AXI clock cycles needed for sending the whole data.
	-- --Data is being sent without any empty bits (data is packed)
	
	-- constant Sigma_cycle	: integer := 4;   -- num of bits / 64
	-- constant PolyA_cycle	: integer := 238;
	-- constant PolyB_cycle	: integer := 165;  -- ceiling((PolyDegree+1)*p_bits))/64)
	-- constant PolyR_cycle	: integer := 37;
	-- constant RHO_cycle		: integer := 4;
    -- constant Message_cycle 	: integer := 4;
	-- constant Sk_cycle		: integer := 4;
	-- constant PolyU_cycle	: integer := 165; --ceiling (PolyDegree*p_bits/64)
	-- constant ctV_cycle		: integer := 20;  --ceiling (t_bits*MessageLen/64)
	
    -- constant FirstPart_cycle    : integer := 165;
    -- constant SecondPart_cycle	: integer := 20;
    -- constant Dec_Msg_cycle 	    : integer := 4;
	
	-- --ENC WR
	-- constant Sigma_cycle_start  : integer := 0;
	-- constant Sigma_cycle_end 	: integer := Sigma_cycle;
	-- constant PolyB_cycle_start  : integer := Sigma_cycle_end+1;
	-- constant PolyB_cycle_end 	: integer := PolyB_cycle_start + PolyB_cycle;
	-- constant RHO_cycle_start  	: integer := PolyB_cycle_end+1;
	-- constant RHO_cycle_end 		: integer := RHO_cycle_start + RHO_cycle;
	-- constant Message_cycle_start: integer := RHO_cycle_end+1;
	-- constant Message_cycle_end 	: integer := Message_cycle_start + Message_cycle;
	-- --DEC WR
	-- constant Sk_cycle_start  	: integer := Message_cycle_end+1;
	-- constant Sk_cycle_end 		: integer := Sk_cycle_start + Sk_cycle;
	-- constant PolyU_cycle_start  : integer := Sk_cycle_end+1;
	-- constant PolyU_cycle_end 	: integer := PolyU_cycle_start + PolyU_cycle;
	-- constant ctV_cycle_start 	: integer := PolyU_cycle_end + 1;
	-- constant ctV_cycle_end		: integer := ctV_cycle_start + ctV_cycle;
	
	
	
	-- --ENC RD
	-- constant FirstPart_cycle_start	: integer := 0;
	-- constant FirstPart_cycle_end	: integer := FirstPart_cycle_start+FirstPart_cycle;
	-- constant SecondPart_cycle_start : integer := FirstPart_cycle_end; -- continious data read
	-- constant SecondPart_cycle_end	: integer := SecondPart_cycle_start+SecondPart_cycle;	
	-- --DEC RD
	-- constant Dec_Msg_cycle_start 	: integer := SecondPart_cycle_end+1;
	-- constant Dec_Msg_cycle_end		: integer := Dec_Msg_cycle_start+Dec_Msg_cycle;
	
	
    -- --SHAKE constant
	-- constant SHAKE_output_sk_cycle			: integer := PolyR_cycle;-- ceiling(PolyDegree * 2 / 64)
	-- constant SHAKE_output_sigma_cycle		: integer := PolyA_cycle;
	-- constant SHAKE_output_rho_cycle			: integer := PolyR_cycle;
	
	-- constant SHAKE_output_sk_cycle_start 	: integer := 0;
	-- constant SHAKE_output_sk_cycle_end   	: integer := SHAKE_output_sk_cycle;
	-- constant SHAKE_output_sigma_cycle_start 	: integer := 0;--SHAKE_output_sk_cycle_end + 1;
	-- constant SHAKE_output_sigma_cycle_end 	: integer := SHAKE_output_sigma_cycle_start + SHAKE_output_sigma_cycle;
	-- constant SHAKE_output_rho_cycle_start 	: integer := 0;--SHAKE_output_sigma_cycle_end + 1;
	-- constant SHAKE_output_rho_cycle_end 	: integer := SHAKE_output_rho_cycle_start + SHAKE_output_rho_cycle;
	-- constant SHAKE_input_sigma_cmd			: std_logic_vector(63 downto 0) := X"C000010000003b6a";
	-- constant SHAKE_input_rho_cmd			: std_logic_vector(63 downto 0) := X"C000010000000924";
	
    -- constant Output_cycle       : integer := FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle;
-- end package;
