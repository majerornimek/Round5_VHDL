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
    input_clock_cycles = [0,0,0,0,0,0] # last 3 for decryption input


    #Sigma
    input_clock_cycles[0] = math.ceil((param_table[4])/AXI_width)
    #PolyB input
    input_clock_cycles[1] = math.ceil(((param_table[0]+1)*param_table[2])/AXI_width)
    #RHO
    input_clock_cycles[2] = math.ceil((param_table[4])/AXI_width)
    #Message_input
    input_clock_cycles[3] = math.ceil(param_table[4]/AXI_width)
    #ctV_input
    input_clock_cycles[4] = math.ceil((param_table[4]*param_table[3])/AXI_width)
    #sk_input
    input_clock_cycles[5] = math.ceil(param_table[4]/AXI_width)

    output_clock_cycles = [0,0,0]

    # Dec_Msg_output
    output_clock_cycles[2] = math.ceil(param_table[4]/AXI_width)
    # SecondPart_output
    output_clock_cycles[1] = math.ceil((param_table[4]*param_table[3])/AXI_width)
    #FirstPart_output
    output_clock_cycles[0] = math.ceil((param_table[0]*param_table[2])/AXI_width)

    SHAKE_out_cycles = [0, 0, 0]

    #PolyA
    SHAKE_out_cycles[0] = math.ceil((param_table[0]*param_table[1])/64)
    #PolyR
    SHAKE_out_cycles[1] = math.ceil((param_table[0]*2)/64)
    SHAKE_out_cycles[2] = SHAKE_out_cycles[1]

    return input_clock_cycles, output_clock_cycles, SHAKE_out_cycles

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
    print("---==========   OUTPUT  ================")
    print("process(clk)")
    print("begin")
    print(" if clk'event and clk = '1' then")
    print("     case output_pointer is\n")
    out_clk = 0
    for i in range(0, data_read_clock_cycles[0]):
        line = ""
        line = "        when \"" + str(to_std_logic_vector(i,pointer_width)) + "\" => \n"
        line += output_signal_name + first_part_signal + str((i+1-out_clk)*int(AXI_width)-1) + " downto " + str((i-out_clk)*int(AXI_width)) + ");"
        print(line)
    out_clk += data_read_clock_cycles[0]

    for i in range(out_clk, out_clk+data_read_clock_cycles[1]):
        line = ""
        line = "        when \"" + str(to_std_logic_vector(i,pointer_width)) + "\" => \n"
        line += output_signal_name + second_part_signal + str((i+1-out_clk)*int(AXI_width)-1) + " downto " + str((i-out_clk)*int(AXI_width)) + ");"
        print(line)
    out_clk += data_read_clock_cycles[1]

    for i in range(out_clk,out_clk+data_read_clock_cycles[2]):
        line = ""
        line = "        when \"" + str(to_std_logic_vector(i,pointer_width)) + "\" => \n"
        line += output_signal_name + dec_msg_signal + str((i+1-out_clk)*int(AXI_width)-1) + " downto " + str((i-out_clk)*int(AXI_width)) + ");"
        print(line)
    print("         when others =>")
    print("     end case;")
    print(" end if;")
    print("end process;")

def generate_mux_input(input_clock_cycle, AXI_width, pointer_width):
    input_signal_name = " <= FIFO_din;"
    PolyB_signal = "PolyB_tmp("
    Message_signal = "Message_tmp("
    ctV_signal ="ctV_tmp("
    # AXI_width_constant  = "AXI_size"

    sum_of_clock_cycles = input_clock_cycle[0]
    print("-----==========   INPUT ENC  ================")
    print("process(clk)")
    print("begin")
    print(" if clk'event and clk = '1' then")
    print("     case input_pointer is\n")
    #ENCRYPTION
    sum_of_clock_cycles = input_clock_cycle[0]
    for i in range(sum_of_clock_cycles, sum_of_clock_cycles + input_clock_cycle[1]):
        line = ""
        line = "        when \"" + str(to_std_logic_vector(i, pointer_width)) + "\" => \n"
        line += PolyB_signal + str((i + 1-sum_of_clock_cycles) * int(AXI_width) - 1) + " downto " + str(
            (i-sum_of_clock_cycles) * int(AXI_width)) + ")" + input_signal_name
        print(line)

    sum_of_clock_cycles += input_clock_cycle[1] + input_clock_cycle[2]

    for i in range(sum_of_clock_cycles, sum_of_clock_cycles + input_clock_cycle[3]):
        line = ""
        line = "        when \"" + str(to_std_logic_vector(i, pointer_width)) + "\" => \n"
        line += Message_signal + str((i + 1-sum_of_clock_cycles) * int(AXI_width) - 1) + " downto " + str(
            (i-sum_of_clock_cycles) * int(AXI_width)) + ")" + input_signal_name
        print(line)

    sum_of_clock_cycles += input_clock_cycle[3]

    print("--==========   INPUT DEC  ================")

    #sum_of_clock_cycles = input_clock_cycle[5]
    #DECRYPTION
    sum_of_clock_cycles += input_clock_cycle[5]
    for i in range(sum_of_clock_cycles, sum_of_clock_cycles + input_clock_cycle[1]):
        line = ""
        line = "        when \"" + str(to_std_logic_vector(i, pointer_width)) + "\" => \n"
        line += PolyB_signal + str((i + 1 - sum_of_clock_cycles) * int(AXI_width) - 1) + " downto " + str(
            (i - sum_of_clock_cycles) * int(AXI_width)) + ")" + input_signal_name
        print(line)

    sum_of_clock_cycles += input_clock_cycle[1]
    for i in range(sum_of_clock_cycles, sum_of_clock_cycles + input_clock_cycle[4]):
        line = ""
        line = "    when \"" + str(to_std_logic_vector(i, pointer_width)) + "\" => \n"
        line += ctV_signal + str((i + 1-sum_of_clock_cycles) * int(AXI_width) - 1) + " downto " + str(
            (i-sum_of_clock_cycles) * int(AXI_width)) + ")" + input_signal_name
        print(line)

    sum_of_clock_cycles += input_clock_cycle[4]

    print("         when others =>")
    print("     end case;")
    print(" end if;")
    print("end process;")


def generate_SHAKE_mux_output(input_clock_cycle, AXI_width, pointer_width):
    input_signal_name = " <= S_FIFO_dout;"
    PolyA_signal = "PolyA_tmp("
    PolyR_signal = "PolyR_tmp("
    # AXI_width_constant  = "AXI_size"

    sum_of_clock_cycles = pow(2,pointer_width-2)
    print("-----==========   SHAKE OUPUT ENC  ================")
    print("process(clk)")
    print("begin")
    print(" if clk'event and clk = '1' then")
    print("     case Extended_SHAKE_output_pointer is\n")
    # ENCRYPTION
    for i in range(sum_of_clock_cycles, sum_of_clock_cycles+input_clock_cycle[0]):
        line = ""
        line = "        when \"" + str(to_std_logic_vector(i, pointer_width)) + "\" => \n"
        line += PolyA_signal + str((i + 1-sum_of_clock_cycles) * int(AXI_width) - 1) + " downto " + str(
            (i-sum_of_clock_cycles) * int(AXI_width)) + ")" + input_signal_name
        print(line)

    sum_of_clock_cycles = pow(2,pointer_width-3)

    for i in range(sum_of_clock_cycles, sum_of_clock_cycles + input_clock_cycle[1]):
        line = ""
        line = "        when \"" + str(to_std_logic_vector(i, pointer_width)) + "\" => \n"
        line += PolyR_signal + str((i + 1 - sum_of_clock_cycles) * int(AXI_width) - 1) + " downto " + str(
            (i - sum_of_clock_cycles) * int(AXI_width)) + ")" + input_signal_name
        print(line)
    print("-----============  SHAKE OUTPUT DEC ============")
    sum_of_clock_cycles = pow(2,pointer_width-1)
    for i in range(sum_of_clock_cycles, sum_of_clock_cycles + input_clock_cycle[2]):
        line = ""
        line = "        when \"" + str(to_std_logic_vector(i, pointer_width)) + "\" => \n"
        line += PolyR_signal + str((i + 1 - sum_of_clock_cycles) * int(AXI_width) - 1) + " downto " + str(
            (i - sum_of_clock_cycles) * int(AXI_width)) + ")" + input_signal_name
        print(line)
    print("         when others =>")
    print("     end case;")
    print(" end if;")
    print("end process;")


if __name__ == "__main__":

    print(to_std_logic_vector(3,8))

    clock_cycles = [10,20,30]
    params = [1018, 14, 9, 4, 256]
    AXI_w = 64
    c_in, c_out, SHAKE_out = generate_clock_cycle_table(params, AXI_w)
    print(c_in, c_out, SHAKE_out)
    generate_mux_input(c_in, AXI_w, 10)
    generate_mux_output(c_out, AXI_w, 8)
    generate_SHAKE_mux_output(SHAKE_out,64,11)