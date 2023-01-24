@echo off
set xv_path=D:\\Xilinx\\Vivado\\2014.3.1\\bin
call %xv_path%/xelab  -wto e150c84ef88a4b2ab1b286e42a810ff4 -m64 --debug typical --relax -L xil_defaultlib -L secureip --snapshot tb_top_behav xil_defaultlib.tb_top -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
