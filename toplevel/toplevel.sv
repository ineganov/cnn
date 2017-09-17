module toplevel ( input               clk, 
                  input               resetn,

                  output        [7:0] pmod_a,
                  output logic [15:0] leds,
                  input               sw,
                  input               btn_ok,

                  output        [7:0] seg7_an,
                  output        [7:0] seg7_ca,

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


logic        tx_vld;
logic        tx_adv;
logic        tx_busy;
logic        tx_last;
logic [10:0] tx_count;
logic [10:0] tx_addr;
logic  [7:0] tx_data;

logic        rx_vld;
logic        rx_last;
logic        rx_err;
logic        rx_crc_ok;
logic        rx_busy;
logic  [7:0] rx_data;
logic [10:0] rx_addr;


logic        udp_tx_req,   arp_tx_req;
logic        udp_tx_grant, arp_tx_grant;
logic [10:0] udp_tx_count, arp_tx_count;
logic  [7:0] udp_tx_data,  arp_tx_data;

logic        count_arp, btn_ok_deb;

logic        uart_tx_vld,  uart_rx_vld, uart_tx_busy;
logic  [7:0] uart_tx_data, uart_rx_data;

logic        fifo_char_en, fifo_nempty, fifo_full;
logic  [7:0] fifo_char;

logic        rx_udp_dvld;
logic [31:0] rx_udp_data, rx_udp_data_q;

assign uart_tx_vld = fifo_nempty & ~uart_tx_busy;


eth eth (   .clk        ( clk        ),
            .reset      ( ~resetn    ),

            .tx_vld     ( tx_vld     ),
            .tx_count   ( tx_count   ),
            .tx_addr    ( tx_addr    ),
            .tx_adv     ( tx_adv     ),
            .tx_busy    ( tx_busy    ),
            .tx_last    ( tx_last    ),
            .tx_data    ( tx_data    ),

            .rx_vld     ( rx_vld     ),
            .rx_last    ( rx_last    ),
            .rx_err     ( rx_err     ),
            .rx_crc_ok  ( rx_crc_ok  ),
            .rx_busy    ( rx_busy    ),
            .rx_addr    ( rx_addr    ),
            .rx_data    ( rx_data    ),

            .eth_resetn ( eth_resetn ),
            .eth_clk    ( eth_clk    ),
            .eth_txd    ( eth_txd    ),
            .eth_tx_en  ( eth_tx_en  ),
            .eth_rxd    ( eth_rxd    ),
            .eth_rx_err ( eth_rx_err ),
            .eth_crs_dv ( eth_crs_dv ) );

arp_machine arp_machine( .clk       ( clk          ),
                         .reset     ( ~resetn      ),

                         .count_arp ( count_arp    ),

                     // MAC RX side
                         .rx_vld    ( rx_vld       ),
                         .rx_last   ( rx_last      ),
                         .rx_err    ( rx_err       ),
                         .rx_crc_ok ( rx_crc_ok    ),
                         .rx_busy   ( rx_busy      ),
                         .rx_addr   ( rx_addr      ),
                         .rx_data   ( rx_data      ),

                         .tx_req    ( arp_tx_req   ),
                         .tx_count  ( arp_tx_count ),
                         .tx_grant  ( arp_tx_grant ),

                     // MAC TX side
                         .tx_addr   ( tx_addr      ),
                         .tx_adv    ( tx_adv       ),
                         .tx_last   ( tx_last      ),
                         .tx_data   ( arp_tx_data  ) );


udp_rx_machine udp_rx_machine( .clk       ( clk       ),
                            .reset     ( ~resetn   ),

                        // MAC RX side
                            .rx_vld    ( rx_vld    ),
                            .rx_last   ( rx_last   ),
                            .rx_err    ( rx_err    ),
                            .rx_crc_ok ( rx_crc_ok ),
                            .rx_busy   ( rx_busy   ),
                            .rx_addr   ( rx_addr   ),
                            .rx_data   ( rx_data   ),
   
                            .rx_udp_dvld ( rx_udp_dvld ),
                            .rx_udp_data ( rx_udp_data ) );


udp_tx_machine udp_tx_machine( .clk         ( clk          ),
                               .reset       ( ~resetn      ),

                           // ARB Side
                               .tx_req      ( udp_tx_req   ),
                               .tx_count    ( udp_tx_count ),
                               .tx_grant    ( udp_tx_grant ),

                           // MAC TX side
                               .tx_addr     ( tx_addr      ),
                               .tx_adv      ( tx_adv       ),
                               .tx_last     ( tx_last      ),
                               .tx_data     ( udp_tx_data  ),

                               .tx_udp_go   ( btn_ok_deb   ),
                               .tx_udp_dvld ( btn_ok_deb   ),
                               .tx_udp_data ( 32'h90ABCDEF ));


bin2char  bin2char( .clk       ( clk          ),
                    .reset     ( ~resetn      ),
                    .bin_vld   ( tx_adv       ),
                    .bin_last  ( tx_last      ), 
                    .bin_data  ( tx_data      ), 
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


btn_debounce btn_debounce( .clk    ( clk        ),
                           .reset  ( ~resetn    ),
                           .btn    ( btn_ok     ),
                           .btn_db ( btn_ok_deb ) );

// fixed TX priorities:

always_comb
   if(arp_tx_req) begin
      tx_vld       = ~tx_busy;
      tx_count     = arp_tx_count;
      arp_tx_grant = ~tx_busy;
      udp_tx_grant = 1'b0;
   end
   else if(udp_tx_req) begin
      tx_vld       = ~tx_busy;
      tx_count     = udp_tx_count;
      arp_tx_grant = 1'b0;
      udp_tx_grant = ~tx_busy;
   end
   else begin
      tx_vld       = 1'b0;
      tx_count     = '0;
      arp_tx_grant = 1'b0;
      udp_tx_grant = 1'b0;
   end


assign tx_data = udp_tx_data | arp_tx_data;


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

logic [15:0] rx_cnt;
logic [15:0] rx_cnt_err;
logic [15:0] rx_cnt_arp;

always_ff@(posedge clk)
   if(~resetn)
      rx_cnt <= '0;
   else if( rx_vld & rx_last & (rx_cnt != '1))
      rx_cnt <= rx_cnt + 1'b1;

always_ff@(posedge clk)
   if(~resetn)
      rx_cnt_err <= '0;
   else if( rx_vld & rx_last & ~rx_crc_ok & (rx_cnt_err != '1))
      rx_cnt_err <= rx_cnt_err + 1'b1;

always_ff@(posedge clk)
   if(~resetn)
      rx_cnt_arp <= '0;
   else if( count_arp & (rx_cnt_arp != '1))
      rx_cnt_arp <= rx_cnt_arp + 1'b1;


always_ff@(posedge clk)
   if(rx_udp_dvld)
      rx_udp_data_q <= rx_udp_data;


wire [31:0] seg7_in = sw ? rx_udp_data_q : {rx_cnt_arp, rx_cnt};

seg7 seg7(  .clk   ( clk                  ),
            .reset ( ~resetn              ),
            .data  ( seg7_in              ),
            .an    ( seg7_an              ),
            .ca    ( seg7_ca              ) );


assign leds = {uart_rx_char_b, uart_rx_char_a} | {15'd0, tx_busy};

assign uart_cts = 1'b1;

assign pmod_a[7:0] = 8'd0;

endmodule
