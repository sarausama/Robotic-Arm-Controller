library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity U_D_Bin_Counter4bit is
	port
	(
			CLK                 : in std_logic := '0';--clock input--
			RESET_n             : in std_logic := '0';--reset input--
			CLK_EN              : in std_logic := '0';--enable input--
			UP1_DOWN0           : in std_logic := '0';-- 1 for up and 0 for down--
			COUNTER_BITS        : out std_logic_vector(3 downto 0)-- 4-bit output--
	);

end entity;

	architecture one of U_D_Bin_Counter4bit is
	signal ud_bin_counter               : UNSIGNED(3 downto 0); -- signal for storing the value of the number as an unsigned number--


begin

--start of the process--
process(CLK, RESET_n) is
begin
	if(RESET_n = '0') then
			ud_bin_counter <= "0000"; --resets the value of the output if reset is activated--
	elsif (rising_edge(CLK)) then
		if(( UP1_DOWN0 ='1') AND (CLK_EN = '1')) then
			ud_bin_counter <= (ud_bin_counter + 1); -- adds 1 to the number because we are counting up and enable is on--
		elsif(( UP1_DOWN0 ='0') AND (CLK_EN = '1')) then
			ud_bin_counter <= (ud_bin_counter - 1); -- subtracts 1 from the number because we are counting down and enable is on --
		end if;
	end if;
	
end process;
COUNTER_BITS <= std_logic_vector(ud_bin_counter); -- assigns the value of ud_bin_counter as an std_logic_vector to the output

end;
