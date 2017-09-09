read_verilog -sv toplevel.sv
read_verilog -sv uart.sv
read_verilog -sv eth.sv
read_verilog -sv bin2char.sv
read_verilog -sv minififo.sv

synth_design  -top toplevel -part xc7a100tcsg324-1
create_clock -name clk -period 10 [get_ports clk]

set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports clk]

set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports resetn];

set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports leds[0]  ]
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports leds[1]  ]
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports leds[2]  ]
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports leds[3]  ]
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports leds[4]  ]
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports leds[5]  ]
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports leds[6]  ]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports leds[7]  ]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports leds[8]  ]
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports leds[9]  ]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports leds[10] ]
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports leds[11] ]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports leds[12] ]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports leds[13] ]
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports leds[14] ]
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports leds[15] ]

set_property -dict { PACKAGE_PIN D3    IOSTANDARD LVCMOS33 } [get_ports uart_cts ]
set_property -dict { PACKAGE_PIN C4    IOSTANDARD LVCMOS33 } [get_ports uart_rx  ]
set_property -dict { PACKAGE_PIN D4    IOSTANDARD LVCMOS33 } [get_ports uart_tx  ]

set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 } [get_ports  pmod_a[0] ];
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports  pmod_a[1] ];
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports  pmod_a[2] ];
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports  pmod_a[3] ];
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports  pmod_a[4] ];
set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports  pmod_a[5] ];
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports  pmod_a[6] ];
set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports  pmod_a[7] ];

set_property -dict { PACKAGE_PIN B3    IOSTANDARD LVCMOS33 } [get_ports  eth_resetn ];
set_property -dict { PACKAGE_PIN D9    IOSTANDARD LVCMOS33 } [get_ports  eth_crs_dv ];
set_property -dict { PACKAGE_PIN C10   IOSTANDARD LVCMOS33 } [get_ports  eth_rx_err ];
set_property -dict { PACKAGE_PIN C11   IOSTANDARD LVCMOS33 } [get_ports  eth_rxd[0] ];
set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVCMOS33 } [get_ports  eth_rxd[1] ];
set_property -dict { PACKAGE_PIN B9    IOSTANDARD LVCMOS33 } [get_ports  eth_tx_en  ];
set_property -dict { PACKAGE_PIN A10   IOSTANDARD LVCMOS33 } [get_ports  eth_txd[0] ];
set_property -dict { PACKAGE_PIN A8    IOSTANDARD LVCMOS33 } [get_ports  eth_txd[1] ];
set_property -dict { PACKAGE_PIN D5    IOSTANDARD LVCMOS33 } [get_ports  eth_clk    ];

set_property IOB TRUE [get_ports eth_rxd[0]]
set_property IOB TRUE [get_ports eth_rxd[0]]
set_property IOB TRUE [get_ports eth_crs_dv]


set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

place_design
route_design

write_bitstream -force bitstream.bit

