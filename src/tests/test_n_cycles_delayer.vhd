--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:45:56 05/22/2011
-- Design Name:   
-- Module Name:   /home/xiadz/prog/fpga/oscilloscope/test_n_cycles_delayer.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: n_cycles_delayer
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
 
ENTITY test_n_cycles_delayer IS
END test_n_cycles_delayer;
 
ARCHITECTURE behavior OF test_n_cycles_delayer IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT n_cycles_delayer
    GENERIC (
        n            : integer range 1 to 1024 := 5;
        signal_width : integer range 1 to 1024 := 8
      );
    PORT(
         nrst : IN  std_logic;
         clk : IN  std_logic;
         input : IN  std_logic_vector(7 downto 0);
         output : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal nrst : std_logic := '0';
   signal clk : std_logic := '0';
   signal input : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal output : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: n_cycles_delayer
      
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
   stim_proc: process is
       variable i, j : std_logic_vector (7 downto 0);
   begin		
      -- hold reset state for 105 ns.
      nrst <= '0';
      wait for clk_period * 10;
      nrst <= '1';
      wait for clk_period * 10;
      
      i := (others => '0');
      while true loop
          i := i + 1;
          input <= i;
          for j in 0 to 3 loop
            wait for clk_period;
            assert output /= input report "Should not match";
          end loop;
          wait for clk_period * 2;
          assert output = input report "Should match";
      end loop;
      wait;
   end process;

END;
