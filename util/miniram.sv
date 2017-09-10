module miniram #( parameter D = 4,   // Size = 2 ** D
                  parameter W = 8 )

               (  input          clk,

                  input          re,
                  input          we,
                  input  [D-1:0] addr,
                  input  [W-1:0] wdata,
                  output [W-1:0] rdata );


logic [W-1:0] data_arr[0:2**D-1]; 
logic [W-1:0] rdata_q;

always_ff@(posedge clk)
   if(we) data_arr[addr] <= wdata;

always_ff@(posedge clk)
   if(re) rdata_q <= data_arr[addr];

assign rdata = rdata_q;

endmodule