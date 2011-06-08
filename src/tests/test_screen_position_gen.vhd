--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:35:03 05/28/2011
-- Design Name:   
-- Module Name:   /home/xiadz/prog/fpga/oscilloscope/test_screen_position_gen.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: screen_position_gen
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
USE work.types.ALL;
 
ENTITY test_screen_position_gen IS
END test_screen_position_gen;
 
ARCHITECTURE behavior OF test_screen_position_gen IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT screen_position_gen
    PORT(
         nrst : IN  std_logic;
         clk108 : IN  std_logic;
         vblank : IN  std_logic;
         in_line_change : IN  std_logic;
         in_page_change : IN  std_logic;
         in_column : IN  integer range 0 to 1279;
         in_column_change : IN  std_logic;
         segment : OUT  integer range 0 to 15;
         segment_change : OUT  std_logic;
         subsegment : OUT  integer range 0 to 3;
         subsegment_change : OUT  std_logic;
         line : OUT  integer range 0 to 15;
         out_line_change : OUT  std_logic;
         out_column : OUT    integer range 0 to 1279;
         out_column_change : OUT  std_logic;
         out_page_change : OUT  std_logic;
         active_pixgen_source : OUT  PIXGEN_SOURCE_T
        );
    END COMPONENT;
    

   --Inputs
   signal nrst : std_logic := '0';
   signal clk108 : std_logic := '0';
   signal vblank : std_logic := '0';
   signal in_line_change : std_logic := '0';
   signal in_page_change : std_logic := '0';
   signal in_column : integer range 0 to 1279 := 0;
   signal in_column_change : std_logic := '0';

 	--Outputs
   signal segment : integer range 0 to 15;
   signal segment_change : std_logic;
   signal subsegment : integer range 0 to 3;
   signal subsegment_change : std_logic;
   signal line : integer range 0 to 15;
   signal out_line_change : std_logic;
   signal out_column : integer range 0 to 1279;
   signal out_column_change : std_logic;
   signal out_page_change : std_logic;
   signal active_pixgen_source : PIXGEN_SOURCE_T;

   -- Clock period definitions
   constant clk108_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: screen_position_gen PORT MAP (
          nrst => nrst,
          clk108 => clk108,
          vblank => vblank,
          in_line_change => in_line_change,
          in_page_change => in_page_change,
          in_column => in_column,
          in_column_change => in_column_change,
          segment => segment,
          segment_change => segment_change,
          subsegment => subsegment,
          subsegment_change => subsegment_change,
          line => line,
          out_line_change => out_line_change,
          out_column => out_column,
          out_column_change => out_column_change,
          out_page_change => out_page_change,
          active_pixgen_source => active_pixgen_source
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
        wait for clk108_period*10;
        
        while true loop
            in_page_change <= '1';
            for x_line in 0 to 1279 loop
                vblank <= '0';
                in_line_change <= '1';
                in_column_change <= '1';
                for x_column in 0 to 1279 loop
                    in_column <= x_column;
                    wait for clk108_period;
                    in_line_change <= '0';
                    in_page_change <= '0';
                end loop;
                in_column_change <= '0';
                vblank <= '1';
                wait for clk108_period * 1000;
            end loop;
            
            wait for clk108_period * 10000;
        end loop;
 
        wait;
    end process;

END;
