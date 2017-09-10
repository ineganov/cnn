module  eth (  input        clk,
               input        reset,

               output       rx_vld,
               output       rx_last,
               output       rx_err,
               output       rx_crc_ok,
               output [7:0] rx_data,

               output       eth_resetn,
               output       eth_clk,
               output [1:0] eth_txd,
               output       eth_tx_en,
               input  [1:0] eth_rxd,
               input        eth_rx_err,
               input        eth_crs_dv );

logic       eth_clk_q = 0;
logic       sample;

logic [1:0] rmii_rxd_d1, rmii_rxd_d2;
logic       rmii_dv_d1, rmii_dv_d2, rmii_rx_err_d1, rmii_vld, rmii_err;
logic [7:0] rmii_byte_sreg;
logic [1:0] rmii_2bit_cnt;

logic [4:0] rx_state = 5'd1;
logic [4:0] rx_nextst;

localparam RX_ST_IDLE  = 0;
localparam RX_ST_DROPZ = 1;
localparam RX_ST_PRMBL = 2;
localparam RX_ST_SFD   = 3;
localparam RX_ST_DATA  = 4;

// Clocking half rate, 100 MHz system clock assumed

always_ff@(posedge clk)
   eth_clk_q <= ~eth_clk_q;

assign sample = ~eth_clk_q;

// Incoming data registered two times: d1 feeds nextstate logic, d2 feeds sampling

always_ff@(posedge clk)
   if(sample) begin
      rmii_rxd_d1 <= eth_rxd;
      rmii_rxd_d2 <= rmii_rxd_d1;
      rmii_dv_d1  <= eth_crs_dv;
      rmii_dv_d2  <= rmii_dv_d1;
      rmii_rx_err_d1 <= eth_rx_err;
   end

always_ff@(posedge clk)
   if(reset)
      rx_state <= 1'b1 << RX_ST_IDLE;
   else if(sample & |rx_nextst)
      rx_state <= rx_nextst;

// FSM Rules:
wire rx_nextst_dropz   = rx_state[RX_ST_IDLE ] &  rmii_dv_d1 & (rmii_rxd_d1 == 2'b00);
wire rx_nextst_prmbl_0 = rx_state[RX_ST_IDLE ] &  rmii_dv_d1 & (rmii_rxd_d1 == 2'b01);
wire rx_nextst_prmbl_1 = rx_state[RX_ST_DROPZ] &  rmii_dv_d1 & (rmii_rxd_d1 == 2'b01);
wire rx_nextst_sfd     = rx_state[RX_ST_PRMBL] &  rmii_dv_d1 & (rmii_rxd_d1 == 2'b11);
wire rx_nextst_data    = rx_state[RX_ST_SFD  ] &  rmii_dv_d1;
wire rx_nextst_idle_0  = rx_state[RX_ST_DATA ] & ~rmii_dv_d1;
wire rx_nextst_idle_1  = rx_state[RX_ST_PRMBL] & (~rmii_dv_d1 | (rmii_rxd_d1 == 2'b10) | (rmii_rxd_d1 == 2'b00));
wire rx_nextst_idle_2  = rx_state[RX_ST_DROPZ] & (~rmii_dv_d1 | ((rmii_rxd_d1 != 2'b01) & (rmii_rxd_d1 != 2'b00)));
wire rx_nextst_idle_3  = ~rx_state[RX_ST_IDLE] & rmii_rx_err_d1;

assign rx_nextst[RX_ST_IDLE ] = rx_nextst_idle_0 | rx_nextst_idle_1 | rx_nextst_idle_2 | rx_nextst_idle_3;
assign rx_nextst[RX_ST_DROPZ] = rx_nextst_dropz;
assign rx_nextst[RX_ST_PRMBL] = rx_nextst_prmbl_0 | rx_nextst_prmbl_1;
assign rx_nextst[RX_ST_SFD  ] = rx_nextst_sfd;
assign rx_nextst[RX_ST_DATA ] = rx_nextst_data;

wire frame_error = rx_nextst_idle_1 | rx_nextst_idle_2;

always_ff@(posedge clk)
   if(sample & rx_state[RX_ST_DATA])
      rmii_byte_sreg <= {rmii_rxd_d2, rmii_byte_sreg[7:2]};

always_ff@(posedge clk)
   if(reset | (sample & rx_state[RX_ST_SFD ]))
      rmii_2bit_cnt <= '0;
   else if    (sample & rx_state[RX_ST_DATA])
      rmii_2bit_cnt <= rmii_2bit_cnt + 1'b1;

always_ff@(posedge clk)
   if(reset | ~rx_state[RX_ST_DATA])
      rmii_vld <= 1'b0;
   else
      rmii_vld <= sample & rx_state[RX_ST_DATA] & (rmii_2bit_cnt == 2'd3);

always_ff@(posedge clk)
   if(reset | rx_state[RX_ST_IDLE])
      rmii_err <= 1'b0;
   else
      rmii_err <= rmii_err | rx_nextst_idle_1 | rx_nextst_idle_2 | rx_nextst_idle_3;

wire        rx_crc_datain = sample ? rmii_rxd_d2[1] : rmii_rxd_d2[0];
wire [31:0] rx_crc_fcs;

eth_fcs eth_rx_crc(  .clk      ( clk                          ),
                     .reset    ( reset | rx_state[RX_ST_IDLE] ),
                     .en       ( rx_state[RX_ST_DATA]         ),
                     .data_in  ( rx_crc_datain                ),
                     .fcs      ( rx_crc_fcs                   ));

assign rx_data   = rmii_byte_sreg;
assign rx_vld    = rmii_vld;
assign rx_last   = rmii_vld & ~rx_state[RX_ST_DATA];
assign rx_err    = rmii_err;
assign rx_crc_ok = (rx_crc_fcs == 32'hc704dd7b);


assign eth_clk    = eth_clk_q;
assign eth_resetn = ~reset;
assign eth_txd    = 2'd0;
assign eth_tx_en  = 1'b0;

endmodule