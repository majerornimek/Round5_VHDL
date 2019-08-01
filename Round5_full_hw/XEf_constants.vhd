library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

library work;
use work.XEf_constants_P5_5d.all -- wybor algo


package XEf_constants is  

type RTab is array(natural range<>) of std_logic_vector(63 downto 0);
type BitTab is array(natural range<>) of std_logic_vector(7 downto 0);


constant fixerr_unpack 	: fu := XEf_fixerr_unpack;
constant fixerr_tab	: ff := XEf_fixerr_tab;
constant reduce_poly	: cr := XEf_reduce_poly;
constant compute_pack 	: cp := XEf_compute_pack;

end package;
