----------------------------------------------------------------------------------
-- Author: Osowski Marcin
-- Create Date:    17:46:36 05/28/2011 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity char_rom_mux is
    port (
        -- Inputs
        nrst                 : in std_logic;
        clk108               : in std_logic;
        active_pixgen_source : in PIXGEN_SOURCE_T;
        char_pos_x           : in integer range 0 to 7;
        char_pos_y           : in integer range 0 to 15;
        time_base_char       : in short_character;
        settings_char        : in short_character;
        
        char_pixel           : out std_logic
    );
end char_rom_mux;

architecture behavioral of char_rom_mux is
    signal addra    : std_logic_vector (13 downto 0);
    signal douta    : std_logic;
    signal char_int : integer range 0 to 127;
    signal char_lv  : std_logic_vector (6 downto 0);
    signal pos_x_lv : std_logic_vector (2 downto 0);
    signal pos_y_lv : std_logic_vector (3 downto 0);
begin
    char_rom_memory: entity work.char_rom_memory
        port map (
            clka => clk108,
            addra => addra,
            douta(0) => douta
        );
    
    char_pixel <= '0' when nrst = '0' else douta;
    
    with active_pixgen_source select
        char_int <= 
            short_character'pos (time_base_char) when TIME_BASE_PIXGEN_T,
            short_character'pos (settings_char)  when SETTINGS_PIXGEN_T,
            0                                    when others;
    char_lv <= std_logic_vector (to_unsigned (char_int, 7));
    pos_x_lv <= std_logic_vector (to_unsigned (char_pos_x, 3));
    pos_y_lv <= std_logic_vector (to_unsigned (char_pos_y, 4));
            
    
    addra <= char_lv (6 downto 4) & pos_y_lv & char_lv (3 downto 0) & pos_x_lv;

end behavioral;

