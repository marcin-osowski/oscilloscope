----------------------------------------------------------------------------------
-- Author: Osowski Marcin
-- Create Date:    20:16:43 05/22/2011 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity time_base_pixgen is
    port (
        nrst                 : in  std_logic;
        clk108               : in  std_logic;
        segment              : in integer range 0 to 15;
        segment_change       : in std_logic;
        subsegment           : in integer range 0 to 3;
        subsegment_change    : in std_logic;
        line                 : in integer range 0 to 15;
        line_change          : in std_logic;
        column               : in integer range 0 to 1279;
        column_change        : in std_logic;
        page_change          : in std_logic;
        active_pixgen_source : in PIXGEN_SOURCE_T;
        char                 : out short_character;
        char_pixel           : in std_logic;
        vout                 : out std_logic_vector (7 downto 0)
    );
end time_base_pixgen;

architecture behavioral of time_base_pixgen is
    signal output : std_logic;
begin
    char <= to_short_character (NUL);
    process (clk108, nrst) is
    begin
        if nrst = '0' then
            output <= '0';
        elsif rising_edge (clk108) then
            if line = 2 or line = 3 or line = 4 or line = 11 or line = 12 or line = 13 then
                if column mod 128 = 127 then
                    output <= '1';
                else
                    output <= '0';
                end if;
            elsif line = 5 or line = 10 then
                if column mod 64 = 63 then
                    output <= '1';
                else
                    output <= '0';
                end if;
            elsif line = 6 or line = 7 or line = 8 or line = 9 then
                if column mod 16 = 15 then
                    output <= '1';
                else
                    output <= '0';
                end if;
            else
                output <= '1';
            end if;
        end if;
    end process;
    
    process (clk108, nrst) is
    begin
        if nrst = '0' then
            vout <= "00000000";
        elsif rising_edge (clk108) then
            if output = '1' then
                vout <= "11111111";
            else
                vout <= "00000000";
            end if;
        end if;
    end process;
end behavioral;
