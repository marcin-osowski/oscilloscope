----------------------------------------------------------------------------------
-- Author: Marcin Osowski
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.types.all;
 
entity oscilloscope is
    port(
        uclk  : in  std_logic;  -- 32 MHz stable
        sw    : in  std_logic_vector (6 downto 0); 
        btn   : in  std_logic_vector (3 downto 0);
        red   : in  std_logic;
        green : in  std_logic;
        blue  : in  std_logic;
        
        -- Project does not use any of the below
        -- pins. They are here just to give them
        -- constant value.
        led   : out std_logic_vector (7 downto 0);
        seg   : out std_logic_vector (7 downto 0);
        an    : out std_logic_vector (3 downto 0);

        hsync : out std_logic;
        vsync : out std_logic;
        vout  : out std_logic_vector (7 downto 0)
    );
end entity oscilloscope;

architecture structural of oscilloscope is
	signal rst       : std_logic;
	signal nrst      : std_logic;
	signal clk108    : std_logic;
    signal clk108_ok : std_logic;
    signal clk10khz  : std_logic;
    
    signal sw_3_delayed  : std_logic_vector (6 downto 0);
    signal btn_3_delayed : std_logic_vector (2 downto 0);
    signal sw_debounced  : std_logic_vector (6 downto 0);
    signal btn_debounced : std_logic_vector (2 downto 0);
    
    signal red_3_delayed   : std_logic;
    signal green_3_delayed : std_logic;
    signal blue_3_delayed  : std_logic;
    
    signal trigger_btn             : std_logic;
    signal trigger_event           : TRIGGER_EVENT_T;
    signal red_enable              : std_logic;
    signal green_enable            : std_logic;
    signal blue_enable             : std_logic;
    signal continue_after_reading  : std_logic;
    signal time_resolution         : integer range 0 to 15;
    signal time_resolution_delayed : integer range 0 to 15;
    
    signal overflow_indicator  : std_logic;
    signal red_after_trigger   : std_logic;
    signal green_after_trigger : std_logic;
    signal blue_after_trigger  : std_logic;
    signal is_reading_active   : std_logic;
    
    signal flush_and_return_to_zero : std_logic;
    signal write_enable             : std_logic;
    signal reader_red_value         : std_logic;
    signal reader_green_value       : std_logic;
    signal reader_blue_value        : std_logic;
    signal reader_screen_segment    : natural range 0 to 13;
    signal reader_screen_column     : natural range 0 to 1279;

    
    signal pre_hsync : std_logic;
    signal pre_vsync : std_logic;
    signal pre_vout  : std_logic_vector (7 downto 0);
    
    signal wea   : std_logic;
    signal addra : std_logic_vector (12 downto 0);
    signal dina  : std_logic_vector (8 downto 0);
    signal addrb : std_logic_vector (12 downto 0);
    signal doutb : std_logic_vector (8 downto 0);
    
    

begin
    led <= (others => '0');
    seg <= (others => '1');
    an <= (others => '1');
	
    display_clock_108mhz: entity work.clock_108mhz
        port map (
            CLKIN_IN => uclk,
            RST_IN => btn (3),
            CLKFX_OUT => clk108,
            CLKIN_IBUFG_OUT => open,
            LOCKED_OUT => clk108_ok
        );
    

    rst <= btn (3) and clk108_ok;
    nrst <= not rst;
    
    divider_10khz: entity work.divider
        generic map (
            n => 5400
        )
        port map (
            clk_in => clk108,
            nrst => nrst,
            clk_out => clk10khz
        );
    
    btn_sw_3_delayer : entity work.n_cycles_delayer
        generic map (
            n => 3,
            signal_width => 10
        )
        port map (
            nrst => nrst,
            clk => clk10khz,
            input (9 downto 7) => btn (2 downto 0),
            input (6 downto 0) => sw (6 downto 0),
            
            output (9 downto 7) => btn_3_delayed (2 downto 0),
            output (6 downto 0) => sw_3_delayed (6 downto 0)
        );
    
    input_signals_3_delayer : entity work.n_cycles_delayer
        generic map (
            n => 3,
            signal_width => 3
        )
        port map (
            nrst => nrst,
            clk => clk108,
            input (2) => red,
            input (1) => green,
            input (0) => blue,
            
            output (2) => red_3_delayed,
            output (1) => green_3_delayed,
            output (0) => blue_3_delayed
        );
        
    btn_sw_debouncers: entity work.debouncer
        generic map (
            n => 50,
            signal_width => 10
        )
        port map (
            nrst => nrst,
            clk => clk10khz,
            input (9 downto 7) => btn_3_delayed,
            input (6 downto 0) => sw_3_delayed,
            
            output (9 downto 7) => btn_debounced,
            output (6 downto 0) => sw_debounced
        );
    
    settings: entity work.settings 
        port map (
            nrst => nrst,
            clk108 => clk108,
            sw => sw_debounced,
            btn => btn_debounced,
            trigger_btn => trigger_btn,
            trigger_event => trigger_event,
            red_enable => red_enable,
            green_enable => green_enable,
            blue_enable => blue_enable,
            continue_after_reading => continue_after_reading,
            time_resolution => time_resolution
        );
              
	trigger: entity work.trigger
        port map (
            nrst => nrst,
            clk108 => clk108,
            trigger_btn => trigger_btn,
            trigger_event => trigger_event,
            red_enable => red_enable,
            green_enable => green_enable,
            blue_enable => blue_enable,
            continue_after_reading => continue_after_reading,
            red_input => red_3_delayed,
            green_input => green_3_delayed,
            blue_input => blue_3_delayed,
            overflow_indicator => overflow_indicator,
            red_output => red_after_trigger,
            green_output => green_after_trigger,
            blue_output => blue_after_trigger,
            is_reading_active => is_reading_active
        );
        
    time_resolution_delayed <= time_resolution when rising_edge (clk108);

	reader: entity work.reader
        port map (
            nrst => nrst,
            clk108 => clk108,
            input_red => red_after_trigger,
            input_green => green_after_trigger,
            input_blue => blue_after_trigger,
            is_reading_active => is_reading_active,
            time_resolution => time_resolution_delayed,
            overflow_indicator => overflow_indicator,
            screen_segment => reader_screen_segment,
            screen_column => reader_screen_column,
            flush_and_return_to_zero => flush_and_return_to_zero,
            write_enable => write_enable,
            red_value => reader_red_value,
            green_value => reader_green_value,
            blue_value => reader_blue_value
        );

	bits_aggregator: entity work.bits_aggregator
        port map (
            nrst => nrst,
            clk108 => clk108,
            flush_and_return_to_zero => flush_and_return_to_zero,
            write_enable => write_enable,
            red_value => reader_red_value,
            green_value => reader_green_value,
            blue_value => reader_blue_value,
            wea => wea,
            addra => addra,
            dina => dina
        );



	oscilloscope_display: entity work.oscilloscope_display
        port map (
            nrst => nrst,
            clk108 => clk108,
            is_reading_active => is_reading_active,
            trigger_event => trigger_event,
            red_enable => red_enable,
            green_enable => green_enable,
            blue_enable => blue_enable,
            continue_after_reading => continue_after_reading,
            time_resolution => time_resolution,
            currently_read_screen_segment => reader_screen_segment,
            currently_read_screen_column => reader_screen_column,
            addrb => addrb,
            doutb => doutb,
            vout => pre_vout,
            vsync => pre_vsync,
            hsync => pre_hsync
        );
        
    vga_signal_formatter: entity work.one_cycle_delayer
        generic map (
            signal_width => 10
        )
        port map (
            nrst => nrst,
            clk => clk108,
            input (9 downto 2) => pre_vout,
            input (1) => pre_vsync,
            input (0) => pre_hsync,
            output (9 downto 2) => vout,
            output (1) => vsync,
            output (0) => hsync
        );
        

    trace_memory: entity work.trace_memory
      port map (
        clka => clk108,
        wea(0) => wea,
        addra => addra,
        dina => dina,
        clkb => clk108,
        rstb => rst,
        addrb => addrb,
        doutb => doutb
      );
      
	
end architecture structural;
