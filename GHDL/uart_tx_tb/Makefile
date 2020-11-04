# vhdl files
FILES = ../../HDL/RTL/*.vhd
VHDLEX = .vhd

# testbench
TESTBENCH = uart_tx_tb
TESTBENCHPATH = ../HDL/TB/${TESTBENCH}$(VHDLEX)

#GHDL CONFIG
GHDL_CMD = ghdl
GHDL_FLAGS  = --ieee=synopsys --warn-no-vital-generic

SIMDIR = sim
# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
#GHDL_SIM_OPT = --stop-time=10000ns

WAVEFORM_VIEWER = gtkwave

all: compile view

compile :
ifeq ($(strip $(TESTBENCH)),)
	@echo "TESTBENCH not set. Use TESTBENCH=value to set it."
	@exit 2
endif                                                                                             
	mkdir -p sim
	$(GHDL_CMD) -a $(GHDL_FLAGS) --workdir=sim --work=work $(TESTBENCHPATH) $(FILES)
	$(GHDL_CMD) -e  $(GHDL_FLAGS) --workdir=sim --work=work $(TESTBENCH)
	$(GHDL_CMD) -r  $(GHDL_FLAGS) --workdir=sim --work=work $(TESTBENCH) --wave=$(SIMDIR)/$(TESTBENCH).ghw

view :
	$(WAVEFORM_VIEWER) $(SIMDIR)/$(TESTBENCH).ghw

clean :
	$(GHDL_CMD) --clean --workdir=sim
