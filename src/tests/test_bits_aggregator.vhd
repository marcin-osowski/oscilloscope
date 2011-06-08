--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:19:19 05/27/2011
-- Design Name:   
-- Module Name:   /home/xiadz/prog/fpga/oscilloscope/test_bits_aggregator.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: bits_aggregator
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
 
ENTITY test_bits_aggregator IS
END test_bits_aggregator;
 
ARCHITECTURE behavior OF test_bits_aggregator IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT bits_aggregator
    PORT(
         nrst : IN  std_logic;
         clk108 : IN  std_logic;
         flush_and_return_to_zero : IN  std_logic;
         write_enable : IN  std_logic;
         red_value : IN  std_logic;
         green_value : IN  std_logic;
         blue_value : IN  std_logic;
         wea : OUT  std_logic;
         addra : OUT  std_logic_vector(12 downto 0);
         dina : OUT  std_logic_vector(8 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal nrst : std_logic := '0';
   signal clk108 : std_logic := '0';
   signal flush_and_return_to_zero : std_logic := '0';
   signal write_enable : std_logic := '0';
   signal red_value : std_logic := '0';
   signal green_value : std_logic := '0';
   signal blue_value : std_logic := '0';

 	--Outputs
   signal wea : std_logic;
   signal addra : std_logic_vector(12 downto 0);
   signal dina : std_logic_vector(8 downto 0);
   
   
   signal rgb : std_logic_vector (2 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk108_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: bits_aggregator PORT MAP (
          nrst => nrst,
          clk108 => clk108,
          flush_and_return_to_zero => flush_and_return_to_zero,
          write_enable => write_enable,
          red_value => red_value,
          green_value => green_value,
          blue_value => blue_value,
          wea => wea,
          addra => addra,
          dina => dina
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
   variable mod3 : integer range 0 to 3 := 0;
   variable sent_row : std_logic_vector (8 downto 0) := (others => '0');
   begin		
      -- hold reset state for 100 ns.
      nrst <= '0';
      wait for 100 ns;
      nrst <= '1';

      wait for clk108_period*10;
      
      
      while true loop
          assert mod3 = 0 report "Unit-test internal error";
          for i in 1 to 99 loop
              wait for clk108_period;
              red_value <= rgb (0);
              green_value <= rgb (1);
              blue_value <= rgb (2);
              sent_row ((mod3 * 3) + 2 downto mod3 * 3) := rgb;
              wait for clk108_period;
              write_enable <= '1';
              wait for clk108_period;
              write_enable <= '0';
              wait for clk108_period;
              rgb <= rgb + 1;
              
              mod3 := mod3 + 1;
              if mod3 = 3 then
                  mod3 := 0;
                  assert sent_row = dina report "Entity generated improper memory input";
              end if;
          end loop;
          
          assert mod3 = 0 report "Unit-test internal error";
          
          -- Testing flush_and_return_to_zero
          wait for clk108_period * 10;
          write_enable <= '1';
          flush_and_return_to_zero <= '1';
          wait for clk108_period;
          write_enable <= '0';
          flush_and_return_to_zero <= '0';
          wait for clk108_period;
          assert "000000" & (rgb - 1) = dina report "Entity generated improper memory input after flushing";
          
          
          -- Now writing 3 bytes. After successbul flush they should be sent to memory row 0
          write_enable <= '1';
          wait for clk108_period;
          assert addra /= "0000000000000" report "Address after flushing went to zero too fast";
          wait for clk108_period;
          assert addra /= "0000000000000" report "Address after flushing went to zero too fast";
          wait for clk108_period;
          write_enable <= '0';
          assert addra = "0000000000000" report "Address after flushing didn't go to zero.";
          assert dina = (rgb - 1) & (rgb - 1) & (rgb - 1) report "Improper dina signal after flushing and writing full word.";

          
          --assert addra = "0000000000000" report "Address after flushing is not zero";
          
          
      end loop;


      wait;
   end process;

END;
