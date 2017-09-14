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

// Valid under rx_vld, fifth from the end, counting from 1
wire [31:0] unused_expected_crc = ~{sreg[24], sreg[25], sreg[26], sreg[27], sreg[28], sreg[29], sreg[30], sreg[31],
                                    sreg[16], sreg[17], sreg[18], sreg[19], sreg[20], sreg[21], sreg[22], sreg[23],
                                    sreg[8], sreg[9],   sreg[10], sreg[11], sreg[12], sreg[13], sreg[14], sreg[15],
                                    sreg[0], sreg[1],   sreg[2],  sreg[3],  sreg[4],  sreg[5],  sreg[6],  sreg[7] };

endmodule
