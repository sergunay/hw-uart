# User variables
set TOP_MODULE uart_tx
set FPGA_PART xc7a35tcpg236-1
set CFGMEM_PART n25q32-3.3v-spi-x1_x2_x4
# set VIVADO_PATH C:/Xilinx/Vivado/2018.3
set VIVADO_PATH /opt/Xilinx/Vivado/2019.2
#-------------------------------------------------------------------------------
set TESTBENCH ${TOP_MODULE}_tb
set TB_GATE_FILE ${TOP_MODULE}_gate_tb.vhd

set RTL_DIR ../../HDL/RTL
set TB_DIR ../../HDL/TB
set BHV_DIR ../../HDL/BHV

set TCL_DIR ../TCL

set PRE_SYNTH_DIR ../PRE_SYNTH
set SYNTH_DIR ../SYNTH
set IMPL_DIR ../IMPL
set CONSTR_DIR ../CONSTR
