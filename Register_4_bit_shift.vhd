library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Register_4_bit_shift is
	port
	(
			CLK                 : in std_logic := '0';--clock input--
			RESET_n             : in std_logic := '0';--reset input--
			CLK_EN              : in std_logic := '0';--enable input--
			LEFT0_RIGHT1        : in std_logic := '0';--LEFT0_RIGHT1 input 0 for left and 1 for right--
			REG_BITS            : out std_logic_vector(3 downto 0) --4 bit output--
	);

end entity;

	architecture one of Register_4_bit_shift is
	signal sreg                  : std_logic_vector(3 downto 0); -- 4-bit signal--


begin

process(CLK, RESET_n) is -- Beginning of the process section--
begin
	if(RESET_n = '0') then
			sreg <= "0000"; --assigning "0000" to sreg because RESET_n is active--
	elsif (rising_edge(CLK) AND (CLK_EN = '1')) then
		if(LEFT0_RIGHT1 = '1') then  -- True for right shift
			sreg (3 downto 0) <='1' & sreg(3 downto 1); -- right-shift of bits
		elsif(LEFT0_RIGHT1 = '0') then -- True for left shift
			sreg (3 downto 0) <= sreg(2 downto 0) & '0'; -- left-shift of bits
		end if;
	end if;
	
end process;
REG_BITS <= sreg; -- assigning the value of sreg to REG_BITS--

end one;


