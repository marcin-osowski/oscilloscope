--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:17:19 05/28/2011
-- Design Name:   
-- Module Name:   /home/xiadz/prog/fpga/oscilloscope/test_trace_pixgen.vhd
-- Project Name:  oscilloscope
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: trace_pixgen
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

 
ENTITY test_trace_pixgen IS
END test_trace_pixgen;
 
ARCHITECTURE behavior OF test_trace_pixgen IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT trace_pixgen
    PORT(
         nrst : IN  std_logic;
         clk108 : IN  std_logic;
         segment : IN  integer range 0 to 15;
         segment_change : IN  std_logic;
         subsegment : IN  integer range 0 to 3;
         subsegment_change : IN  std_logic;
         line : IN  integer range 0 to 15;
         line_change : IN  std_logic;
         column : IN  integer range 0 to 1279;
         column_change : IN  std_logic;
         page_change : IN  std_logic;
         active_pixgen_source : IN  PIXGEN_SOURCE_T;
         doutb : IN  std_logic_vector(8 downto 0);
         addrb : OUT  std_logic_vector(12 downto 0);
         vout : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal nrst : std_logic := '0';
   signal clk108 : std_logic := '0';
   signal segment : integer range 0 to 15 := 0;
   signal segment_change : std_logic := '0';
   signal subsegment : integer range 0 to 3 := 0;
   signal subsegment_change : std_logic := '0';
   signal line : integer range 0 to 15 := 0;
   signal line_change : std_logic := '0';
   signal column : integer range 0 to 1279 := 0;
   signal column_change : std_logic := '0';
   signal page_change : std_logic := '0';
   signal active_pixgen_source : PIXGEN_SOURCE_T := TRACE_PIXGEN_T;
   signal doutb : std_logic_vector(8 downto 0) := (others => '0');

 	--Outputs
   signal addrb : std_logic_vector(12 downto 0);
   signal vout : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk108_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: trace_pixgen PORT MAP (
          nrst => nrst,
          clk108 => clk108,
          segment => segment,
          segment_change => segment_change,
          subsegment => subsegment,
          subsegment_change => subsegment_change,
          line => line,
          line_change => line_change,
          column => column,
          column_change => column_change,
          page_change => page_change,
          active_pixgen_source => active_pixgen_source,
          doutb => doutb,
          addrb => addrb,
          vout => vout
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
            for x_segment in 0 to 15 loop
                for x_subsegment in 0 to 3 loop
                    for x_line in 0 to 15 loop
                        if x_segment = 14 or x_segment = 15 then
                            active_pixgen_source <= SETTINGS_PIXGEN_T;
                        else
                            if x_subsegment = 3 then
                                active_pixgen_source <= TIME_BASE_PIXGEN_T;
                            else
                                active_pixgen_source <= TRACE_PIXGEN_T;
                            end if;
                        end if;
                        for x_column in 0 to 1279 loop
                            column_change <= '1';
                            segment <= x_segment;
                            subsegment <= x_subsegment;
                            line <= x_line;
                            column <= x_column;
                            if x_column = 0 then
                                line_change <= '1';
                                if x_line = 0 then
                                    subsegment_change <= '1';
                                    if x_subsegment = 0 then
                                        segment_change <= '1';
                                        if x_segment = 0 then
                                            page_change <= '1';
                                        else
                                            page_change <= '0';
                                        end if;
                                    else
                                    segment_change <= '0';
                                    page_change <= '0';
                                    end if;
                                else
                                subsegment_change <= '0';
                                segment_change <= '0';
                                page_change <= '0';
                                end if;
                            else
                                line_change <= '0';
                                subsegment_change <= '0';
                                segment_change <= '0';
                                page_change <= '0';
                            end if;
                            
                            wait for clk108_period;
                          
                        end loop;
                        column_change <= '0';
                        active_pixgen_source <= BLANK_PIXGEN_T;
                        wait for clk108_period * 1000;
                    end loop;
                end loop;
            end loop;
            wait for clk108_period * 10000;
        end loop;
        wait;
    end process;

END;
