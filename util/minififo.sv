module minififo #(  parameter D = 4,   // Size = 2 ** D
                    parameter W = 8 )

                 (  input          clk,
                    input          reset,

                    input          re,
                    output [W-1:0] rdata,
                    output         nempty,

                    input          we,
                    input  [W-1:0] wdata,
                    output         full );

logic [W-1:0] data_arr[0:2**D-1]; 
logic [W-1:0] rdata_q;
logic   [D:0] rd_ptr, wr_ptr, rd_ptr_q, wr_ptr_q; 


always_ff@(posedge clk)
   if(reset)   rd_ptr <= '0;
   else if(re) rd_ptr <= rd_ptr + 1'b1;

always_ff@(posedge clk)
   if(reset)   wr_ptr <= '0;
   else if(we) wr_ptr <= wr_ptr + 1'b1;

always_ff@(posedge clk)
   if(we) data_arr[wr_ptr[D-1:0]] <= wdata;

always_ff@(posedge clk)
   rdata_q <= data_arr[rd_ptr[D-1:0]];

// This is super-wrong and can only be used in slow reads
always_ff@(posedge clk)
   if(reset) rd_ptr_q <= '0;
   else      rd_ptr_q <= rd_ptr;

always_ff@(posedge clk)
   if(reset) wr_ptr_q <= '0;
   else      wr_ptr_q <= wr_ptr;

assign rdata = rdata_q;
assign nempty = (rd_ptr_q != wr_ptr_q);
assign full   = (rd_ptr[D-1:0] == wr_ptr[D-1:0]) & (rd_ptr[D] ^ wr_ptr[D]);

always@(posedge clk)
   assert(! ( re & ~nempty & ~reset) );

always@(posedge clk)
   assert(!( we & full & ~reset));


endmodule