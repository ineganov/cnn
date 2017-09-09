module eth_top_tb;


logic       clk = 0;
logic       reset = 1;

logic       rx_vld;
logic       rx_last;
logic [7:0] rx_data;

logic       eth_resetn;
logic       eth_clk;
logic [1:0] eth_txd;
logic       eth_tx_en;
logic [1:0] eth_rxd;
logic       eth_rx_err;
logic       eth_crs_dv;


int msg_test[] = {8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'hd5,
                  8'h00, 8'h10, 8'hA4, 8'h7B, 8'hEA, 8'h80, 8'h00, 8'h12, 
                  8'h34, 8'h56, 8'h78, 8'h90, 8'h08, 8'h00, 8'h45, 8'h00,
                  8'h00, 8'h2E, 8'hB3, 8'hFE, 8'h00, 8'h00, 8'h80, 8'h11,
                  8'h05, 8'h40, 8'hC0, 8'hA8, 8'h00, 8'h2C, 8'hC0, 8'hA8,
                  8'h00, 8'h04, 8'h04, 8'h00, 8'h04, 8'h00, 8'h00, 8'h1A,
                  8'h2D, 8'hE8, 8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05,
                  8'h06, 8'h07, 8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D,
                  8'h0E, 8'h0F, 8'h10, 8'h11 }; // FCS: E6 C5 3D B2

int msg_simple[] = {8'ha1, 8'hb2, 8'hc3, 8'hd4, 8'he5 };



always #5ns clk <= ~clk;

initial begin
   eth_rx_err = 0;
   eth_rxd = 2'b00;
   eth_crs_dv = 0;
   #20ns;
   @(posedge clk) reset = 0;

   #40ns;

   rmii_msg(msg_test);

   #100ns;


   $finish;
end


always@(posedge clk)
   if(rx_vld)
      if(rx_last) $write("%02x received\n", rx_data);
      else        $write("%02x ",           rx_data);


eth uut(.*);



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
