
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.all;
 
ENTITY test_types IS
END test_types;
 
ARCHITECTURE behavior OF test_types IS 
 
    signal tested_num : integer range 0 to 127;
    signal tested_num2 : integer range 0 to 127;
    signal tested_short_char : short_character;
 
BEGIN
   stim_proc: process
   begin
      for i in 0 to 127 loop
          tested_num <= i;
          tested_short_char <= character_conv_table (i);
          wait for 1 ns;
          tested_num2 <= short_character'pos (tested_short_char);
          wait for 1 ns;
          assert tested_num = tested_num2;
          assert tested_short_char = short_character'val (i);
      end loop;
      wait;
   end process;

END;
