module  eth_fcs_tb;

// Captured frame example:

// Sync             Target       Sender       ARP  Htpe Ptpe Alen Op   SenderHWAddr Sendr IP Target_HWadr 
// 55555555555555d5 ffffffffffff 985aebdd1c64 0806 0001 0800 0604 0001 985aebdd1c64 c0a80202 000000000000 9d37eb91 000000000000000000000000000000000000 f1ff3421
// 8                6            6            2    2    2    2    2    6            4        6            4        18                                   4
//                  12                        10                       10                    10

logic [511:0] tv_a = 512'hffffffffffff985aebdd1c6408060001080006040001985aebdd1c64c0a802020000000000009d37eb91000000000000000000000000000000000000f1ff3421;
logic [511:0] tv_b = 512'hffffffffffff985aebdd1c6408060001080006040001985aebdd1c64c0a802020000000000009d37eb9100000000000000000000000000000000000000000000;

logic  [63:0] tv_c = 64'h4142434400000000; 

logic        clk = 0, reset = 1, en = 0, data_in = 0;
logic [31:0] fcs;
logic  [7:0] cur_byte;

always #5ns clk = ~clk;


initial
begin
   #20ns reset = 0;

   @(posedge clk) en = 1;
   for (int i = 63; i >= 0; i--)
   begin
      cur_byte = tv_a[i*8+:8];

      for(int j = 0; j < 8; j++)
      begin
         data_in = cur_byte[j];
         @(posedge clk) #1;
      end

   end
   en = 0 ;

   #100ns;

   $display("FCS:     %08x\n", fcs);
   $display("FCS_rev: %08x\n", { fcs[0],  fcs[1],  fcs[2],  fcs[3],  fcs[4],  fcs[5],  fcs[6],  fcs[7],
                                 fcs[8],  fcs[9],  fcs[10], fcs[11], fcs[12], fcs[13], fcs[14], fcs[15], 
                                 fcs[16], fcs[17], fcs[18], fcs[19], fcs[20], fcs[21], fcs[22], fcs[23], 
                                 fcs[24], fcs[25], fcs[26], fcs[27], fcs[28], fcs[29], fcs[30], fcs[31] });

   $finish;
end

eth_fcs eth_fcs(  .clk     ( clk     ),
                  .reset   ( reset   ),
                  .en      ( en      ),
                  .data_in ( data_in ),
                  .fcs     ( fcs     ) );

endmodule