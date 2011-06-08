----------------------------------------------------------------------------------
-- Author: Osowski Marcin
--
-- Description:
--     o Entity generates impulses required for managing
--       vga port in 1280x1024@60hz mode
--
--     o It requires 108 Mhz input clock
--
--     o It generates vblank signal. Whenever it's active,
--       vga color output should be set to "00000000" (all black).
--       It indicates an off-the-screen position.
--
--     o Sync pulses schema:
--
-- timing diagram for the horizontal synch signal (HS)
-- 0                         1328   1440           1680 (pixels)
-- -------------------------|______|-------------------
-- timing diagram for the vertical synch signal (VS)
-- 0                                   1025   1028 1066 (lines)
-- -----------------------------------|______|---------
--
--
--
--     o For "next entities" (video signal generators), it generates signals line_change
--       and page_change. They are set to '1' for one clock cycle just before
--       there's a change in (appropriately) current line or current page.
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity vga_controller_1280_1024 is
    port (
        nrst          : in  std_logic;
        clk108        : in  std_logic;
        hsync         : out std_logic;
        vsync         : out std_logic;
        vblank        : out std_logic;
        line_change   : out std_logic;
        page_change   : out std_logic;
        column        : out integer range 0 to 1279;
        column_change : out std_logic
    );
end vga_controller_1280_1024;

architecture behavioral of vga_controller_1280_1024 is

    
    constant HFrontPorch : integer := 1280;
    constant HSyncPulse  : integer := 1328;
    constant HBackPorch  : integer := 1440;
    constant HTotal      : integer := 1688;
    
    constant VFrontPorch : integer := 1024;
    constant VSyncPulse  : integer := 1025;
    constant VBackPorch  : integer := 1028;
    constant VTotal      : integer := 1066;
    
    signal hcount: integer range 0 to 1687 := 0;
    signal vcount: integer range 0 to 1065 := 0;
    
    signal next_hcount: integer range 0 to 1687;
    signal next_vcount: integer range 0 to 1065;
    
    signal internal_column    : integer range 0 to 1279;
    signal next_column        : integer range 0 to 1279;
    signal next_column_change : std_logic;
    
begin

    -- Generating next_hcount.
    next_hcount <= hcount + 1 when hcount < (HTotal - 1) else 0;
    
    -- Generating next_vcount.
    process (vcount, next_hcount) is
    begin
        if next_hcount = 0 then
            if vcount < (VTotal - 1) then
                next_vcount <= vcount + 1;
            else
                next_vcount <= 0;
            end if;
        else
            next_vcount <= vcount;
        end if;
    end process;
    
    -- Generating next_column and next_column_change.
    process (next_hcount, internal_column, next_column) is
    begin
        if (next_hcount >= 1280) then
            next_column <= 1279;
        else
            next_column <= next_hcount;
        end if;
        
        if next_column /= internal_column then
            next_column_change <= '1';
        else
            next_column_change <= '0';
        end if;
    end process;
    
    column <= internal_column;

    
    -- Generating sync pulses and line_change, page_change signals.
    process (nrst, clk108) is
    begin
        if nrst = '0' then
            line_change <= '0';
            page_change <= '0';
            hsync <= '0';
            vsync <= '0';
            vblank <= '0';
            internal_column <= 0;
            column_change <= '0';
        elsif rising_edge (clk108) then
            if vcount /= next_vcount then
                line_change <= '1';
            else
                line_change <= '0';
            end if;
            if vcount /= next_vcount and next_vcount = 0 then
                page_change <= '1';
            else
                page_change <= '0';
            end if;
            
            hcount <= next_hcount;
            if (next_hcount >= 1280) then
                internal_column <= 1279;
            else
                internal_column <= next_hcount;
            end if;
            column_change <= next_column_change;
            vcount <= next_vcount;
            
            if next_hcount < HFrontPorch and next_vcount < VFrontPorch then
                vblank <= '0';
            else
                vblank <= '1';
            end if;
            
            if next_hcount >= HSyncPulse and next_hcount < HBackPorch then
                hsync <= '1';
            else
                hsync <= '0';
            end if;
            
            if next_vcount >= VSyncPulse and next_vcount < VBackPorch then
                vsync <= '1';
            else
                vsync <= '0';
            end if;
        end if;
    end process;

end architecture behavioral;
