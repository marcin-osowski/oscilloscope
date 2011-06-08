library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity screen_position_gen is
    port (
        -- inputs
        nrst                 : in std_logic;
        clk108               : in std_logic;
        vblank               : in std_logic;
        in_line_change       : in std_logic;
        in_page_change       : in std_logic;
        in_column            : in integer range 0 to 1279;
        in_column_change     : in std_logic;
        
        -- outputs
        segment              : out integer range 0 to 15;
        segment_change       : out std_logic;
        subsegment           : out integer range 0 to 3;
        subsegment_change    : out std_logic;
        line                 : out integer range 0 to 15;
        out_line_change      : out std_logic;
        out_column           : out integer range 0 to 1279;
        out_column_mod_8     : out integer range 0 to 7;
        out_column_div_8     : out integer range 0 to 159;
        out_column_change    : out std_logic;
        out_page_change      : out std_logic;
        active_pixgen_source : out PIXGEN_SOURCE_T
    );
end screen_position_gen;


architecture behavioral of screen_position_gen is
    signal internal_segment    : integer range 0 to 15;
    signal internal_subsegment : integer range 0 to 3;
    signal internal_line       : integer range 0 to 15;

    signal next_segment    : integer range 0 to 15;
    signal next_subsegment : integer range 0 to 3;
    signal next_line       : integer range 0 to 15;
    
begin
    segment <= internal_segment;
    subsegment <= internal_subsegment;
    line <= internal_line;
    
    -- This process calculates next_line, next_subsegment, next_segment signals
    process (in_line_change, in_page_change, internal_segment, internal_subsegment, internal_line) is
    begin
        if in_page_change = '1' then
            next_line <= 0;
            next_subsegment <= 0;
            next_segment <= 0;
        else
            if in_line_change = '1' then
                if internal_line = 15 then
                    next_line <= 0;
                    if internal_subsegment = 3 then
                        next_subsegment <= 0;
                        if internal_segment = 15 then
                            next_segment <= 0;
                        else
                            next_segment <= internal_segment + 1;
                        end if;
                    else
                        next_subsegment <= internal_subsegment + 1;
                        next_segment <= internal_segment;
                    end if;
                else
                    next_line <= internal_line + 1;
                    next_subsegment <= internal_subsegment;
                    next_segment <= internal_segment;
                end if;
            else
                next_line <= internal_line;
                next_subsegment <= internal_subsegment;
                next_segment <= internal_segment;
            end if;
        end if;
    end process;
    
    -- This proces generates all output signals
    process (clk108, nrst) is
    begin
        if nrst = '0' then
            
        elsif rising_edge (clk108) then
            internal_line <= next_line;
            internal_subsegment <= next_subsegment;
            internal_segment <= next_segment;
            out_line_change <= in_line_change;
            
            if internal_subsegment /= next_subsegment then
                subsegment_change <= '1';
            else
                subsegment_change <= '0';
            end if;
            
            if internal_segment /= next_segment then
                segment_change <= '1';
            else
                segment_change <= '0';
            end if;
            
            out_column <= in_column;
            out_column_mod_8 <= in_column mod 8;
            out_column_div_8 <= in_column / 8;
            out_column_change <= in_column_change;           
            out_page_change <= in_page_change;
            
            if vblank = '1' then
                active_pixgen_source <= BLANK_PIXGEN_T;
            elsif next_segment < 14 then
                if next_subsegment /= 3 then
                    active_pixgen_source <= TRACE_PIXGEN_T;
                else
                    active_pixgen_source <= TIME_BASE_PIXGEN_T;
                end if;
            else
                active_pixgen_source <= SETTINGS_PIXGEN_T;
            end if;
        end if;
    end process;
end architecture behavioral;
