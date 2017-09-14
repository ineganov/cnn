top:
	vlog eth_top_tb.sv
	vlog ../eth_tx_fcs.sv
	vlog ../eth_rx_fcs.sv
	vlog ../arp_machine.sv
	vlog ../udp_machine.sv
	vlog ../../util/miniram.sv
	vlog ../eth.sv
	vsim work.eth_top_tb -c -do "log -r /*; run -all"

fcs:
	vlog eth_fcs_tb.sv
	vlog ../eth_fcs.sv
	vsim work.eth_fcs_tb -c -do "log -r /*; run -all"

view:
	vsim -view vsim.wlf -do "do wave.do"

lib:
	vlib work

clean:
	rm transcript
	rm vsim.wlf
	rm -rf work

