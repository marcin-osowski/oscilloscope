----------------------------------------------------------------------------------
-- Author: Osowski Marcin
-- Create Date:    17:31:43 05/22/2011 
--
-- Description: This entity delays given signal of width signal_width by n clock cycles.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


entity n_cycles_delayer is
    generic (
        n            : integer range 2 to 1024;
        signal_width : integer range 1 to 1024
    );
    
    port (
        nrst   : in std_logic;
        clk    : in std_logic;
        input  : in std_logic_vector (signal_width - 1 downto 0);
        output : out std_logic_vector (signal_width - 1 downto 0) 
    );
end n_cycles_delayer;

architecture behavioral of n_cycles_delayer is
    type delay_array_t is array (n - 1 downto 0) of std_logic_vector (signal_width - 1 downto 0);
    signal delay_array: delay_array_t ;--:= (others => (others => '0'));
    
begin
    output <= delay_array (n - 1);
    process (clk, nrst) is
    variable i : integer range 0 to n - 2;
    begin
        if nrst = '0' then
            for i in 0 to n - 1 loop
                delay_array (i) <= (others => '0');
            end loop;
        elsif rising_edge (clk) then
            delay_array (0) <= input;
            for i in 0 to (n - 2) loop
                delay_array (i + 1) <= delay_array (i);
            end loop;
        end if;
    end process;

end architecture behavioral;

