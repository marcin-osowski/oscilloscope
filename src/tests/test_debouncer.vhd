--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:28:48 05/24/2011
-- Design Name:   
-- Module Name:   /home/xiadz/prog/fpga/oscilloscope/test_debouncer.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: debouncer
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_debouncer IS
END test_debouncer;
 
ARCHITECTURE behavior OF test_debouncer IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    constant n            : natural := 5;
    constant signal_width : natural := 8;
    
    COMPONENT debouncer
    GENERIC (
        n            : natural := n;
        signal_width : natural := signal_width
    );
    PORT(
         nrst : IN  std_logic;
         clk : IN  std_logic;
         input : IN  std_logic_vector(signal_width - 1 downto 0);
         output : OUT  std_logic_vector(signal_width - 1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal nrst : std_logic := '0';
   signal clk : std_logic := '0';
   signal input : std_logic_vector(signal_width - 1 downto 0) := (others => '0');

 	--Outputs
   signal output : std_logic_vector(signal_width - 1 downto 0);
   signal ones : std_logic_vector(signal_width - 1 downto 0) := (others => '1');
   signal zeros : std_logic_vector(signal_width - 1 downto 0) := (others => '0');
   

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: debouncer PORT MAP (
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
          
          input <= zeros;
          wait for clk_period * (n + 1);
          input <= ones;
          wait for clk_period;
          for i in 1 to n loop
              input <= zeros;
              wait for clk_period / 2;
              assert output = ones report "Should be equal '1', but is not";
              input <= ones;
              wait for clk_period / 2;
              assert output = ones report "Should be equal '1', but is not";
          end loop;
          
          wait for clk_period * (n + 1);
          
      end loop;

      wait;
   end process;

END;
