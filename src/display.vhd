----------------------------------------------------------------------------------
-- Author: Osowski Marcin
-- Create Date:    15:58:36 05/22/2011
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;


entity oscilloscope_display is
    port (
        nrst                          : in  std_logic;
        clk108                        : in  std_logic;
        is_reading_active             : in std_logic;
        trigger_event                 : in TRIGGER_EVENT_T;
        red_enable                    : in std_logic;
        green_enable                  : in std_logic;
        blue_enable                   : in std_logic;
        continue_after_reading        : in std_logic;
        time_resolution               : in integer range 0 to 15;
        currently_read_screen_segment : in natural range 0 to 13;
        currently_read_screen_column  : in natural range 0 to 1279;
        addrb                         : out std_logic_vector (12 downto 0);
        doutb                         : in  std_logic_vector (8 downto 0);
        vout                          : out std_logic_vector (7 downto 0);
        vsync                         : out std_logic;
        hsync                         : out std_logic
    );
end oscilloscope_display;

architecture behavioral of oscilloscope_display is
    signal vga_cntl_line_change   : std_logic;
    signal vga_cntl_page_change   : std_logic;
    signal vga_cntl_column        : integer range 0 to 1279;
    signal vga_cntl_column_change : std_logic;
    signal vga_cntl_vblank        : std_logic;
    signal vga_cntl_hsync         : std_logic;
    signal vga_cntl_vsync         : std_logic;
    
    signal scr_pos_segment              : integer range 0 to 15;
    signal scr_pos_segment_change       : std_logic;
    signal scr_pos_subsegment           : integer range 0 to 3;
    signal scr_pos_subsegment_change    : std_logic;
    signal scr_pos_line                 : integer range 0 to 15;
    signal scr_pos_out_line_change      : std_logic;
    signal scr_pos_out_column           : integer range 0 to 1279;
    signal scr_pos_out_column_mod_8     : integer range 0 to 7;
    signal scr_pos_out_column_div_8     : integer range 0 to 159;
    signal scr_pos_column_change        : std_logic;
    signal scr_pos_out_page_change      : std_logic;
    signal scr_pos_active_pixgen_source : PIXGEN_SOURCE_T;
    
    
    signal scr_pos_out_column_mod_8_delayed       : integer range 0 to 7;
    signal scr_pos_line_delayed                   : integer range 0 to 15;
    
    signal scr_pos_active_pixgen_source_delayed_1 : PIXGEN_SOURCE_T;
    signal scr_pos_active_pixgen_source_delayed_2 : PIXGEN_SOURCE_T;
    
    signal time_base_char          : short_character;
    signal settings_char           : short_character;
    signal char_rom_mux_char_pixel : std_logic;
    
    signal trace_vout     : std_logic_vector (7 downto 0);
    signal time_base_vout : std_logic_vector (7 downto 0);
    signal settings_vout  : std_logic_vector (7 downto 0);
    
begin

	vga_controller_1280_1024: entity work.vga_controller_1280_1024
        port map (
            nrst => nrst,
            clk108 => clk108,
            hsync => vga_cntl_hsync,
            vsync => vga_cntl_vsync,
            vblank => vga_cntl_vblank,
            line_change => vga_cntl_line_change,
            page_change => vga_cntl_page_change,
            column => vga_cntl_column,
            column_change => vga_cntl_column_change
        );
        
        
        
 	screen_position_gen: entity work.screen_position_gen
        port map (
            nrst => nrst,
            clk108 => clk108,
            vblank => vga_cntl_vblank,
            in_line_change => vga_cntl_line_change,
            in_page_change => vga_cntl_page_change,
            in_column => vga_cntl_column,
            in_column_change => vga_cntl_column_change,
            
            segment => scr_pos_segment, 
            segment_change => scr_pos_segment_change,
            subsegment => scr_pos_subsegment,
            subsegment_change => scr_pos_subsegment_change,
            line => scr_pos_line,
            out_line_change => scr_pos_out_line_change,
            out_column => scr_pos_out_column,
            out_column_mod_8 => scr_pos_out_column_mod_8,
            out_column_div_8 => scr_pos_out_column_div_8,
            out_column_change => scr_pos_column_change,
            out_page_change => scr_pos_out_page_change,
            active_pixgen_source => scr_pos_active_pixgen_source
        );
        
 	trace_pixgen: entity work.trace_pixgen
        port map (
            nrst => nrst,
            clk108 => clk108,
            segment => scr_pos_segment, 
            segment_change => scr_pos_segment_change,
            subsegment => scr_pos_subsegment,
            subsegment_change => scr_pos_subsegment_change,
            line => scr_pos_line,
            line_change => scr_pos_out_line_change,
            column => scr_pos_out_column,
            column_change => scr_pos_column_change,
            page_change => scr_pos_out_page_change,
            active_pixgen_source => scr_pos_active_pixgen_source,
            currently_read_screen_segment => currently_read_screen_segment,
            currently_read_screen_column => currently_read_screen_column,
            time_resolution => time_resolution,
            is_reading_active => is_reading_active,
            doutb => doutb,
            addrb => addrb,
            vout => trace_vout
        );
        
    scr_pos_out_column_mod_8_delayed <= scr_pos_out_column_mod_8 when rising_edge (clk108);
    scr_pos_line_delayed <= scr_pos_line when rising_edge (clk108);
    scr_pos_active_pixgen_source_delayed_1 <= scr_pos_active_pixgen_source when rising_edge (clk108);
    scr_pos_active_pixgen_source_delayed_2 <= scr_pos_active_pixgen_source_delayed_1 when rising_edge (clk108);
        
    char_rom_mux: entity work.char_rom_mux
        port map (
            nrst => nrst,
            clk108 => clk108,
            active_pixgen_source => scr_pos_active_pixgen_source_delayed_1,
            char_pos_x => scr_pos_out_column_mod_8_delayed,
            char_pos_y => scr_pos_line_delayed,
            time_base_char => time_base_char,
            settings_char => settings_char,
            char_pixel => char_rom_mux_char_pixel
        );
          
 	time_base_pixgen: entity work.time_base_pixgen
        port map (
            nrst => nrst,
            clk108 => clk108,
            segment => scr_pos_segment, 
            segment_change => scr_pos_segment_change,
            subsegment => scr_pos_subsegment,
            subsegment_change => scr_pos_subsegment_change,
            line => scr_pos_line,
            line_change => scr_pos_out_line_change,
            column => scr_pos_out_column,
            column_change => scr_pos_column_change,
            page_change => scr_pos_out_page_change,
            active_pixgen_source => scr_pos_active_pixgen_source,
            char => time_base_char,
            char_pixel => char_rom_mux_char_pixel,
            vout => time_base_vout
        );
        
 	settings_pixgen: entity work.settings_pixgen
        port map (
            nrst => nrst,
            clk108 => clk108,
            segment => scr_pos_segment, 
            segment_change => scr_pos_segment_change,
            subsegment => scr_pos_subsegment,
            subsegment_change => scr_pos_subsegment_change,
            line => scr_pos_line,
            line_change => scr_pos_out_line_change,
            column => scr_pos_out_column,
            column_div_8 => scr_pos_out_column_div_8,
            column_mod_8 => scr_pos_out_column_mod_8,
            column_change => scr_pos_column_change,
            page_change => scr_pos_out_page_change,
            active_pixgen_source => scr_pos_active_pixgen_source,
            is_reading_active => is_reading_active,
            trigger_event => trigger_event,
            red_enable => red_enable,
            green_enable => green_enable,
            blue_enable => blue_enable,
            continue_after_reading => continue_after_reading,
            time_resolution => time_resolution,
            char => settings_char,
            char_pixel => char_rom_mux_char_pixel,
            vout => settings_vout
        );
        
    
 	pixgen_mux: entity work.pixgen_mux
        port map (
            nrst => nrst,
            clk108 => clk108,
            trace_vout => trace_vout,
            time_base_vout => time_base_vout,
            settings_vout => settings_vout,
            active_pixgen_source => scr_pos_active_pixgen_source_delayed_2,
            vout => vout
        );
        
    vga_sync_signals_4_delay: entity work.n_cycles_delayer
        generic map (
            n => 4,
            signal_width => 2
        )
        port map (
            nrst => nrst,
            clk => clk108,
            input(0) => vga_cntl_hsync,
            input(1) => vga_cntl_vsync,
            output(0) => hsync,
            output(1) => vsync
        );

end behavioral;

