import math

def to_std_logic_vector(number, length):
    """
    Generate logic vector of given length representing selected number
    :param number: Number to be converted to std_logic_vector
    :param length: Length of std_logic_vector
    :return:
    """
    res = bin(number)[2:]
    return '0'*(length- len(res)) + res

def generate_clock_cycle_table(param_table, AXI_width):
    """
    Generate table with numbers of clock cycle needed for read and write for selected ports of arithmetic module
    :param param_table: Table with [degree, q_bits, p_bits, t_bits, MessageLen]
    :param AXI_width: The width of AXI output bus
    :return: Tuple of tables containing numbers of clock cycles for data write and read from FPGA
    """
    input_clock_cycles = [0,0,0,0,0] # last 3 for decryption input

    #PolyA input
    input_clock_cycles[0] = math.ceil((param_table[0]*param_table[1])/AXI_width)
    #PolyB input
    input_clock_cycles[1] = math.ceil(((param_table[0]+1)*param_table[2])/AXI_width)
    #PolyR_input
    input_clock_cycles[2] = math.ceil((param_table[0]*2)/AXI_width)
    #Message_input
    input_clock_cycles[3] = math.ceil(param_table[4]/AXI_width)
    #ctV_input
    input_clock_cycles[4] = math.ceil((param_table[4]*param_table[3])/AXI_width)

    output_clock_cycles = [0,0,0]

    # Dec_Msg_output
    output_clock_cycles[2] = math.ceil(param_table[4]/AXI_width)
    # SecondPart_output
    output_clock_cycles[1] = math.ceil((param_table[4]*param_table[3])/AXI_width)
    #FirstPart_output
    output_clock_cycles[0] = math.ceil((param_table[0]*param_table[2])/AXI_width)

    return input_clock_cycles, output_clock_cycles

def generate_mux_output(data_read_clock_cycles, AXI_width, pointer_width ):
    """
    Function to generate mux code. for output
    :param data_read_clock_cycles: Three elemental list containing number of clock cycles needed for data read for
        the following ports:  first_part, second_part, dec_msg,
    :param AXI_width: The width of AXI output bus
    :param pointer_width: The number of bits for storing addres pointer
    :return: Text
    """
    output_signal_name  = "FIFO_dout <= "
    dec_msg_signal      = "dec_msg_tmp("
    second_part_signal  = "SecondPart_tmp("
    first_part_signal   = "FirstPart_tmp("
    #AXI_width_constant  = "AXI_size"
    print("==========   OUTPUT  ================")
    print("case output_pointer is\n")
    out_clk = 0
    for i in range(0, data_read_clock_cycles[0]):
        line = ""
        line = "    when \"" + str(to_std_logic_vector(i,pointer_width)) + "\" => \n"
        line += output_signal_name + first_part_signal + str((i+1-out_clk)*int(AXI_width)-1) + " downto " + str((i-out_clk)*int(AXI_width)) + ");"
        print(line)
    out_clk += data_read_clock_cycles[0]

    for i in range(out_clk, out_clk+data_read_clock_cycles[1]):
        line = ""
        line = "    when \"" + str(to_std_logic_vector(i,pointer_width)) + "\" => \n"
        line += output_signal_name + second_part_signal + str((i+1-out_clk)*int(AXI_width)-1) + " downto " + str((i-out_clk)*int(AXI_width)) + ");"
        print(line)
    out_clk += data_read_clock_cycles[1]

    for i in range(out_clk,out_clk+data_read_clock_cycles[2]):
        line = ""
        line = "    when \"" + str(to_std_logic_vector(i,pointer_width)) + "\" => \n"
        line += output_signal_name + dec_msg_signal + str((i+1-out_clk)*int(AXI_width)-1) + " downto " + str((i-out_clk)*int(AXI_width)) + ");"
        print(line)
    print("     when others =>")
    print("end case;")

def generate_mux_input(input_clock_cycle, AXI_width, pointer_width):
    input_signal_name = " <= FIFO_din("
    PolyA_signal = "PolyA_poly("
    PolyB_signal = "PolyB_poly("
    PolyR_signal = "PolyR_poly("
    Message_signal = "Message_poly("
    ctV_signal ="ctV_poly("
    # AXI_width_constant  = "AXI_size"

    sum_of_clock_cycles = input_clock_cycle[0]
    print("-----==========   INPUT ENC  ================")
    print("case input_pointer is\n")
    #ENCRYPTION
    for i in range(0, input_clock_cycle[0]):
        line = ""
        line = "    when \"" + str(to_std_logic_vector(i, pointer_width)) + "\" => \n"
        line += PolyA_signal + str((input_clock_cycle[0]-i)) + ")" + input_signal_name + str(input_clock_cycle[1]) + " downto 0);"
        print(line)


    for i in range(input_clock_cycle[0], sum_of_clock_cycles + input_clock_cycle[0]):
        line = ""
        line = "    when \"" + str(to_std_logic_vector(i, pointer_width)) + "\" => \n"
        line += PolyB_signal + str((sum_of_clock_cycles+input_clock_cycle[0]-i)) + ")" + input_signal_name + str(input_clock_cycle[2]) + " downto 0);"
        print(line)

    sum_of_clock_cycles += input_clock_cycle[0]

    for i in range(sum_of_clock_cycles, sum_of_clock_cycles + input_clock_cycle[2]):
        line = ""
        line = "    when \"" + str(to_std_logic_vector(i, pointer_width)) + "\" => \n"
        line += PolyR_signal + str((sum_of_clock_cycles+input_clock_cycle[0]-i)) + ")" + input_signal_name + str(1) + " downto 0);"
        print(line)

    sum_of_clock_cycles += input_clock_cycle[0]

    for i in range(sum_of_clock_cycles, sum_of_clock_cycles + int(input_clock_cycle[4]/64)):
        line = ""
        line = "    when \"" + str(to_std_logic_vector(i, pointer_width)) + "\" => \n"
        line += Message_signal + str((i + 1-sum_of_clock_cycles) * int(AXI_width) - 1) + " downto " + str(
            (i-sum_of_clock_cycles) * int(AXI_width)) + ")" + input_signal_name
        print(line)

    sum_of_clock_cycles +=  input_clock_cycle[4]/64

    print("--==========   INPUT DEC  ================")

    #sum_of_clock_cycles = input_clock_cycle[5]
    #DECRYPTION
    for i in range(sum_of_clock_cycles, sum_of_clock_cycles + input_clock_cycle[0]):
        line = ""
        line = "    when \"" + str(to_std_logic_vector(i, pointer_width)) + "\" => \n"
        line += PolyB_signal + str((sum_of_clock_cycles+input_clock_cycle[0]-i)) + ")" + input_signal_name + str(input_clock_cycle[2]) + " downto 0);"
        print(line)
    sum_of_clock_cycles += input_clock_cycle[1]

    for i in range(sum_of_clock_cycles, sum_of_clock_cycles + input_clock_cycle[2]):
        line = ""
        line = "    when \"" + str(to_std_logic_vector(i, pointer_width)) + "\" => \n"
        line += PolyR_signal + str((sum_of_clock_cycles + input_clock_cycle[0] - i)) + ")" + input_signal_name + str(
            1) + " downto 0);"
        print(line)
    sum_of_clock_cycles += input_clock_cycle[2]

    for i in range(sum_of_clock_cycles, sum_of_clock_cycles + input_clock_cycle[4]):
        line = ""
        line = "    when \"" + str(to_std_logic_vector(i, pointer_width)) + "\" => \n"
        line += ctV_signal + str((i + 1-sum_of_clock_cycles) * int(AXI_width) - 1) + " downto " + str(
            (i-sum_of_clock_cycles) * int(AXI_width)) + ")" + input_signal_name
        print(line)
    print("     when others =>")
    print("end case;")

if __name__ == "__main__":

    print(to_std_logic_vector(3,8))

    clock_cycles = [10,20,30]
    params = [618, 11, 8, 4, 128]
    AXI_w = 64
    c_in, c_out = generate_clock_cycle_table(params, AXI_w)
    print(c_in)
    generate_mux_input(params, AXI_w, 11)
    generate_mux_output(c_out, AXI_w, 8)