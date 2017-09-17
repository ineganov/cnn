module udp_rx_machine ( input         clk,
                        input         reset,

                        // MAC RX side
                        input         rx_vld,
                        input         rx_last,
                        input         rx_err,
                        input         rx_crc_ok,
                        input         rx_busy,
                        input  [10:0] rx_addr,
                        input   [7:0] rx_data,
   
                        output        rx_udp_dvld,
                        output [31:0] rx_udp_data );

// UDP:
//                                          LEN_ _ID_ FLG_ TTL PROT  CHK_  SenderIP  Dest__IP SPort DPort  Len_  Chk_  Data______
// 001fc6618ec5 acbc329f4423    0800   4500 0021 e0a3 0000  40   11  168b  c0a8014c  c0a80101 ea83  4e50   000d  3a5c  0102030405

//FIXME: parameterize

logic [47:0] my_hwaddr = 48'h98_5a_eb_dd_1c_65;
logic [47:0] rx_hwaddr;

logic [31:0] my_ip = 32'hc0a80205; // 192.168.2.5
logic [31:0] rx_ip;

logic [15:0] my_port = 16'h4e50; // 20048

logic [31:0] my_data;

logic  [4:0] udp_state = 5'd1;
logic  [4:0] udp_nextst;

logic        is_udp;
logic        byte_chk;

localparam UDP_ST_IDLE  = 0;
localparam UDP_ST_CHECK = 1;
localparam UDP_ST_DATA  = 2;
localparam UDP_ST_ACT   = 3;
localparam UDP_ST_WAIT  = 4;

always_ff@(posedge clk)
   if(reset)
      udp_state <= 1'b1 << UDP_ST_IDLE;
   else if(|udp_nextst)
      udp_state <= udp_nextst;

assign udp_nextst[UDP_ST_CHECK] = udp_state[UDP_ST_IDLE ] & rx_busy;
assign udp_nextst[UDP_ST_DATA ] = udp_state[UDP_ST_CHECK] & rx_vld & is_udp & (rx_addr == 11'd41);
assign udp_nextst[UDP_ST_WAIT ] = udp_state[UDP_ST_CHECK] & rx_vld & ~is_udp; // Wait until the end of current packet
assign udp_nextst[UDP_ST_ACT  ] = udp_state[UDP_ST_DATA ] & rx_vld & rx_last & ~rx_err & rx_crc_ok;
assign udp_nextst[UDP_ST_IDLE ] = udp_state[UDP_ST_ACT] |
                                  | ( udp_state[UDP_ST_DATA] & rx_vld & rx_last & (rx_err | ~rx_crc_ok) )
                                  | ( udp_state[UDP_ST_WAIT] & rx_vld & rx_last );



always_ff@(posedge clk)
   if(reset | udp_nextst[UDP_ST_CHECK])
      is_udp <= 1'b1;
   else if(rx_vld)
      is_udp <= is_udp & byte_chk;


always_comb
   case(rx_addr)

      11'd0:   byte_chk = (rx_data == my_hwaddr[5*8+:8]);
      11'd1:   byte_chk = (rx_data == my_hwaddr[4*8+:8]);
      11'd2:   byte_chk = (rx_data == my_hwaddr[3*8+:8]);
      11'd3:   byte_chk = (rx_data == my_hwaddr[2*8+:8]);
      11'd4:   byte_chk = (rx_data == my_hwaddr[1*8+:8]);
      11'd5:   byte_chk = (rx_data == my_hwaddr[0*8+:8]);

      // 6..11 -> skip sender hwaddr chk

      11'd12:  byte_chk = (rx_data == 8'h08); // is IP
      11'd13:  byte_chk = (rx_data == 8'h00); // is IP

      // ---- IP Header ----

      // 14: IPV4, header length
      11'd14:  byte_chk = (rx_data == 8'h45); // IPv4, 20 byte header (no options)

      // 15: DSCP/ECN: ignore

      // 16..17: Total length: ignore

      // 18..19: packet ID: ignore

      // 20..21: Flags, fragment offset
      11'd20:  byte_chk = (rx_data == 8'h00); // No fragmentation
      11'd21:  byte_chk = (rx_data == 8'h00); // No fragmentation

      // 22: TTL: ignore

      // 23: IP Proto:
      11'd23: byte_chk = (rx_data == 8'h11); // Is UDP

      // 24..25: Header chksum
      // <accept any>

      // 26..29: Source IP
      // <accept any>

      // 30..33: Destination IP
      11'd30:  byte_chk = (rx_data == my_ip[3*8+:8]);
      11'd31:  byte_chk = (rx_data == my_ip[2*8+:8]);
      11'd32:  byte_chk = (rx_data == my_ip[1*8+:8]);
      11'd33:  byte_chk = (rx_data == my_ip[0*8+:8]);

      // ---- UDP header ----

      // 34..35 Source port
      // <accept any>

      // 36..37 Destination port
      11'd36:  byte_chk = (rx_data == my_port[1*8+:8]);
      11'd37:  byte_chk = (rx_data == my_port[0*8+:8]);

      // 38..39 Length
      // <accept any>

      // 40..41 UDP checksum
      // <accept any>

      // 42 onwards: UDP data

      default: byte_chk = 1'b1;
   endcase

always_ff@(posedge clk) if(udp_state[UDP_ST_DATA] & (rx_addr == 11'd42)) my_data[3*8+:8] <= rx_data;
always_ff@(posedge clk) if(udp_state[UDP_ST_DATA] & (rx_addr == 11'd43)) my_data[2*8+:8] <= rx_data;
always_ff@(posedge clk) if(udp_state[UDP_ST_DATA] & (rx_addr == 11'd44)) my_data[1*8+:8] <= rx_data;
always_ff@(posedge clk) if(udp_state[UDP_ST_DATA] & (rx_addr == 11'd45)) my_data[0*8+:8] <= rx_data;


assign rx_udp_dvld = udp_nextst[UDP_ST_ACT];
assign rx_udp_data = my_data;

endmodule
