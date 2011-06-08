----------------------------------------------------------------------------------
-- Author: Osowski Marcin
-- Create Date:    15:03:57 05/24/2011 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity single_debouncer is
    generic (
        n : natural := 5000
    );
    port (
        nrst   : in std_logic;
        clk    : in std_logic;
        input  : in std_logic;
        output : out std_logic
    );
end single_debouncer;

architecture behavioral of single_debouncer is
    signal counter: natural range 0 to n := 0;
    signal output2: std_logic := '0';
begin
  output <= output2;
  process (clk, nrst) is
  begin
    if nrst = '0' then
        counter <= 0;
        output2 <= '0';
    elsif rising_edge (clk) then
      if counter >= n then
        if output2 /= input then
          output2 <= input;
          counter <= 0;
        end if;
      else
        counter <= counter + 1;
      end if;
    end if;
  end process;
end behavioral;


