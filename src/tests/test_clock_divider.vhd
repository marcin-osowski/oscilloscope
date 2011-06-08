--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:15:48 05/28/2011
-- Design Name:   
-- Module Name:   /home/xiadz/prog/fpga/oscilloscope/test_clock_divider.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: divider
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_clock_divider IS
END test_clock_divider;
 
ARCHITECTURE behavior OF test_clock_divider IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT divider
    GENERIC (n:  natural  range 1 to 2147483647 := 5);
    PORT(
         clk_in : IN  std_logic;
         nrst : IN  std_logic;
         clk_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_in : std_logic := '0';
   signal nrst : std_logic := '0';

	--Output
   signal clk_out : std_logic;

   -- Clock period definitions
   constant clk_in_period : time := 10 ns;
   
   constant c : character := character'val(0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: divider PORT MAP (
          clk_in => clk_in,
          nrst => nrst,
          clk_out => clk_out
        );

   -- Clock process definitions
   clk_in_process :process
   begin
		clk_in <= '0';
		wait for clk_in_period/2;
		clk_in <= '1';
		wait for clk_in_period/2;
   end process;

    -- Stimulus process
    stim_proc: process
    begin		
        -- hold reset state for 100 ns.
        nrst <= '0';
        wait for 100 ns;	
        nrst <= '1';
        wait for clk_in_period*10;
        

        -- insert stimulus here 

        wait;
    end process;

END;
