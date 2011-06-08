
package types is

    type PIXGEN_SOURCE_T is (
        TRACE_PIXGEN_T,
        TIME_BASE_PIXGEN_T,
        SETTINGS_PIXGEN_T,
        BLANK_PIXGEN_T
    );

    type TRIGGER_EVENT_T is (
        RED_TRIGGER_T,
        GREEN_TRIGGER_T,
        BLUE_TRIGGER_T,
        BUTTON_TRIGGER_T
    );
    
    
    
    -- This stupid thing is workaround a bug in ISE 13.1 XST synthesis tool
    -- It does not understand character'val(...) statements.
    type character_array_128 is array (0 to 127) of character;
    constant character_conv_table : character_array_128 :=
        (
            NUL, SOH, STX, ETX, EOT, ENQ, ACK, BEL, BS, HT, LF, VT, FF, CR, SO,
            SI, DLE, DC1, DC2, DC3, DC4, NAK, SYN, ETB, CAN, EM, SUB, ESC, FSP, GSP,
            RSP, USP, ' ', '!', '"', '#', '$', '%', '&', ''', '(', ')', '*', '+', ',',
            '-', '.', '/', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':', ';',
            '<', '=', '>', '?', '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
            'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y',
            'Z', '[', '\', ']', '^', '_', '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
            'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w',
            'x', 'y', 'z', '{', '|', '}', '~', DEL
        );
    
    -- short_character differs from character only by its range.
    -- It has 128 first characters.
    subtype short_character is character range character_conv_table (0) to character_conv_table (127);
            
    -- short_string differs from string by:
    --    o it's built of short_character's
    --    o it's indexed from 0
    type short_string is array (natural range <>) of short_character;
    
    function to_short_character ( c : character ) return short_character;
    function to_short_string ( s : string ) return short_string;
    
end types;

package body types is

    function to_short_character ( c : character ) return short_character is
    begin
        return character_conv_table (character'pos (c) mod 128);
    end function to_short_character;


    function to_short_string ( s: string ) return short_string is
    variable out_s : short_string (s'length - 1 downto 0);
    begin
        for i in s'length downto 1 loop
            out_s (i - 1) := to_short_character (s (i));
        end loop;
        return out_s;
    end function to_short_string;
  
  


end types;
