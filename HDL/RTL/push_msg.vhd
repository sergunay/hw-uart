--! @file       push_msg.vhd
--! @brief      Transmit UART messages
--! @details    Instantiates uart_tx and transmits a text message with reset.
--! @author     Selman Ergunay
--! @date       2020-10-20
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.push_msg_pkg.all;
----------------------------------------------------------------------------
entity push_msg is
----------------------------------------------------------------------------
	port(
		iClk       : in std_logic;
		iRst       : in std_logic;

	    oTx        : out std_logic);
end entity push_msg;


architecture rtl of push_msg is
----------------------------------------------------------------------------

	component uart_tx is
		port(
			iClk       : in std_logic;
			iRst       : in std_logic;
			iBaud      : in std_logic_vector(2 downto 0);
			iWord_len  : in std_logic_vector(1 downto 0);
			iParity_en : in std_logic;
			iParity    : in std_logic;
			iEstop_en  : in std_logic;
			iReq       : in std_logic;
			iData      : in std_logic_vector(7 downto 0);
			oAck       : out std_logic;
			oTx        : out std_logic);
	end component;

	signal cmd_cnt 	: unsigned (3 downto 0) := (others=>'0');
	signal req      : std_logic := '0';
	signal ack      : std_logic := '0';
	signal msg_char : std_logic_vector(7 downto 0) := (others=>'0');

begin
----------------------------------------------------------------------------

	I_UART_TX: uart_tx
		port map(
			iClk       => iClk,
			iRst       => iRst,
			iBaud      => "011",
			iWord_len  => "11",
			iParity_en => '0',
			iParity    => '0',
			iEstop_en  => '0',
			iReq       => req,
			iData      => msg_char,
			oAck       => ack,
			oTx        => oTx);

	CMD_CNT_PROC:
	process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' then
				cmd_cnt	<= (others=>'0');
			elsif ack = '1' and cmd_cnt < C_NB_CHAR-1 then
				cmd_cnt <= cmd_cnt + 1;
			end if;
		end if;
	end process;

	msg_char <= PUSH_MSG_LIST(to_integer(cmd_cnt));

	REQ_REG_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1'then
				req <= '1';
			elsif cmd_cnt = C_NB_CHAR-1 and ack = '1' then
				req <= '0';
			end if;
		end if;
	end process REQ_REG_PROC;

----------------------------------------------------------------------------
end architecture rtl;
----------------------------------------------------------------------------

