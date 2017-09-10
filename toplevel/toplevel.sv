module toplevel ( input               clk, 
                  input               resetn,

                  output        [7:0] pmod_a,
                  output logic [15:0] leds,
                  input               sw,

                  output              eth_resetn,
                  output logic        eth_clk,
                  output        [1:0] eth_txd,
                  output              eth_tx_en,
                  input         [1:0] eth_rxd,
                  input               eth_rx_err,
                  input               eth_crs_dv,

                  input               uart_rx,
                  output              uart_tx,
                  output              uart_cts );


logic       eth_rx_vld, eth_rx_last, eth_crc_ok;
logic [7:0] eth_rx_data;

logic       uart_tx_vld,  uart_rx_vld, uart_tx_busy;
logic [7:0] uart_tx_data, uart_rx_data;

logic       fifo_char_en, fifo_nempty, fifo_full;
logic [7:0] fifo_char;

assign uart_tx_vld = fifo_nempty & ~uart_tx_busy;

eth eth (  .clk          ( clk         ),
           .reset        ( ~resetn     ), 

           .rx_vld       ( eth_rx_vld  ),        
           .rx_last      ( eth_rx_last ),
           .rx_err       (             ),
           .rx_crc_ok    ( eth_crc_ok  ),

           .rx_data      ( eth_rx_data ),    
           .eth_resetn   ( eth_resetn  ),       
           .eth_clk      ( eth_clk     ),    
           .eth_txd      ( eth_txd     ),    
           .eth_tx_en    ( eth_tx_en   ),      
           .eth_rxd      ( eth_rxd     ),    
           .eth_rx_err   ( eth_rx_err  ),       
           .eth_crs_dv   ( eth_crs_dv  ) );       


bin2char  bin2char( .clk       ( clk          ),
                    .reset     ( ~resetn      ),
                    .bin_vld   ( eth_rx_vld   ),
                    .bin_last  ( eth_rx_last  ), 
                    .bin_data  ( eth_rx_data  ), 
                    .char_vld  ( fifo_char_en ),
                    .char_data ( fifo_char    ) );

minififo        #(  .D      ( 16           ),
                    .W      ( 8            ) ) 
minififo         (  .clk    ( clk          ),
                    .reset  ( ~resetn      ),
                    .re     ( uart_tx_vld  ),
                    .rdata  ( uart_tx_data ),
                    .nempty ( fifo_nempty  ),
                    .we     ( fifo_char_en & ~fifo_full),
                    .wdata  ( fifo_char    ),
                    .full   ( fifo_full    ));


uart uart(  .clk     ( clk          ),
            .reset   (~resetn       ),

            .tx_vld  ( uart_tx_vld  ),
            .tx_data ( uart_tx_data ),
            .tx_busy ( uart_tx_busy ),

            .rx_vld  ( uart_rx_vld  ),
            .rx_data ( uart_rx_data ),

            .rx      ( uart_rx      ),
            .tx      ( uart_tx      ) );



logic [7:0] uart_rx_char_a, uart_rx_char_b;

always_ff@(posedge clk)
   if(~resetn) begin
      uart_rx_char_a <= '0;
      uart_rx_char_b <= '0;
   end 
   else if (uart_rx_vld) begin
      uart_rx_char_a <= uart_rx_data;
      uart_rx_char_b <= uart_rx_char_a;
   end

logic [7:0] rx_cnt;
logic [7:0] rx_cnt_err;

always_ff@(posedge clk)
   if(~resetn)
      rx_cnt <= '0;
   else if( eth_rx_vld & eth_rx_last & (rx_cnt != 8'hFF))
      rx_cnt <= rx_cnt + 1'b1;

always_ff@(posedge clk)
   if(~resetn)
      rx_cnt_err <= '0;
   else if( eth_rx_vld & eth_rx_last & ~eth_crc_ok & (rx_cnt_err != 8'hFF))
      rx_cnt_err <= rx_cnt_err + 1'b1;


assign leds = sw ? { rx_cnt, rx_cnt_err} : {uart_rx_char_b, uart_rx_char_a};


assign uart_cts = 1'b1;

assign pmod_a[7:0] = 8'd0;

endmodule
