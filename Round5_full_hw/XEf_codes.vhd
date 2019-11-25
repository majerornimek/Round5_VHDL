library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;  
use work.Round5_constants.all;

entity XEf_codes is
	port(
		InputMsg			: in std_logic_vector(0 to MessageLen-1);
		InputCodeword  : in std_logic_vector(0 to code_len-1);
		mode				: in std_logic; ---- 0 enc, 1 dec
		rst 				: in std_logic;
		start				: in std_logic;
		clk 				: in std_logic;
		
		Code_computed	: out std_logic;
		Code_fixed		: out std_logic;
		
		OutputMsg : out std_logic_vector(0 to MessageLen-1);
		OutputCode: out std_logic_vector(0 to code_len-1)
	);
end entity;

architecture a1 of XEf_codes is
type VectorArray is array(natural range<>) of std_logic_vector(0 to xef_shortest-1);
type MessageArray is array(natural range<>) of std_logic_vector(0 to MessageLen-1);
type SumArray is array(natural range<>) of std_logic_vector(0 to 3); -- store computed values if bit has to be flipped
signal out_regs : VectorArray(0 to 9);
signal vertical_out_regs 					: VectorArray(0 to xef_shortest-1);
signal vertical_out_regs_to_compare 	: VectorArray(0 to 9);
signal vertical_out_regs_after_compare : VectorArray(0 to 9);
signal msg_regs : MessageArray(0 to 9);
signal sum_values : SumArray(0 to xef_shortest-1);
signal rotate, acc : std_logic;
signal after_reduction : std_logic;  --- flag to mark, if computed code and previously received are subtracted
signal start_msg_shift : std_logic;
signal fixerr_applied : std_logic;
signal code_computed_internal : std_logic;
signal shift_counts : std_logic_vector(0 to 3);
signal cc_0 : std_logic_vector(0 to xef_reg_len(0)-1);
signal cc_1 : std_logic_vector(0 to xef_reg_len(1)-1);
signal cc_2 : std_logic_vector(0 to xef_reg_len(2)-1);
signal cc_3 : std_logic_vector(0 to xef_reg_len(3)-1);
signal cc_4 : std_logic_vector(0 to xef_reg_len(4)-1);
signal cc_5 : std_logic_vector(0 to xef_reg_len(5)-1);
signal cc_6 : std_logic_vector(0 to xef_reg_len(6)-1);
signal cc_7 : std_logic_vector(0 to xef_reg_len(7)-1);
signal cc_8 : std_logic_vector(0 to xef_reg_len(8)-1);
signal cc_9 : std_logic_vector(0 to xef_reg_len(9)-1);

signal pc_0 : std_logic_vector(0 to xef_div_boundaries(0)-1);
signal pc_1 : std_logic_vector(xef_div_boundaries(0) to xef_div_boundaries(1)-1);
signal pc_2 : std_logic_vector(xef_div_boundaries(1) to xef_div_boundaries(2)-1);
signal pc_3 : std_logic_vector(xef_div_boundaries(2) to xef_div_boundaries(3)-1);
signal pc_4 : std_logic_vector(xef_div_boundaries(3) to xef_div_boundaries(4)-1);
signal pc_5 : std_logic_vector(xef_div_boundaries(4) to xef_div_boundaries(5)-1);
signal pc_6 : std_logic_vector(xef_div_boundaries(5) to xef_div_boundaries(6)-1);
signal pc_7 : std_logic_vector(xef_div_boundaries(6) to xef_div_boundaries(7)-1);
signal pc_8 : std_logic_vector(xef_div_boundaries(7) to xef_div_boundaries(8)-1);
signal pc_9 : std_logic_vector(xef_div_boundaries(8) to xef_div_boundaries(9)-1);

signal fixed_msg : std_logic_vector(0 to xef_Extended_MessageLen-1);
signal msg_to_fix : std_logic_vector(0 to xef_Extended_MessageLen-1);
signal fixerred_reg : std_logic_vector(0 to xef_shortest-1);
signal reduction_counter : std_logic_vector(0 to 4) := (others => '0');
begin
	
	----- process counting shifts until code is computed
	process(clk)
	begin
		if rst = '1' then
			shift_counts <= (others => '0');
			start_msg_shift <= '0';
			code_computed_internal <= '0';
		elsif clk'event and clk = '1' then
			if start = '1' then
				if shift_counts >= xef_num_of_shifts then
					start_msg_shift <= '0';
					code_computed_internal <= '1';
				else
					shift_counts <= shift_counts + '1';
					start_msg_shift <= '1'; ----  signal to msg registers to start shifting
					code_computed_internal <= '0';
				end if;
			else
				shift_counts <= (others => '0');
				start_msg_shift <= '0';
				code_computed_internal <= '0';
			end if;
		end if;
	end process;

	Code_computed <= Code_computed_internal;
	Code_fixed <= fixerr_applied;
	
	
	---- process to manage xor_shift_registers (state)
	process(clk)
	begin
		if rst = '1' then
			acc <= '0';
			rotate <= '0';
			after_reduction <= '0';
			reduction_counter <= (others => '0');
		elsif clk'event and clk = '1' then
			if start = '1' then
				if code_computed_internal = '0' then
					acc <= '1';
					after_reduction <= '0';
					reduction_counter <= (others => '0');
				elsif mode = '1' and code_computed_internal = '1' and after_reduction = '0' then
					acc <= '1';
					rotate <= '1';
					after_reduction <= '1';
				elsif mode = '1' and code_computed_internal = '1' and after_reduction = '1' then
					acc <= '0';
					rotate <= '1';
					if reduction_counter < xef_num_of_fixerr then
						reduction_counter <= reduction_counter + '1';
						fixerr_applied <= '0';
					else
						fixerr_applied <= '1';
					end if;
				else
					after_reduction <= '0';
					fixerr_applied <= '0';
					reduction_counter <= (others => '0');
				end if;
			else
				acc <= '0';
				rotate <= '0';
				after_reduction <= '0';
				fixerr_applied <= '0';
				reduction_counter <= (others => '0');
			end if;
		end if;
	end process;
	
	
	---- concatenating ouput msg
	process(clk)
	begin
		if rst = '1' then
			fixed_msg <= (others => '0');
			msg_to_fix <= (others => '0');
		elsif clk'event and clk = '1' then
			if start = '1' then
				if mode = '1' and code_computed_internal = '1' and after_reduction = '1' and fixerr_applied = '0' then
					msg_to_fix <= msg_to_fix(xef_shortest to xef_Extended_MessageLen-1) & msg_to_fix(0 to xef_shortest-1);
					fixed_msg <= fixerred_reg & fixed_msg(xef_shortest to xef_Extended_MessageLen-1);
				else
					msg_to_fix(0 to MessageLen-1) <= InputMsg;
					msg_to_fix(MessageLen to xef_Extended_MessageLen-1) <= (others => '0');
				end if;
			else
				fixed_msg <= (others => '0');
			end if;
		end if;
	end process;
	
	OutputMsg <= fixed_msg(0 to MessageLen-1);
	
	---- MSG shift registers to feed code computing register
	gen_reg: for i in 0 to 9 generate
		s1: entity work.shift_register 
		generic map(
			register_len => MessageLen,
			shift_value  => xef_reg_len(i)
		)
		port map(
			DataIN => InputMsg,
			rst 	=> rst,
			clk 	=> clk,
			start	=> start_msg_shift,
			DataOUT => msg_regs(i)
		
		);
	end generate gen_reg;


		
		
	---- bits concatenation across registers for given position. Num of positions limited to the shortest one
	change_reg: for i in 0 to xef_shortest-1 generate
		vertical_out_regs(i) <= out_regs(0)(i) & out_regs(1)(i) &  out_regs(2)(i) & out_regs(3)(i) &  out_regs(4)(i) & out_regs(5)(i) &  out_regs(6)(i) & out_regs(7)(i) &  out_regs(8)(i) & out_regs(9)(i); 
	end generate change_reg;

	---- SUM across all 10 registers for given position to compute if bit has to be flipped
	sum_reg: for i in 0 to xef_shortest-1 generate
		ss: entity work.compute_bit_sum 
				port map(
					DataIn 	=> vertical_out_regs(i),
					clk		=> clk,
					DataOut	=> sum_values(i)
		 		);
	end generate sum_reg;
	
	---- check condition and negate bit if necessary (correct bit)
	negatee: for i in 0 to xef_shortest-1 generate
		ss: entity work.negate_msg_bit 
				port map(
					BitIn		=> msg_to_fix(i),
					IntValue	=> sum_values(i),
		
					clk => clk,
		
					BitOut	=> fixerred_reg(i)
		 		);
	end generate negatee;
	
	
	-------- Concatenate newly computed code
	OutputCode <= cc_0 & cc_1 & cc_2 & cc_3 & cc_4 & cc_5 & cc_6 & cc_7 & cc_8 & cc_9;
	
	------- out of the generate loop, computed codes have different length
	f0: entity work.pairity_shift_register 
				generic map(
					register_len => xef_reg_len(0),
					shift_value => xef_shortest
				)
				port map(
					DataIN => msg_regs(0)(0 to  xef_reg_len(0)-1),
					Previous_code => pc_0,
					
					rst 	=> rst,
					clk 	=> clk,
					acc	=> acc,
					rotate => rotate,
				
					Computed_code => cc_0,
					DataOUT => out_regs(0)
				);
	
	
	
	f1: entity work.XOR_shift_register 
			generic map(
				register_len => xef_reg_len(1),
				shift_value  => xef_shortest
			)
			port map(
				DataIN => msg_regs(1)(0 to xef_reg_len(1)-1),
				Previous_code => pc_1,
				rst 	=> rst,
				clk 	=> clk,
				acc	=> acc,
				rotate => rotate,
			
			
				Computed_code => cc_1,
				DataOUT => out_regs(1)
			);
			
	f2: entity work.XOR_shift_register 
			generic map(
				register_len => xef_reg_len(2),
				shift_value  => xef_shortest
			)
			port map(
				DataIN => msg_regs(2)(0 to xef_reg_len(2)-1),
				Previous_code => pc_2,
				rst 	=> rst,
				clk 	=> clk,
				acc	=> acc,
				rotate => rotate,
			
				Computed_code => cc_2,
				DataOUT => out_regs(2)
			);
	
	f3: entity work.XOR_shift_register 
			generic map(
				register_len => xef_reg_len(3),
				shift_value  => xef_shortest
			)
			port map(
				DataIN => msg_regs(3)(0 to xef_reg_len(3)-1),
				Previous_code => pc_3,
				rst 	=> rst,
				clk 	=> clk,
				acc	=> acc,
				rotate => rotate,
			
				Computed_code => cc_3,
				DataOUT => out_regs(3)
			);
			
	f4: entity work.XOR_shift_register 
			generic map(
				register_len => xef_reg_len(4),
				shift_value  => xef_shortest
			)
			port map(
				DataIN => msg_regs(4)(0 to xef_reg_len(4)-1),
				Previous_code => pc_4,
				rst 	=> rst,
				clk 	=> clk,
				acc	=> acc,
				rotate => rotate,
			
				Computed_code => cc_4,
				DataOUT => out_regs(4)
			);
	f5: entity work.XOR_shift_register 
			generic map(
				register_len => xef_reg_len(5),
				shift_value  => xef_shortest
			)
			port map(
				DataIN => msg_regs(5)(0 to xef_reg_len(5)-1),
				Previous_code => pc_5,
				rst 	=> rst,
				clk 	=> clk,
				acc	=> acc,
				rotate => rotate,
			
				Computed_code => cc_5,
				DataOUT => out_regs(5)
			);
	f6: entity work.XOR_shift_register 
			generic map(
				register_len => xef_reg_len(6),
				shift_value  => xef_shortest
			)
			port map(
				DataIN => msg_regs(6)(0 to xef_reg_len(6)-1),
				Previous_code => pc_6,
				rst 	=> rst,
				clk 	=> clk,
				acc	=> acc,
				rotate => rotate,
			
				Computed_code => cc_6,
				DataOUT => out_regs(6)
			);
	f7: entity work.XOR_shift_register 
			generic map(
				register_len => xef_reg_len(7),
				shift_value  => xef_shortest
			)
			port map(
				DataIN => msg_regs(7)(0 to xef_reg_len(7)-1),
				Previous_code => pc_7,
				rst 	=> rst,
				clk 	=> clk,
				acc	=> acc,
				rotate => rotate,
			
				Computed_code => cc_7,
				DataOUT => out_regs(7)
			);
	f8: entity work.XOR_shift_register 
			generic map(
				register_len => xef_reg_len(8),
				shift_value  => xef_shortest
			)
			port map(
				DataIN => msg_regs(8)(0 to xef_reg_len(8)-1),
				Previous_code => pc_8,
				rst 	=> rst,
				clk 	=> clk,
				acc	=> acc,
				rotate => rotate,
			
				Computed_code => cc_8,
				DataOUT => out_regs(8)
			);
	f9: entity work.XOR_shift_register 
			generic map(
				register_len => xef_reg_len(9),
				shift_value  => xef_shortest
			)
			port map(
				DataIN => msg_regs(9)(0 to xef_reg_len(9)-1),
				Previous_code => pc_9,
				rst 	=> rst,
				clk 	=> clk,
				acc	=> acc,
				rotate => rotate,
			
				Computed_code => cc_9,
				DataOUT => out_regs(9)
			);

----------- OLD
--	
--	
--	gen_xef_reg: for i in 0 to 9 generate
--		first: if i=0 generate
--			fr: entity work.pairity_shift_register 
--				generic map(
--					register_len => xef_reg_len(i),
--					shift_value => xef_shortest
--				)
--				port map(
--					DataIN => msg_regs(i)(0 to  xef_reg_len(i)-1),
--				
--					rst 	=> rst,
--					clk 	=> clk,
--					acc	=> acc,
--			--		rotate: std_logic;
--				
--					DataOUT => out_regs(i)
--				);
--		end generate first;
--			
--		last: if i>0 generate
--			fl: entity work.XOR_shift_register 
--			generic map(
--				register_len => xef_reg_len(i),
--				shift_value  => xef_shortest
--			)
--			port map(
--				DataIN => msg_regs(i)(0 to xef_reg_len(i)-1),
--			
--				rst 	=> rst,
--				clk 	=> clk,
--				acc	=> acc,
--				rotate => rotate,
--			
--				DataOUT => out_regs(i)
--			);
--		end generate last;
--		
--		end generate gen_xef_reg;			
			
			
			
end a1;