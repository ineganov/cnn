module testbench;


logic clk = 0, reset;

logic       tx_vld, tx_busy, rx_vld, rx, tx;
logic [7:0] tx_data, rx_data;

task uart_bit(int b);
  begin
  rx = b;
  #8.68us;
  end
endtask

task uart_byte(int bb);
  begin
  uart_bit(0); //start bit
  for(int i = 0; i < 8; i++)
    uart_bit(bb[i]);
  end
  uart_bit(1); //stop bit
  #10000;
endtask

/*task uart_tx_byte(int bb);
   tx_data = bb[7:0];
   tx_vld = 1'b1;
   @(posedge clk) tx_vld = 1'b0;
endtask*/ 

always
   #5ns clk = ~clk;


initial begin
   reset = 1;
   rx = 1;
//   tx_vld = 0;
   #20ns;
   reset = 0;
   #1us;

   uart_byte(8'h00);
   uart_byte(8'hFF);
   uart_byte(8'h01);
   uart_byte(8'h80);
   uart_byte(8'h31);
   uart_byte(8'h00);
/*
   #5us;
   uart_tx_byte(8'h00);

   @(negedge tx_busy)
   uart_tx_byte(8'hFF);

   @(negedge tx_busy)
   uart_tx_byte(8'h01);

   @(negedge tx_busy)
   uart_tx_byte(8'h80);

   @(negedge tx_busy)
   uart_tx_byte(8'h31);

   @(negedge tx_busy) #1us;
   uart_tx_byte(8'h00);
*/
   @(negedge tx_busy) #50us;

   $finish;
end

assign tx_vld = rx_vld;
assign tx_data = rx_data;

uart uut(.*);

endmodule
