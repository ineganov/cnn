module uart (  input              clk,
               input              reset,

               input  logic       tx_vld,
               input  logic [7:0] tx_data,
               output logic       tx_busy,

               output logic       rx_vld,
               output logic [7:0] rx_data,

               input  logic       rx,
               output logic       tx );

//---------------------------------------------------------------------------//

localparam CLK_FREQ    = 100000000; // In Hz
localparam BAUDRATE    = 115200;

localparam BIT_TIME    = CLK_FREQ/BAUDRATE - 1;
localparam HF_BIT_TIME = BIT_TIME/2 - 1;

localparam BIT_TIME_W  = $clog2(BIT_TIME);

//---------------------------------------------------------------------------//
//                              RX PART                                      //
//---------------------------------------------------------------------------//

localparam ST_RX_IDLE  = 0;
localparam ST_RX_START = 1;
localparam ST_RX_DATA  = 2;

logic            [3:0] rx_reg;
logic            [2:0] rx_state = 3'b001;
logic                  rx_sync, rx_negedge, rx_done;

logic [BIT_TIME_W-1:0] rx_bit_timer;
logic                  rx_bit_timer_bit, rx_bit_timer_hf_bit;

logic            [3:0] rx_bit_cnt;
logic                  rx_bit_cnt_last;

//---------------------------------------------------------------------------//


always_ff@(posedge clk)
   if(reset) rx_reg <= 4'b0;
   else      rx_reg <= {rx_reg[2:0], rx};

assign rx_sync    = rx_reg[3];
assign rx_negedge = rx_reg[3] & ~rx_reg[2]; 

//---------------------------------------------------------------------------//

always_ff@(posedge clk)
   if(reset | rx_bit_timer_bit | (rx_state[ST_RX_START] & rx_bit_timer_hf_bit))
      rx_bit_timer <= '0;
   else if(rx_state[ST_RX_START] | rx_state[ST_RX_DATA])
      rx_bit_timer <= rx_bit_timer + 1'b1;

assign rx_bit_timer_bit    = rx_bit_timer == BIT_TIME;
assign rx_bit_timer_hf_bit = rx_bit_timer == HF_BIT_TIME;

//---------------------------------------------------------------------------//

always_ff@(posedge clk)
   if(reset | (rx_bit_cnt_last & rx_bit_timer_bit))
      rx_bit_cnt <= '0;
   else if(rx_state[ST_RX_DATA] & rx_bit_timer_bit)
      rx_bit_cnt <= rx_bit_cnt + 1'b1;

assign rx_bit_cnt_last = rx_bit_cnt == 4'd8; // 8 because of stop bit
assign rx_done = rx_state[ST_RX_DATA] & rx_bit_timer_bit & rx_bit_cnt_last;

//---------------------------------------------------------------------------//

always_ff@(posedge clk)
   if(rx_state[ST_RX_DATA] & rx_bit_timer_bit & ~rx_bit_cnt_last)
      rx_data <= {rx_sync, rx_data[7:1]};

//---------------------------------------------------------------------------//

always_ff@(posedge clk)
   if(reset | rx_done)
      rx_state <= 3'b001;
   else if(rx_state[ST_RX_IDLE] & rx_negedge)
      rx_state <= 3'b010;
   else if(rx_state[ST_RX_START] & rx_bit_timer_hf_bit)
      rx_state <= 3'b100;

assign rx_vld = rx_done;

//---------------------------------------------------------------------------//
//                              TX PART                                      //
//---------------------------------------------------------------------------//

logic                  tx_transmit;
logic                  tx_done;

logic [BIT_TIME_W-1:0] tx_bit_timer;
logic                  tx_bit_timer_bit;

logic            [3:0] tx_bit_cnt;
logic                  tx_bit_cnt_last;

logic            [8:0] tx_data_sreg;

//---------------------------------------------------------------------------//

always_ff@(posedge clk)
   if(reset | tx_bit_timer_bit)
      tx_bit_timer <= '0;
   else if(tx_transmit)
      tx_bit_timer <= tx_bit_timer + 1'b1;

assign tx_bit_timer_bit = tx_bit_timer == BIT_TIME;

//---------------------------------------------------------------------------//

always_ff@(posedge clk)
   if(reset)
      tx_data_sreg <= '0;
   else if(tx_vld & (~tx_transmit | tx_done))
      tx_data_sreg <= {tx_data, 1'b0}; // tx_data + start bit
   else if(tx_transmit & tx_bit_timer_bit)
      tx_data_sreg <= {1'b1, tx_data_sreg[8:1]};

//---------------------------------------------------------------------------//

always_ff@(posedge clk)
   if(reset | tx_done)
      tx_bit_cnt <= '0;
   else if(tx_transmit & tx_bit_timer_bit)
      tx_bit_cnt <= tx_bit_cnt + 1'b1;

assign tx_bit_cnt_last = tx_bit_cnt == 4'd9; // Start bit + data + stop bit
assign tx_done = tx_transmit & tx_bit_cnt_last & tx_bit_timer_bit;

//---------------------------------------------------------------------------//

always_ff@(posedge clk)
   if(reset | (tx_done & ~tx_vld)) 
      tx_transmit <= 1'b0;
   else if(tx_vld & (~tx_transmit | tx_done))
      tx_transmit <= 1'b1;

//---------------------------------------------------------------------------//

assign tx_busy = tx_transmit & ~tx_done;
assign tx      = ~tx_transmit | tx_data_sreg[0];

endmodule
