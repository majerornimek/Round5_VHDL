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

	------------- CONSTANTS FOR ROUNDING ------
	constant R5_p_PolyMask	: std_logic_vector(R5_q_bits-1 downto 0) := "0000111111111";
	constant R5_b_mask_enc1 	: std_logic_vector(R5_q_bits-1 downto 0) := "0000111111111";
	constant R5_b_mask_enc2 	: std_logic_vector(R5_p_bits-1 downto 0) := "000001111";
	constant R5_b_mask_dec1 	: std_logic_vector(R5_p_bits-1 downto 0) := "000000001";

	constant R5_r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
	constant R5_r_const_enc2 	: std_logic_vector(7 downto 0) := "00010000";
	constant R5_r_const_dec1 	: std_logic_vector(7 downto 0) := "10000000";
	
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
	
	------------- CONSTANTS FOR ROUNDING ------
	constant R5_p_PolyMask	: std_logic_vector(R5_q_bits-1 downto 0) 	:= "000111111111";
	constant R5_b_mask_enc1 	: std_logic_vector(R5_q_bits-1 downto 0):= "000111111111";
	constant R5_b_mask_enc2 	: std_logic_vector(R5_p_bits-1 downto 0):= "000001111";
	constant R5_b_mask_dec1 	: std_logic_vector(R5_p_bits-1 downto 0):= "000000001";

	constant R5_r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
	constant R5_r_const_enc2 	: std_logic_vector(7 downto 0) := "00010000";
	constant R5_r_const_dec1 	: std_logic_vector(7 downto 0) := "10000000";
	
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

	------------- CONSTANTS FOR ROUNDING ------
	constant R5_p_PolyMask	: std_logic_vector(R5_q_bits-1 downto 0) := "0000111111111";
	constant R5_b_mask_enc1 	: std_logic_vector(R5_q_bits-1 downto 0) := "0000111111111";
	constant R5_b_mask_enc2 	: std_logic_vector(R5_p_bits-1 downto 0) := "000001111";
	constant R5_b_mask_dec1 	: std_logic_vector(R5_p_bits-1 downto 0) := "000000001";

	constant R5_r_const_enc1 	: std_logic_vector(7 downto 0) := "00001000";
	constant R5_r_const_enc2 	: std_logic_vector(7 downto 0) := "00010000";
	constant R5_r_const_dec1 	: std_logic_vector(7 downto 0) := "10000000";

end package;
