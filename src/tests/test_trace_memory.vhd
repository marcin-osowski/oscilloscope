--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:28:51 05/22/2011
-- Design Name:   
-- Module Name:   /home/xiadz/prog/fpga/oscilloscope/test_trace_memory.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: trace_memory
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
USE ieee.std_logic_arith.ALL;
 
ENTITY test_trace_memory IS
END test_trace_memory;
 
ARCHITECTURE behavior OF test_trace_memory IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT trace_memory
    PORT(
         clka : IN  std_logic;
         wea : IN  std_logic_vector(0 downto 0);
         addra : IN  std_logic_vector(12 downto 0);
         dina : IN  std_logic_vector(8 downto 0);
         clkb : IN  std_logic;
         rstb : IN  std_logic;
         addrb : IN  std_logic_vector(12 downto 0);
         doutb : OUT  std_logic_vector(8 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clka : std_logic := '0';
   signal wea : std_logic_vector(0 downto 0) := (others => '0');
   signal addra : std_logic_vector(12 downto 0) := (others => '0');
   signal dina : std_logic_vector(8 downto 0) := (others => '0');
   signal clkb : std_logic := '0';
   signal rstb : std_logic := '0';
   signal addrb : std_logic_vector(12 downto 0) := (others => '0');

 	--Outputs
   signal doutb : std_logic_vector(8 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: trace_memory PORT MAP (
          clka => clka,
          wea => wea,
          addra => addra,
          dina => dina,
          clkb => clkb,
          rstb => rstb,
          addrb => addrb,
          doutb => doutb
        );

   clk_process :process
   begin
		clka <= '0';
        clkb <= '0';
		wait for clk_period/2;
		clka <= '1';
        clkb <= '1';
		wait for clk_period/2;
   end process;
 
 

   -- Stimulus process
   stim_proc: process
   variable i: integer;
   begin		
      -- hold reset state for 100 ns.
      rstb <= '1';
      wait for 100 ns;	
      rstb <= '0';
      wait for clk_period * 10;
      
      addra <= "0000000000000";
      dina <= "010101101";
      wea <= "1";
      wait for clk_period;
      wea <= "0";
      
      wait for clk_period * 10;
      
      wea <= "1";
      for i in 0 to 20 loop
         dina <= conv_std_logic_vector (i, 9);
         addra <= conv_std_logic_vector (i, 13);
         wait for clk_period;
      end loop;
      wea <= "0";
      
      wait for clk_period * 10;
      
      for i in 0 to 20 loop
         addrb <= conv_std_logic_vector (i, 13);
         wait for clk_period;
      end loop;

      wait;
   end process;

END;
