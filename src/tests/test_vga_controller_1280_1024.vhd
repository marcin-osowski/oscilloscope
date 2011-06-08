--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:00:31 05/17/2011
-- Design Name:   
-- Module Name:   /home/xiadz/prog/fpga/oscilloscope/test_vga_controller_1280_1024.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: vga_controller_1280_1024
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
use ieee.numeric_std.all;
 
 
ENTITY test_vga_controller_1280_1024 IS
END test_vga_controller_1280_1024;
 
ARCHITECTURE behavior OF test_vga_controller_1280_1024 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT vga_controller_1280_1024
    PORT(
         nrst : IN  std_logic;
         clk108 : IN  std_logic;
         hsync : OUT  std_logic;
         vsync : OUT  std_logic;
         vblank : OUT  std_logic;
         line_change : OUT  std_logic;
         page_change : OUT  std_logic;
         column : out integer range 0 to 1279;
         column_change : out std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal nrst : std_logic := '1';
   signal clk108 : std_logic := '0';

 	--Outputs
   signal hsync : std_logic;
   signal vsync : std_logic;
   signal vblank : std_logic;
   signal line_change : std_logic;
   signal page_change : std_logic;
   signal column : integer range 0 to 1279;
   signal column_change : std_logic;
   
   
   
   signal clock_periods : std_logic_vector (31 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk108_period : time := 9.25925926 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: vga_controller_1280_1024 PORT MAP (
          nrst => nrst,
          clk108 => clk108,
          hsync => hsync,
          vsync => vsync,
          vblank => vblank,
          line_change => line_change,
          page_change => page_change,
          column => column,
          column_change => column_change
        );

   -- Clock process definitions
   clk108_process : process
   begin
		clk108 <= '1';
		wait for clk108_period/2;
		clk108 <= '0';
		wait for clk108_period/2;
        clock_periods <= clock_periods + 1;
   end process;

END;
