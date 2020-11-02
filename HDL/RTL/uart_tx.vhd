--! @file       uart_tx.vhd
--! @brief      UART transmitter FSM
--! @details    Generates UART TX signaling when a data (iData) is provided
--!             with a request signal (iReq). When the transmission is started,
--!             an acknowledgement (oAck) signal is generated. The next data
--!             then can be supplied after this ack signal.
--!             Control bits:
--!             WORD_NBITS : "00"=>5, "01"=>6, "10"=>7, "11"=>8
--!             STOP_NBITS : "00"=>1, "01"=>1, "10"=>2, "11"=>1.5
--!             PARITY     : "0X"=>No parity,  "10"=>Even parity, "11"=>Odd parity
--!             BAUD       : "000"=>1200,  "001"=>2400, "010"=>4800,  "011"=>9600
--!                          "100"=>19200, "101"=>38400,"110"=>57600, "111"=>115200
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
		iParity_en : in std_logic;
		iParity    : in std_logic;  --! 0: even, 1:odd
		iWord_len  : in std_logic_vector(1 downto 0);
		iStop_len  : in std_logic;

		iReq       : in std_logic;  --! Tx request
		iData      : in std_logic_vector(7 downto 0);
		oAck       : out std_logic;
		oTx        : out std_logic);
end entity uart_tx;

----------------------------------------------------------------------------
architecture rtl of uart_tx is

	constant C_BAUD_CNT_NBITS : integer := 12;

	signal baud_cnt_limit  : unsigned(C_BAUD_CNT_NBITS-1 downto 0) := (others=>'0');
	signal baud_cnt        : unsigned(C_BAUD_CNT_NBITS-1 downto 0) := (others=>'0');
	signal baud_en         : std_logic := '0';

	signal word_nbits      : unsigned(3 downto 0) := (others=>'0');

	signal data_in_next    : std_logic_vector(7 downto 0) := (others=>'0');
	signal data_in_reg     : std_logic_vector(7 downto 0) := (others=>'0');
	signal nbits_left_next : unsigned(3 downto 0) := (others=>'0');
	signal nbits_left_reg  : unsigned(3 downto 0) := (others=>'0');

	signal baud_tick       : std_logic := '0'; --! Baud ticks at desired baud rate

	signal tx_next         : std_logic := '0';
	signal tx_reg          : std_logic := '0';

	signal parity_next     : std_logic := '0';
	signal parity_reg      : std_logic := '0';

	signal req             : std_logic := '0';
	signal ack             : std_logic := '0';

	type fsm_states is(
		ST_START,
		ST_TX_DATA,
		ST_PARITY,
		ST_STOP,
	   	ST_STOP_EXT);

	signal state_next, state_reg 	: fsm_states := ST_START;

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
					  to_unsigned(  104, C_BAUD_CNT_NBITS) when iBaud = "111";

	-- WORD_NBITS : "00"=>5, "01"=>6, "10"=>7, "11"=>8
	word_nbits <= to_unsigned(4, 4) when iWord_len = "00" else
			      to_unsigned(5, 4) when iWord_len = "01" else
				  to_unsigned(6, 4) when iWord_len = "10" else
				  to_unsigned(7, 4) when iWord_len = "11";

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


	DATA_IN_REG_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1'then
				data_in_reg <= (others=>'0');
			else
				data_in_reg <= data_in_next;
			end if;
		end if;
	end process DATA_IN_REG_PROC;

	NBITS_LEFT_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1'then
				nbits_left_reg <= word_nbits;
			else
				nbits_left_reg <= nbits_left_next;
			end if;
		end if;
	end process NBITS_LEFT_PROC;

	PARITY_REG_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1'then
				parity_reg <= '0';
			else
				parity_reg <= parity_next;
			end if;
		end if;
	end process PARITY_REG_PROC;

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
--!  TX_DATA  -> PARITY   [label = "parity_en"]
--!  TX_DATA  -> STOP     [label = "!parity_en"]
--!  PARITY   -> STOP
--!  PARITY   -> STOP_EXT [label = "stop_len"];
--!  STOP     -> START    [label = "!stop_len"];
--!  STOP     -> STOP_EXT [label = "stop_len"];
--!  STOP_EXT -> START    [label = "!stop_len"];
--! }
--! @enddot

	--! FSM - Next state logic
	FSM_NSL: process(state_reg, baud_tick, data_in_reg, nbits_left_reg, req, 
					 parity_reg, iData, word_nbits, iParity, iStop_len)
	begin
		state_next 	    <= state_reg;
		tx_next         <= tx_reg;
		data_in_next    <= data_in_reg;
		nbits_left_next <= nbits_left_reg;
		ack             <= '0';
		parity_next     <= parity_reg;
		baud_en         <= '1';

		case state_reg is

			when ST_START		=>

				if req = '1' then
					tx_next      <= '0';
					data_in_next <= iData;
				else
					baud_en      <= '0';
				end if;

				if baud_tick = '1' then
					state_next 	 <= ST_TX_DATA;
					ack          <= '1';
				end if;

			---------------------------------------------------

			when ST_TX_DATA	=>

				tx_next         <= data_in_reg(0);

				if baud_tick = '1' then

					parity_next     <= parity_reg xor data_in_reg(0);

					data_in_next    <= '0' & data_in_reg(7 downto 1);
					nbits_left_next <= nbits_left_reg - 1;

					if nbits_left_reg = 0 then

						nbits_left_next <= word_nbits;
						if iParity_en = '1' then
							state_next	<= ST_PARITY;
						else
							state_next	<= ST_STOP;
						end if;
					end if;
				end if;

			---------------------------------------------------
			when ST_PARITY =>

				tx_next     <= iParity xor parity_reg;

				if baud_tick = '1' then
					parity_next <= '0';
					state_next 	<= ST_STOP;
				end if;

			---------------------------------------------------
			when ST_STOP  =>

				tx_next         <= '1';

				if baud_tick = '1' then
					if iStop_len = '0' then
				  		state_next <= ST_START;
					else
				  		state_next <= ST_STOP_EXT;
					end if;

					state_next 	<= ST_START;

				end if;

			---------------------------------------------------
			when ST_STOP_EXT  =>

				if baud_tick = '1' then
					state_next 	<= ST_START;
				end if;

		end case;

	end process FSM_NSL;

--------------------------------------------------------------------------------

	TX_REG_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1'then
				tx_reg <= '1';
			else
				tx_reg <= tx_next;
			end if;
		end if;
	end process TX_REG_PROC;

	oTx  <= tx_reg;
	oAck <= ack;
			
--------------------------------------------------------------------------------
end architecture rtl;
----------------------------------------------------------------------------
