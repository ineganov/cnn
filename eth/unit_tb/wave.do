onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /eth_top_tb/clk
add wave -noupdate /eth_top_tb/reset
add wave -noupdate -divider <NULL>
add wave -noupdate /eth_top_tb/eth_crs_dv
add wave -noupdate -radix binary /eth_top_tb/eth_rxd
add wave -noupdate -divider <NULL>
add wave -noupdate /eth_top_tb/rx_vld
add wave -noupdate /eth_top_tb/rx_last
add wave -noupdate /eth_top_tb/rx_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {305000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1024 ns}
