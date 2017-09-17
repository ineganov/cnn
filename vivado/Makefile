synth:
	vivado -mode batch -source script.tcl

program:
	vivado -mode batch -source program.tcl

warning:
	cat vivado.log | grep WARNING | grep -v 'Synth 8-6014'

clean:
	rm bitstream.bit
	rm *webtalk*
	rm *.jou
	rm *.log

