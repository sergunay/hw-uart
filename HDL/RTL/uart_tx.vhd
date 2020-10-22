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

	constant C_BAUD_CNT_NBITS : integer := 12;

	signal baud_cnt_limit : unsigned(C_BAUD_CNT_NBITS-1 downto 0);
	signal baud_cnt       : unsigned(C_BAUD_CNT_NBITS-1 downto 0);

	signal baud_tick      : std_logic;

begin

	baud_cnt_limit <= to_unsigned(1250, C_BAUD_CNT_NBITS) when BAUD = 9600   else
					  to_unsigned( 625, C_BAUD_CNT_NBITS) when BAUD = 19200  else
					  to_unsigned( 104, C_BAUD_CNT_NBITS) when BAUD = 115200 else
					  to_unsigned(   0, C_BAUD_CNT_NBITS);

	BAUD_CNT_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' or baud_cnt = baud_cnt_limit-1 then
				 baud_cnt <= (others=>'0');
			else
				 baud_cnt <= baud_cnt + 1;
			end if;
		end if;
	end process BAUD_CNT_PROC;

	baud_tick <= '1' when baud_cnt = baud_cnt_limit-1 else
				 '0';

end architecture rtl;
----------------------------------------------------------------------------

