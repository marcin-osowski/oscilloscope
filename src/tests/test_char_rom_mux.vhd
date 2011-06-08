--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:31:59 05/28/2011
-- Design Name:   
-- Module Name:   /home/xiadz/prog/fpga/oscilloscope/test_char_rom_mux.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: char_rom_mux
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;
 
ENTITY test_char_rom_mux IS
END test_char_rom_mux;
 
ARCHITECTURE behavior OF test_char_rom_mux IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT char_rom_mux
    PORT(
         nrst : IN  std_logic;
         clk108 : IN  std_logic;
         active_pixgen_source : IN  PIXGEN_SOURCE_T;
         time_base_char : IN  short_character;
         time_base_char_pos_x : IN  integer range 0 to 7;
         time_base_char_pos_y : IN  integer range 0 to 15;
         settings_char : IN  short_character;
         settings_char_pos_x : IN  integer range 0 to 7;
         settings_char_pos_y : IN  integer range 0 to 15;
         char_pixel : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal nrst : std_logic := '0';
   signal clk108 : std_logic := '0';
   signal active_pixgen_source : PIXGEN_SOURCE_T := BLANK_PIXGEN_T;
   signal time_base_char : short_character := short_character'val (0);
   signal time_base_char_pos_x : integer range 0 to 7 := 0;
   signal time_base_char_pos_y : integer range 0 to 15 := 0;
   signal settings_char : short_character := short_character'val (0);
   signal settings_char_pos_x : integer range 0 to 7 := 0;
   signal settings_char_pos_y : integer range 0 to 15 := 0;

 	--Outputs
   signal char_pixel : std_logic;

   -- Clock period definitions
   constant clk108_period : time := 10 ns;
   
   type chars_8 is array (0 to 7) of character;
   
   type letter is array (0 to 15) of chars_8;
   constant a_letter : letter := 
       ( "--------",
         "--------",
         "---X----",
         "--XXX---",
         "-XX-XX--",
         "XX---XX-",
         "XX---XX-",
         "XXXXXXX-",
         "XX---XX-",
         "XX---XX-",
         "XX---XX-",
         "XX---XX-",
         "--------",
         "--------",
         "--------",
         "--------" );
                  
                  
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: char_rom_mux PORT MAP (
          nrst => nrst,
          clk108 => clk108,
          active_pixgen_source => active_pixgen_source,
          time_base_char => time_base_char,
          time_base_char_pos_x => time_base_char_pos_x,
          time_base_char_pos_y => time_base_char_pos_y,
          settings_char => settings_char,
          settings_char_pos_x => settings_char_pos_x,
          settings_char_pos_y => settings_char_pos_y,
          char_pixel => char_pixel
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
        
        -- Testing memory against some random character: 'A'
        active_pixgen_source <= TIME_BASE_PIXGEN_T;
        time_base_char <= 'A';
        time_base_char_pos_y <= 0;
        for y in 0 to 15 loop
            time_base_char_pos_x <= 0;
            for x in 0 to 7 loop
                wait for clk108_period;
                if char_pixel = '1' then
                    assert a_letter (y)(x) = 'X' report "char_pixel should be '1', but is not";
                else
                    assert a_letter (y)(x) = '-' report "char_pixel should be '0', but is not";
                end if;
                
                if time_base_char_pos_x = 7 then
                    time_base_char_pos_x <= 0;
                else
                    time_base_char_pos_x <= time_base_char_pos_x + 1;
                end if;
            end loop;
            if time_base_char_pos_y = 15 then
                time_base_char_pos_y <= 0;
            else
                time_base_char_pos_y <= time_base_char_pos_y + 1;
            end if;
        end loop;
        wait;
    end process;

END;
