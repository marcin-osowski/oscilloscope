LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY test_compiler_error IS
END test_compiler_error;
 
ARCHITECTURE behavior OF test_compiler_error IS 
   signal output : std_logic_vector(7 downto 0);
BEGIN
   stim_proc: process
   variable i:integer;
   begin
      -- Release version : ISE 13.1 lin64
      -- Application Version: O.40d
      -- Behavioral simulation
      --
      -- Uncomment the below two lines to get an Internal Compiler Error
      --for i in 0 to 9 loop
      --end loop;
      
      assert output = (others => '1') report "Should be equal '1', but is not";
   end process;
END;


-- Compiler complains:
-- FATAL_ERROR:Simulator:CompilerAssert.h:40:1.65 - Internal Compiler Error in file ../src/VhdlExpr.cpp at line 5262   Process will terminate. For technical support on this issue, please open a WebCase with this project attached at http://www.xilinx.com/support.
