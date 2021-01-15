library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Compx4 is
	port
	(
		input_0, input_1	                              : in std_logic_vector(3 downto 0); -- 4-bit inputs --
		bit_out_less, bit_out_equal, bit_out_great		: out std_logic --less than, equal to, greater than--
	);
end entity;


architecture arc of Compx4 is

component Compx1
 	port (
		bit_0, bit_1		                  : in std_logic; -- inputs --
		less_out, equal_out, greater_out		: out std_logic --less than, equal to, greater than--
			);
end component;

signal bit_number_3_less, bit_number_3_equal, bit_number_3_great : std_logic; --signals for the 4th bit (most significant bit)--
signal bit_number_2_less, bit_number_2_equal, bit_number_2_great : std_logic; --signals for the 3th bit--
signal bit_number_1_less, bit_number_1_equal, bit_number_1_great : std_logic; --signals for the 2nd bit--
signal bit_number_0_less, bit_number_0_equal, bit_number_0_great : std_logic; --signals for the 1st bit (least significant bit)--


begin

	bit_number_3: Compx1 port map (input_0(3), input_1(3), bit_number_3_less, bit_number_3_equal, bit_number_3_great); --compares the 4th bit of both inputs--
	bit_number_2: Compx1 port map (input_0(2), input_1(2), bit_number_2_less, bit_number_2_equal, bit_number_2_great); --compares the 3rd bit of both inputs--
	bit_number_1: Compx1 port map (input_0(1), input_1(1), bit_number_1_less, bit_number_1_equal, bit_number_1_great); --compares the 2nd bit of both inputs--
	bit_number_0: Compx1 port map (input_0(0), input_1(0), bit_number_0_less, bit_number_0_equal, bit_number_0_great); --compares the 1st bit of both inputs--
	
	bit_out_less  <= bit_number_3_less OR                                                   --compares the most significant bit first--
						(bit_number_3_equal AND bit_number_2_less) OR                            --if the most significant bits are equal compare the second most significant bits--
						(bit_number_3_equal AND bit_number_2_equal AND bit_number_1_less) OR     --same pattern continues.....--
						(bit_number_3_equal AND bit_number_2_equal AND bit_number_1_equal AND bit_number_0_less);
						
	bit_out_equal <= bit_number_3_equal AND bit_number_2_equal AND bit_number_1_equal AND bit_number_0_equal; -- they are only equal if all bits are equal--
	
	bit_out_great <= bit_number_3_great OR 
						(bit_number_3_equal AND bit_number_2_great) OR                           --compares the most significant bit first--
						(bit_number_3_equal AND bit_number_2_equal AND bit_number_1_great) OR    --if the most significant bits are equal compare the second most significant bits--
						(bit_number_3_equal AND bit_number_2_equal AND bit_number_1_equal AND bit_number_0_great); --same pattern continues.....--
end arc;


