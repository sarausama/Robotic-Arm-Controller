library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Grappler IS Port
(
 Fully_extended                              : in std_logic_vector(3 downto 0); -- 4-bit input (state of extender)--
 clk_input, rst_n, Toggle          				: IN std_logic; --clock, reset and toggle inputs--
 state         										: OUT std_logic --output of the state of grappler (0 for closed and 1 for open)--
 );
END ENTITY;

 Architecture SM of Grappler is

TYPE STATE_NAMES IS (opened, closed);   -- opened and closed as my state names--
SIGNAL current_state, next_state	: STATE_NAMES:=closed;     	-- currnet and next states signals--

--This is NOT a state machine as it doesn't depend on the clock and it also only has two states--

BEGIN
Register_Section: PROCESS (rst_n, Toggle)  -- register section--
BEGIN
	IF (rst_n = '0') THEN
		current_state <= closed; -- if reset is active, current state is reset to closed--
	ELSIF(falling_edge(Toggle)) THEN 
		current_state <= next_State; -- the current state gets updated when the button is clicked
	END IF;
END PROCESS;
	
Transition_Section: PROCESS (Fully_extended, Toggle, current_state) --transition section--

BEGIN
     CASE current_state IS
          WHEN opened => --current state is opened--
				IF(Fully_extended="1111" AND Toggle ='1') THEN -- if it's fully extended and toggle is on--
					next_state <= closed; -- next state is the opposite of the current state (current state only gets updated when it's the falling edge of the button)--
				ELSE
					next_state <= opened; --next state is the same as current state--
				END IF;
			WHEN closed =>	 --current state is closed--
				IF(Fully_extended="1111" AND Toggle ='1') THEN -- if it's fully extended and toggle is on--
					next_state <= opened; -- next state is the opposite of the current state (current state only gets updated when it's the falling edge of the button)--
				ELSE
					next_state <= closed; --next state is the same as current state--
				END IF;
 	END CASE;
 END PROCESS; 
  
Decoder_Section: PROCESS (current_state) --decoder section--

BEGIN
     CASE current_state IS
         WHEN opened =>	--if current state is opened--
			state <= '1'; --grappler should be on--
			
         WHEN closed =>	--if current state is closed-- 
			state <= '0'; --grappler is off--	
  END CASE; 
 END PROCESS;
 END ARCHITECTURE SM;