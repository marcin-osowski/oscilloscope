--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:36:40 05/24/2011
-- Design Name:   
-- Module Name:   /home/xiadz/prog/fpga/oscilloscope/test_trigger.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: trigger
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.types.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_trigger IS
END test_trigger;
 
ARCHITECTURE behavior OF test_trigger IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT trigger
    PORT(
         nrst : IN  std_logic;
         clk108 : IN  std_logic;
         trigger_btn : IN  std_logic;
         trigger_event : IN  TRIGGER_EVENT_T;
         red_enable : IN  std_logic;
         green_enable : IN  std_logic;
         blue_enable : IN  std_logic;
         continue_after_reading : IN  std_logic;
         red_input : IN  std_logic;
         green_input : IN  std_logic;
         blue_input : IN  std_logic;
         overflow_indicator : IN  std_logic;
         red_output : OUT  std_logic;
         green_output : OUT  std_logic;
         blue_output : OUT  std_logic;
         is_reading_active : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal nrst : std_logic := '0';
   signal clk108 : std_logic := '0';
   signal trigger_btn : std_logic := '0';
   signal trigger_event : TRIGGER_EVENT_T := BUTTON_TRIGGER_T;
   signal red_enable : std_logic := '0';
   signal green_enable : std_logic := '0';
   signal blue_enable : std_logic := '0';
   signal continue_after_reading : std_logic := '0';
   signal red_input : std_logic := '0';
   signal green_input : std_logic := '0';
   signal blue_input : std_logic := '0';
   signal overflow_indicator : std_logic := '0';

 	--Outputs
   signal red_output : std_logic;
   signal green_output : std_logic;
   signal blue_output : std_logic;
   signal is_reading_active : std_logic;

   -- Clock period definitions
   constant clk108_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: trigger PORT MAP (
          nrst => nrst,
          clk108 => clk108,
          trigger_btn => trigger_btn,
          trigger_event => trigger_event,
          red_enable => red_enable,
          green_enable => green_enable,
          blue_enable => blue_enable,
          continue_after_reading => continue_after_reading,
          red_input => red_input,
          green_input => green_input,
          blue_input => blue_input,
          overflow_indicator => overflow_indicator,
          red_output => red_output,
          green_output => green_output,
          blue_output => blue_output,
          is_reading_active => is_reading_active
        );

   -- Clock process definitions
   clk108_process :process
   begin
		clk108 <= '0';
		wait for clk108_period/2;
		clk108 <= '1';
		wait for clk108_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      nrst <= '0';
      wait for 100 ns;	
      nrst <= '1';
      
      wait for clk108_period;
      
      
      wait for clk108_period * 10;
      trigger_btn <= '1';
      wait for clk108_period;
      trigger_btn <= '0';
      
      assert is_reading_active = '1' report "Reading should be active";
      
      
      red_enable <= '1';
      green_enable <= '0';
      blue_enable <= '1';
      red_input <= '1';
      green_input <= '1';
      blue_input <= '0';
      
      wait for clk108_period;
      assert red_output = '1' report "Red should be active";
      assert green_output = '0' report "Green should not be active";
      assert blue_output = '0' report "Blue should not be active";
      wait for clk108_period;
      red_input <= '0';
      green_input <= '0';
      blue_input <= '0';
      
      
      wait for clk108_period * 10;
      
      continue_after_reading <= '0';
      overflow_indicator <= '1';
      wait for clk108_period;
      assert is_reading_active = '0' report "Reading should not be active; issued an overflow";
      overflow_indicator <= '0';
      
      wait for clk108_period * 10;
      
      trigger_event <= GREEN_TRIGGER_T;
      green_input <= '1';
      wait for clk108_period;
      green_input <= '0';
      wait for clk108_period;
      assert is_reading_active = '1' report "Reading should be active; trigger on rising edge at green";
      
      
      wait for clk108_period * 10;
      trigger_btn <= '1';
      wait for clk108_period;
      trigger_btn <= '0';
      assert is_reading_active = '0' report "Reading should not be active; stopped it with button";
      
      
      wait;
   end process;

END;
