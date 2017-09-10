module eth_rx_fcs (  input  clk,
                     input  reset,
                     input  en,
                     input  data_in,
                     output crc_ok );

logic [31:0] sreg = 32'hffffffff;
logic [31:0] sreg_n;
logic        do_xor;

assign do_xor = sreg[31] ^ data_in;

assign sreg_n = do_xor ? {sreg[30:0], 1'b0} ^ 32'h04c11db7 : {sreg[30:0], 1'b0};

always_ff@(posedge clk)
   if(reset)   sreg <= '1;
   else if(en) sreg <= sreg_n;

assign crc_ok = (sreg == 32'hc704dd7b);

endmodule
