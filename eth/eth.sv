module  eth (  input        clk,
               input        reset,

               output       rx_vld,
               output       rx_last,
               output [7:0] rx_data,

               output       eth_resetn,
               output       eth_clk,
               output [1:0] eth_txd,
               output       eth_tx_en,
               input  [1:0] eth_rxd,
               input        eth_rx_err,
               input        eth_crs_dv );

logic       eth_clk_q = 0;
logic       eth_rx_sample, eth_dv_q, eth_dv_qq;

logic       rx_st_drop_zeroes;
logic       rx_first, rx_is_zero, rx_drop;

logic [1:0] eth_rxd_q;
logic [7:0] rmii_byte_sreg;
logic [1:0] rmii_2bit_cnt;

always_ff@(posedge clk)
   eth_clk_q <= ~eth_clk_q;

assign eth_rx_sample = ~eth_clk_q;


always_ff@(posedge clk)
   if(eth_rx_sample) begin
      eth_rxd_q <= eth_rxd;
      eth_dv_q  <= eth_crs_dv;
   end

assign rx_first   = eth_dv_q & ~eth_dv_qq;
assign rx_is_zero = (eth_rxd_q == 2'b00);
assign rx_drop    = (rx_st_drop_zeroes & rx_is_zero) | (rx_first & rx_is_zero);

always_ff@(posedge clk)
   if(reset | (rx_st_drop_zeroes & ~rx_is_zero & eth_rx_sample))
      rx_st_drop_zeroes <= 1'b0;
   else if(rx_first & rx_is_zero & eth_rx_sample)
      rx_st_drop_zeroes <= 1'b1;

always_ff@(posedge clk)
   if(eth_rx_sample)
      eth_dv_qq <= eth_dv_q;

always_ff@(posedge clk)
   if(eth_rx_sample & eth_dv_q & ~rx_drop)
      rmii_byte_sreg <= {eth_rxd_q, rmii_byte_sreg[7:2]};

always_ff@(posedge clk)
   if(reset | rx_last | rx_drop)
      rmii_2bit_cnt <= '0;
   else if(eth_rx_sample & eth_dv_q)
      rmii_2bit_cnt <= rmii_2bit_cnt + 1'b1;

assign rx_data = rmii_byte_sreg;
assign rx_vld  = eth_dv_qq & eth_rx_sample & (rmii_2bit_cnt == '0) & ~rx_st_drop_zeroes;
assign rx_last =  eth_dv_qq & ~eth_dv_q;

assign eth_clk    = eth_clk_q;
assign eth_resetn = ~reset;
assign eth_txd    = 2'd0;
assign eth_tx_en  = 1'b0;

endmodule