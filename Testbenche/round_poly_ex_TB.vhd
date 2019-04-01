library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

library work;
use work.Round5_constants.all;

entity round_poly_ex_tb is
end entity;

architecture a1 of round_poly_ex_tb is

component round_poly_ex is
	port(
		PolyA		: in q_bitsPoly(PolyDegree downto 0);
		InputConst	: in std_logic_vector(6 downto 0);
		clk 		: in std_logic;
		PolyEnc1	: out P_bitsPoly(PolyDegree downto 0);
		PolyEnc2	: out t_bitsPoly(PolyDegree downto 0);
		PolyDec1	: out std_logic_vector(PolyDegree downto 0)--t_bitsPoly(PolyDegree-1 downto 0)
	);
	
end component;

signal clk : std_logic;

constant CLK_PERIOD : time := 10 ps;
signal PolyA_tmp : q_bitsPoly(PolyDegree downto 0);
signal start_tmp : std_logic;
signal P1 : P_bitsPoly(PolyDegree downto 0);
signal P2 : t_bitsPoly(PolyDegree downto 0);
signal P3 : std_logic_vector(PolyDegree downto 0);


type input_array is array(PolyDegree-1 downto 0) of integer;
begin 

   clk_process :process
   begin
        clk <= '0';
        wait for CLK_PERIOD/2;  --for half of clock period clk stays at '0'.
        clk <= '1';
        wait for CLK_PERIOD/2;  --for next half of clock period clk stays at '1'.
   end process;

   uut: round_poly_ex port map(
		PolyA		=> PolyA_tmp,
		InputMask	=> b_mask_enc1,
		InputConst	=> r_const_enc1,
		clk 		=> clk,
		PolyEnc1	=> P1,
		PolyEnc2	=> P2,
		PolyDec1	=> P3
   );
   
process
	procedure check_round	( 	constant inV1	: in input_array; -- v1
										constant outLong	: in input_array) is
		variable res: input_array;
		
	begin
		GG: for i in PolyDegree-1 downto 0 loop
			PolyA_tmp(i) <= std_logic_vector(to_unsigned(inV1(i), a_bits_enc1));
		end loop GG;
		
		wait for CLK_PERIOD;
		start_tmp <= '1';
		wait for CLK_PERIOD*(PolyDegree+5);
		start_tmp <= '0';
		wait for  CLK_PERIOD;
		
		RR: for i in PolyDegree-1 downto 0 loop
			res(i) := to_integer(unsigned(P1(i)));

		end loop RR;
		assert res = outLong 
		report 	"Unexpected result: " --&
--				"IN1 = " & integer'image(in1) & "; " &
--				"IN2 = " & integer'image(in2) & "; " &
--				"MUL = " & integer'image(res) & "; " &
--				"MUL_expected = " & integer'image(res_ex)
		severity error;
	end procedure check_round;
begin
	--check_unlift((86, 750, 1749, 647, 811, 2000, 416, 60, 1799, 786, 564, 1152, 484, 178, 823,0), (1962, 1212, 1511, 864, 53, 101, 1733, 1673, 1922, 1136, 572, 1468, 984, 806, 2031,0));
	--check_unlift((18, 224, 180, 118, 5, 122, 108, 18, 228, 21, 146, 214, 106, 251, 3,0),(238, 14, 90, 228, 223, 101, 249, 231, 3, 238, 92, 134, 28, 33, 30,0));
	check_round(
	(589, 1400, 1227, 1545, 1045, 1921, 109, 1569, 108, 1754, 1556, 14, 1409, 237, 1106, 1922, 1259, 1966, 583, 747, 510, 1545, 1994, 35, 1613, 1439, 1064, 1147, 730, 1932, 1819, 1580, 1517, 324, 1459, 161, 600, 711, 530, 503, 784, 912, 14, 562, 739, 1649, 609, 346, 1695, 405, 928, 2034, 1988, 1541, 1761, 156, 833, 1503, 112, 1486, 854, 588, 871, 616, 127, 1865, 1837, 2034, 961, 1861, 193, 521, 1206, 471, 788, 517, 1436, 603, 1692, 1558, 1329, 1576, 1641, 2003, 1193, 1339, 1665, 1553, 58, 2003, 1981, 256, 267, 1760, 690, 1879, 1954, 1905, 1516, 1834, 284, 218, 421, 1, 1030, 416, 97, 121, 1175, 1816, 1663, 1754, 249, 1462, 1305, 2029, 1977, 1497, 1713, 669, 642, 593, 1462, 1085, 1306, 1498, 547, 1385, 1961, 1113, 910, 1786, 432, 564, 825, 658, 763, 1529, 460, 901, 1815, 1810, 956, 853, 1824, 361, 558, 1973, 1948, 1687, 1673, 45, 1548, 847, 1220, 1873, 578, 482, 1035, 760, 1383, 1224, 1907, 1287, 918, 897, 1454, 573, 2017, 1548, 317, 641, 1019, 525, 1286, 48, 1132, 1227, 1907, 75, 1180, 366, 1871, 1568, 1658, 718, 110, 107, 1256, 536, 1788, 360, 792, 257, 928, 1872, 831, 42, 610, 1724, 286, 908, 1266, 326, 1827, 1444, 1927, 889, 1405, 1270, 1757, 1617, 296, 1753, 1628, 1144, 1543, 1529, 1209, 808, 1399, 443, 1564, 1381, 323, 1277, 91, 1269, 1553, 453, 1466, 1443, 443, 2042, 1923, 1559, 834, 1897, 281, 251, 312, 455, 1510, 563, 260, 1714, 1337, 348, 1691, 1624, 1601, 1027, 1552, 914, 746, 630, 1287, 66, 467, 1932, 1053, 513, 310, 1164, 612, 93, 488, 1945, 40, 882, 506, 221, 1831, 547, 1158, 1398, 1147, 1781, 1051, 1608, 1925, 1870, 1404, 922, 1413, 2, 876, 1252, 591, 301, 818, 995, 1659, 854, 740, 1391, 1225, 1420, 1842, 714, 1478, 1154, 1619, 286, 2029, 273, 516, 1754, 1980, 1636, 13, 243, 43, 1873, 151, 1659, 228, 437, 351, 463, 1826, 379, 881, 1155, 1658, 1646, 576, 1771, 1410, 447, 1674, 480, 1423, 35, 1916, 746, 1799, 721, 138, 1536, 280, 1955, 853, 663, 47, 1734, 653, 801, 561, 1518, 1401, 587, 518, 41, 214, 239, 1932, 28, 1781, 1377, 1251, 260, 958, 64, 380, 2015, 163, 171, 1351, 15, 129, 850, 683, 252, 1623, 100, 1245, 443, 1658, 874, 1547, 1312, 1437, 1730, 510, 635, 1391, 230, 1197, 1130, 740, 1097, 1644, 1145, 1625, 1410, 525, 1245, 1124, 1523, 1823, 1642, 1356, 1708, 133, 1811, 723, 1565, 1241, 928, 185, 1168, 2041, 259, 653, 113, 817, 1875, 1490, 1005, 622, 2032, 919, 734, 133, 1998, 93, 1910, 983, 484, 1445, 276, 226, 1090, 1161, 409, 1928, 1276, 1580, 841, 1494, 716, 1613, 1838, 1349, 518, 1755, 2014, 692, 1783, 668, 1282, 1772, 1008, 1343, 358, 1249, 1906, 108, 285, 1043, 1522, 1167, 1901, 15, 1542, 1866, 1998, 233, 1055, 959, 993, 1301, 1421, 2002, 962, 662, 731, 1299, 728, 384, 1510, 130, 503, 1031, 346, 1022, 1404, 152, 1257, 158, 1734, 1840, 671, 833, 733, 1232, 1035, 139, 680, 1494, 1830, 642, 567, 1704, 1019, 1370, 1874, 495, 1122, 1380, 237, 1851, 332, 336, 1853, 1470, 1383, 1242, 279, 1200, 1431, 864, 367, 973, 297, 269, 1708, 852, 880, 1965, 663, 228, 40, 837, 1359, 446, 306, 1262, 1573, 784, 186, 1302, 344, 1185, 342, 388, 892, 1887, 1216, 1602, 1498, 79, 347, 1643, 1162, 929, 434, 1914, 674, 903, 1709, 1931, 1904, 283, 1734, 367, 1991, 504, 667, 1135, 1951, 1873, 29, 1872, 1061, 890, 436, 2028, 995, 459, 602, 674, 939, 1509, 830, 1724, 42, 1224, 1003, 1305, 342, 1355, 804, 1099, 52, 677, 181, 1629, 2017, 1633, 339, 1316, 352, 247, 9, 1072, 1314, 1512, 1077, 87, 220, 1067, 124, 1614, 1291, 776, 1398),
	(74, 175, 153, 193, 131, 240, 14, 196, 14, 219, 195, 2, 176, 30, 138, 240, 157, 246, 73, 93, 64, 193, 249, 4, 202, 180, 133, 143, 91, 242, 227, 198, 190, 41, 182, 20, 75, 89, 66, 63, 98, 114, 2, 70, 92, 206, 76, 43, 212, 51, 116, 254, 249, 193, 220, 20, 104, 188, 14, 186, 107, 74, 109, 77, 16, 233, 230, 254, 120, 233, 24, 65, 151, 59, 99, 65, 180, 75, 212, 195, 166, 197, 205, 250, 149, 167, 208, 194, 7, 250, 248, 32, 33, 220, 86, 235, 244, 238, 190, 229, 36, 27, 53, 0, 129, 52, 12, 15, 147, 227, 208, 219, 31, 183, 163, 254, 247, 187, 214, 84, 80, 74, 183, 136, 163, 187, 68, 173, 245, 139, 114, 223, 54, 71, 103, 82, 95, 191, 58, 113, 227, 226, 120, 107, 228, 45, 70, 247, 244, 211, 209, 6, 194, 106, 153, 234, 72, 60, 129, 95, 173, 153, 238, 161, 115, 112, 182, 72, 252, 194, 40, 80, 127, 66, 161, 6, 142, 153, 238, 9, 148, 46, 234, 196, 207, 90, 14, 13, 157, 67, 224, 45, 99, 32, 116, 234, 104, 5, 76, 216, 36, 114, 158, 41, 228, 181, 241, 111, 176, 159, 220, 202, 37, 219, 204, 143, 193, 191, 151, 101, 175, 55, 196, 173, 40, 160, 11, 159, 194, 57, 183, 180, 55, 255, 240, 195, 104, 237, 35, 31, 39, 57, 189, 70, 33, 214, 167, 44, 211, 203, 200, 128, 194, 114, 93, 79, 161, 8, 58, 242, 132, 64, 39, 146, 77, 12, 61, 243, 5, 110, 63, 28, 229, 68, 145, 175, 143, 223, 131, 201, 241, 234, 176, 115, 177, 0, 110, 157, 74, 38, 102, 124, 207, 107, 93, 174, 153, 178, 230, 89, 185, 144, 202, 36, 254, 34, 65, 219, 248, 205, 2, 30, 5, 234, 19, 207, 29, 55, 44, 58, 228, 47, 110, 144, 207, 206, 72, 221, 176, 56, 209, 60, 178, 4, 240, 93, 225, 90, 17, 192, 35, 244, 107, 83, 6, 217, 82, 100, 70, 190, 175, 73, 65, 5, 27, 30, 242, 4, 223, 172, 156, 33, 120, 8, 48, 252, 20, 21, 169, 2, 16, 106, 85, 32, 203, 13, 156, 55, 207, 109, 193, 164, 180, 216, 64, 79, 174, 29, 150, 141, 93, 137, 206, 143, 203, 176, 66, 156, 141, 190, 228, 205, 170, 214, 17, 226, 90, 196, 155, 116, 23, 146, 255, 32, 82, 14, 102, 234, 186, 126, 78, 254, 115, 92, 17, 250, 12, 239, 123, 61, 181, 35, 28, 136, 145, 51, 241, 160, 198, 105, 187, 90, 202, 230, 169, 65, 219, 252, 87, 223, 84, 160, 222, 126, 168, 45, 156, 238, 14, 36, 130, 190, 146, 238, 2, 193, 233, 250, 29, 132, 120, 124, 163, 178, 250, 120, 83, 91, 162, 91, 48, 189, 16, 63, 129, 43, 128, 176, 19, 157, 20, 217, 230, 84, 104, 92, 154, 129, 17, 85, 187, 229, 80, 71, 213, 127, 171, 234, 62, 140, 173, 30, 231, 42, 42, 232, 184, 173, 155, 35, 150, 179, 108, 46, 122, 37, 34, 214, 107, 110, 246, 83, 29, 5, 105, 170, 56, 38, 158, 197, 98, 23, 163, 43, 148, 43, 49, 112, 236, 152, 200, 187, 10, 43, 205, 145, 116, 54, 239, 84, 113, 214, 241, 238, 35, 217, 46, 249, 63, 83, 142, 244, 234, 4, 234, 133, 111, 55, 254, 124, 57, 75, 84, 117, 189, 104, 216, 5, 153, 125, 163, 43, 169, 101, 137, 7, 85, 23, 204, 252, 204, 42, 165, 44, 31, 1, 134, 164, 189, 135, 11, 28, 133, 16, 202, 161, 97, 175)
	);
	
end process;
end a1;