----------------------------------------------------------------------------------
-- Author: Osowski Marcin
-- Create Date:    21:10:21 05/22/2011 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.types.all;


entity pixgen_mux is
    port (
        nrst                 : in  std_logic;
        clk108               : in  std_logic;
        trace_vout           : in  std_logic_vector (7 downto 0);
        time_base_vout       : in  std_logic_vector (7 downto 0);
        settings_vout        : in  std_logic_vector (7 downto 0);
        active_pixgen_source : in  PIXGEN_SOURCE_T;
        vout                 : out std_logic_vector (7 downto 0)
    );
end pixgen_mux;

architecture behavioral of pixgen_mux is

begin
    process (nrst, clk108) is
    begin
        if nrst = '0' then
            vout <= "00000000";
        elsif rising_edge (clk108) then
            if active_pixgen_source = TRACE_PIXGEN_T then
                vout <= trace_vout;
            elsif active_pixgen_source = TIME_BASE_PIXGEN_T then
                vout <= time_base_vout;
            elsif active_pixgen_source = SETTINGS_PIXGEN_T then
                vout <= settings_vout;
            else
                vout <= "00000000";
            end if;
        end if;
    end process;

end behavioral;
