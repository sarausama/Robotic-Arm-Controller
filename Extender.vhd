library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Extender IS Port
(
 toggle, not_moving, clk, rst_n  : in std_logic; --toggle input (the button), not_moving input (from moving, is the arm moving?), clock and reset inputs
 output                          : out std_logic_vector(3 downto 0); -- 4-bit output (state of the extender)--
 extender_out                    : out std_logic -- is the extender_out (the output is used in moving)--
 );
END ENTITY;

 Architecture SM of Extender is
	component Register_4_bit_shift port --component for the 4-bit shift register--
	(
			CLK                 : in std_logic := '0'; --clock input--
			RESET_n             : in std_logic := '0'; --reset input--
			CLK_EN              : in std_logic := '0'; --enable input--
			LEFT0_RIGHT1        : in std_logic := '0'; -- 0 for left shift and 1 for right shift--
			REG_BITS            : out std_logic_vector(3 downto 0) -- 4-bit output--
	);
	end component;

		component Extender_toggle port --component for the extender_toggle--
	(
		 toggle, enable, rst_n           : in std_logic; --toggle button input, enable input, reset input--
		 output                          : out std_logic --output from extender_toggle (0 to retract and 1 to extend)--
	);
	end component;
	
TYPE STATE_NAMES IS (retracting, extending, fully_retracted, fully_extended);   -- the 4 states of the state machine -- 
SIGNAL current_state, next_state	:  STATE_NAMES;     	-- current and next state signals--
SIGNAL right_left           : std_logic; --signal to store whether it's retracted/retracting (0) or extended/extending(1)--
SIGNAL temp_output          : std_logic_vector (3 downto 0); -- 4-bit signal that stores the output (state of the extender)--
SIGNAL moving               : std_logic; -- signal to store whether my extender is moving or not (it's 1 if the arm is extending or retracting and it's 0 otherwise)--

BEGIN

Register_Section: PROCESS (clk, rst_n)  -- this process synchronizes the activity to the clock--
BEGIN
	IF (rst_n = '0') THEN
		current_state <= fully_retracted; -- if reset is activated, my current state is reset to fully_retracted--
	ELSIF(rising_edge(clk)) THEN --when it's a rising edge of the clock--
		current_state <= next_State; --current state gets updated--
	END IF;
END PROCESS;	

Transition_Section: PROCESS (right_left, current_state, temp_output) --transition section--
BEGIN
     CASE current_state IS
			WHEN fully_retracted => --current state is fully retracted--
				if(right_left = '1') THEN --if right_left is 1 the extender will start extending--
					next_State <= extending;
				ELSE
					next_State <= fully_retracted; -- if right_left is 0 the extender will remain fully retracted--
				END IF;
			WHEN fully_extended => --current state is fully extended--
				if(right_left = '0') THEN 
					next_State <= retracting; --since right_left is 0, extender should start retracting--
				ELSE
					next_State <= fully_extended; --otherwise it remains in the same state (fully_extended)--
				END IF;
			WHEN retracting => --current state is retracting--
				if(temp_output = "0000") THEN --if the output is 0000 that means that it reached full retraction--
					next_State <= fully_retracted;
				ELSE
					next_State <= retracting; -- otherwise it keeps retracting--
				END IF;
			WHEN extending => --current state is extending--
				if(temp_output = "1111") THEN --if it reached maximum extension--
					next_State <= fully_extended; -- next state is fully extended--
				ELSE
					next_State <= extending; --if it didn't reach maximum extension, it keeps extending--
				END IF;
	  END CASE;
 END PROCESS; 

--instance to take care of the button, if the arm is not moving and extender is not moving, enable is 1. right_left indicates the state 0 for retracted/retracting and 1 otherwise--
Toggle_inst: Extender_toggle port map(Toggle, not_moving AND (NOT moving), rst_n, right_left);	
--instance to shift right and left based on the value of right_left and it assigns the output to temp_output--
shift: Register_4_bit_shift port map(clk, rst_n, moving, right_left, temp_output(3 downto 0));
output <= temp_output; --assigning the value of temp_output to output--	

--The decoder section depends on the current state and the inputs so it's a mealy machine (I used it to reduce the delay)--
Decoder_Section: PROCESS (current_state, right_left, temp_output) --decoder_Section--
BEGIN
     CASE current_state IS
			WHEN fully_retracted => --current state is fully retracted--
				if(right_left = '1') THEN --if right_left is 1 the extender will start extending--
					moving <= '1'; --moving is 1 because the extender is extending hence moving--
					extender_out <='1'; --Since it's moving extender is out--
				ELSE
					moving <= '0'; -- since it's fully retracted it's not moving--
					extender_out <='0'; --since it's fully retracted extender is not out--
				END IF;
			WHEN fully_extended => --current state is fully extended--
				if(right_left = '0') THEN 
					moving <= '1'; --since it's retracting it's moving--
					extender_out <='1'; --since it's moving extender is out--
				ELSE
					moving <= '0'; --since it's fully extended it's not moving--
					extender_out <='1'; --since it's fully extended extender is out--
				END IF;
			WHEN retracting => --current state is retracting--
				if(temp_output = "0000") THEN --if the output is 0000 that means that it reached full retraction--
					moving <= '0'; --it's not moving because it reached maximum retraction--
					extender_out <='0'; --it's fully_retracted so extender is not out--
				ELSE
					moving <= '1'; --since it's retracting it's moving--
					extender_out <='1'; --it's moving so extender is out--
				END IF;
			WHEN extending => --current state is extending--
				if(temp_output = "1111") THEN --if it reached maximum extension--
					moving <= '0'; --extender is not moving because it reached maximum extension--
					extender_out <= '1'; --it's fully extended so extender is out--
				ELSE
					moving <= '1'; -- extender is moving because it's extending--
					extender_out <= '1'; --it's moving so extender is out--
				END IF;
  END CASE;
 END PROCESS;
END ARCHITECTURE SM;