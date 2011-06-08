--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:08:56 05/24/2011
-- Design Name:   
-- Module Name:   /home/xiadz/prog/fpga/oscilloscope/test_single_debouncer.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: single_debouncer
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
 
ENTITY test_single_debouncer IS
END test_single_debouncer;
 
ARCHITECTURE behavior OF test_single_debouncer IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    
    constant n : integer := 5;
 
    COMPONENT single_debouncer
    GENERIC (n : natural := n);
    PORT(
         nrst : IN  std_logic;
         clk : IN  std_logic;
         input : IN  std_logic;
         output : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal nrst : std_logic := '0';
   signal clk : std_logic := '0';
   signal input : std_logic := '0';

 	--Outputs
   signal output : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: single_debouncer 
   PORT MAP (
          nrst => nrst,
          clk => clk,
          input => input,
          output => output
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   variable i:integer;
   begin		
      -- hold reset state for 100 ns.
      nrst <= '0';
      wait for 100 ns;	
      nrst <= '1';

      wait for clk_period * 10;

      while true loop
          for i in 0 to 9 loop
              input <= not input;
              wait for clk_period;
              assert output = input report "Should be equal, but is not";
              wait for clk_period * (n + 1);
          end loop;
          
          input <= '0';
          wait for clk_period * (n + 1);
          input <= '1';
          wait for clk_period;
          for i in 1 to n loop
              input <= '0';
              wait for clk_period / 2;
              assert output = '1' report "Should be equal '1', but is not";
              input <= '1';
              wait for clk_period / 2;
              assert output = '1' report "Should be equal '1', but is not";
          end loop;
          
          wait for clk_period * (n + 1);
          
      end loop;

      wait;
   end process;

END;
