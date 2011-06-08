----------------------------------------------------------------------------------
-- Author: Osowski Marcin
-- Create Date:    19:12:14 05/24/2011 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.types.all;

entity trigger is
    port (
        -- Inputs
        nrst                   : in std_logic;
        clk108                 : in std_logic;
        trigger_btn            : in std_logic;
        trigger_event          : in TRIGGER_EVENT_T;
        red_enable             : in std_logic;
        green_enable           : in std_logic;
        blue_enable            : in std_logic;
        continue_after_reading : in std_logic;
        red_input              : in std_logic;
        green_input            : in std_logic;
        blue_input             : in std_logic;
        overflow_indicator     : in std_logic;
        
        -- Outputs
        red_output        : out std_logic;
        green_output      : out std_logic;
        blue_output       : out std_logic;     
        is_reading_active : out std_logic
    );
end trigger;

architecture behavioral of trigger is
    signal internal_is_reading_active    : std_logic := '0';
    signal previous_trigger_btn          : std_logic := '0';
    signal previous_red_input            : std_logic := '0';
    signal previous_green_input          : std_logic := '0';
    signal previous_blue_input           : std_logic := '0';
    
begin
    is_reading_active <= internal_is_reading_active;
    
    process (nrst, clk108) is
    begin
        if nrst = '0' then
            red_output <= '0';
            green_output <= '0';
            blue_output <= '0';     
            internal_is_reading_active <= '0';
            previous_trigger_btn <= '0';
            previous_red_input <= '0';
            previous_green_input <= '0';
            previous_blue_input <= '0';
        elsif rising_edge (clk108) then
            red_output <= red_input and red_enable;
            green_output <= green_input and green_enable;
            blue_output <= blue_input and blue_enable;
            
            previous_trigger_btn <= trigger_btn;
            previous_red_input <= red_input;
            previous_green_input <= green_input;
            previous_blue_input <= blue_input;
            
            if internal_is_reading_active = '0' then
                -- reading is currently not active
                
                if trigger_event = BUTTON_TRIGGER_T and
                   previous_trigger_btn = '0' and
                   trigger_btn = '1' then
                       -- Rising edge on trigger button.
                       internal_is_reading_active <= '1';
                       
                elsif trigger_event = RED_TRIGGER_T  and
                   previous_red_input = '0' and
                   red_input = '1' then
                       -- Rising edge on red input.
                       internal_is_reading_active <= '1';
                       
                elsif trigger_event = GREEN_TRIGGER_T  and
                   previous_green_input = '0' and
                   green_input = '1' then
                       -- Rising edge on green input.
                       internal_is_reading_active <= '1';
                    
                elsif trigger_event = BLUE_TRIGGER_T  and
                   previous_blue_input = '0' and
                   blue_input = '1' then
                       -- Rising edge on blue input.
                       internal_is_reading_active <= '1';
                    
                end if;
            else
                -- reading is currently active
                
                if previous_trigger_btn = '0' and trigger_btn = '1' then
                    internal_is_reading_active <= '0';
                elsif overflow_indicator = '1' and continue_after_reading = '0' then
                    internal_is_reading_active <= '0';
                end if;
                
            end if;
        end if;
    end process;

end behavioral;

