LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
   Clk			: in	std_logic;                     --- clk signal---
	rst_n			: in	std_logic;                     --- reset signal (resets everything to its initial state)---
	pb				: in	std_logic_vector(3 downto 0);  --- inputs ----
 	sw   			: in  std_logic_vector(7 downto 0);  --- inputs ----
   leds			: out std_logic_vector(15 downto 0)	 --- outputs ----
	);
END LogicalStep_Lab4_top;

ARCHITECTURE Circuit OF LogicalStep_Lab4_top IS

----------------------------------COMPONENTS-------------------------------------


--Component for part A (the bit shift register) (wasn't used in part C) --
--	component Bidir_shift_reg port 
--	(
--			CLK                 : in std_logic := '0';
--			RESET_n             : in std_logic := '0';
--			CLK_EN              : in std_logic := '0';
--			LEFT0_RIGHT1        : in std_logic := '0';
--			REG_BITS            : out std_logic_vector(7 downto 0)
--	);
--	end component;
	
--Component for part B (8 bit counter) (wasn't used in part C) --	
--	component U_D_Bin_Counter8bit port
--	(
--			CLK                 : in std_logic := '0';
--			RESET_n             : in std_logic := '0';
--			CLK_EN              : in std_logic := '0';
--			UP1_DOWN0           : in std_logic := '0';
--			COUNTER_BITS        : out std_logic_vector(7 downto 0)
--	);
--	end component;

--------------- Component for Grappler---------------
	component Grappler Port
	(
		Fully_extended                            : in std_logic_vector(3 downto 0); --4-bit input of the state of the extender---
		clk_input, rst_n, Toggle          			: IN std_logic; -- clock input, reset input and button input--
		state         										: OUT std_logic -- state of the grappler (open or closed) --
	);
	END component;

--------------- Component for extender-------------
	component Extender Port
	(
	toggle, not_moving, clk, rst_n  : in std_logic; -- button input, not_moving input, clock input and reset input--
	output                          : out std_logic_vector(3 downto 0); -- 4-bit output (extender state)--
	extender_out                    : out std_logic -- is off when the extender is fully retracted otherwise it's on--
	);
	END component;

--------------- Component for RAC movement operations ----------
	component Moving Port
	(
	 toggle, extender_out, clk, rst_n  : in std_logic; -- button input, is_the_extender_out input, clock and reset inputs--
	 x_target, y_target                : in std_logic_vector(3 downto 0); -- x and y target positions inputs--
	 x_pos, y_pos                      : out std_logic_vector(3 downto 0); -- x and y current positions outputs---
	 error, not_moving                 : out std_logic -- error and not_moving outputs--
	);
	END component;
-----------------------------------------------------------------------

--------------------------------SIGNALS----------------------------------
signal extender_out                   : std_logic;	-- extender_out (0 when fully retracted and 1 otherwise) signal--
signal not_moving                     : std_logic; -- not_moving signal (0 when moving and 1 when not moving)--
signal extend                         : std_logic_vector(3 downto 0); -- temporary signal that holds the state of the extender--
-----------------------------------------------------------------------
begin

--instance1: Bidir_shift_reg port map(
--		clk, pb(0), sw(0), sw(1), leds(7 downto 0)
--);

--instance2: U_D_Bin_Counter8bit port map(
--		clk, pb(0), sw(0), sw(1), leds(7 downto 0)
--);

--test: Grappler port map(pb(3 downto 0),clk,rst_n,sw(0),leds(0));

--test: Extender port map(sw(0), sw(1), clk, rst_n, leds(3 downto 0), leds(4));

--test: Moving port map(pb(0), pb(1), clk, rst_n, sw(3 downto 0), sw(7 downto 4), leds(3 downto 0), leds(7 downto 4), leds(8), leds(9));

----------------------------------INSTANCE for the RAC movement operations---------------------------
instance1: Moving port map(pb(2), extender_out, clk, rst_n, sw(7 downto 4), sw(3 downto 0), leds(15 downto 12), leds(11 downto 8), leds(0), not_moving);

----------------------------------INSTANCE for the extender--------------------------
instance2: Extender port map(pb(1), not_moving, clk, rst_n, extend, extender_out);

------------------------------------INSTANCE for the grappler--------------------
instance3: Grappler port map(extend, clk, rst_n, pb(0), leds(3));

leds(7 downto 4) <= extend;   ---- assignment the value of extend to leds(7 downto 4) --------  

end Circuit;
