Project name  : UART
Release       : 0.0
Date          : 2020-10-20

General Description
--------------------------------------------------------------------------

* Data width: 5, 6, 7, 8 bit
* Parity: none, even, odd
* Stop bits: 1, 2
* Baud rate: 1200, 2400, 4800, 9600, 19200, 38400, 57600, 115200
* Verification hardware: CMOD-A7

Directory structure
--------------------------------------------------------------------------

DOC
	DOX_HDL : Auto-generated Doxygen documentation

HDL
	RTL	: Synthesized RTL codes.
	BHV	: Behavioral codes.
	TB	: Testbenches.

PYTHON
	tvgen_uart.py : Python script generates random test vectors.

VIVADO
	BIN    : Binary files
	CONSTR : Constraint files
	IMPL   : Implementation files
	SYNTH  : Synthesis files
	TCL    : Vivado scripts
	WORK   : Working directory for TCL based operations

Hardware
--------------------------------------------------------------------------

* CMOD-A7 is used for verification. 
  - FPGA: Xilinx Artix-7 (XC7A35T-1CPG236C)
  - 12 MHz clock
   
Connections
--------------------------------------------------------------------------

Simulation
--------------------------------------------------------------------------

GHDL:

	Go to GHDL directory
	make

Synthesis
--------------------------------------------------------------------------

Vivado in TCL mode:

	Go to VIVADO/WORK directory.
	cmd
	vivado -mode tcl
	source ../TCL/build.tcl

Implementation results:

  - Area  :
  - Speed :

Programming the FPGA
--------------------------------------------------------------------------

Run program.tcl to program the FPGA:

	vivado -mode tcl
	source ../TCL/program.tcl

Run flash.tcl to program the configuration flash memory:
	
	source ../TCL/flash.tcl

Verification
--------------------------------------------------------------------------



TODO
--------------------------------------------------------------------------

* [ ] UART TX
* [ ] UART TX interface w/FIFO
* [ ] UART RX
* [ ] UART RX interface w/FIFO 

--------------------------------------------------------------------------
END OF README
--------------------------------------------------------------------------
