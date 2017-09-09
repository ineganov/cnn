module eth_fcs (  input         clk,
                  input         reset,
                  input         en,
                  input         data_in,
                  output [31:0] fcs );

logic [31:0] sreg = 32'hffffffff;
logic [31:0] sreg_n;
logic        do_xor;

assign do_xor = sreg[31] ^ data_in;

assign sreg_n = do_xor ? {sreg[30:0], 1'b0} ^ 32'h04c11db7 : {sreg[30:0], 1'b0};

always_ff@(posedge clk)
   if(reset)   sreg <= '1;
   else if(en) sreg <= sreg_n;

assign fcs = sreg;


wire [31:0] sreg_inv = {fcs[0],  fcs[1],  fcs[2],  fcs[3],  fcs[4],  fcs[5],  fcs[6],  fcs[7],
                        fcs[8],  fcs[9],  fcs[10], fcs[11], fcs[12], fcs[13], fcs[14], fcs[15], 
                        fcs[16], fcs[17], fcs[18], fcs[19], fcs[20], fcs[21], fcs[22], fcs[23], 
                        fcs[24], fcs[25], fcs[26], fcs[27], fcs[28], fcs[29], fcs[30], fcs[31] };

endmodule