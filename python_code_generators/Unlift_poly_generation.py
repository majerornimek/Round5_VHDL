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

def generate_mux_input(num_of_elements, pointer_width ):
    """
    Function to generate mux code. for output
    :param data_read_clock_cycles: Three elemental list containing number of clock cycles needed for data read for
        the following ports:  first_part, second_part, dec_msg,
    :param AXI_width: The width of AXI output bus
    :param pointer_width: The number of bits for storing addres pointer
    :return: Text
    """
    output_signal_name  = "sub_element <= "
    first_part_signal   = "PolyA("
    #AXI_width_constant  = "AXI_size"
    print("---==========   InPUT Pointer  ================")
    print("process(clk)")
    print("begin")
    print(" if clk'event and clk = '1' then")
    print("     case input_pointer is\n")
    out_clk = 0
    for i in range(1, num_of_elements+1):
        line = ""
        line = "        when \"" + str(to_std_logic_vector(i,pointer_width)) + "\" => \n"
        line += output_signal_name + first_part_signal + str(num_of_elements-i) + ");"
        print(line)
    print("         when others =>")
    print("             "+output_signal_name+"(others => '0');")
    print("     end case;")
    print(" end if;")
    print("end process;")


def generate_mux_output(num_of_elements, pointer_width ):
    """
    Function to generate mux code. for output
    :param data_read_clock_cycles: Three elemental list containing number of clock cycles needed for data read for
        the following ports:  first_part, second_part, dec_msg,
    :param AXI_width: The width of AXI output bus
    :param pointer_width: The number of bits for storing addres pointer
    :return: Text
    """
    output_signal_name  = "sub_element <= "
    first_part_signal   = "LongRes("
    #AXI_width_constant  = "AXI_size"
    print("---==========   OutPUT Pointer  ================")
    print("process(clk)")
    print("begin")
    print(" if clk'event and clk = '1' then")
    print("     case input_pointer is\n")
    out_clk = 0
    for i in range(2, num_of_elements+2):
        line = ""
        line = "        when \"" + str(to_std_logic_vector(i,pointer_width)) + "\" => \n"
        line += first_part_signal + str(num_of_elements-i+1) + ") <= " + "sub_result;"
        print(line)
    print("         when others =>")
    print("     end case;")
    print(" end if;")
    print("end process;")

if __name__ == "__main__":

    generate_mux_input(1019,10)
    generate_mux_output(1019,10)