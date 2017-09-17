module udp_tx_machine ( input         clk,
                        input         reset,

                        // ARB side
                        output        tx_req,
                        output [10:0] tx_count,
                        input         tx_grant,

                        // MAC TX side
                        input  [10:0] tx_addr,
                        input         tx_adv,
                        input         tx_last,
                        output  [7:0] tx_data,
   
                        input         tx_udp_go,
                        input         tx_udp_dvld,
                        input  [31:0] tx_udp_data );

// UDP:
//                                          LEN_ _ID_ FLG_ TTL PROT  CHK_  SenderIP  Dest__IP SPort DPort  Len_  Chk_  Data______
// 001fc6618ec5 acbc329f4423    0800   4500 0021 e0a3 0000  40   11  168b  c0a8014c  c0a80101 ea83  4e50   000d  3a5c  0102030405

//FIXME: parameterize

logic [47:0] my_hwaddr = 48'h98_5a_eb_dd_1c_65;
logic [47:0] rx_hwaddr = 48'h98_5a_eb_dd_1c_64;

logic [31:0] my_ip = 32'hc0a80205; // 192.168.2.5
logic [31:0] rx_ip = 32'hc0a80202; // 192.168.2.2

logic [15:0] my_port = 16'h4e50; // 20048

logic [31:0] my_data;

logic [15:0] pkt_count;
logic [15:0] ip_chksum;
logic [15:0] total_len;

logic  [3:0] udp_state = 4'd1;
logic  [3:0] udp_nextst;

localparam UDP_ST_IDLE  = 0;
localparam UDP_ST_ARB   = 1;
localparam UDP_ST_HDR   = 2;
localparam UDP_ST_DATA  = 3;

always_ff@(posedge clk)
   if(reset)
      udp_state <= 1'b1 << UDP_ST_IDLE;
   else if(|udp_nextst)
      udp_state <= udp_nextst;

assign udp_nextst[UDP_ST_ARB  ] = udp_state[UDP_ST_IDLE] & tx_udp_go;
assign udp_nextst[UDP_ST_HDR  ] = udp_state[UDP_ST_ARB ] & tx_grant;
assign udp_nextst[UDP_ST_DATA ] = udp_state[UDP_ST_HDR ] & tx_adv & (tx_addr == 11'd41);
assign udp_nextst[UDP_ST_IDLE ] = udp_state[UDP_ST_DATA] & tx_last;
                                  


logic [7:0] tx_data_n, tx_data_q;

always_ff@(posedge clk)
   if((udp_state[UDP_ST_HDR] | udp_state[UDP_ST_DATA]) & tx_adv)
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

      11'd12: tx_data_n = 8'h08; // is IP
      11'd13: tx_data_n = 8'h00; // is IP

      // ------------ IP Header ------------ //

      11'd14: tx_data_n = 8'h45; // IPv4, 20 byte header
      11'd15: tx_data_n = 8'h00; // DSCP/ECN

      11'd16: tx_data_n = total_len[1*8+:8]; // Total length
      11'd17: tx_data_n = total_len[0*8+:8]; // Total length

      11'd18: tx_data_n = pkt_count[1*8+:8]; // ID
      11'd19: tx_data_n = pkt_count[0*8+:8]; // ID

      11'd20: tx_data_n = 8'h00; // Flags
      11'd21: tx_data_n = 8'h00; // Flags

      11'd22: tx_data_n = 8'h40; // TTL
      11'd23: tx_data_n = 8'h11; // Proto UDP

      11'd24: tx_data_n = ip_chksum[1*8+:8]; // IP Checksum
      11'd25: tx_data_n = ip_chksum[0*8+:8]; // IP Checksum

      11'd26: tx_data_n = my_ip[3*8+:8]; // Src IP
      11'd27: tx_data_n = my_ip[2*8+:8]; // Src IP
      11'd28: tx_data_n = my_ip[1*8+:8]; // Src IP
      11'd29: tx_data_n = my_ip[0*8+:8]; // Src IP

      11'd30: tx_data_n = rx_ip[3*8+:8]; // Dest IP
      11'd31: tx_data_n = rx_ip[2*8+:8]; // Dest IP
      11'd32: tx_data_n = rx_ip[1*8+:8]; // Dest IP
      11'd33: tx_data_n = rx_ip[0*8+:8]; // Dest IP

      // ------------ UDP Header ------------ //

      11'd34: tx_data_n = my_port[1*8+:8]; // Src port
      11'd35: tx_data_n = my_port[0*8+:8]; // Src port

      11'd36: tx_data_n = my_port[1*8+:8]; // Dest port
      11'd37: tx_data_n = my_port[0*8+:8]; // Dest port

      11'd38: tx_data_n = 8'h00; // UDP Length
      11'd39: tx_data_n = 8'h1a; // UDP Length

      11'd40: tx_data_n = 8'h00; // UDP checksum
      11'd41: tx_data_n = 8'h00; // UDP checksum

      // ------------- Payload ------------- //

      11'd42: tx_data_n = my_data[3*8+:8]; // Payload
      11'd43: tx_data_n = my_data[2*8+:8]; // Payload
      11'd44: tx_data_n = my_data[1*8+:8]; // Payload
      11'd45: tx_data_n = my_data[0*8+:8]; // Payload

      default: tx_data_n = 8'h00;
   endcase

always_ff@(posedge clk)
   if(tx_udp_dvld)
      my_data <= tx_udp_data;

always_ff@(posedge clk)
   if(reset)        pkt_count <= '0;
   else if(tx_last) pkt_count <= pkt_count + 1'b1;

assign total_len = 16'd46; // 20 bytes IP header + 26 UDP, incl header

assign ip_chksum = ~(16'h0002        +
                     16'h4500        +
                     total_len       +
                     pkt_count       +
                     16'h0000        +
                     16'h4011        +
                     my_ip[1*16+:16] +
                     my_ip[0*16+:16] +
                     rx_ip[1*16+:16] +
                     rx_ip[0*16+:16] );

assign tx_req   = udp_state[UDP_ST_ARB];
assign tx_count = {11{udp_state[UDP_ST_ARB]}} & 11'd60; // 60 = 14 + 20 + 26 (Eth frame, IP hdr, UDP hdr+data)
assign tx_data  = {8{udp_state[UDP_ST_HDR] | udp_state[UDP_ST_DATA]}} & tx_data_q;

endmodule
