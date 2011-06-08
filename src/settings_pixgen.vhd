----------------------------------------------------------------------------------
-- Author: Osowski Marcin
-- Create Date:    20:16:43 05/22/2011 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.types.all;

entity settings_pixgen is
    port (
        nrst                   : in  std_logic;
        clk108                 : in  std_logic;
        segment                : in integer range 0 to 15;
        segment_change         : in std_logic;
        subsegment             : in integer range 0 to 3;
        subsegment_change      : in std_logic;
        line                   : in integer range 0 to 15;
        line_change            : in std_logic;
        column                 : in integer range 0 to 1279;
        column_mod_8           : in integer range 0 to 7;
        column_div_8           : in integer range 0 to 159;
        column_change          : in std_logic;
        page_change            : in std_logic;
        active_pixgen_source   : in PIXGEN_SOURCE_T;
        is_reading_active      : in std_logic;
        trigger_event          : in TRIGGER_EVENT_T;
        red_enable             : in std_logic;
        green_enable           : in std_logic;
        blue_enable            : in std_logic;
        continue_after_reading : in std_logic;
        time_resolution        : in integer range 0 to 15;
        char                   : out short_character;
        char_pixel             : in std_logic;
        vout                   : out std_logic_vector (7 downto 0)
    );
end settings_pixgen;

architecture behavioral of settings_pixgen is
    constant s_red_sig   : short_string := to_short_string ("  Red signal (C6): ???abled (SW6)");
    constant s_green_sig : short_string := to_short_string ("Green signal (B6): ???abled (SW5)");
    constant s_blue_sig  : short_string := to_short_string (" Blue signal (C5): ???abled (SW4)");
    constant s_enabled   : short_string := to_short_string (" en");
    constant s_disabled  : short_string := to_short_string ("dis");
    
    constant s_resolution : short_string := to_short_string ("   Resolution: ???????? (SW3 ~ SW0)");
    constant s_trigger    : short_string := to_short_string ("   Trigger on: ???????? (BTN2 to change)");
    constant s_after      : short_string := to_short_string ("After reading: ???????? (BTN1 to change)");
    
    type res_array_t is array (0 to 15) of short_string (7 downto 0);
    
    constant res_array : res_array_t := (
        to_short_string ("  54 Mhz"),
        to_short_string ("21.6 Mhz"),
        to_short_string ("10.8 Mhz"),
        to_short_string (" 5.4 Mhz"),
        to_short_string ("   1 Mhz"),
        to_short_string (" 500 khz"),
        to_short_string (" 250 khz"),
        to_short_string (" 100 khz"),
        to_short_string ("  50 khz"),
        to_short_string ("  25 khz"),
        to_short_string ("  10 khz"),
        to_short_string ("   5 khz"),
        to_short_string (" 2.5 khz"),
        to_short_string ("   1 khz"),
        to_short_string ("  500 hz"),
        to_short_string ("  250 hz")
    );
    
    constant s_btn0       : short_string := to_short_string ("    BTN0");
    constant s_red        : short_string := to_short_string ("     red");
    constant s_green      : short_string := to_short_string ("   green");
    constant s_blue       : short_string := to_short_string ("    blue");
    
    constant s_continue   : short_string := to_short_string ("continue");
    constant s_stop       : short_string := to_short_string ("    stop");
    
    constant s_reading_active  : short_string := to_short_string ("    Running... (press BTN0 to stop)");
    constant s_reading_stopped : short_string := to_short_string ("Stopped. Waiting for trigger event.");
    
    
begin
    process (nrst, clk108) is
    begin
        if nrst = '0' then
            char <= character_conv_table (0);
        elsif rising_edge (clk108) then
            if segment = 14 then
                -- Upper settings segment (segment = 14)
                if subsegment = 0 then
                    -- Red subsegment
                    if column_div_8 < 19 then
                        char <= s_red_sig (column_div_8);
                    elsif column_div_8 < 22 then
                        if red_enable = '1' then
                            char <= s_enabled (column_div_8 - 19);
                        else
                            char <= s_disabled (column_div_8 - 19);
                        end if;
                    elsif column_div_8 < s_red_sig'length then
                        char <= s_red_sig (column_div_8);
                    else
                        char <= to_short_character (' ');
                    end if;
                    
                    
                elsif subsegment = 1 then
                    -- Green subsegment
                    if column_div_8 < 19 then
                        char <= s_green_sig (column_div_8);
                    elsif column_div_8 < 22 then
                        if green_enable = '1' then
                            char <= s_enabled (column_div_8 - 19);
                        else
                            char <= s_disabled (column_div_8 - 19);
                        end if;
                    elsif column_div_8 < s_green_sig'length then
                        char <= s_green_sig (column_div_8);
                    else
                        char <= to_short_character (' ');
                    end if;
                    
                    
                elsif subsegment = 2 then
                    -- Blue subsegment
                    if column_div_8 < 19 then
                        char <= s_blue_sig (column_div_8);
                    elsif column_div_8 < 22 then
                        if blue_enable = '1' then
                            char <= s_enabled (column_div_8 - 19);
                        else
                            char <= s_disabled (column_div_8 - 19);
                        end if;
                    elsif column_div_8 < s_blue_sig'length then
                        char <= s_blue_sig (column_div_8);
                    else
                        char <= to_short_character (' ');
                    end if;
                    
                    
                else
                    -- Empty subsegment
                    char <= to_short_character (' ');
                end if;
                
                
            else
                -- Lower settings segment (segment = 15)
                if subsegment = 0 then
                    -- Resolution subsegment
                    if column_div_8 < 15 then
                        char <= s_resolution (column_div_8);
                    elsif column_div_8 < 23 then
                        char <= res_array (time_resolution) (column_div_8 - 15);
                    elsif column_div_8 < s_resolution'length then
                        char <= s_resolution (column_div_8);
                    else
                        char <= to_short_character (' ');
                    end if;
                    
                    
                elsif subsegment = 1 then
                    -- Trigger subsegment
                    if column_div_8 < 15 then
                        char <= s_trigger (column_div_8);
                    elsif column_div_8 < 23 then
                        if trigger_event = RED_TRIGGER_T then
                            char <= s_red (column_div_8 - 15);
                        elsif trigger_event = GREEN_TRIGGER_T then
                            char <= s_green (column_div_8 - 15);
                        elsif trigger_event = BLUE_TRIGGER_T then
                            char <= s_blue (column_div_8 - 15);
                        else
                            char <= s_btn0 (column_div_8 - 15);
                        end if;
                    elsif column_div_8 < s_trigger'length then
                        char <= s_trigger (column_div_8);
                    else
                        char <= to_short_character (' ');
                    end if;
                    
                    
                elsif subsegment = 2 then
                    -- Behaviour after reading subsegment
                    if column_div_8 < 15 then
                        char <= s_after (column_div_8);
                    elsif column_div_8 < 23 then
                        if continue_after_reading = '1' then
                            char <= s_continue (column_div_8 - 15);
                        else
                            char <= s_stop (column_div_8 - 15);
                        end if;
                    elsif column_div_8 < s_after'length then
                        char <= s_after (column_div_8);
                    else
                        char <= to_short_character (' ');
                    end if;
                    
                    
                else
                    -- Status subsegment.
                    if column_div_8 < 125 then
                        char <= to_short_character (' ');
                    else
                        if is_reading_active = '1' then
                            char <= s_reading_active (column_div_8 - 125);
                        else
                            char <= s_reading_stopped (column_div_8 - 125);
                        end if;
                    end if;
                end if;

            end if;
        end if;
    end process;
    
    process (char_pixel, segment, subsegment) is
    begin
        if char_pixel = '1' then
            if segment = 14 then
                if subsegment = 0 then
                    vout <= "11100000";
                elsif subsegment = 1 then
                    vout <= "00011100";
                elsif subsegment = 2 then
                    vout <= "00000011";
                else
                    vout <= "11111111";
                end if;
            else
                vout <= "11111111";
            end if;
        else
            vout <= "00000000";
        end if;
    end process;
end behavioral;

