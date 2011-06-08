----------------------------------------------------------------------------------
-- Author: Osowski Marcin
-- Create Date:    16:19:05 05/24/2011 
--
-- Description: This entity delays given signal of width signal_width by n clock cycles.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


entity one_cycle_delayer is
    generic (
        signal_width : integer range 1 to 1024
    );
    
    port (
        nrst   : in std_logic;
        clk    : in std_logic;
        input  : in std_logic_vector (signal_width - 1 downto 0);
        output : out std_logic_vector (signal_width - 1 downto 0) 
    );
end one_cycle_delayer;

architecture behavioral of one_cycle_delayer is

begin
    process (clk, nrst) is
    begin
        if nrst = '0' then
            output <= (others => '0');
        elsif rising_edge (clk) then
            output <= input;
        end if;
    end process;
end behavioral;

