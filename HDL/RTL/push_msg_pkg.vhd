library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package push_msg_pkg is

	constant C_NB_CHAR : natural := 13;

	type PUSH_MSG_TYPE is array(0 to C_NB_CHAR-1) of std_logic_vector(7 downto 0);

	constant PUSH_MSG_LIST : PUSH_MSG_TYPE :=
	(
		"01001000",
		"01100101",
		"01101100",
		"01101100",
		"01101111",
		"00100000",
		"01010111",
		"01101111",
		"01110010",
		"01101100",
		"01100100",
		"00100001",
		"00001010"
	);
end package push_msg_pkg;
