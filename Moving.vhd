library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Moving IS Port
(
 toggle, extender_out, clk, rst_n  : in std_logic; --button input, extender_out input (0 if fully retracted and 1 if not), clock and reset inputs--
 x_target, y_target                : in std_logic_vector(3 downto 0); -- x and y target positions inputs--
 x_pos, y_pos                      : out std_logic_vector(3 downto 0); -- x and y current positions outputs--
 error, not_moving                 : out std_logic -- error output and not_moving (used in extender) output--
 );
END ENTITY;

Architecture Move of Moving is

-- component for the 4-bit counter--
component U_D_Bin_Counter4bit port 
	(
			CLK                 : in std_logic := '0'; --clock input--
			RESET_n             : in std_logic := '0'; --reset input--
			CLK_EN              : in std_logic := '0'; --clock enable input--
			UP1_DOWN0           : in std_logic := '0'; -- 1 for up and 0 for down--
			COUNTER_BITS        : out std_logic_vector(3 downto 0) -- 4-bit outputs--
	);
end component;

--component for the 4-bit comparator--
component Compx4 port
	(
		input_0, input_1	                              : in std_logic_vector(3 downto 0); -- 4-bit inputs --
		bit_out_less, bit_out_equal, bit_out_great		: out std_logic --less than, equal to, greater than--
	);
end component;

----------------------------Signals-------------------------- 
SIGNAL X_EQ, X_GT, X_LT         				: std_logic; --signals to store the results of the x comparator--
SIGNAL Y_EQ, Y_GT, Y_LT                   : std_logic; --signals to store the results of the y comparator--
SIGNAL X_pos_temp, Y_pos_temp             : std_logic_vector (3 downto 0); --temporary signals to store the current x and y positions--
SIGNAL X_target_temp 					      : std_logic_vector (3 downto 0):= x_target(3 downto 0); --temporary signal to store the x target--
SIGNAL Y_target_temp					         : std_logic_vector (3 downto 0):= y_target(3 downto 0); --temporary signal to store the y target--
SIGNAL x_enable, y_enable                 : std_logic; -- x and y enable signals--
SIGNAL ACTIVATED, no_movement             : std_logic; -- Activated signal (can the arm move?), no_movement signal (stores the output of not moving)--
-------------------------------------------------------------------

BEGIN
-- start of the process section--
logic: PROCESS (toggle, rst_n, extender_out)  
BEGIN
	IF (rst_n = '0') THEN -- if reset is activated--
		x_pos(3 downto 0) <= "0000"; --resets the x position to 0000--
		y_pos(3 downto 0) <= "0000"; --resets the y position to 0000--
		X_target_temp(3 downto 0) <= "0000"; --resets the x target to 0000--
		Y_target_temp(3 downto 0) <= "0000"; --resets the y target to 0000--
		x_enable <= '0'; --resets the x_enable (for the x counter) to 0--
		y_enable <= '0'; --resets the y_enable (for the y counter) to 0--
		error <= '0'; --resets the error to 0--
	ELSE 
		x_pos(3 downto 0) <= x_pos_temp(3 downto 0); -- assigns the value of x_pos_temp to x_pos output--
		y_pos(3 downto 0) <= y_pos_temp(3 downto 0); -- assigns the value of y_pos_temp to y_pos output--
	
	IF(falling_edge(toggle)) THEN -- if it's a falling edge of the button--
		IF(extender_out = '1') THEN --if extender is out--
			error <= '1'; -- error is on--
			not_moving <= '1'; --the arm is not moving--
			no_movement<='1'; -- the arm is not moving--
			x_enable <= '0'; --x_enable and y_enable are 0--
			y_enable <= '0'; 
			ACTIVATED <= '0'; --the arm cannot move--
		ELSE
			error <= '0'; --if extender is not 1 error is off--
			ACTIVATED <= '1'; -- the arm can move--
			if(no_movement = '1') THEN --if the arm is not moving--
				X_target_temp(3 downto 0)<= x_target(3 downto 0); -- the x target is stored in 	 signal--
				Y_target_temp(3 downto 0)<= y_target(3 downto 0); -- the y target is stored in y_target_temp signal--
			END IF;
		END IF;
	END IF;
	IF(extender_out = '0') THEN --if extender is not out--
		error <= '0'; -- error is off--
	END IF;
	IF(X_EQ = '1') THEN
		x_enable <= '0'; -- if the arm reached its x target it should stop in the x direction (x_enable is 0)--
	ELSE
		x_enable <= '1' AND ACTIVATED; --x_enable is 1 if it hasn't reached its target x position AND the arm can move (the extender is not out)--
	END IF;
	IF(Y_EQ = '1') THEN
		Y_enable <= '0'; -- if the arm reached its y target it should stop in the y direction (y_enable is 0)--
	ELSE
		y_enable <= '1' AND ACTIVATED; --y_enable is 1 if it hasn't reached its target y position AND the arm can move (the extender is not out)--
	END IF;
	IF (X_EQ = '1' AND Y_EQ = '1') THEN --if it reached both its x and y targets--
		no_movement <= '1'; -- the arm is not moving anymore--
		Not_moving <= '1'; -- the arm is not moving anymore--
	ELSE
		no_movement <='0'; -- otherwise the arm is moving--
		not_moving <= '0'; -- otherwise the arm is moving--
	END IF;
	END IF;
END PROCESS;

--instance to increase/decrease the x position, it takes x_enable as an enable input--
--if the current x position is less than the target x position it should increase the current x position--
--if the current x position is greater than the target x position it should decrease the current x position--
counter_x: U_D_Bin_Counter4bit port map(clk, rst_n, x_enable, X_LT, X_pos_temp(3 downto 0));

--instance to increase/decrease the y position, it takes y_enable as an enable input--
--if the current y position is less than the target y position it should increase the current y position--
--if the current y position is greater than the target y position it should decrease the current y position--
counter_y: U_D_Bin_Counter4bit port map(clk, rst_n, y_enable, Y_LT, Y_pos_temp(3 downto 0));

--instance to compare the current and the target x positions--
Compare_X: Compx4 port map(X_pos_temp(3 downto 0), x_target_temp(3 downto 0), X_LT, X_EQ, X_GT);

--instance to compare the current and the target y positions--
Compare_Y: Compx4 port map(Y_pos_temp(3 downto 0), y_target_temp(3 downto 0), Y_LT, Y_EQ, Y_GT); 
	 
END ARCHITECTURE Move;