--! @file 			uart_tx_tb.vhd
--! @brief 			a short description what can be found in the file
--! @details 		detailed description
--! @author 		Selman Ergünay
--! @date 			20.10.2020
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

----------------------------------------------------------------------------
entity uart_tx_tb is
end entity;
----------------------------------------------------------------------------

architecture tb of uart_tx_tb is
------------------------------------------------------------------------
	component uart_tx
		port(
			iClk       : in std_logic;
			iRst       : in std_logic;
			iBaud      : in std_logic_vector(2 downto 0);
			iParity_en : in std_logic;
			iParity    : in std_logic;  --! 0: even, 1:odd
			iWord_len  : in std_logic_vector(1 downto 0);
			iStop_len  : in std_logic_vector(1 downto 0);
			iReq       : in std_logic;
			iData      : in std_logic_vector(7 downto 0);
			oAck       : out std_logic;
			oTx        : out std_logic);
	end component;

	-- Simulation constants
	constant C_CLK_PER    : time    := 83.33 ns;

	-- Simulation control signals
	signal sim_clk       : std_logic := '0';
	signal sim_rst       : std_logic := '0';
	signal sim_stop      : boolean 	:= FALSE;		-- stop simulation?
	signal sim_baud      : std_logic_vector(2 downto 0) := "011";
	signal sim_parity    : std_logic := '0';
	signal sim_parity_en : std_logic := '1';
	signal sim_word_len  : std_logic_vector(1 downto 0) := "10";
	signal sim_stop_len  : std_logic_vector(1 downto 0) := "00";

	signal sim_req  : std_logic := '0';
	signal sim_data : std_logic_vector(7 downto 0) := (others=>'0');

	signal duv_ack : std_logic := '0';
	signal duv_tx  : std_logic := '0';


begin
----------------------------------------------------------------------------

	DUV: uart_tx
		port map(
			iClk       => sim_clk,
			iRst       => sim_rst,
			iBaud      => sim_baud,
			iParity_en => sim_parity_en,
			iParity    => sim_parity,
			iWord_len  => sim_word_len,
			iStop_len  => sim_stop_len,
			iReq       => sim_req,
			iData      => sim_data,
			oAck       => duv_ack,
			oTx        => duv_tx);

	CLK_STIM : sim_clk 	<= not sim_clk after C_CLK_PER/2 when not sim_stop;

	INFO_PROC: process
        variable l : line;
 	begin
		write (l, string'("Simulation started."));
        writeline (output, l);
        wait;
	end process;

	STIM_PROC: process

		procedure init is
		begin
			sim_rst 			<= '1';
			wait for 400 ns;
			sim_rst				<= '0';
		end procedure init;

		procedure uart_write(
			constant uart_tx_data : std_logic_vector(7 downto 0)) is
		begin
			sim_data  <= uart_tx_data(7 downto 0);
			sim_req   <= '1';

			--wait until falling_edge(duv_ack);
			wait for 1 ms;

			sim_data   <= (others=>'0');
			sim_req    <= '0';
		end procedure uart_write;

	begin
		init;
		wait for 500 ns;
		uart_write("10110000");
		wait for 1 ms;
		sim_stop 	<= True;
		wait;
	end process STIM_PROC;

----------------------------------------------------------------------------
end architecture tb;
----------------------------------------------------------------------------

