top:
	vlog toplevel_tb.sv
	vlog ../toplevel.sv
	vlog ../../uart/uart.sv
	vlog ../../eth/eth_tx_fcs.sv
	vlog ../../eth/eth_rx_fcs.sv
	vlog ../../eth/arp_machine.sv
	vlog ../../eth/udp_rx_machine.sv
	vlog ../../eth/udp_tx_machine.sv
	vlog ../../eth/eth.sv
	vlog ../../util/*.sv
	vsim work.toplevel_tb -c -do "log -r /*; run -all"

view:
	vsim -view vsim.wlf -do "do wave.do"

lib:
	vlib work

clean:
	rm transcript
	rm vsim.wlf
	rm -rf work

