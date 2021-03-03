library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package push_msg_pkg is

	constant C_NB_CHAR : natural := 14;

	type PUSH_MSG_TYPE is array(0 to C_NB_CHAR-1) of std_logic_vector(7 downto 0);

	constant PUSH_MSG_LIST : PUSH_MSG_TYPE :=
	(
		"01001000", -- H
		"01100101", -- e
		"01101100", -- l
		"01101100", -- l
		"01101111", -- o
		"00100000", --
		"01010111", -- W
		"01101111", -- o
		"01110010", -- r
		"01101100", -- l
		"01100100", -- d
		"00100001", -- !
		"00001101", --
		"00001010"
	);
end package push_msg_pkg;
