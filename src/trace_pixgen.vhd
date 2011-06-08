----------------------------------------------------------------------------------
-- Author: Osowski Marcin
-- Create Date:    20:16:43 05/22/2011 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity trace_pixgen is
    port (
        nrst                          : in  std_logic;
        clk108                        : in  std_logic;
        segment                       : in integer range 0 to 15;
        segment_change                : in std_logic;
        subsegment                    : in integer range 0 to 3;
        subsegment_change             : in std_logic;
        line                          : in integer range 0 to 15;
        line_change                   : in std_logic;
        column                        : in integer range 0 to 1279;
        column_change                 : in std_logic;
        page_change                   : in std_logic;
        active_pixgen_source          : in PIXGEN_SOURCE_T;
        currently_read_screen_segment : in natural range 0 to 13;
        currently_read_screen_column  : in natural range 0 to 1279;
        time_resolution               : in integer range 0 to 15;
        is_reading_active             : in std_logic;
        doutb                         : in  std_logic_vector (8 downto 0);
        addrb                         : out std_logic_vector (12 downto 0);
        vout                          : out std_logic_vector (7 downto 0)
    );
end trace_pixgen;

architecture behavioral of trace_pixgen is
    signal position_div_3 : integer range 0 to 5973;
    signal position_mod_3 : integer range 0 to 2;
    
    signal delayed_active_pixgen_source : PIXGEN_SOURCE_T;
    signal delayed_subsegment           : integer range 0 to 3;
    signal delayed_position_mod_3       : integer range 0 to 2;
    signal delayed_line                 : integer range 0 to 15;
    
    
    signal position_div_3_on_beginning_segment : integer range 0 to 5973;
    signal position_mod_3_on_beginning_segment : integer range 0 to 2;
    
    
    signal currently_inside_reading_zone : std_logic;
    
begin
    -- Computing current position
    process (nrst, clk108, position_mod_3, position_div_3) is
    variable incremented_position_div_3 : integer range 0 to 5973;
    variable incremented_position_mod_3 : integer range 0 to 2;
    begin
        if position_mod_3 = 2 then
            incremented_position_div_3 := position_div_3 + 1;
            incremented_position_mod_3 := 0;
        else
            incremented_position_div_3 := position_div_3;
            incremented_position_mod_3 := position_mod_3 + 1;
        end if;
        
        
        if nrst = '0' then
            position_div_3 <= 0;
            position_mod_3 <= 0;
            currently_inside_reading_zone <= '0';
        elsif rising_edge (clk108) then
            if currently_read_screen_segment = 0 and currently_read_screen_column = 0 then
                currently_inside_reading_zone <= '0';
            else
                if time_resolution >= 10 or is_reading_active = '0' then
                    if segment = currently_read_screen_segment and
                       column - currently_read_screen_column < 6 and
                       column - currently_read_screen_column >= 0 then
                        currently_inside_reading_zone <= '1';
                    else
                        currently_inside_reading_zone <= '0';
                    end if;
                elsif time_resolution >= 7 then
                    if segment = currently_read_screen_segment then
                        currently_inside_reading_zone <= '1';
                    else
                        currently_inside_reading_zone <= '0';
                    end if;
                else
                    currently_inside_reading_zone <= '0';
                end if;
            end if;
            if active_pixgen_source = TRACE_PIXGEN_T then
                if page_change = '1' then
                    position_div_3 <= 0;
                    position_mod_3 <= 0;
                    position_div_3_on_beginning_segment <= 0;
                    position_mod_3_on_beginning_segment <= 0;
                elsif segment_change = '1' then
                    position_div_3 <= incremented_position_div_3;
                    position_mod_3 <= incremented_position_mod_3;
                    position_div_3_on_beginning_segment <= incremented_position_div_3;
                    position_mod_3_on_beginning_segment <= incremented_position_mod_3;
                elsif line_change = '1' then
                    position_div_3 <= position_div_3_on_beginning_segment;
                    position_mod_3 <= position_mod_3_on_beginning_segment;
                else
                    position_div_3 <= incremented_position_div_3;
                    position_mod_3 <= incremented_position_mod_3;
                end if;
            end if;
        end if;
    end process;
    
    addrb <= std_logic_vector (to_unsigned (position_div_3, 13));
    
    delayed_active_pixgen_source <= active_pixgen_source when rising_edge (clk108);
    delayed_subsegment <= subsegment when rising_edge (clk108);
    delayed_position_mod_3 <= position_mod_3 when rising_edge (clk108);
    delayed_line <= line when rising_edge (clk108);

    
    process (nrst, delayed_active_pixgen_source, delayed_subsegment, delayed_position_mod_3, delayed_line, currently_inside_reading_zone) is
    begin
        if nrst = '0' or delayed_active_pixgen_source /= TRACE_PIXGEN_T then
            vout <= "00000000";
        else
            if currently_inside_reading_zone = '1' then
                vout <= "10010010";
            elsif delayed_subsegment = 0 then
                -- red
                if delayed_line = 15 then
                    vout <= "11100000";
                elsif doutb (3 * delayed_position_mod_3) = '1' then
                    vout <= "11100000";
                else
                    vout <= "00000000";
                end if;
            elsif delayed_subsegment = 1 then
                -- green
                if delayed_line = 15 then
                    vout <= "00011100";
                elsif doutb (3 * delayed_position_mod_3 + 1) = '1' then
                    vout <= "00011100";
                else
                    vout <= "00000000";
                end if;
            elsif delayed_subsegment = 2 then
                -- blue
                if delayed_line = 15 then
                    vout <= "00000011";
                elsif doutb (3 * delayed_position_mod_3 + 2) = '1' then
                    vout <= "00000011";
                else
                    vout <= "00000000";
                end if;
            else
                vout <= "00000000";
            end if;
        end if;
    end process;
    
end behavioral;

