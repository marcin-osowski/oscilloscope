----------------------------------------------------------------------------------
-- Author: Osowski Marcin
-- Create Date:    15:03:57 05/24/2011 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


entity debouncer is
    generic (
        n            : natural := 5000;
        signal_width : natural := 8
    );
    port (
        nrst   : in std_logic;
        clk    : in std_logic;
        input  : in std_logic_vector (signal_width - 1 downto 0);
        output : out std_logic_vector (signal_width - 1 downto 0)
    );
end debouncer;

architecture behavioral of debouncer is
begin
    debouncers: for i in 0 to signal_width - 1 generate
        one_debouncer: entity work.single_debouncer
            generic map (
                n => n
            )
            port map(
                nrst => nrst,
                clk => clk,
                input => input (i),
                output => output (i)
            );
    end generate debouncers;

end behavioral;

