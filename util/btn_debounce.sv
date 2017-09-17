module btn_debounce( input  clk,
                     input  reset,
                     input  btn,
                     output btn_db );

logic [2:0] btn_sync;
logic       btn_reg;

always_ff@(posedge clk)
   btn_sync <= {btn_sync[1:0], btn};

logic [15:0] cnt = 0;

always_ff@(posedge clk)
   if(reset)
      cnt <= '0;
   else if(btn_sync[2])
      cnt <= '1;
   else if (|cnt)
      cnt <= cnt - 1'b1;

always_ff@(posedge clk)
   if(reset | (|cnt))
      btn_reg <= 1'b0;
   else if(btn_sync[2])
      btn_reg <= 1'b1;

assign btn_db = btn_reg;

endmodule
