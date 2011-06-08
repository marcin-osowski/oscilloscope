----------------------------------------------------------------------------------
-- Author: Osowski Marcin
-- Create Date:    14:48:55 05/24/2011
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity reader is
    port (
        nrst              : in std_logic;
        clk108            : in std_logic;
        input_red         : in std_logic;
        input_green       : in std_logic;
        input_blue        : in std_logic;
        is_reading_active : in std_logic;
        time_resolution   : in integer range 0 to 15;

        -- This is an asynchronous output. It indicates that during next
        -- clock cycle entity will generate flush_and_return_to_zero.
        overflow_indicator       : out std_logic;
        
        screen_segment           : out natural range 0 to 13;
        screen_column            : out natural range 0 to 1279;
        flush_and_return_to_zero : out std_logic;
        write_enable             : out std_logic;
        red_value                : out std_logic;
        green_value              : out std_logic;
        blue_value               : out std_logic
    );
    
    constant max_time_resolution : natural := 432000;
    
    type res_array is array (0 to 15) of natural range 2 to max_time_resolution;
    
    -- Real time resolution will be given by equation:
    -- time_between_probes = time_resolutions (time_resolution) / (108 Mhz)
    -- No 1 (ones) here please!
    constant time_resolutions : res_array := (
        2, 5, 10, 20, 108, 216, 432, 1080, 2160, 4320,
        10800, 21600, 43200, 108000, 216000, 432000
    );


end reader;


architecture behavioral of reader is
    signal time_position      : natural range 0 to max_time_resolution + 1 := 0;
    signal next_time_position : natural range 0 to max_time_resolution + 1;
    signal time_overflow      : std_logic;
    
    signal memory_position      : natural range 0 to (14 * 1280) := 0;
    signal next_memory_position : natural range 0 to (14 * 1280);
    
    signal internal_screen_segment : natural range 0 to 13:= 0;
    signal internal_screen_column  : natural range 0 to 1279 := 0;
    signal next_screen_segment     : natural range 0 to 14;
    signal next_screen_column      : natural range 0 to 1280;
    
    
    signal internal_overflow_indicator : std_logic;
begin
    overflow_indicator <= internal_overflow_indicator;
    screen_segment <= internal_screen_segment;
    screen_column <= internal_screen_column;

    -- Process computes next_time_position and time_overflow
    process (time_position) is
    begin
        if time_position + 1 >= time_resolutions (time_resolution) then
            next_time_position <= 0;
            time_overflow <= '1';
        else
            next_time_position <= time_position + 1;
            time_overflow <= '0';
        end if;
    end process;
    
    -- Process computes next_memory_position and internal_overflow_indicator
    process (memory_position, internal_screen_segment, internal_screen_column, time_overflow) is
    begin
        if time_overflow = '1' then
            if memory_position + 1 >= (14 * 1280) then
                next_memory_position <= 0;
                next_screen_segment <= 0;
                next_screen_column <= 0;
                internal_overflow_indicator <= '1';
            else
                next_memory_position <= memory_position + 1;
                if internal_screen_column + 1 >= 1280 then
                    next_screen_column <= 0;
                    next_screen_segment <= internal_screen_segment + 1;
                else
                    next_screen_column <= internal_screen_column + 1;
                    next_screen_segment <= internal_screen_segment;
                end if;
                internal_overflow_indicator <= '0';
            end if;
        else
            next_memory_position <= memory_position;
            next_screen_column <= internal_screen_column;
            next_screen_segment <= internal_screen_segment;
            internal_overflow_indicator <= '0';
        end if;
    end process;
    
    
    process (nrst, clk108) is
    begin
        if nrst = '0' then
            time_position <= 0;
            memory_position <= 0;
            flush_and_return_to_zero <= '0';
            write_enable <= '0';
            red_value <= '0';
            green_value <= '0';
            blue_value <= '0';
        elsif rising_edge (clk108) then
            memory_position <= next_memory_position;
            internal_screen_column <= next_screen_column;
            internal_screen_segment <= next_screen_segment;
            if is_reading_active = '1' or time_position /= 0 then
                time_position <= next_time_position;
                if time_overflow = '1' then
                    red_value <= input_red;
                    green_value <= input_green;
                    blue_value <= input_blue;
                    write_enable <= '1';
                    flush_and_return_to_zero <= internal_overflow_indicator;
                else
                    red_value <= '0';
                    green_value <= '0';
                    blue_value <= '0';
                    write_enable <= '0';
                    flush_and_return_to_zero <= '0';
                end if;
            else
                red_value <= '0';
                green_value <= '0';
                blue_value <= '0';
                write_enable <= '0';
                flush_and_return_to_zero <= '0';
            end if;
        end if;
    end process;

end behavioral;
