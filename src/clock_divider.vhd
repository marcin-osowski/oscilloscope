-- A simple frequency divider

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divider is
    --                1
    -- f_out = f_in -----
    --              2 * n
    generic (n:  natural  range 1 to 2147483647);
    port (
        clk_in  : in std_logic;
        nrst    : in std_logic;
        clk_out : out std_logic
    );
end entity divider;

architecture counter of divider is
    signal cnt              : integer range 0 to n - 1;
    signal internal_clk_out : std_logic := '0';
begin
    clk_out <= internal_clk_out;
    process (clk_in, nrst)
    begin
        if nrst = '0' then
            cnt <= 0;
            internal_clk_out <= '0';
        elsif rising_edge (clk_in) then
            if cnt = n - 1 then
                cnt <= 0;
                internal_clk_out <= not internal_clk_out;
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;
end architecture counter;
