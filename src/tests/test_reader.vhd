--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:54:34 05/24/2011
-- Design Name:   
-- Module Name:   /home/xiadz/prog/fpga/oscilloscope/test_reader.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: reader
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
USE ieee.numeric_std.ALL;
 
ENTITY test_reader IS
END test_reader;
 
ARCHITECTURE behavior OF test_reader IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT reader
    PORT(
         nrst : IN  std_logic;
         clk108 : IN  std_logic;
         input_red : IN  std_logic;
         input_green : IN  std_logic;
         input_blue : IN  std_logic;
         is_reading_active : IN  std_logic;
         time_resolution : IN  integer range 0 to 15;
         overflow_indicator : OUT  std_logic;
         flush_and_return_to_zero : OUT  std_logic;
         write_enable : OUT  std_logic;
         red_value : OUT  std_logic;
         green_value : OUT  std_logic;
         blue_value : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal nrst : std_logic := '0';
   signal clk108 : std_logic := '0';
   signal input_red : std_logic := '0';
   signal input_green : std_logic := '0';
   signal input_blue : std_logic := '0';
   signal is_reading_active : std_logic := '0';
   signal time_resolution : integer range 0 to 15 := 0;

 	--Outputs
   signal overflow_indicator : std_logic;
   signal flush_and_return_to_zero : std_logic;
   signal write_enable : std_logic;
   signal red_value : std_logic;
   signal green_value : std_logic;
   signal blue_value : std_logic;

   -- Clock period definitions
   constant clk108_period : time := 10 ns;
   
   signal was_there_an_overflow : std_logic := '0';
   signal please_reset_overflow : std_logic := '0';
   signal currently_doing_nothing : std_logic := '0';
   
   signal write_enable_count_between_flushes : natural := 0;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: reader PORT MAP (
          nrst => nrst,
          clk108 => clk108,
          input_red => input_red,
          input_green => input_green,
          input_blue => input_blue,
          is_reading_active => is_reading_active,
          time_resolution => time_resolution,
          overflow_indicator => overflow_indicator,
          flush_and_return_to_zero => flush_and_return_to_zero,
          write_enable => write_enable,
          red_value => red_value,
          green_value => green_value,
          blue_value => blue_value
        );

   -- Clock process definitions
   clk108_process :process
   begin
		clk108 <= '0';
		wait for clk108_period/2;
		clk108 <= '1';
		wait for clk108_period/2;
   end process;
   
   simulate_trigger : process (nrst, clk108) is
   begin
       if nrst = '0' then
           is_reading_active <= '1';
       elsif rising_edge (clk108) then
           if please_reset_overflow = '1' then
              was_there_an_overflow <= '0';
              is_reading_active <= '1';
              time_resolution <= (time_resolution + 1) mod 16;
           elsif was_there_an_overflow = '0' then
              if overflow_indicator = '1' then
                  was_there_an_overflow <= '1';
                  is_reading_active <= '0';
              end if;
           end if;
       end if;
   end process;
   
   restart_was_there_an_overflow: process is
   begin
       while true loop
           if was_there_an_overflow = '1' then
               wait for clk108_period * 25;
               currently_doing_nothing <= '1';
               wait for clk108_period;
               currently_doing_nothing <= '0';
               wait for clk108_period * 25;
               please_reset_overflow <= '1';
           end if;
           wait for clk108_period;
           please_reset_overflow <= '0';
       end loop;
   end process;
   
   
   write_enable_counter: process (nrst, clk108) is
   begin
       if nrst = '0' then
           write_enable_count_between_flushes <= 0;
       elsif rising_edge (clk108) then
           if currently_doing_nothing = '1' then
               assert write_enable_count_between_flushes = 14 * 1280 report "Improper number of write_enable ones.";
               write_enable_count_between_flushes <= 0;
           elsif write_enable = '1' then
               write_enable_count_between_flushes <= write_enable_count_between_flushes + 1;
           end if;
       end if;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      nrst <= '0';
      wait for 100 ns;	
      nrst <= '1';
      

      wait for clk108_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
