Project name  : UART
Release       : 0.0
Date          : 2020-10-20

General Description
--------------------------------------------------------------------------

* Supports 5, 6, 7, 8 bit data packages.
* Parity
* 1, 1.5, 2 stop bits
* 9600, 115200 baud rate
* Verification hardware: CMOD-A7

Version control
--------------------------------------------------------------------------

Directory structure
--------------------------------------------------------------------------

DOC
	DOX_HDL : Auto-generated Doxygen documentation

HDL
	RTL	: Synthesized RTL codes.
	BHV	: Behavioral codes.
	TB	: Testbenches.

LA
	Logic analyzer waveform and screenshots

PYTHON

VIVADO
	BIN    : Binary files
	CONSTR : Constraint files
	IMPL   : Implementation files
	SYNTH  : Synthesis files
	TCL    : Vivado scripts
	WORK   : Working directory for TCL based operations

Hardware
--------------------------------------------------------------------------

Connections
--------------------------------------------------------------------------

Simulation
--------------------------------------------------------------------------

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

Notes
--------------------------------------------------------------------------

Revision history
--------------------------------------------------------------------------

--------------------------------------------------------------------------
END OF README
--------------------------------------------------------------------------
