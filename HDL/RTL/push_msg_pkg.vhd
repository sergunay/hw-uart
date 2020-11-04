library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package push_msg_pkg is

	constant C_NB_CHAR : natural := 2;

	type PUSH_MSG_TYPE is array(0 to C_NB_CHAR-1) of std_logic_vector(7 downto 0);

	constant PUSH_MSG_LIST : PUSH_MSG_TYPE :=
		(
			"01010011",   -- S
			"01000101"    -- E
		);
end package push_msg_pkg;
