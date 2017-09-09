all:
	vlib work
	vlog testbench.sv
	vlog ../uart.sv
	vsim work.testbench -c -do "log -r /*; run -all"

view:
	vsim -view vsim.wlf

lib:
	vlib work

clean:
	rm transcript
	rm vsim.wlf
	rm -rf work

