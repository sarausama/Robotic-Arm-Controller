library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Extender_toggle IS Port
(
 toggle, enable, rst_n           : in std_logic; -- button input, enable (the button actualy made a change in the state of extender) and reset input--
 output                          : out std_logic -- 1-bit output --
 );
END ENTITY;

architecture arc of Extender_toggle is

signal output_temp                     : std_logic; -- signal to store the output--

Begin

--process to implement the logic--
logic: PROCESS (toggle, rst_n)  -- takes in clock and reset --
Begin
	if(rst_n = '0') then 
		output_temp <= '0'; --resets the output if reset is active--
	elsif (falling_edge(toggle) AND enable ='1') then -- if it's falling edge of the button and it's enabled--
		output_temp <= NOT output_temp; -- the state becomes the opposite of its current value--
	END if;
End process;

output <= output_temp; -- assigns the value of the output_temp to the output--
END arc;