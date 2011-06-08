----------------------------------------------------------------------------------
-- Author: Osowski Marcin
-- Create Date:    13:36:26 05/24/2011 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;


entity settings is
    port (
        -- Inputs
        nrst   : in std_logic;
        clk108 : in std_logic;
        sw     : in std_logic_vector (6 downto 0);
        btn    : in std_logic_vector (2 downto 0);

        -- Outputs
        trigger_btn            : out std_logic := '0';
        trigger_event          : out TRIGGER_EVENT_T;
        red_enable             : out std_logic := '0';
        green_enable           : out std_logic := '0';
        blue_enable            : out std_logic := '0';
        continue_after_reading : out std_logic;
        time_resolution        : out integer range 0 to 15 := 0
    );
end settings;

architecture behavioral of settings is
    signal prev_btn_1 : std_logic := '0';
    signal prev_btn_2 : std_logic := '0';
    
    signal internal_continue_after_reading : std_logic := '0';
    signal internal_trigger_event          : TRIGGER_EVENT_T := BUTTON_TRIGGER_T;

begin
    continue_after_reading <= internal_continue_after_reading;
    trigger_event <= internal_trigger_event;
    
    process (nrst, clk108) is
    begin
        if nrst = '0' then
            trigger_btn <= '0';
            internal_trigger_event <= BUTTON_TRIGGER_T;
            red_enable <= '0';
            green_enable <= '0';
            blue_enable <= '0';
            internal_continue_after_reading <= '0';
            time_resolution <= 0;
            prev_btn_1 <= '0';
            prev_btn_2 <= '0';
        elsif rising_edge (clk108) then
            trigger_btn <= btn (0);
            
            prev_btn_2 <= btn (2);
            if btn (2) = '1' and prev_btn_2 = '0' then
                -- cycle through available modes
                if internal_trigger_event = BUTTON_TRIGGER_T then
                    internal_trigger_event <= RED_TRIGGER_T;
                elsif internal_trigger_event = RED_TRIGGER_T then
                    internal_trigger_event <= GREEN_TRIGGER_T;
                elsif internal_trigger_event = GREEN_TRIGGER_T then
                    internal_trigger_event <= BLUE_TRIGGER_T;
                elsif internal_trigger_event = BLUE_TRIGGER_T then
                    internal_trigger_event <= BUTTON_TRIGGER_T;
                end if;
            end if;
            
            red_enable <= sw (6);
            green_enable <= sw (5);
            blue_enable <= sw (4);
            
            prev_btn_1 <= btn (1);
            if btn (1) = '1' and prev_btn_1 = '0' then
                internal_continue_after_reading <= not internal_continue_after_reading;
            end if;
            time_resolution <= to_integer (unsigned (sw (3 downto 0)));
        end if;
    end process;

end behavioral;