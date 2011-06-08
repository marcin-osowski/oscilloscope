--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:01:11 05/24/2011
-- Design Name:   
-- Module Name:   /home/xiadz/prog/fpga/oscilloscope/test_oscilloscope_display.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: oscilloscope_display
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
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_oscilloscope_display IS
END test_oscilloscope_display;
 
ARCHITECTURE behavior OF test_oscilloscope_display IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT oscilloscope_display
    PORT(
         nrst : IN  std_logic;
         clk108 : IN  std_logic;
         is_reading_active      : in std_logic;
         trigger_event          : in TRIGGER_EVENT_T;
         red_enable             : in std_logic;
         green_enable           : in std_logic;
         blue_enable            : in std_logic;
         continue_after_reading : in std_logic;
         time_resolution        : in integer range 0 to 15;
         addrb : OUT  std_logic_vector(12 downto 0);
         doutb : IN  std_logic_vector(8 downto 0);
         vout : OUT  std_logic_vector(7 downto 0);
         vsync : OUT  std_logic;
         hsync : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal nrst : std_logic := '0';
   signal clk108 : std_logic := '0';
   signal doutb : std_logic_vector(8 downto 0) := (others => '0');
   
   
   
   signal is_reading_active      : std_logic := '0';
   signal trigger_event          : TRIGGER_EVENT_T := BUTTON_TRIGGER_T;
   signal red_enable             : std_logic := '1';
   signal green_enable           : std_logic := '1';
   signal blue_enable            : std_logic := '1';
   signal continue_after_reading : std_logic := '0';
   signal time_resolution        : integer range 0 to 15;
   

 	--Outputs
   signal addrb : std_logic_vector(12 downto 0);
   signal vout : std_logic_vector(7 downto 0);
   signal vsync : std_logic;
   signal hsync : std_logic;

   -- Clock period definitions
   constant clk108_period : time := 10 ns;
   
   -- Locals
   signal clock_periods : std_logic_vector (15 downto 0) := (others => '0');
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: oscilloscope_display PORT MAP (
          nrst => nrst,
          clk108 => clk108,
          is_reading_active => is_reading_active,
          trigger_event => trigger_event,
          red_enable => red_enable,
          green_enable => green_enable,
          blue_enable => blue_enable,
          continue_after_reading => continue_after_reading,
          time_resolution => time_resolution,
          addrb => addrb,
          doutb => doutb,
          vout => vout,
          vsync => vsync,
          hsync => hsync
        );

   -- Clock process definitions
   clk108_process :process
   begin
		clk108 <= '0';
		wait for clk108_period/2;
		clk108 <= '1';
        if nrst = '1' then
            clock_periods <= clock_periods + 1;
        end if;
		wait for clk108_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      nrst <= '0';
      wait for clk108_period * 10;
      nrst <= '1';
      
      wait for clk108_period * 10;

      -- insert stimulus here 

      wait;
   end process;

END;
