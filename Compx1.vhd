library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Compx1 is

	port
	(
		bit_0, bit_1		                  : in std_logic; -- inputs --
		less_out, equal_out, greater_out		: out std_logic --less than, equal to, greater than outputs--
	);

end entity;

architecture arc of Compx1 is


begin
   less_out <= (NOT bit_0) AND bit_1; -- it's only true when the first bit is 0 and the second bit is 1 (0 is less than 1)--
	equal_out <= (bit_0 AND bit_1) OR ((NOT bit_0) AND (NOT bit_1)); -- it's true when the first and second bits match--
	greater_out <= bit_0 AND (NOT bit_1); -- it's only true when the first bit is 1 and the second bit is 0 (1 is greater than 0)--
end arc;


