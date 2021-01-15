library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Bidir_shift_reg is
	port
	(
			CLK                 : in std_logic := '0';
			RESET_n             : in std_logic := '0';
			CLK_EN              : in std_logic := '0';
			LEFT0_RIGHT1        : in std_logic := '0';
			REG_BITS            : out std_logic_vector(7 downto 0)
	);

end entity;

	architecture one of Bidir_shift_reg is
	signal sreg                  : std_logic_vector(7 downto 0);


begin

process(CLK, RESET_n) is
begin
	if(RESET_n = '0') then
			sreg <= "00000000";
	elsif (rising_edge(CLK) AND (CLK_EN = '1')) then
		if(LEFT0_RIGHT1 = '1') then  -- True for right shift
			sreg (7 downto 0) <='1' & sreg(7 downto 1); -- right-shift of bits
		elsif(LEFT0_RIGHT1 = '0') then
			sreg (7 downto 0) <= sreg(6 downto 0) & '0'; -- left-shift of bits
		end if;
	end if;
	
end process;
REG_BITS <= sreg;

end one;


