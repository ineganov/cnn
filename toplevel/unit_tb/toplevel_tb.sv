module toplevel_tb;

logic        clk = 0, resetn = 0;

logic  [7:0] pmod_a;
logic [15:0] leds;
logic        sw, btn_ok;

logic  [7:0] seg7_an, seg7_ca;

logic        eth_resetn, eth_clk;
logic  [1:0] eth_txd, eth_rxd;
logic        eth_tx_en, eth_rx_err, eth_crs_dv;

logic        uart_rx, uart_tx, uart_cts;

logic        lp_rxvalid, lp_rxerr, lp_crcok, lp_last;
logic  [7:0] lp_rxdata;

always #5ns clk <= ~clk;

toplevel uut(.*);

initial begin
   eth_rx_err = 0;
   eth_rxd = 2'b00;
   eth_crs_dv = 0;
   btn_ok = 0;
   #10ns;
   @(posedge clk) resetn = 1'b1;
   #100ns;

   btn_ok = 1; #1us; btn_ok = 0;

   @(negedge uut.tx_busy) #100ns;

   $finish;
end


eth uut_loopback(  .clk        ( clk        ),
                   .reset      ( reset      ),
                   .tx_vld     ( 1'b0       ),
                   .tx_count   ( 11'd0      ),
                   .tx_addr    (            ),
                   .tx_adv     (            ),
                   .tx_busy    (            ),
                   .tx_last    (            ),
                   .tx_data    ( 8'h0       ),
                   .rx_vld     ( lp_rxvalid ),
                   .rx_last    ( lp_last    ),
                   .rx_err     ( lp_rxerr   ),
                   .rx_crc_ok  ( lp_crcok   ),
                   .rx_busy    (            ),
                   .rx_addr    (            ),
                   .rx_data    ( lp_rxdata  ),
                   .eth_resetn (            ),
                   .eth_clk    (            ),
                   .eth_txd    (            ),
                   .eth_tx_en  (            ),
                   .eth_rxd    ( eth_txd    ),
                   .eth_rx_err ( 1'b0       ),
                   .eth_crs_dv ( eth_tx_en  ) );

always@(posedge clk)
   if(lp_rxvalid)
      if(lp_last) $write("%02x received on LP\n", lp_rxdata);
      else        $write("%02x ",                 lp_rxdata);

endmodule
