--! @file 			uart_tx.vhd
--! @brief 			a short description what can be found in the file
--! @details 		detailed description
--! @author 		Selman Ergünay
--! @date 			21.10.2020
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----------------------------------------------------------------------------
entity uart_tx is
	generic(
		BAUD       : positive := 9600;
		DATA_NBITS : positive := 7;
		PARITY     : natural  := 0;  --! 0: no parity, 1: odd, 2: even
		STOP_NBITS : positive := 1); --! 1: 1, 2: 2, 3: 1.5
	port(
		iClk  : in std_logic;
		iRst  : in std_logic;
		iReq  : in std_logic;
		iData : in std_logic_vector(DATA_NBITS-1 downto 0);
		oAck  : out std_logic;
		oTx   : out std_logic);
end entity uart_tx;
----------------------------------------------------------------------------
architecture rtl of uart_tx is
begin


end architecture rtl;
----------------------------------------------------------------------------

