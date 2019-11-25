library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

library work;
use work.R5ND_5PKE_5d_param_set.all;  --- CHANGE USED PACKAGE TO CHANGE PARAMETERS

package Round5_constants is  -- R5ND_1KEM_0C

	constant PolyDegree		: integer := R5_PolyDegree;
	constant PolyDegreeLog2	: integer := R5_PolyDegreeLog2;
	constant MessageLen		: integer := R5_MessageLen;
	constant q_bits			: integer := R5_q_bits;
	constant p_bits			: integer := R5_p_bits;
	constant t_bits			: integer := R5_t_bits;
	constant NumOfMulUnits	: integer := R5_NumOfMulUnits;
    
    constant p_PolyMask	: std_logic_vector(q_bits-1 downto 0) := R5_p_PolyMask;
	------------- CONSTANTS FOR ROUNDING ------
	constant b_mask_enc1 	: std_logic_vector(q_bits-1 downto 0) := R5_b_mask_enc1;
	constant b_mask_enc2 	: std_logic_vector(p_bits-1 downto 0) := R5_b_mask_enc2;
	constant b_mask_dec1 	: std_logic_vector(p_bits-1 downto 0) := R5_b_mask_dec1;

	constant r_const_enc1 	: std_logic_vector(7 downto 0) := R5_r_const_enc1;
	constant r_const_enc2 	: std_logic_vector(7 downto 0) := R5_r_const_enc2;
	constant r_const_dec1 	: std_logic_vector(7 downto 0) := R5_r_const_dec1;

	---------------------- CONSTANTS FOR ROUNDING ------

	type Trinomial is array(natural range<>) of std_logic_vector(1 downto 0);
	type q_bitsPoly is array(natural range<>) of std_logic_vector(q_bits-1 downto 0);
	type P_bitsPoly is array(natural range<>) of std_logic_vector(p_bits-1 downto 0);
	type t_bitsPoly	is array(natural range<>) of std_logic_vector(t_bits-1 downto 0);
	--type IntegerArray is array(natural range<>) of integer;
    constant zero_fill      : std_logic_vector(q_bits-1 - 8 downto 0) := (others => '0');
    
    ---------------------- CONSTANTS FOR AXI WRAPPER ----
    constant AXI_data_width : integer := 64; -- number of bits saved in one clock cycle
   
    
    --These constants describe the number of AXI clock cycles needed for sending the whole data.
	--Data is being sent without any empty bits (data is packed)
	
	constant Sigma_cycle	: integer := R5_Sigma_cycle;   -- num of bits / 64
	constant PolyA_cycle	: integer := R5_PolyA_cycle;
	constant PolyB_cycle	: integer := R5_PolyB_cycle;  -- ceiling((PolyDegree+1)*p_bits))/64)
	constant PolyR_cycle	: integer := R5_PolyR_cycle;
	constant RHO_cycle		: integer := R5_RHO_cycle;
    constant Message_cycle 	: integer := R5_Message_cycle;
	constant Sk_cycle		: integer := R5_Sk_cycle;
	constant PolyU_cycle	: integer := R5_PolyU_cycle; --ceiling (PolyDegree*p_bits/64)
	constant ctV_cycle		: integer := R5_ctV_cycle;  --ceiling (t_bits*MessageLen/64)
	
    constant FirstPart_cycle    : integer := R5_FirstPart_cycle;
    constant SecondPart_cycle	: integer := R5_SecondPart_cycle;
    constant Dec_Msg_cycle 	    : integer := R5_Dec_Msg_cycle;
	constant XEf_cycle				: integer := R5_XEf_cycle;
	---- XEf
--	constant xef_p1				: integer := R5_xef_p1;
--	constant xef_f					: integer := R5_xef_f; -- 0 or 5
	constant xef_reg_len			: IntegerArray := R5_xef_reg_len;
	constant xef_div_boundaries: IntegerArray := R5_xef_div_boundaries;
	constant code_len				: integer := R5_code_len;
	--constant xef_shortest		: integer := R5_xef_shortest;
	constant xef_shortest		: integer := 10;
	constant xef_num_of_shifts : integer := R5_xef_num_of_shifts;
	constant xef_num_of_fixerr : integer := R5_xef_num_of_fixerr;
	constant xef_Extended_MessageLen : integer := xef_num_of_fixerr*xef_shortest;
	
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
	constant XEf_cycle_start		: integer := Message_cycle_end+1;
	constant XEf_cycle_end			: integer := XEf_cycle_start + XEf_cycle;
	
	
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
-- CYCLES COUNT FO STATE MACHINES
	constant CPA_KEM_WRITE_SEC_HASH_RESULT_CLOCK_CYCLES : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(4,16));
    constant CPA_KEM_PolyA_cycle_move					: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));
    constant CPA_KEM_Move_RHO_clock_cycles				: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyR_cycle,16));
    constant CPA_KEM_MOVE_ENC_RESULT_CLOCK_CYCLES		: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyU_cycle+ctV_cycle,16));
    constant CPA_KEM_MSG_LOAD_CYCLES					: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(Dec_Msg_cycle,16));
    constant CPA_KEM_RHO_LOAD_CYCLES					: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(Dec_Msg_cycle,16));
    constant CPA_KEM_PubB_data_load						: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyB_cycle,16));
    constant CPA_KEM_SIGMA_LOAD_CYCLES					: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(sigma_cycle,16));
	constant CPA_KEM_POLY_B_LOAD_CYCLES					: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyB_cycle,16));
	constant CPA_RHO_LOAD_CYCLES						: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(RHO_cycle,16));
	constant CPA_KEM_MOVE_RHO_LOAD_CYCLES				: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(RHO_cycle,16));
	constant CPA_KEM_RESULT_LOAD_CYCLES					: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(ctV_cycle,16));
	constant CPA_PKE_SK_LOAD_CYCLES						: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(Sk_cycle,16));
	constant CPA_PKE_CTV_LOAD_CYCLES					: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(ctV_cycle,16));
	constant CPA_PKE_PolyB_MOVE_CYCLES					: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyB_cycle,16));
	constant CPA_PKE_DEC_RESULT_LOAD_CYCLES				: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));
	constant CPA_KEM_ENCAPS_HASH_RESULT_LOAD_CYCLES		: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));
	constant CCA_L_G_RHO_MOVE_CYCLES						: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));
	constant CCA_L_G_MOVE_CYCLES							: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));
	constant CCA_SIGMA_MOVE_CYCLES							: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));
	constant CCA_PolyA_MOVE_CYCLES							: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));
	constant CCA_KEM_ENCAPS_HASH_RESULT_LOAD_CYCLES			: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));
	constant CCA_MSG_LOAD_CYCLES							: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));
	constant CCA_PK_LOAD_CYCLES							: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));
	constant CCA_SIGMA_LOAD_CYCLES							: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));
	constant CCA_CT_LOAD_CYCLES			: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));
	constant CCA_KEM_L_MOVE_CYCLES			: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));
	constant CCA_SK_LOAD_CYCLES				: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));
	constant CCA_CTV_LOAD_CYCLES			: std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));
	constant CCA_PKE_DEC_RESULT_LOAD_CYCLES : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(PolyA_cycle,16));


end package;


