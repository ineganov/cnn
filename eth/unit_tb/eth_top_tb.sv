module eth_top_tb;


logic        clk = 0;
logic        reset = 1;


logic        tx_vld;
logic        tx_adv;
logic        tx_busy;
logic [10:0] tx_count;
logic [10:0] tx_addr;
logic  [7:0] tx_data;

logic        rx_vld;
logic        rx_last;
logic        rx_err;
logic        rx_crc_ok;
logic  [7:0] rx_data;
logic [10:0] rx_addr;

logic        eth_resetn;
logic        eth_clk;
logic  [1:0] eth_txd;
logic        eth_tx_en;
logic  [1:0] eth_rxd;
logic        eth_rx_err;
logic        eth_crs_dv;


int msg_test[] = {8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'hd5,
                  8'h00, 8'h10, 8'hA4, 8'h7B, 8'hEA, 8'h80, 8'h00, 8'h12, 
                  8'h34, 8'h56, 8'h78, 8'h90, 8'h08, 8'h00, 8'h45, 8'h00,
                  8'h00, 8'h2E, 8'hB3, 8'hFE, 8'h00, 8'h00, 8'h80, 8'h11,
                  8'h05, 8'h40, 8'hC0, 8'hA8, 8'h00, 8'h2C, 8'hC0, 8'hA8,
                  8'h00, 8'h04, 8'h04, 8'h00, 8'h04, 8'h00, 8'h00, 8'h1A,
                  8'h2D, 8'hE8, 8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05,
                  8'h06, 8'h07, 8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D,
                  8'h0E, 8'h0F, 8'h10, 8'h11 };

int msg_test_my[] = {8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'hd5,
                     8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'h98, 8'h5a,
                     8'heb, 8'hdd, 8'h1c, 8'h64, 8'h08, 8'h06, 8'h00, 8'h01,
                     8'h08, 8'h00, 8'h06, 8'h04, 8'h00, 8'h01, 8'h98, 8'h5a,
                     8'heb, 8'hdd, 8'h1c, 8'h64, 8'hc0, 8'ha8, 8'h02, 8'h02,
                     8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h9d, 8'h37,
                     8'heb, 8'h91, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
                     8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
                     8'h00, 8'h00, 8'h00, 8'h00, 8'hf1, 8'hff, 8'h34, 8'h21 };

int msg_simple[] = { 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'hd5,
                     8'ha1, 8'hb2, 8'hc3, 8'hd4, 8'he5,
                     8'hdf, 8'hf9, 8'hc3, 8'h9a };



always #5ns clk <= ~clk;

initial begin
   eth_rx_err = 0;
   eth_rxd = 2'b00;
   eth_crs_dv = 0;
   tx_vld = 1'b0;
   #20ns;
   @(posedge clk) reset = 0;

   #40ns;

   // rmii_msg(msg_test_my);
   // tx_count = 60;

   rmii_msg(msg_simple);
   tx_count = 5;

   

   @(negedge rx_vld) #1
   @(posedge clk) #1
   @(posedge clk) tx_vld = 1'b1;
   @(posedge clk) tx_vld = 1'b0;

   @(negedge tx_busy) #100ns;

   $finish;
end


always@(posedge clk)
   if(rx_vld)
      if(rx_last) $write("%02x received\n", rx_data);
      else        $write("%02x ",           rx_data);


eth uut(.*);

wire       lp_rxvalid, lp_rxerr, lp_crcok, lp_last;
wire [7:0] lp_rxdata;

eth uut_loopback(  .clk        ( clk        ),
                   .reset      ( reset      ),
                   .tx_vld     ( 1'b0       ),
                   .tx_count   ( 11'd0      ),
                   .tx_addr    (            ),
                   .tx_adv     (            ),
                   .tx_busy    (            ),
                   .tx_data    ( 8'h0       ),
                   .rx_vld     ( lp_rxvalid ),
                   .rx_last    ( lp_last    ),
                   .rx_err     ( lp_rxerr   ),
                   .rx_crc_ok  ( lp_crcok   ),
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



miniram #( .D (11),   
           .W (8 ) )
miniram  ( .clk   ( clk               ),
           .re    ( tx_adv            ),
           .we    ( rx_vld            ),
           .addr  ( tx_busy ? tx_addr : rx_addr ),
           .wdata ( rx_data           ),
           .rdata ( tx_data           ));


// -------------------------------------------------//

task rmii_nibble(int nbbl);
   begin
      @(posedge clk) eth_rxd = nbbl[1:0];
      @(posedge clk) #1;      
   end
endtask

task rmii_intro(int n);
   begin

      @(posedge clk) 
      if(~eth_crs_dv) eth_crs_dv = 1;
         eth_rxd = 0;
      @(posedge clk) #1;

      for(int i = 0; i < n; i++)
         rmii_nibble(0);

   end
endtask

task rmii_byte(int bb, int last);
  begin
      @(posedge clk) 
      if(~eth_crs_dv) eth_crs_dv = 1;
         eth_rxd = bb[1:0];
      @(posedge clk) #1;

      rmii_nibble(bb[3:2]);
      rmii_nibble(bb[5:4]);
      rmii_nibble(bb[7:6]);

      if(last) begin
         @(posedge clk)
            eth_crs_dv = 1'b0;
         end
   end
endtask

task rmii_msg(int msg[$]);
   begin

   rmii_intro(2); // Three leading "zero" pairs

   for(int i = 0; i < $size(msg) - 1; i++)
      rmii_byte(msg[i], 0);

   rmii_byte(msg[$size(msg) - 1], 1);
   end
endtask

endmodule
