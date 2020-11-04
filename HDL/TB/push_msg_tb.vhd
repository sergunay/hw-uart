--! @file 			push_msg_tb.vhd
--! @brief 			Testbench of push_msg__tx module
--! @details 		This testbench provides clock and reset to DUV.
--! @author 		Selman Ergunay
--! @date 			20.10.2020
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;
use ieee.std_logic_textio.all;

----------------------------------------------------------------------------
entity push_msg_tb is
end entity;
----------------------------------------------------------------------------

architecture tb of push_msg_tb is
------------------------------------------------------------------------

	component push_msg is
		port(
			iClk       : in std_logic;
			iRst       : in std_logic;
			oTx        : out std_logic);
	end component;

	-- Simulation constants
	constant C_CLK_PER   : time    := 83.33 ns;
	constant C_BAUD_PER  : time    := 104 us;

	-- Simulation control signals
	signal sim_clk       : std_logic := '0';
	signal sim_rst       : std_logic := '0';
	signal sim_stop      : boolean 	:= FALSE;		-- stop simulation?

	signal duv_tx        : std_logic := '0';

begin
----------------------------------------------------------------------------


	DUV: push_msg
		port map(
			iClk  => sim_clk,
			iRst  => sim_rst,
			oTx   => duv_tx);

	CLK_STIM : sim_clk 	<= not sim_clk after C_CLK_PER/2 when not sim_stop;

	STIM_PROC: process

		procedure init is
		begin
			sim_rst 			<= '1';
			wait for 400 ns;
			sim_rst				<= '0';
		end procedure init;

	begin
		init;
		wait for 3 ms;
		sim_stop <= True;
		wait;
	end process STIM_PROC;

----------------------------------------------------------------------------
end architecture tb;
----------------------------------------------------------------------------
