module arp_machine ( input        clk,
                     input        reset,

                     // MAC RX side
                     input        rx_vld,
                     input        rx_last,
                     input        rx_err,
                     input        rx_crc_ok,
                     input        rx_busy,
                     input [10:0] rx_addr,
                     input  [7:0] rx_data,

                     output       count_arp,

                     // MAC TX side
                     output        tx_vld,
                     output [10:0] tx_count,
                     input  [10:0] tx_addr,
                     input         tx_adv,
                     input         tx_busy,
                     input         tx_last,
                     output  [7:0] tx_data );

// Captured ARP req example:
// Target       Sender       ARP  Htpe Ptpe Alen Op   SenderHWAddr Sendr IP Target_HWadr 
// ffffffffffff 985aebdd1c64 0806 0001 0800 0604 0001 985aebdd1c64 c0a80202 000000000000 9d37eb91 000000000000000000000000000000000000 f1ff3421


logic [47:0] my_hwaddr = 48'h98_5a_eb_dd_1c_65;
logic [47:0] rx_hwaddr;

logic [31:0] my_ip = 32'hc0a80205; // 192.168.2.5
logic [31:0] rx_ip;

logic  [3:0] arp_state = 4'd1;
logic  [3:0] arp_nextst;

logic        is_arp;
logic        byte_chk;

localparam ARP_ST_IDLE  = 0;
localparam ARP_ST_CHECK = 1;
localparam ARP_ST_ARB   = 2;
localparam ARP_ST_SEND  = 3;

always_ff@(posedge clk)
   if(reset)
      arp_state <= 1'b1 << ARP_ST_IDLE;
   else if(|arp_nextst)
      arp_state <= arp_nextst;

assign arp_nextst[ARP_ST_CHECK] = arp_state[ARP_ST_IDLE ] & rx_busy;
assign arp_nextst[ARP_ST_ARB  ] = arp_state[ARP_ST_CHECK] & rx_vld & rx_last & rx_crc_ok & ~rx_err & is_arp;
assign arp_nextst[ARP_ST_SEND ] = arp_state[ARP_ST_ARB  ] & ~tx_busy;
assign arp_nextst[ARP_ST_IDLE ] = (arp_state[ARP_ST_SEND ] & tx_last) |
                                  (arp_state[ARP_ST_CHECK] & rx_vld & rx_last & (~rx_crc_ok  | rx_err | ~is_arp));


always_ff@(posedge clk)
   if(reset | arp_nextst[ARP_ST_CHECK])
      is_arp <= 1'b1;
   else if(rx_vld)
      is_arp <= is_arp & byte_chk;


always_comb
   case(rx_addr)

      11'd0:   byte_chk = (rx_data == 8'hFF) | (rx_data == my_hwaddr[5*8+:8]);
      11'd1:   byte_chk = (rx_data == 8'hFF) | (rx_data == my_hwaddr[4*8+:8]);
      11'd2:   byte_chk = (rx_data == 8'hFF) | (rx_data == my_hwaddr[3*8+:8]);
      11'd3:   byte_chk = (rx_data == 8'hFF) | (rx_data == my_hwaddr[2*8+:8]);
      11'd4:   byte_chk = (rx_data == 8'hFF) | (rx_data == my_hwaddr[1*8+:8]);
      11'd5:   byte_chk = (rx_data == 8'hFF) | (rx_data == my_hwaddr[0*8+:8]);

      // 6..11 -> skip sender hwaddr chk

      11'd12:  byte_chk = (rx_data == 8'h08); // is ARP
      11'd13:  byte_chk = (rx_data == 8'h06); // is ARP

      // 14..15 -> skip hw type chk
 
      11'd16:  byte_chk = (rx_data == 8'h08); // proto ipv4
      11'd17:  byte_chk = (rx_data == 8'h00); // proto ipv4

      // 18..19 -> skip addr len chk

      11'd20:  byte_chk = (rx_data == 8'h00); // is req
      11'd21:  byte_chk = (rx_data == 8'h01); // is req

      11'd38:  byte_chk = (rx_data == my_ip[3*8+:8]);
      11'd39:  byte_chk = (rx_data == my_ip[2*8+:8]);
      11'd40:  byte_chk = (rx_data == my_ip[1*8+:8]);
      11'd41:  byte_chk = (rx_data == my_ip[0*8+:8]);

      default: byte_chk = 1'b1;
   endcase

always_ff@(posedge clk) if(arp_state[ARP_ST_CHECK] & (rx_addr == 11'd6 )) rx_hwaddr[5*8+:8] <= rx_data;
always_ff@(posedge clk) if(arp_state[ARP_ST_CHECK] & (rx_addr == 11'd7 )) rx_hwaddr[4*8+:8] <= rx_data;
always_ff@(posedge clk) if(arp_state[ARP_ST_CHECK] & (rx_addr == 11'd8 )) rx_hwaddr[3*8+:8] <= rx_data;
always_ff@(posedge clk) if(arp_state[ARP_ST_CHECK] & (rx_addr == 11'd9 )) rx_hwaddr[2*8+:8] <= rx_data;
always_ff@(posedge clk) if(arp_state[ARP_ST_CHECK] & (rx_addr == 11'd10)) rx_hwaddr[1*8+:8] <= rx_data;
always_ff@(posedge clk) if(arp_state[ARP_ST_CHECK] & (rx_addr == 11'd11)) rx_hwaddr[0*8+:8] <= rx_data;

always_ff@(posedge clk) if(arp_state[ARP_ST_CHECK] & (rx_addr == 11'd28)) rx_ip[3*8+:8] <= rx_data;
always_ff@(posedge clk) if(arp_state[ARP_ST_CHECK] & (rx_addr == 11'd29)) rx_ip[2*8+:8] <= rx_data;
always_ff@(posedge clk) if(arp_state[ARP_ST_CHECK] & (rx_addr == 11'd30)) rx_ip[1*8+:8] <= rx_data;
always_ff@(posedge clk) if(arp_state[ARP_ST_CHECK] & (rx_addr == 11'd31)) rx_ip[0*8+:8] <= rx_data;


logic [7:0] tx_data_n, tx_data_q;

always_ff@(posedge clk)
   if(arp_state[ARP_ST_SEND] & tx_adv)
      tx_data_q <= tx_data_n;

always_comb
   case(tx_addr)

      11'd0:  tx_data_n = rx_hwaddr[5*8+:8];
      11'd1:  tx_data_n = rx_hwaddr[4*8+:8];
      11'd2:  tx_data_n = rx_hwaddr[3*8+:8];
      11'd3:  tx_data_n = rx_hwaddr[2*8+:8];
      11'd4:  tx_data_n = rx_hwaddr[1*8+:8];
      11'd5:  tx_data_n = rx_hwaddr[0*8+:8];

      11'd6:  tx_data_n = my_hwaddr[5*8+:8];
      11'd7:  tx_data_n = my_hwaddr[4*8+:8];
      11'd8:  tx_data_n = my_hwaddr[3*8+:8];
      11'd9:  tx_data_n = my_hwaddr[2*8+:8];
      11'd10: tx_data_n = my_hwaddr[1*8+:8];
      11'd11: tx_data_n = my_hwaddr[0*8+:8];

      11'd12: tx_data_n = 8'h08; // is ARP
      11'd13: tx_data_n = 8'h06; // is ARP

      11'd14: tx_data_n = 8'h00;
      11'd15: tx_data_n = 8'h01;

      11'd16: tx_data_n = 8'h08; // proto ipv4
      11'd17: tx_data_n = 8'h00; // proto ipv4

      11'd18: tx_data_n = 8'h06;
      11'd19: tx_data_n = 8'h04;

      11'd20: tx_data_n = 8'h00;
      11'd21: tx_data_n = 8'h02; // Reply

      11'd22: tx_data_n = my_hwaddr[5*8+:8];
      11'd23: tx_data_n = my_hwaddr[4*8+:8];
      11'd24: tx_data_n = my_hwaddr[3*8+:8];
      11'd25: tx_data_n = my_hwaddr[2*8+:8];
      11'd26: tx_data_n = my_hwaddr[1*8+:8];
      11'd27: tx_data_n = my_hwaddr[0*8+:8];

      11'd28: tx_data_n = my_ip[3*8+:8];
      11'd29: tx_data_n = my_ip[2*8+:8];
      11'd30: tx_data_n = my_ip[1*8+:8];
      11'd31: tx_data_n = my_ip[0*8+:8];

      11'd32: tx_data_n = rx_hwaddr[5*8+:8];
      11'd33: tx_data_n = rx_hwaddr[4*8+:8];
      11'd34: tx_data_n = rx_hwaddr[3*8+:8];
      11'd35: tx_data_n = rx_hwaddr[2*8+:8];
      11'd36: tx_data_n = rx_hwaddr[1*8+:8];
      11'd37: tx_data_n = rx_hwaddr[0*8+:8];

      11'd38: tx_data_n = rx_ip[3*8+:8];
      11'd39: tx_data_n = rx_ip[2*8+:8];
      11'd40: tx_data_n = rx_ip[1*8+:8];
      11'd41: tx_data_n = rx_ip[0*8+:8];

      default: tx_data_n = 8'h00;
   endcase

assign tx_vld   = arp_state[ARP_ST_ARB];
assign tx_count = 11'd60;
assign tx_data  = tx_data_q;

assign count_arp = arp_nextst[ARP_ST_ARB  ];

endmodule
