--! @file 			uart_tx_tb.vhd
--! @brief 			Testbench of uart_tx module
--! @details 		This testbench reads the test vector file tv_in.txt
--!                 which lists data and control signals in 8-bit binary
--!                 format.
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
			iWord_len  : in std_logic_vector(1 downto 0);
			iParity_en : in std_logic;
			iParity    : in std_logic;  --! 0: even, 1:odd
			iEstop_en  : in std_logic;
			iReq       : in std_logic;
			iData      : in std_logic_vector(7 downto 0);
			oAck       : out std_logic;
			oTx        : out std_logic);
	end component;

	-- Simulation constants
	constant C_CLK_PER   : time    := 83.33 ns;
	constant C_BAUD_PER  : time    := 104 us;

	-- Simulation control signals
	signal sim_clk       : std_logic := '0';
	signal sim_rst       : std_logic := '0';
	signal sim_stop      : boolean 	:= FALSE;		-- stop simulation?
	signal sim_baud      : std_logic_vector(2 downto 0) := "011";
	signal sim_parity    : std_logic := '0';
	signal sim_parity_en : std_logic := '1';
	signal sim_word_len  : std_logic_vector(1 downto 0) := "11";
	signal sim_estop_en  : std_logic := '0';

	signal sim_req       : std_logic := '0';
	signal sim_data      : std_logic_vector(7 downto 0) := (others=>'0');
	signal rx_word       : std_logic_vector(7 downto 0) := (others=>'0');

	signal sim_check     : std_logic := '0';

	signal duv_ack       : std_logic := '0';
	signal duv_tx        : std_logic := '0';

	signal start_detect  : std_logic := '0';

	-- File/file name definitions
	constant C_TV_FILE_NAME : string := "./IN/tv_in.txt";
	file TV_FILE            : text;

	function sl_to_int(sl : std_logic)
	return integer is
    begin
		if sl = '1' then
			return 1;
		else
			return 0;
		end if;
    end function;

begin
----------------------------------------------------------------------------

	DUV: uart_tx
		port map(
			iClk       => sim_clk,
			iRst       => sim_rst,
			iBaud      => sim_baud,
			iWord_len  => sim_word_len,
			iParity_en => sim_parity_en,
			iParity    => sim_parity,
			iEstop_en  => sim_estop_en,
			iReq       => sim_req,
			iData      => sim_data,
			oAck       => duv_ack,
			oTx        => duv_tx);

	CLK_STIM : sim_clk 	<= not sim_clk after C_CLK_PER/2 when not sim_stop;

	STIM_PROC: process

		variable tv_line	: line;
		variable tv_data    : std_logic_vector(7 downto 0) := (others=>'0');
		variable tv_control : std_logic_vector(7 downto 0) := (others=>'0');
		variable parity     : std_logic := '0';
		variable wordlen    : natural := 8;
        variable l          : line;
		variable tv_num     : positive := 1;

		procedure init is
		begin
			sim_rst 			<= '1';
			wait for 400 ns;
			sim_rst				<= '0';
		end procedure init;

		procedure load(
			constant data    : std_logic_vector(7 downto 0);
			constant control : std_logic_vector(7 downto 0)) is
		begin
			report "Loading test vector #" & integer'image(tv_num);
			sim_data(7 downto 0)     <= data(7 downto 0);
			sim_baud(2 downto 0)     <= "011";
			sim_word_len(1 downto 0) <= control(4 downto 3);
			sim_parity_en            <= control(2);
			sim_parity               <= control(1);
			sim_estop_en             <= control(0);
			sim_req                  <= '1';
			tv_num                   := tv_num + 1;
		end procedure load;

		procedure check(
			constant data    : std_logic_vector(7 downto 0);
			constant control : std_logic_vector(7 downto 0)) is
		begin
			report "Checking DUV output";
			sim_check <= '0';
			wait for C_BAUD_PER/2;

			-- check start bit
			sim_check <= '1';
			assert duv_tx = '0'
			report "START bit missing "
			severity ERROR;
			wait for 5 ns;
			sim_check <= '0';

			-- check data
			wordlen   := to_integer(unsigned(sim_word_len)) + 5;
			for bit_idx in 0 to wordlen-1 loop
				wait for C_BAUD_PER - 5 ns;
				sim_check <= '1';
				assert duv_tx = data(bit_idx)
				report 	"Data Error: Exp = " & integer'image(sl_to_int(data(bit_idx))) & " / " &
						"Got = " & integer'image(sl_to_int(duv_tx))
				severity ERROR;
				wait for 5 ns;
				sim_check <= '0';
			end loop;

			sim_req   <= '0';

			-- check parity
			if sim_parity_en = '1' then
				parity := sim_parity;
				for bit_idx in 0 to wordlen-1 loop
					parity := parity xor data(bit_idx);
				end loop;
				wait for C_BAUD_PER - 5 ns;
				sim_check <= '1';
				assert duv_tx = parity
				report 	"Parity Error: Exp = " & integer'image(sl_to_int(parity)) & " / " &
						"Got = " & integer'image(sl_to_int(duv_tx))
				severity ERROR;
				wait for 5 ns;
				sim_check <= '0';
			end if;

			-- check stop
			wait for C_BAUD_PER - 5 ns;
			sim_check <= '1';
			assert duv_tx = '1'
			report "STOP bit is missing."
			severity ERROR;
			wait for 5 ns;
			sim_check <= '0';

			-- check extra stop
			if sim_estop_en = '1' then
				wait for C_BAUD_PER - 5 ns;
				sim_check <= '1';
				assert duv_tx = '1'
				report "EXTRA STOP bit is missing."
				severity ERROR;
				sim_check <= '0';
			end if;
		end procedure check;

	begin
		init;
		file_open(TV_FILE, C_TV_FILE_NAME, READ_MODE);
		while not endfile(TV_FILE) loop
			readline(TV_FILE, tv_line);
			read(tv_line, tv_data);
			read(tv_line, tv_control);
			load(tv_data, tv_control);
			check(tv_data, tv_control);
			wait for C_BAUD_PER;
		end loop;
		sim_stop 	<= True;
		wait;
	end process STIM_PROC;

----------------------------------------------------------------------------
end architecture tb;
----------------------------------------------------------------------------
