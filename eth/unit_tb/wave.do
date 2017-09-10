onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /eth_top_tb/clk
add wave -noupdate /eth_top_tb/reset
add wave -noupdate /eth_top_tb/rx_busy
add wave -noupdate /eth_top_tb/tx_busy
add wave -noupdate -divider <NULL>
add wave -noupdate /eth_top_tb/eth_crs_dv
add wave -noupdate -radix binary /eth_top_tb/eth_rxd
add wave -noupdate /eth_top_tb/eth_tx_en
add wave -noupdate /eth_top_tb/eth_txd
add wave -noupdate -divider <NULL>
add wave -noupdate /eth_top_tb/rx_vld
add wave -noupdate /eth_top_tb/rx_last
add wave -noupdate /eth_top_tb/uut/rx_crc_ok
add wave -noupdate /eth_top_tb/rx_data
add wave -noupdate -radix unsigned /eth_top_tb/rx_addr
add wave -noupdate /eth_top_tb/uut/rx_state
add wave -noupdate -divider <NULL>
add wave -noupdate /eth_top_tb/uut/sample
add wave -noupdate /eth_top_tb/tx_vld
add wave -noupdate /eth_top_tb/uut/tx_state
add wave -noupdate /eth_top_tb/uut/tx_data
add wave -noupdate -radix unsigned /eth_top_tb/uut/tx_addr
add wave -noupdate /eth_top_tb/uut/tx_adv
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1585000 ps} 0}
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
WaveRestoreZoom {0 ps} {4096 ns}
