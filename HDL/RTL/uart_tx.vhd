--! @file       uart_tx.vhd
--! @brief      UART transmitter FSM
--! @details    Generates UART TX signaling when a data (iData) is provided
--!             with a request signal (iReq). When the transmission is started,
--!             an acknowledgement (oAck) signal is generated. The next data
--!             then can be supplied after this ack signal.
--!             Control bits:
--!             [7:5] BAUD : "000"=>1200,  "001"=>2400, "010"=>4800,  "011"=>9600
--!                          "100"=>19200, "101"=>38400,"110"=>57600, "111"=>115200
--!             [4:3] WORD_LEN : "00"=>5, "01"=>6, "10"=>7, "11"=>8
--!             [  2] PARITY_EN
--!             [  1] PARITY   : "0"=>Even parity_reg, "1"=>Odd parity
--!             [  0] ESTOP_EN
--! @author     Selman Ergunay
--! @date       2020-10-20
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
----------------------------------------------------------------------------
entity uart_tx is
	port(
		iClk       : in std_logic;  --! System clock, 12 MHz
		iRst       : in std_logic;  --! System reset
		-- Control pins
		iBaud      : in std_logic_vector(2 downto 0);
		iWord_len  : in std_logic_vector(1 downto 0);
		iParity_en : in std_logic;
		iParity    : in std_logic;  --! 0: even, 1:odd
		iEstop_en  : in std_logic;  --! 0: 1xStop, 1: 2xStop

		iReq       : in std_logic;  --! Tx request
		iData      : in std_logic_vector(7 downto 0);
		oAck       : out std_logic;
		oTx        : out std_logic);
end entity uart_tx;
----------------------------------------------------------------------------
architecture rtl of uart_tx is

	-- Control signals:

	constant C_BAUD_CNT_NBITS : integer := 12;

	-- Baud counter
	signal baud_cnt_limit  : unsigned(C_BAUD_CNT_NBITS-1 downto 0) := (others=>'0');
	signal baud_cnt        : unsigned(C_BAUD_CNT_NBITS-1 downto 0) := (others=>'0');
	signal baud_en         : std_logic := '0';
	signal baud_tick       : std_logic := '0'; --! Baud ticks at desired baud rate

	signal data_in_reg     : std_logic_vector(7 downto 0) := (others=>'0');

	-- Shift register with parallel load
	signal data_reg        : std_logic_vector(7 downto 0) := (others=>'0');
	signal data_load       : std_logic := '0';
	signal data_shift      : std_logic := '0';

	-- Data bit down counter
	signal dbit_cnt_reg    : unsigned(2 downto 0) := (others=>'0');
	signal dbit_cnt_dec    : std_logic := '0';
	signal dbit_cnt_of     : std_logic := '0';
	signal data_tx         : std_logic := '0'; -- data_reg(0)
	signal word_nbits      : unsigned(2 downto 0) := (others=>'0');

	-- Request flag
	signal req_clr         : std_logic := '0';
	signal req_set         : std_logic := '0';
	signal req_flag_reg    : std_logic := '0';

	-- Parity XORREG
	signal parity_reg      : std_logic := '0';
	signal parity_xor_en   : std_logic := '0';

	signal tx_reg          : std_logic := '0';

	signal req             : std_logic := '0';
	signal ack             : std_logic := '0';

	type fsm_states is(
		ST_START,
		ST_TX_DATA,
		ST_PARITY,
		ST_STOP,
	   	ST_STOP_EXT);

	signal state_next, state_reg : fsm_states := ST_START;
----------------------------------------------------------------------------
begin

	-- BAUD       : "000"=>1200, "001"=>2400, "010"=>4800, "011"=>9600
	--              "100"=>19200, "101"=>38400,"110"=>57600, "111"=>115200
	baud_cnt_limit <= to_unsigned(10000, C_BAUD_CNT_NBITS) when iBaud = "000" else
					  to_unsigned( 5000, C_BAUD_CNT_NBITS) when iBaud = "001" else
					  to_unsigned( 2500, C_BAUD_CNT_NBITS) when iBaud = "010" else
					  to_unsigned( 1250, C_BAUD_CNT_NBITS) when iBaud = "011" else
					  to_unsigned(  625, C_BAUD_CNT_NBITS) when iBaud = "100" else
					  to_unsigned(  312, C_BAUD_CNT_NBITS) when iBaud = "101" else
					  to_unsigned(  208, C_BAUD_CNT_NBITS) when iBaud = "110" else
					  to_unsigned(  104, C_BAUD_CNT_NBITS);           --"111"

	--! Clock counter to generate baud ticks
	BAUD_CNT_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' or baud_cnt = baud_cnt_limit-1 or baud_en = '0' then
				 baud_cnt <= (others=>'0');
			else
				 baud_cnt <= baud_cnt + 1;
			end if;
		end if;
	end process BAUD_CNT_PROC;

	-- Generate baud tick
	baud_tick <= '1' when baud_cnt = baud_cnt_limit-1 else
				 '0';

	--! Request input register process
	REQ_REG_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1'then
				req <= '0';
			else
				req <= iReq;
			end if;
		end if;
	end process REQ_REG_PROC;


----------------------------------------------------------------------------

-- Datapath

	-- INREG
	DATA_IN_REG_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1'then
				data_in_reg <= (others=>'0');
			else
				data_in_reg <= iData;
			end if;
		end if;
	end process DATA_IN_REG_PROC;

	-- SRwPL
	DATA_SHIFT_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1'then
				data_reg <= (others=>'0');
			elsif data_load = '1' then
				data_reg <= data_in_reg;
			elsif data_shift = '1' then
				data_reg <= '0' & data_reg(7 downto 1);
			end if;
		end if;
	end process DATA_SHIFT_PROC;

	data_tx <= data_reg(0);

	-- XORREG
	PARITY_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1'then
				parity_reg <= '0';
			elsif data_load = '1' then
				parity_reg <= iParity;
			elsif parity_xor_en = '1' then
				parity_reg <= parity_reg xor data_tx;
			end if;
		end if;
	end process PARITY_PROC;

	-- MUXREG
	OUTSEL_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1'then
				tx_reg <= '1';
			elsif state_reg = ST_START and req = '1' then
				tx_reg <= '0';
			elsif state_reg = ST_TX_DATA then
				tx_reg <= data_tx;
			elsif state_reg = ST_PARITY then
				tx_reg <= parity_reg;
			else
				tx_reg <= '1';
			end if;
		end if;
	end process OUTSEL_PROC;

	oTx  <= tx_reg;

----------------------------------------------------------------------------

	-- Control

	-- WORD_NBITS : "00"=>5, "01"=>6, "10"=>7, "11"=>8
	word_nbits <= to_unsigned(4, 3) when iWord_len = "00" else
			      to_unsigned(5, 3) when iWord_len = "01" else
				  to_unsigned(6, 3) when iWord_len = "10" else
				  to_unsigned(7, 3);               --"11";

	-- CNTDN
	DBIT_CNTDN_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' or state_reg = ST_START then
				dbit_cnt_reg <= word_nbits;
			elsif dbit_cnt_dec = '1' then
				dbit_cnt_reg <= dbit_cnt_reg - 1;
			end if;
		end if;
	end process DBIT_CNTDN_PROC;

	dbit_cnt_of <= '1' when dbit_cnt_reg = 0 else
				   '0';

	-- FLAG
	REQ_FLAG_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' or ack = '1' then
				req_flag_reg <= '0';
			elsif req = '1' then
				req_flag_reg <= '1';
			end if;
		end if;
	end process REQ_FLAG_PROC;

----------------------------------------------------------------------------

	--! FSM - state register
	FSM_STATE_REG : process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1' then
				state_reg 		<= ST_START;
			else
				state_reg 		<= state_next;
			end if;
		end if;
	end process FSM_STATE_REG;

--! @dot
--! digraph FSM_UART_TX {
--!  node [shape=circle];
--!  START 	  -> TX_DATA  [label = "req"];
--!  TX_DATA  -> TX_DATA  [label = "data_left"];
--!  TX_DATA  -> PARITY   [label = "parity_reg_en"]
--!  TX_DATA  -> STOP     [label = "!parity_reg_en"]
--!  PARITY   -> STOP
--!  STOP     -> START    [label = "!estop_en"];
--!  STOP     -> ESTOP    [label = "estop_en"];
--!  ESTOP    -> START
--! }
--! @enddot

	--! FSM - Next state logic
	FSM_NSL: process(state_reg, baud_tick, req_flag_reg, iParity_en, iEstop_en, dbit_cnt_of)
	begin
		state_next 	    <= state_reg;
		ack             <= '0';
		baud_en         <= '1';
		data_load       <= '0';
		data_shift      <= '0';
		parity_xor_en   <= '0';
		dbit_cnt_dec    <= '0';

		case state_reg is

			when ST_START		=>

				if req_flag_reg = '1' then
				else
					baud_en         <= '0';
				end if;

				if baud_tick = '1' then
					state_next 	 <= ST_TX_DATA;
					data_load    <= '1';
					ack          <= '1';
				end if;

			---------------------------------------------------

			when ST_TX_DATA	=>

				if baud_tick = '1' then

					data_shift      <= '1';
					parity_xor_en   <= iParity_en;
					dbit_cnt_dec    <= '1';

					if dbit_cnt_of = '1' then

						if iParity_en = '1' then
							state_next	<= ST_PARITY;
						else
							state_next	<= ST_STOP;
						end if;
					end if;
				end if;

			---------------------------------------------------
			when ST_PARITY =>

				if baud_tick = '1' then
					state_next 	<= ST_STOP;
				end if;

			---------------------------------------------------
			when ST_STOP  =>

				if baud_tick = '1' then
					if iEstop_en = '0' then
				  		state_next <= ST_START;
					else
				  		state_next <= ST_STOP_EXT;
					end if;
				end if;

			---------------------------------------------------
			when ST_STOP_EXT  =>

				if baud_tick = '1' then
					state_next 	<= ST_START;
				end if;

		end case;

	end process FSM_NSL;

	oAck <= ack;

--------------------------------------------------------------------------------
end architecture rtl;
----------------------------------------------------------------------------
