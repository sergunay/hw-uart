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

	signal data_in_next    : std_logic_vector(DATA_NBITS - 1 downto 0);
	signal data_in_reg     : std_logic_vector(DATA_NBITS - 1 downto 0);
	signal nbits_left_next : unsigned(4 - 1 downto 0);
	signal nbits_left_reg  : unsigned(4 - 1 downto 0);

	signal baud_tick      : std_logic;

	signal tx_next        : std_logic;
	signal tx_reg         : std_logic;

	signal start_next     : std_logic;
	signal start_reg      : std_logic;

	signal req            : std_logic;
	signal ack            : std_logic;


	type fsm_states is(
		ST_START,
		ST_TX_DATA,
		ST_PARITY,
		ST_STOP,
		ST_EXTRA_HALF_STOP,
	   	ST_EXTRA_FULL_STOP);

	signal state_next, state_reg 	: fsm_states := ST_START;

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

	START_PROC: process(iClk)
	begin
		if rising_edge(iClk) then
			if iRst = '1'then
				start_reg <= '0';
			else
				start_reg <= start_next;
			end if;
		end if;
	end process START_PROC;

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
				nbits_left_reg <= to_unsigned(DATA_NBITS - 1, 4);
			else
				nbits_left_reg <= nbits_left_next;
			end if;
		end if;
	end process NBITS_LEFT_PROC;


----------------------------------------------------------------------------

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

	FSM_NSL: process(state_reg, baud_tick, data_in_reg, nbits_left_reg, req, start_reg)
	begin
		state_next 	    <= state_reg;
		tx_next         <= tx_reg;
		start_next      <= start_reg;
		data_in_next    <= data_in_reg;
		nbits_left_next <= nbits_left_reg;
		ack             <= '0';

		case state_reg is

			when ST_START		=>

				if baud_tick = '1' and req = '1' then
					start_next   <= '1';
					tx_next      <= '0';
					data_in_next <= iData;
				end if;

				if baud_tick = '1' and start_reg = '1' then
					start_next   <= '0';
					state_next 	 <= ST_TX_DATA;
					ack          <= '1';

				end if;

			---------------------------------------------------

			when ST_TX_DATA	=>

				tx_next         <= data_in_reg(0);

				if baud_tick = '1' then

					data_in_next    <= '0' & data_in_reg(DATA_NBITS-1 downto 1);
					nbits_left_next <= nbits_left_reg - 1;

					if nbits_left_reg = 0 then

						nbits_left_next <= to_unsigned(DATA_NBITS, 4);
						if parity = 1 then
							state_next	<= ST_PARITY;
						else
							state_next	<= ST_STOP;
						end if;
					end if;
				end if;

			---------------------------------------------------
			when ST_PARITY		=>

				if baud_tick = '1' then
					state_next 	<= ST_STOP;
				end if;

			---------------------------------------------------
			when ST_STOP		=>

				tx_next         <= '1';

				if baud_tick = '1' then
					state_next 	<= ST_START;
				end if;

			---------------------------------------------------
			when ST_EXTRA_HALF_STOP		=>

				if baud_tick = '1' then
					state_next 	<= ST_START;
				end if;

			---------------------------------------------------
			when ST_EXTRA_FULL_STOP		=>

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

