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
	end component;

	-- Simulation constants
	constant C_CLK_PER    : time    := 83.33 ns;
	constant C_BAUD       : natural := 9600;
	constant C_DATA_NBITS : natural := 8;
	constant C_PARITY     : natural := 0;
	constant C_STOP_NBITS : natural := 1;

	-- Simulation control signals
	signal sim_clk  : std_logic := '0';
	signal sim_rst  : std_logic := '0';
	signal sim_stop : boolean 	:= FALSE;		-- stop simulation?

	signal sim_req  : std_logic := '0';
	signal sim_data : std_logic_vector(C_DATA_NBITS-1 downto 0) := (others=>'0');

	signal duv_ack : std_logic := '0';
	signal duv_tx  : std_logic := '0';


begin
----------------------------------------------------------------------------

	DUV: uart_tx
		generic map(
			BAUD       => C_BAUD,
			DATA_NBITS => C_DATA_NBITS,
			PARITY     => C_PARITY,
			STOP_NBITS => C_STOP_NBITS)
		port map(
			iClk  => sim_clk,
			iRst  => sim_rst,
			iReq  => sim_req,
			iData => sim_data,
			oAck  => duv_ack,
			oTx   => duv_tx);

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
			constant uart_tx_data : std_logic_vector(C_DATA_NBITS-1 downto 0)) is
		begin
			sim_data  <= uart_tx_data(C_DATA_NBITS-1 downto 0);
			sim_req   <= '1';

			--wait until falling_edge(duv_ack);
			wait for 1 ms;

			sim_data   <= (others=>'0');
			sim_req    <= '0';
		end procedure uart_write;

	begin
		init;
		wait for 500 ns;
		uart_write("11110000");
		wait for 1 ms;
		sim_stop 	<= True;
		wait;
	end process STIM_PROC;

----------------------------------------------------------------------------
end architecture tb;
----------------------------------------------------------------------------

