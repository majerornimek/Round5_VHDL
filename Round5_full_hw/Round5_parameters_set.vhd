library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

--library work;
--use work.Round5_parameters_set.R5ND_1KEM_0d.all;

package R5ND_1KEM_0d_param_set is
	constant R5_PolyDegree		: integer := 618;
	constant R5_PolyDegreeLog2	: integer := 11;
	constant R5_MessageLen		: integer := 128;
	constant R5_q_bits			: integer := 11;
	constant R5_p_bits			: integer := 8;
	constant R5_t_bits			: integer := 4;
	constant R5_NumOfMulUnits	: integer := R5_PolyDegree;

	constant R5_Sigma_cycle	: integer := 2;   -- num of bits / 64
	constant R5_PolyA_cycle	: integer := 107;
	constant R5_PolyB_cycle	: integer := 78;  -- ceiling((PolyDegree+1)*p_bits))/64)
	constant R5_PolyR_cycle	: integer := 20;
	constant R5_RHO_cycle		: integer := 2;
    constant R5_Message_cycle 	: integer := 2;
	constant R5_Sk_cycle		: integer := 2;
	constant R5_PolyU_cycle	: integer := 78; --ceiling (PolyDegree*p_bits/64)
	constant R5_ctV_cycle		: integer := 8;  --ceiling (t_bits*MessageLen/64)
	
    constant R5_FirstPart_cycle    : integer := 78;
    constant R5_SecondPart_cycle	: integer := 8;
    constant R5_Dec_Msg_cycle 	    : integer := 2;
	
	------------- CONSTANTS FOR ROUNDING ------
	constant R5_p_PolyMask		: std_logic_vector(R5_q_bits-1 downto 0) := "00011111111";
	constant R5_b_mask_enc1 	: std_logic_vector(R5_q_bits-1 downto 0) := "00011111111";
	constant R5_b_mask_enc2 	: std_logic_vector(R5_p_bits-1 downto 0) := "00001111";
	constant R5_b_mask_dec1 	: std_logic_vector(R5_p_bits-1 downto 0) := "00000001";

	constant R5_r_const_enc1 	: std_logic_vector(7 downto 0) := "00000100";
	constant R5_r_const_enc2 	: std_logic_vector(7 downto 0) := "00000100";
	constant R5_r_const_dec1 	: std_logic_vector(7 downto 0) := "01000100";
	
	----------- XEf
	type IntegerArray is array(natural range<>) of integer;
	constant R5_xef_reg_len			: IntegerArray := (16, 11, 13, 16, 17, 19, 21, 23, 25, 29);
	constant R5_xef_div_boundaries: IntegerArray := (16, 27, 40, 56, 73, 92, 113, 136, 161, 190);
	--constant R5_xef_shortest		: integer := 11;
	constant R5_xef_shortest		: integer := 10;
	constant R5_code_len 			: integer := 190;
	constant R5_xef_num_of_shifts 	: integer := 8;
	constant R5_xef_num_of_fixerr : integer := 13; -- msg len/shortest (10)

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

package R5ND_3KEM_0d_param_set is
	constant R5_PolyDegree		: integer := 786;
	constant R5_PolyDegreeLog2	: integer := 11;
	constant R5_MessageLen		: integer := 192;
	constant R5_q_bits			: integer := 13;
	constant R5_p_bits			: integer := 9;
	constant R5_t_bits			: integer := 4;
	constant R5_NumOfMulUnits	: integer := R5_PolyDegree;

	constant R5_Sigma_cycle	: integer := 3;   -- num of bits / 64
	constant R5_PolyA_cycle	: integer := 160;
	constant R5_PolyB_cycle	: integer := 111;  -- ceiling((PolyDegree+1)*p_bits))/64)
	constant R5_PolyR_cycle	: integer := 25;
	constant R5_RHO_cycle		: integer := 3;
    constant R5_Message_cycle 	: integer := 3;
	constant R5_Sk_cycle		: integer := 3;
	constant R5_PolyU_cycle	: integer := 111; --ceiling (PolyDegree*p_bits/64)
	constant R5_ctV_cycle		: integer := 12;  --ceiling (t_bits*MessageLen/64)
	
    constant R5_FirstPart_cycle    : integer := 111;
    constant R5_SecondPart_cycle	: integer := 12;
    constant R5_Dec_Msg_cycle 	    : integer := 3;
	
	------------- CONSTANTS FOR ROUNDING ------
	constant R5_p_PolyMask		: std_logic_vector(R5_q_bits-1 downto 0) := "0000111111111";
	constant R5_b_mask_enc1 	: std_logic_vector(R5_q_bits-1 downto 0) := "0000111111111";
	constant R5_b_mask_enc2 	: std_logic_vector(R5_p_bits-1 downto 0) := "000001111";
	constant R5_b_mask_dec1 	: std_logic_vector(R5_p_bits-1 downto 0) := "000000001";

	constant R5_r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
	constant R5_r_const_enc2 	: std_logic_vector(7 downto 0) := "00001000";
	constant R5_r_const_dec1 	: std_logic_vector(7 downto 0) := "10001000";

	
	----------- XEf
	type IntegerArray is array(natural range<>) of integer;
	constant R5_xef_reg_len			: IntegerArray := (24, 13, 16, 17, 19, 21, 23, 25, 29, 31);
	constant R5_xef_div_boundaries: IntegerArray := (24, 37, 53, 70, 89, 110, 133, 158, 187,218);
	constant R5_xef_shortest		: integer := 10;  --- set to 10
	constant R5_code_len 			: integer := 218;
	constant R5_xef_num_of_shifts 	: integer := 8;
	constant R5_xef_num_of_fixerr : integer := 20; -- msg len/shortest

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

package R5ND_5KEM_0d_param_set is
	constant R5_PolyDegree		: integer := 1018;
	constant R5_PolyDegreeLog2	: integer := 11;
	constant R5_MessageLen		: integer := 256;
	constant R5_q_bits			: integer := 14;
	constant R5_p_bits			: integer := 9;
	constant R5_t_bits			: integer := 4;
	constant R5_NumOfMulUnits	: integer := R5_PolyDegree;

	constant R5_Sigma_cycle	: integer := 4;   -- num of bits / 64
	constant R5_PolyA_cycle	: integer := 223;
	constant R5_PolyB_cycle	: integer := 144;  -- ceiling((PolyDegree+1)*p_bits))/64)
	constant R5_PolyR_cycle	: integer := 32;
	constant R5_RHO_cycle		: integer := 4;
    constant R5_Message_cycle 	: integer := 4;
	constant R5_Sk_cycle		: integer := 4;
	constant R5_PolyU_cycle	: integer := 144; --ceiling (PolyDegree*p_bits/64)
	constant R5_ctV_cycle		: integer := 16;  --ceiling (t_bits*MessageLen/64)
	
    constant R5_FirstPart_cycle    : integer := 144;
    constant R5_SecondPart_cycle	: integer := 16;
    constant R5_Dec_Msg_cycle 	    : integer := 4;

	------------- CONSTANTS FOR ROUNDING ------
	constant R5_p_PolyMask	: std_logic_vector(R5_q_bits-1 downto 0) := "00000111111111";
	constant R5_b_mask_enc1 	: std_logic_vector(R5_q_bits-1 downto 0) := "00000111111111";
	constant R5_b_mask_enc2 	: std_logic_vector(R5_p_bits-1 downto 0) := "000001111";
	constant R5_b_mask_dec1 	: std_logic_vector(R5_p_bits-1 downto 0) := "000000001";

	constant R5_r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
	constant R5_r_const_enc2 	: std_logic_vector(7 downto 0) := "00010000";
	constant R5_r_const_dec1 	: std_logic_vector(7 downto 0) := "10000000";	

	----------- XEf
	type IntegerArray is array(natural range<>) of integer;
	constant R5_xef_reg_len			: IntegerArray := (16, 16, 17, 19, 21, 23, 25, 29, 31, 37);
	constant R5_xef_div_boundaries: IntegerArray := (16, 32, 49, 68, 89, 112, 137, 166, 197,234);
	constant R5_code_len 			: integer := 234;
	constant R5_xef_shortest		: integer := 10; -- set to 10
	constant R5_xef_num_of_shifts : integer := 16;
	constant R5_xef_num_of_fixerr : integer := 26; -- msg len/shortest

	
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

package R5ND_1PKE_0d_param_set is
	constant R5_PolyDegree		: integer := 586;
	constant R5_PolyDegreeLog2	: integer := 11;
	constant R5_MessageLen		: integer := 128;
	constant R5_q_bits			: integer := 13;
	constant R5_p_bits			: integer := 9;
	constant R5_t_bits			: integer := 4;
	constant R5_NumOfMulUnits	: integer := R5_PolyDegree;

	constant R5_Sigma_cycle	: integer := 2;   -- num of bits / 64
	constant R5_PolyA_cycle	: integer := 120;
	constant R5_PolyB_cycle	: integer := 83;  -- ceiling((PolyDegree+1)*p_bits))/64)
	constant R5_PolyR_cycle	: integer := 19;
	constant R5_RHO_cycle		: integer := 2;
   constant R5_Message_cycle 	: integer := 2;
	constant R5_Sk_cycle		: integer := 2;
	constant R5_PolyU_cycle	: integer := 83; --ceiling (PolyDegree*p_bits/64)
	constant R5_ctV_cycle		: integer := 8;  --ceiling (t_bits*MessageLen/64)
	
   constant R5_FirstPart_cycle    : integer := 83;
   constant R5_SecondPart_cycle	: integer := 8;
   constant R5_Dec_Msg_cycle 	    : integer := 2;
	constant R5_XEf_cycle			: integer := 0; -- ceiling(code_len/64) (if no XEf = 0)
	------------- CONSTANTS FOR ROUNDING ------
	constant R5_p_PolyMask	: std_logic_vector(R5_q_bits-1 downto 0) := "0000111111111";
	constant R5_b_mask_enc1 	: std_logic_vector(R5_q_bits-1 downto 0) := "0000111111111";
	constant R5_b_mask_enc2 	: std_logic_vector(R5_p_bits-1 downto 0) := "000001111";
	constant R5_b_mask_dec1 	: std_logic_vector(R5_p_bits-1 downto 0) := "000000001";

	constant R5_r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
	constant R5_r_const_enc2 	: std_logic_vector(7 downto 0) := "00010000";
	constant R5_r_const_dec1 	: std_logic_vector(7 downto 0) := "10000000";
	
		----------- XEf
	type IntegerArray is array(natural range<>) of integer;
	constant R5_xef_reg_len			: IntegerArray := (16, 11, 13, 16, 17, 19, 21, 23, 25, 29);
	constant R5_xef_div_boundaries: IntegerArray := (16, 27, 40, 56, 73, 92, 113, 136, 161, 190);
	constant R5_xef_shortest		: integer := 10; --- set to 10
	constant R5_code_len 			: integer := 190;
	constant R5_xef_num_of_shifts : integer := 8;
	constant R5_xef_num_of_fixerr : integer := 13; -- code len/shortest

end package;



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

package R5ND_3PKE_0d_param_set is
	constant R5_PolyDegree		: integer := 852;
	constant R5_PolyDegreeLog2	: integer := 11;
	constant R5_MessageLen		: integer := 192;
	constant R5_q_bits			: integer := 12;
	constant R5_p_bits			: integer := 9;
	constant R5_t_bits			: integer := 5;
	constant R5_NumOfMulUnits	: integer := R5_PolyDegree;

	constant R5_Sigma_cycle	: integer := 3;   -- num of bits / 64
	constant R5_PolyA_cycle	: integer := 160;
	constant R5_PolyB_cycle	: integer := 120;  -- ceiling((PolyDegree+1)*p_bits))/64)
	constant R5_PolyR_cycle	: integer := 27;
	constant R5_RHO_cycle		: integer := 3;
    constant R5_Message_cycle 	: integer := 3;
	constant R5_Sk_cycle		: integer := 3;
	constant R5_PolyU_cycle	: integer := 120; --ceiling (PolyDegree*p_bits/64)
	constant R5_ctV_cycle		: integer := 15;  --ceiling (t_bits*MessageLen/64)
	
    constant R5_FirstPart_cycle    : integer := 120;
    constant R5_SecondPart_cycle	: integer := 15;
    constant R5_Dec_Msg_cycle 	    : integer := 3;
	constant R5_XEf_cycle			: integer := 0; -- ceiling(code_len/64) (if no XEf = 0)
	------------- CONSTANTS FOR ROUNDING ------
	constant R5_p_PolyMask	: std_logic_vector(R5_q_bits-1 downto 0) 	:= "000111111111";
	constant R5_b_mask_enc1 	: std_logic_vector(R5_q_bits-1 downto 0):= "000111111111";
	constant R5_b_mask_enc2 	: std_logic_vector(R5_p_bits-1 downto 0):= "000001111";
	constant R5_b_mask_dec1 	: std_logic_vector(R5_p_bits-1 downto 0):= "000000001";

	constant R5_r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
	constant R5_r_const_enc2 	: std_logic_vector(7 downto 0) := "00010000";
	constant R5_r_const_dec1 	: std_logic_vector(7 downto 0) := "10000000";
	
		----------- XEf
	type IntegerArray is array(natural range<>) of integer;
	constant R5_xef_reg_len			: IntegerArray := (24, 13, 16, 17, 19, 21, 23, 25, 29, 31);
	constant R5_xef_div_boundaries: IntegerArray := (24, 37, 53, 70, 89, 110, 133, 158, 187,218);
	constant R5_xef_shortest		: integer := 10;
	constant R5_code_len 			: integer := 218;
	constant R5_xef_num_of_shifts 	: integer := 8;
	constant R5_xef_num_of_fixerr : integer := 20; -- code len/shortest

end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

package R5ND_5PKE_0d_param_set is
	constant R5_PolyDegree		: integer := 1170;
	constant R5_PolyDegreeLog2	: integer := 12;
	constant R5_MessageLen		: integer := 256;
	constant R5_q_bits			: integer := 13;
	constant R5_p_bits			: integer := 9;
	constant R5_t_bits			: integer := 5;
	constant R5_NumOfMulUnits	: integer := R5_PolyDegree;

	constant R5_Sigma_cycle	: integer := 4;   -- num of bits / 64
	constant R5_PolyA_cycle	: integer := 238;
	constant R5_PolyB_cycle	: integer := 165;  -- ceiling((PolyDegree+1)*p_bits))/64)
	constant R5_PolyR_cycle	: integer := 37;
	constant R5_RHO_cycle		: integer := 4;
    constant R5_Message_cycle 	: integer := 4;
	constant R5_Sk_cycle		: integer := 4;
	constant R5_PolyU_cycle	: integer := 165; --ceiling (PolyDegree*p_bits/64)
	constant R5_ctV_cycle		: integer := 20;  --ceiling (t_bits*MessageLen/64)
	
    constant R5_FirstPart_cycle    : integer := 165;
    constant R5_SecondPart_cycle	: integer := 20;
    constant R5_Dec_Msg_cycle 	    : integer := 4;
	constant R5_XEf_cycle			: integer := 0; -- ceiling(code_len/64) (if no XEf = 0)
	------------- CONSTANTS FOR ROUNDING ------
	constant R5_p_PolyMask	: std_logic_vector(R5_q_bits-1 downto 0) := "0000111111111";
	constant R5_b_mask_enc1 	: std_logic_vector(R5_q_bits-1 downto 0) := "0000111111111";
	constant R5_b_mask_enc2 	: std_logic_vector(R5_p_bits-1 downto 0) := "000001111";
	constant R5_b_mask_dec1 	: std_logic_vector(R5_p_bits-1 downto 0) := "000000001";

	constant R5_r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
	constant R5_r_const_enc2 	: std_logic_vector(7 downto 0) := "00010000";
	constant R5_r_const_dec1 	: std_logic_vector(7 downto 0) := "10000000";

		----------- XEf
	type IntegerArray is array(natural range<>) of integer;
	constant R5_xef_reg_len			: IntegerArray := (16, 16, 17, 19, 21, 23, 25, 29, 31, 37);
	constant R5_xef_div_boundaries: IntegerArray := (16, 32, 49, 68, 89, 112, 137, 166, 197,234);
	constant R5_code_len 			: integer := 234;
	constant R5_xef_shortest		: integer := 16;
	constant R5_xef_num_of_shifts 	: integer := 16;
	constant R5_xef_num_of_fixerr : integer := 26; -- code len/shortest
end package;

-----------------------------------
-------XEF
----------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

package R5ND_1KEM_5d_param_set is
	constant R5_PolyDegree		: integer := 490;
	constant R5_PolyDegreeLog2	: integer := 10;
	constant R5_MessageLen		: integer := 128;
	constant R5_q_bits			: integer := 10;
	constant R5_p_bits			: integer := 7;
	constant R5_t_bits			: integer := 3;
	constant R5_NumOfMulUnits	: integer := R5_PolyDegree;

	constant R5_Sigma_cycle	: integer := 2;   -- num of bits / 64
	constant R5_PolyA_cycle	: integer := 77;
	constant R5_PolyB_cycle	: integer := 54;  -- ceiling((PolyDegree+1)*p_bits))/64)
	constant R5_PolyR_cycle	: integer := 16;
	constant R5_RHO_cycle		: integer := 2;
   constant R5_Message_cycle 	: integer := 2;
	constant R5_Sk_cycle		: integer := 2;
	constant R5_PolyU_cycle	: integer := 54; --ceiling (PolyDegree*p_bits/64)
	constant R5_ctV_cycle		: integer := 6;  --ceiling (t_bits*MessageLen/64)
	
   constant R5_FirstPart_cycle    : integer := R5_PolyA_cycle;
   constant R5_SecondPart_cycle	: integer := R5_ctV_cycle;
   constant R5_Dec_Msg_cycle 	    : integer := 2;
	constant R5_XEf_cycle			: integer := 3; -- ceiling(code_len/64) (if no XEf = 0)
	------------- CONSTANTS FOR ROUNDING ------
	constant R5_p_PolyMask		: std_logic_vector(R5_q_bits-1 downto 0) := "0011111111";
	constant R5_b_mask_enc1 	: std_logic_vector(R5_q_bits-1 downto 0) := "0011111111";
	constant R5_b_mask_enc2 	: std_logic_vector(R5_p_bits-1 downto 0) := "0001111";
	constant R5_b_mask_dec1 	: std_logic_vector(R5_p_bits-1 downto 0) := "0000001";

	constant R5_r_const_enc1 	: std_logic_vector(7 downto 0) := "00000100";
	constant R5_r_const_enc2 	: std_logic_vector(7 downto 0) := "00000100";
	constant R5_r_const_dec1 	: std_logic_vector(7 downto 0) := "01000100";
	
	----------- XEf
	type IntegerArray is array(natural range<>) of integer;
	constant R5_xef_reg_len			: IntegerArray := (16, 11, 13, 16, 17, 19, 21, 23, 25, 29);
	constant R5_xef_div_boundaries: IntegerArray := (16, 27, 40, 56, 73, 92, 113, 136, 161, 190);
	--constant R5_xef_shortest		: integer := 11;
	constant R5_xef_shortest		: integer := 10;
	constant R5_code_len 			: integer := 190;
	constant R5_xef_num_of_shifts 	: integer := 8;
	constant R5_xef_num_of_fixerr : integer := 13; -- msg len/shortest (10)

end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

package R5ND_3KEM_5d_param_set is
	constant R5_PolyDegree		: integer := 756;
	constant R5_PolyDegreeLog2	: integer := 11;
	constant R5_MessageLen		: integer := 192;
	constant R5_q_bits			: integer := 12;
	constant R5_p_bits			: integer := 8;
	constant R5_t_bits			: integer := 2;
	constant R5_NumOfMulUnits	: integer := R5_PolyDegree;

	constant R5_Sigma_cycle	: integer := 3;   -- num of bits / 64
	constant R5_PolyA_cycle	: integer := 142;
	constant R5_PolyB_cycle	: integer := 95;  -- ceiling((PolyDegree+1)*p_bits))/64)
	constant R5_PolyR_cycle	: integer := 24;
	constant R5_RHO_cycle		: integer := 3;
   constant R5_Message_cycle 	: integer := 3;
	constant R5_Sk_cycle		: integer := 3;
	constant R5_PolyU_cycle	: integer := R5_PolyB_cycle; --ceiling (PolyDegree*p_bits/64)
	constant R5_ctV_cycle		: integer := 6;  --ceiling (t_bits*MessageLen/64)
	
   constant R5_FirstPart_cycle    : integer := R5_PolyA_cycle;
   constant R5_SecondPart_cycle	: integer := R5_ctV_cycle;
   constant R5_Dec_Msg_cycle 	    : integer := 3;
	constant R5_XEf_cycle			: integer := 4; -- ceiling(code_len/64) (if no XEf = 0)
	------------- CONSTANTS FOR ROUNDING ------
	constant R5_p_PolyMask		: std_logic_vector(R5_q_bits-1 downto 0) := "000011111111";
	constant R5_b_mask_enc1 	: std_logic_vector(R5_q_bits-1 downto 0) := "000011111111";
	constant R5_b_mask_enc2 	: std_logic_vector(R5_p_bits-1 downto 0) := "00001111";
	constant R5_b_mask_dec1 	: std_logic_vector(R5_p_bits-1 downto 0) := "00000011";

	constant R5_r_const_enc1 	: std_logic_vector(7 downto 0) := "00000100";
	constant R5_r_const_enc2 	: std_logic_vector(7 downto 0) := "00000100";
	constant R5_r_const_dec1 	: std_logic_vector(7 downto 0) := "01000100";
	
	----------- XEf
	type IntegerArray is array(natural range<>) of integer;
	constant R5_xef_reg_len			: IntegerArray := (24, 13, 16, 17, 19, 21, 23, 25, 29, 31);
	constant R5_xef_div_boundaries: IntegerArray := (24, 37, 53, 70, 89, 110, 133, 158, 187,218);
	constant R5_xef_shortest		: integer := 10;
	constant R5_code_len 			: integer := 218;
	constant R5_xef_num_of_shifts 	: integer := 8;
	constant R5_xef_num_of_fixerr : integer := 20; -- msg len/shortest (changed to 10)

end package;



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

package R5ND_5KEM_5d_param_set is
	constant R5_PolyDegree		: integer := 940;
	constant R5_PolyDegreeLog2	: integer := 11;
	constant R5_MessageLen		: integer := 256;
	constant R5_q_bits			: integer := 12;
	constant R5_p_bits			: integer := 8;
	constant R5_t_bits			: integer := 2;
	constant R5_NumOfMulUnits	: integer := R5_PolyDegree;

	constant R5_Sigma_cycle	: integer := 4;   -- num of bits / 64
	constant R5_PolyA_cycle	: integer := 177;
	constant R5_PolyB_cycle	: integer := 118;  -- ceiling((PolyDegree+1)*p_bits))/64)
	constant R5_PolyR_cycle	: integer := 32;
	constant R5_RHO_cycle		: integer := 4;
   constant R5_Message_cycle 	: integer := 4;
	constant R5_Sk_cycle		: integer := 4;
	constant R5_PolyU_cycle	: integer := R5_PolyB_cycle; --ceiling (PolyDegree*p_bits/64)
	constant R5_ctV_cycle		: integer := 8;  --ceiling (t_bits*MessageLen/64)
	
   constant R5_FirstPart_cycle    : integer := R5_PolyA_cycle;
   constant R5_SecondPart_cycle	: integer := R5_ctV_cycle;
   constant R5_Dec_Msg_cycle 	    : integer := 4;
	constant R5_XEf_cycle			: integer := 4; -- ceiling(code_len/64) (if no XEf = 0)
	------------- CONSTANTS FOR ROUNDING ------
	constant R5_p_PolyMask	: std_logic_vector(R5_q_bits-1 downto 0) := "000111111111";
	constant R5_b_mask_enc1 	: std_logic_vector(R5_q_bits-1 downto 0) := "000111111111";
	constant R5_b_mask_enc2 	: std_logic_vector(R5_p_bits-1 downto 0) := "00001111";
	constant R5_b_mask_dec1 	: std_logic_vector(R5_p_bits-1 downto 0) := "00000011";

	constant R5_r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
	constant R5_r_const_enc2 	: std_logic_vector(7 downto 0) := "00010000";
	constant R5_r_const_dec1 	: std_logic_vector(7 downto 0) := "10000000";	

	----------- XEf
	type IntegerArray is array(natural range<>) of integer;
	constant R5_xef_reg_len			: IntegerArray := (16, 16, 17, 19, 21, 23, 25, 29, 31, 37);
	constant R5_xef_div_boundaries: IntegerArray := (16, 32, 49, 68, 89, 112, 137, 166, 197,234);
	constant R5_code_len 			: integer := 234;
	constant R5_xef_shortest		: integer := 10;
	constant R5_xef_num_of_shifts : integer := 16;
	constant R5_xef_num_of_fixerr : integer := 26; -- msg len/shortest

	
end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

package R5ND_1PKE_5d_param_set is
	constant R5_PolyDegree		: integer := 508;
	constant R5_PolyDegreeLog2	: integer := 10;
	constant R5_MessageLen		: integer := 128;
	constant R5_q_bits			: integer := 10;
	constant R5_p_bits			: integer := 7;
	constant R5_t_bits			: integer := 4;
	constant R5_NumOfMulUnits	: integer := R5_PolyDegree;

	constant R5_Sigma_cycle	: integer := 2;   -- num of bits / 64
	constant R5_PolyA_cycle	: integer := 80;
	constant R5_PolyB_cycle	: integer := 56;  -- ceiling((PolyDegree+1)*p_bits))/64)
	constant R5_PolyR_cycle	: integer := 16;
	constant R5_RHO_cycle		: integer := 2;
   constant R5_Message_cycle 	: integer := 2;
	constant R5_Sk_cycle		: integer := 2;
	constant R5_PolyU_cycle	: integer := R5_PolyB_cycle; --ceiling (PolyDegree*p_bits/64)
	constant R5_ctV_cycle		: integer := 8;  --ceiling (t_bits*MessageLen/64)
	
   constant R5_FirstPart_cycle    : integer := R5_PolyB_cycle;
   constant R5_SecondPart_cycle	: integer := 8;
   constant R5_Dec_Msg_cycle 	    : integer := 2;
	constant R5_XEf_cycle			: integer := 3; -- ceiling(code_len/64) (if no XEf = 0)
	------------- CONSTANTS FOR ROUNDING ------
	constant R5_p_PolyMask	: std_logic_vector(R5_q_bits-1 downto 0) := "0001111111";
	constant R5_b_mask_enc1 	: std_logic_vector(R5_q_bits-1 downto 0) := "0001111111";
	constant R5_b_mask_enc2 	: std_logic_vector(R5_p_bits-1 downto 0) := "0000111";
	constant R5_b_mask_dec1 	: std_logic_vector(R5_p_bits-1 downto 0) := "0000011";

	constant R5_r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
	constant R5_r_const_enc2 	: std_logic_vector(7 downto 0) := "00010000";
	constant R5_r_const_dec1 	: std_logic_vector(7 downto 0) := "10000000";
	
		----------- XEf
	type IntegerArray is array(natural range<>) of integer;
	constant R5_xef_reg_len			: IntegerArray := (16, 11, 13, 16, 17, 19, 21, 23, 25, 29);
	constant R5_xef_div_boundaries: IntegerArray := (16, 27, 40, 56, 73, 92, 113, 136, 161, 190);
	constant R5_xef_shortest		: integer := 10;
	constant R5_code_len 			: integer := 190;
	constant R5_xef_num_of_shifts : integer := 8;
	constant R5_xef_num_of_fixerr : integer := 13; -- code len/shortest

end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

package R5ND_3PKE_5d_param_set is
	constant R5_PolyDegree		: integer := 756;
	constant R5_PolyDegreeLog2	: integer := 11;
	constant R5_MessageLen		: integer := 192;
	constant R5_q_bits			: integer := 12;
	constant R5_p_bits			: integer := 8;
	constant R5_t_bits			: integer := 3;
	constant R5_NumOfMulUnits	: integer := R5_PolyDegree;

	constant R5_Sigma_cycle	: integer := 3;   -- num of bits / 64
	constant R5_PolyA_cycle	: integer := 142;
	constant R5_PolyB_cycle	: integer := 95;  -- ceiling((PolyDegree+1)*p_bits))/64)
	constant R5_PolyR_cycle	: integer := 24;
	constant R5_RHO_cycle		: integer := 3;
   constant R5_Message_cycle 	: integer := 3;
	constant R5_Sk_cycle		: integer := 3;
	constant R5_PolyU_cycle	: integer := R5_PolyB_cycle; --ceiling (PolyDegree*p_bits/64)
	constant R5_ctV_cycle		: integer := 9;  --ceiling (t_bits*MessageLen/64)
	
   constant R5_FirstPart_cycle    : integer := R5_PolyB_cycle;
   constant R5_SecondPart_cycle	: integer := 15;
   constant R5_Dec_Msg_cycle 	    : integer := 3;
	constant R5_XEf_cycle			: integer := 4; -- ceiling(code_len/64) (if no XEf = 0)
	------------- CONSTANTS FOR ROUNDING ------
	constant R5_p_PolyMask	: std_logic_vector(R5_q_bits-1 downto 0) 	:= "000111111111";
	constant R5_b_mask_enc1 	: std_logic_vector(R5_q_bits-1 downto 0):= "000111111111";
	constant R5_b_mask_enc2 	: std_logic_vector(R5_p_bits-1 downto 0):= "00001111";
	constant R5_b_mask_dec1 	: std_logic_vector(R5_p_bits-1 downto 0):= "00000001";

	constant R5_r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
	constant R5_r_const_enc2 	: std_logic_vector(7 downto 0) := "00010000";
	constant R5_r_const_dec1 	: std_logic_vector(7 downto 0) := "10000000";
	
		----------- XEf
	type IntegerArray is array(natural range<>) of integer;
	constant R5_xef_reg_len			: IntegerArray := (24, 13, 16, 17, 19, 21, 23, 25, 29, 31);
	constant R5_xef_div_boundaries: IntegerArray := (24, 37, 53, 70, 89, 110, 133, 158, 187,218);
	constant R5_xef_shortest		: integer := 10;
	constant R5_code_len 			: integer := 218;
	constant R5_xef_num_of_shifts 	: integer := 8;
	constant R5_xef_num_of_fixerr : integer := 20; -- code len/shortest

end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

package R5ND_5PKE_5d_param_set is
	constant R5_PolyDegree		: integer := 946;
	constant R5_PolyDegreeLog2	: integer := 11;
	constant R5_MessageLen		: integer := 256;
	constant R5_q_bits			: integer := 11;
	constant R5_p_bits			: integer := 8;
	constant R5_t_bits			: integer := 5;
	constant R5_NumOfMulUnits	: integer := R5_PolyDegree;

	constant R5_Sigma_cycle	: integer := 4;   -- num of bits / 64
	constant R5_PolyA_cycle	: integer := 163;
	constant R5_PolyB_cycle	: integer := 119;  -- ceiling((PolyDegree+1)*p_bits))/64)
	constant R5_PolyR_cycle	: integer := 30;
	constant R5_RHO_cycle		: integer := 4;
    constant R5_Message_cycle 	: integer := 4;
	constant R5_Sk_cycle		: integer := 4;
	constant R5_PolyU_cycle	: integer := R5_PolyB_cycle; --ceiling (PolyDegree*p_bits/64)
	constant R5_ctV_cycle		: integer := 20;  --ceiling (t_bits*MessageLen/64)
	
    constant R5_FirstPart_cycle    : integer := R5_PolyB_cycle;
    constant R5_SecondPart_cycle	: integer := 20;
    constant R5_Dec_Msg_cycle 	    : integer := 4;
	constant R5_XEf_cycle			: integer := 4; -- ceiling(code_len/64) (if no XEf = 0)
	------------- CONSTANTS FOR ROUNDING ------
	constant R5_p_PolyMask	: std_logic_vector(R5_q_bits-1 downto 0) := "00011111111";
	constant R5_b_mask_enc1 	: std_logic_vector(R5_q_bits-1 downto 0) := "00011111111";
	constant R5_b_mask_enc2 	: std_logic_vector(R5_p_bits-1 downto 0) := "00001111";
	constant R5_b_mask_dec1 	: std_logic_vector(R5_p_bits-1 downto 0) := "00000011";

	constant R5_r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
	constant R5_r_const_enc2 	: std_logic_vector(7 downto 0) := "00010000";
	constant R5_r_const_dec1 	: std_logic_vector(7 downto 0) := "10000000";

		----------- XEf
	type IntegerArray is array(natural range<>) of integer;
	constant R5_xef_reg_len			: IntegerArray := (16, 16, 17, 19, 21, 23, 25, 29, 31, 37);
	constant R5_xef_div_boundaries: IntegerArray := (16, 32, 49, 68, 89, 112, 137, 166, 197,234);
	constant R5_code_len 			: integer := 234;
	constant R5_xef_shortest		: integer := 10;  --- set to 10
	constant R5_xef_num_of_shifts 	: integer := 16;
	constant R5_xef_num_of_fixerr : integer := 26; -- code len/shortest
end package;
