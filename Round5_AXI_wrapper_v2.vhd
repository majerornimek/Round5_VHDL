--------------
-- 	Author: 	Michal Andrzejczak
-- 	Mail:		michal.r.andrzejczak@gmail.com
--	
--	Desc:		Round5_arithmtic module frapper. Connect the module with SoC via AXI bus.
--	Info:
--				Round5_arithm has following data ports:
--					INPUT:			DATA WIDTH (bits)		R5ND_1KEM
--						PolyA	- PolyDegree * q_bits			6798
--						PolyB	- PolyDegree * p_bits			4944
--						PolyR	- PolyDegree * 2				1236
--						Message - MessageLen					128
--						ctV		- MessageLen * t_bits			512
--					
--					OUTPU:
--						FirstPart 	- 	PolyDegree * p_bits
--						SecondPart 	- 	MessageLen * t_bits
--						Dec_Msg		- 	MessageLen
--
--				Message and ctV should be loaded at the end, respectively for encryption and decryption.
--				Ouput is stored in one long register to simplify output handling. FirstPart 0000 SecondPaart 0000 Dec_Msg.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity Round5_AXI_wrapper is	
	port(
	clk			: in std_logic;
	-- FIFO WRITE
	FIFO_Full	: out std_logic;
	FIFO_din	: in std_logic_vector(63 downto 0);
	FIFO_wr_en	: in std_logic;
	-- FIFO READ
	FIFO_Empty	: out std_logic;
	FIFO_dout	: out std_logic_vector(63 downto 0);
	FIFO_rd_en	: in std_logic
	);
end entity;


architecture a1 of Round5_AXI_wrapper is 

component Round5_enc_arith is	
	port (
		PolyA			: in q_bitsPoly(PolyDegree-1 downto 0);  --W enc: A
		PolyB			: in p_bitsPoly(PolyDegree downto 0);	--W enc: polyB,   W dec: polyU
		PolyR			: in Trinomial(PolyDegree-1 downto 0); --W enc: poly R   W dec: polyS
		Message		    : in std_logic_vector(MessageLen-1 downto 0);
		ctV             : in t_bitsPoly(MessageLen-1  downto 0);
        
        
		clk			: in std_logic;
		Start			: in std_logic;
		Reset			: in std_logic;
		Operation	: in std_logic;  -- 1 enc, 0 dec
		Done        : out std_logic;
		
		FirstPart	: out p_bitsPoly(PolyDegree-1 downto 0);
		SecondPart	: out t_bitsPoly(MessageLen-1  downto 0);
        
		Dec_Msg		: out std_logic_vector(MessageLen-1 downto 0)
		
	);
end component;

signal start_module, reset_module, done_module 	: std_logic;
signal op_module	: std_logic;
signal op_selected  : std_logic;


------	DATA REGISTERS
signal PolyA_tmp 	: std_logic_vector(PolyA_cycle*AXI_data_width-1 downto 0); 	-- register to store input data to arithm module with overhead to store full input words
signal PolyB_tmp 	: std_logic_vector(PolyB_cycle*AXI_data_width-1 downto 0);
signal PolyR_tmp 	: std_logic_vector(PolyR_cycle*AXI_data_width-1 downto 0);
signal Message_tmp 	: std_logic_vector(Message_cycle*AXI_data_width-1 downto 0);
signal ctV_tmp		: std_logic_vector(ctV_cycle*AXI_data_width-1 downto 0);

--signal FirstPart_tmp	: std_logic_vector(FirstPart_cycle*AXI_data_width-1 downto 0);
--signal SecondPart_tmp	: std_logic_vector(SecondPart_cycle*AXI_data_width-1 downto 0);
signal Dec_Msg_tmp		: std_logic_vector(MessageLen-1 downto 0);
signal OutputTmp		: std_logic_vector((FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width-1 downto 0);
signal Output_Reg       : std_logic_vector((FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width-1 downto 0);
signal Encrypted_Reg	: std_logic_vector((FirstPart_cycle+SecondPart_cycle)*AXI_data_width-1 downto 0);

------	ADDRES POINTERS/COUNTERS
signal PolyA_count	: std_logic_vector(7 downto 0); -- point the region in PolyA_tmp register to write
signal PolyB_count	: std_logic_vector(7 downto 0); 
signal PolyR_count	: std_logic_vector(7 downto 0); 
signal Message_count	: std_logic_vector(3 downto 0); 
signal ctV_count	: std_logic_vector(7 downto 0);

--signal FirstPart_count 	: std_logic_vector(7 downto 0);
--signal SecondPart_count : std_logic_vector(7 downto 0);
--signal Dec_Msg_count 	: std_logic_vector(3 downto 0);
signal Output_count	: std_logic_vector(7 downto 0);
signal Out_saved 	: std_logic;	

------- POLYNOMIALS
signal PolyA_poly  : q_bitsPoly(PolyDegree-1 downto 0);
signal PolyB_poly  : p_bitsPoly(PolyDegree downto 0);
signal PolyR_poly  : Trinomial(PolyDegree-1 downto 0);
signal ctV_poly    : t_bitsPoly(PolyDegree-1 downto 0);
signal FirstPart_poly : p_bitsPoly(PolyDegree-1 downto 0);
signal SecondPart_poly: t_bitsPoly(MessageLen-1 downto 0);


------	DATA FLAGS
constant PolyA_addr 	: std_logic_vector(3 downto 0) := "0001";
constant PolyB_addr 	: std_logic_vector(3 downto 0) := "0010";
constant PolyR_addr 	: std_logic_vector(3 downto 0) := "0011";
constant Message_addr 	: std_logic_vector(3 downto 0) := "0100";
constant ctV_addr 		: std_logic_vector(3 downto 0) := "0101";

constant FirstPart_addr	: std_logic_vector(3 downto 0) := "0001";
constant SecondPart_addr: std_logic_vector(3 downto 0) := "0010";
constant Dec_Msg_addr	: std_logic_vector(3 downto 0) := "0011";

signal Round5_status	: std_logic_vector(63 downto AXI_data_width) := (others => '0');


begin

	arit: Round5_enc_arith port map(
		PolyA			=> PolyA_poly(PolyDegree-1 downto 0),
		PolyB			=> PolyB_poly(PolyDegree downto 0),
		PolyR			=> PolyR_poly(PolyDegree-1 downto 0),
		Message		    => Message_tmp(MessageLen-1 downto 0),
		ctV             => ctV_poly(MessageLen-1 downto 0),
        
        
		clk			=> clk,
		Start		=> start_module,
		Reset		=> reset_module,
		Operation	=> op_module,
		Done		=> done_module,
		
		FirstPart	=> FirstPart_poly,
        --OutputTmp((SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width-1+PolyDegree*p_bits downto (SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width),
		--FirstPart_tmp(PolyDegree*p_bits-1 downto 0),
		SecondPart	=> SecondPart_poly,
        --OutputTmp(Dec_Msg_cycle*AXI_data_width-1+MessageLen*t_bits downto (Dec_Msg_cycle)*AXI_data_width),
		--SecondPart_tmp(MessageLen*t_bits-1 downto 0),
        
		Dec_Msg		=> Dec_Msg_tmp(MessageLen-1 downto 0)
		--OutputTmp(MessageLen-1 downto 0)
	);
    
--------------------------------- RAW DATA TO POLYNOMIALS 
PA: for i in 0 to PolyDegree-1 generate
    PolyA_poly(i) <= PolyA_tmp((i+1)*q_bits-1 downto i*q_bits);
    PolyR_poly(i) <= PolyR_tmp((i+1)*2-1 downto i*2);

    --OutputTmp((SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width+(i+1)*p_bits-1 downto (SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width+(i)*p_bits) <= FirstPart_poly(i);

end generate PA;

P1: for i in 0 to PolyDegree generate
    PolyB_poly(i) <= PolyB_tmp((i+1)*p_bits-1 downto i*p_bits);
end generate P1;


MA: for i in 0 to MessageLen-1 generate
    ctV_poly(i) <= ctV_tmp((i+1)*t_bits-1 downto i*t_bits);
    --OutputTmp((Dec_Msg_cycle)*AXI_data_width+(i+1)*t_bits-1 downto (Dec_Msg_cycle)*AXI_data_width+(i)*t_bits) <= SecondPart_poly(i);
end generate MA;
	
----------------------------------- ENC/DEC selection and MODULE START SIGNAL OPERATING
process(clk)
begin
	if clk'event and clk = '1' then
		if FIFO_wr_en = '1' then
			if FIFO_din(63 downto 60) = Message_addr and Message_count = Message_cycle then
				op_module <= '1';  -- encryption
				op_selected <= '1';
				reset_module <= '0';
			elsif FIFO_din(63 downto 60) = ctV_addr and ctV_count = ctV_cycle then 
				op_module <= '0';	-- decryption
				op_selected <= '1';
				reset_module <= '0';
			elsif FIFO_din(63 downto 60) = PolyB_addr then
				op_selected <= '0';
				reset_module <= '1';
			end if;
		else
			if op_selected = '1' then		-- ALL DATA LOADED, START COMPUTATION
				start_module <= '1';
			else
				start_module <= '0';	--------- POTENTIAL PROBLEM DUE TO NOT HOLDING START SIGNAL 
			end if;
			
			if out_saved = '1' then
				reset_module <= '1';
			else
				reset_module <= '0';
			end if;
			
		end if;
	end if;
end process;


-----------------------------------	OUTPUT DATA	--------------------------------------------------------

 --FirstPart_tmp(FirstPart_cycle*AXI_data_width-1 downto PolyDegree*p_bits) <= (others => '0');		-- fill with zeros the remaining part
 --SecondPart_tmp(SecondPart_cycle*AXI_data_width-1 downto MessageLen*t_bits) <= (others => '0');		-- fill with zeros the remaining part
 --Dec_Msg_tmp(Dec_Msg_cycle*AXI_data_width-1 downto MessageLen) <= (others => '0');					-- fill with zeros the remaining part
 
 OutputTmp((FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width-1 downto (SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width+PolyDegree*p_bits) <= (others => '0'); -- fill with zeros the remaining part
 OutputTmp((FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width-PolyDegree*p_bits-1 downto SecondPart_cycle*AXI_data_width) <= (others => '0'); -- fill with zeros the remaining part
 OutputTmp((Dec_Msg_cycle)*AXI_data_width-1 downto MessageLen) <= (others => '0'); -- fill with zeros the remaining part
 
 Encrypted_Reg((FirstPart_cycle+SecondPart_cycle)*AXI_data_width-1 downto (SecondPart_cycle)*AXI_data_width+(PolyDegree)*p_bits) <= (others => '0');
  Encrypted_Reg((SecondPart_cycle)*AXI_data_width-1 downto (MessageLen)*t_bits) <= (others => '0');
-- data output handling
PAo: for i in 0 to PolyDegree-1 generate	--first part poly to raw data
    Encrypted_Reg((SecondPart_cycle)*AXI_data_width+(i+1)*p_bits-1 downto (SecondPart_cycle)*AXI_data_width+(i)*p_bits) <= FirstPart_poly(i);
end generate PAo;

MAo: for i in 0 to MessageLen-1 generate	--second part poly to raw data
    Encrypted_Reg((i+1)*t_bits-1 downto (i)*t_bits) <= SecondPart_poly(i);
end generate MAo;
	

---	Process handling saving data from arithm module to outpu reg and manage the pointer value
--- NOTE: Too big process, should be divided in 2-3 smaller processes.
process(clk)
begin
	if clk'event and clk = '1' then 
		if Out_saved = '0' then
			if done_module = '1' then 
				Out_saved <= '1';
				if op_module = '1' then
					Output_Reg((FirstPart_cycle+SecondPart_cycle)*AXI_data_width-1 downto 0) <= Encrypted_Reg;
					Output_Reg((FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width-1 downto (FirstPart_cycle+SecondPart_cycle)*AXI_data_width) <= (others =>'0');
					Output_count <= std_logic_vector(to_unsigned(Dec_Msg_cycle,8))  + '1';  -- set the pointer to encryption results
				else
					Output_Reg(MessageLen-1 downto 0) <= Dec_Msg_tmp;
					Output_Reg((FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width-1 downto MessageLen) <= (others =>'0');
					Output_count <= (others => '0');	-- set the pointer to decryption results
				end if;
				FIFO_Full <= '1';
			else
				
			end if;
		else	
			if Output_count = Dec_Msg_cycle or Output_count = Output_cycle then
				Out_saved <= '0';
				FIFO_Full <= '0';
			else
				Output_count <= Output_count + '1';
				Output_Reg <= Output_Reg(63 downto 0) & Output_Reg((FirstPart_cycle+SecondPart_cycle+Dec_Msg_cycle)*AXI_data_width-1 downto 64);
			end if;
		end if;
	end if;
end process;



process(clk)
begin
	if clk'event and clk = '1' then 
		if done_module = '1' then 
			if Output_count < Output_cycle then
				FIFO_dout(AXI_data_width-1 downto 0) <= Output_Reg(AXI_data_width-1 downto 0);--OutputTmp((to_integer(unsigned(Output_count)+1)*AXI_data_width)-1 downto to_integer(unsigned(Output_count))*AXI_data_width);
				FIFO_dout(63 downto AXI_data_width) <= Round5_status;
			end if;
		end if;
	end if;
end process;

-----------------------------------	INPUT DATA	--------------------------------------------------------

-- PolyA_counter
process(clk)
begin
	if clk'event and clk = '1' then
		if FIFO_wr_en = '1' then
			if FIFO_din(63 downto 60) = PolyA_addr then
				PolyA_count <= PolyA_count + '1';
			else
				PolyA_count <= (others => '0');
			end if;
		end if;
	end if;
end process;

-- PolyA_MSG
process(clk)
begin
	if clk'event and clk = '1' then
		if FIFO_wr_en = '1' then
			if FIFO_din(63 downto 60) = PolyA_addr and PolyA_count < PolyA_cycle then
				PolyA_tmp(AXI_data_width*(to_integer(unsigned(PolyA_count))+1) - 1 downto AXI_data_width*(to_integer(unsigned(PolyA_count)))) <= FIFO_din(AXI_data_width-1 downto 0);
			end if;
		end if;
	end if;
end process;

-- PolyB_counter
process(clk)
begin
	if clk'event and clk = '1' then
		if FIFO_wr_en = '1' then
			if FIFO_din(63 downto 60) = PolyB_addr then
				PolyB_count <= PolyB_count + '1';
			else
				PolyB_count <= (others => '0');
			end if;
		end if;
	end if;
end process;

-- PolyB_MSG
process(clk)
begin
	if clk'event and clk = '1' then
		if FIFO_wr_en = '1' then
			if FIFO_din(63 downto 60) = PolyA_addr and PolyB_count < PolyB_cycle then
				PolyB_tmp(AXI_data_width*(to_integer(unsigned(PolyB_count))+1) - 1 downto AXI_data_width*(to_integer(unsigned(PolyB_count)))) <= FIFO_din(AXI_data_width-1 downto 0);
			end if;
		end if;
	end if;
end process;

-- PolyR_counter
process(clk)
begin
	if clk'event and clk = '1' then
		if FIFO_wr_en = '1' then
			if FIFO_din(63 downto 60) = PolyR_addr then
				PolyR_count <= PolyR_count + '1';
			else
				PolyR_count <= (others => '0');
			end if;
		end if;
	end if;
end process;

-- PolyR_MSG
process(clk)
begin
	if clk'event and clk = '1' then
		if FIFO_wr_en = '1' then
			if FIFO_din(63 downto 60) = PolyR_addr and PolyR_count < PolyR_cycle then
				PolyR_tmp(AXI_data_width*(to_integer(unsigned(PolyR_count))+1) - 1 downto AXI_data_width*(to_integer(unsigned(PolyR_count)))) <= FIFO_din(AXI_data_width-1 downto 0);
			end if;
		end if;
	end if;
end process;

-- Message_counter
process(clk)
begin
	if clk'event and clk = '1' then
		if FIFO_wr_en = '1' then
			if FIFO_din(63 downto 60) = Message_addr then
				Message_count <= Message_count + '1';
			else
				Message_count <= (others => '0');
			end if;
		end if;
	end if;
end process;

-- Message_MSG
process(clk)
begin
	if clk'event and clk = '1' then
		if FIFO_wr_en = '1' then
			if FIFO_din(63 downto 60) = Message_addr and Message_count < Message_cycle then
				Message_tmp(AXI_data_width*(to_integer(unsigned(Message_count))+1) - 1 downto AXI_data_width*(to_integer(unsigned(Message_count)))) <= FIFO_din(AXI_data_width-1 downto 0);
			end if;
		end if;
	end if;
end process;

-- ctV_counter
process(clk)
begin
	if clk'event and clk = '1' then
		if FIFO_wr_en = '1' then
			if FIFO_din(63 downto 60) = ctV_addr then
				ctV_count <= ctV_count + '1';
			else
				ctV_count <= (others => '0');
			end if;
		end if;
	end if;
end process;

-- ctV_MSG
process(clk)
begin
	if clk'event and clk = '1' then
		if FIFO_wr_en = '1' then
			if FIFO_din(63 downto 60) = ctV_addr and ctV_count < ctV_cycle then
				ctV_tmp(AXI_data_width*(to_integer(unsigned(ctV_count))+1) - 1 downto AXI_data_width*(to_integer(unsigned(ctV_count)))) <= FIFO_din(AXI_data_width-1 downto 0);
			end if;
		end if;
	end if;
end process;


---- FirstPart_counter
--process(clk)
--begin
--	if clk'event and clk = '1' then
--		if FIFO_rd_en = '1' then
--			if FIFO_din(63 downto 60) = PolyA_addr then
--				PolyA_count <= PolyA_count + '1';
--			else
--				PolyA_count <= (others => '0');
--			end if;
--		end if;
--	end if;
--end process;
--
---- FirstPart_MSG
--process(clk)
--begin
--	if clk'event and clk = '1' then
--		if FIFO_rd_en = '1' then
--			if FIFO_din(63 downto 60) = PolyA_addr and PolyA_count < PolyA_cycle then
--				PolyA_tmp(AXI_data_width*(unsigned(PolyA_count)+1) - 1 downto AXI_data_width*(unsigned(PolyA_count))) <= FIFO_din;
--			end if;
--		end if;
--	end if;
--end process;


for i in range(

select FIFO_dout with 

	case pointer is
		when "00000001" => 
			FIFO_dout <= FirstPart(AXI_bus_width*(i+1)-1 downto AXI_bus_width*(i))
		


end a1;
