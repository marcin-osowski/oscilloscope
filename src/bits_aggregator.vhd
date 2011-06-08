----------------------------------------------------------------------------------
-- Author:         Osowski Marcin
-- Create Date:    19:43:33 05/27/2011
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bits_aggregator is
    port (
        -- Inputs
        nrst                     : in std_logic;
        clk108                   : in std_logic;
        flush_and_return_to_zero : in std_logic;
        write_enable             : in std_logic;
        red_value                : in std_logic;
        green_value              : in std_logic;
        blue_value               : in std_logic;
        
        -- Outputs
        wea   : out std_logic;
        addra : out std_logic_vector (12 downto 0);
        dina  : out std_logic_vector (8 downto 0)
    );
end bits_aggregator;

architecture behavioral of bits_aggregator is
    signal mod3          : integer range 0 to 2 := 0;
    signal next_mod3     : integer range 0 to 2;
    signal mod3_overflow : std_logic := '0';
    
    signal address       : std_logic_vector (12 downto 0) := (others => '0');
    signal next_address  : std_logic_vector (12 downto 0);
    
    signal row_buffer : std_logic_vector (5 downto 0) := (others => '0');
    signal next_row : std_logic_vector (8 downto 0) := (others => '0');
begin
    
    -- Process calculates next_mod3, mod3_overflow, next_address
    process (mod3, address) is
    begin
        if mod3 = 2 then
            next_mod3 <= 0;
            mod3_overflow <= '1';
            next_address <= address + 1;
        else
            next_mod3 <= mod3 + 1;
            mod3_overflow <= '0';
            next_address <= address;
        end if;
    end process;
    
    -- Process calculates next_row
    process (mod3, row_buffer, red_value, green_value, blue_value) is
    begin
        if mod3 = 0 then
            next_row (0) <= red_value;
            next_row (1) <= green_value;
            next_row (2) <= blue_value;
            next_row (8 downto 3) <= (others => '0');
        elsif mod3 = 1 then
            next_row (2 downto 0) <= row_buffer (2 downto 0);
            next_row (3) <= red_value;
            next_row (4) <= green_value;
            next_row (5) <= blue_value;
            next_row (8 downto 6) <= (others => '0');
        else
            next_row (5 downto 0) <= row_buffer (5 downto 0);
            next_row (6) <= red_value;
            next_row (7) <= green_value;
            next_row (8) <= blue_value;
        end if;
    end process;
    
    process (nrst, clk108) is
    begin
        if nrst = '0' then
            mod3 <= 0;
            address <= (others => '0');
            wea <= '0';
            addra <= (others => '0');
            dina <= (others => '0');
        elsif rising_edge (clk108) then
            if flush_and_return_to_zero = '1' then
                mod3 <= 0;
                address <= (others => '0');
                row_buffer <= (others => '0');
                addra <= address;
                dina  <= next_row;
                wea <= '1';
            elsif write_enable = '1' then
                mod3 <= next_mod3;
                address <= next_address;
                row_buffer <= next_row (5 downto 0);
                if mod3_overflow = '1' then
                    addra <= address;
                    dina  <= next_row;
                    wea <= '1';
                else
                    wea <= '0';
                end if;
            else
                wea <= '0';
            end if;
        end if;
    end process;


end behavioral;

