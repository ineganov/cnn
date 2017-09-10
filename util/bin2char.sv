module bin2char  (input        clk,
                  input        reset,

                  input        bin_vld,
                  input        bin_last, // Generates a space after last digit
                  input  [7:0] bin_data, 

                  output       char_vld,
                  output [7:0] char_data );


logic       char_byte_0_vld;
logic [7:0] char_byte_0;

logic       char_byte_1_vld;
logic [7:0] char_byte_1;

logic       char_space_vld;
logic [7:0] char_space = 8'h20;

logic       char_byte_en;
logic [7:0] char_byte;

logic [7:0] bin_data_q;
logic [2:0] data_push, last_push;


assign char_byte_0 = to_char(bin_data_q[7:4]);
assign char_byte_1 = to_char(bin_data_q[3:0]);


always@(posedge clk)
   if(bin_vld)
      bin_data_q <= bin_data;

always@(posedge clk)
   if(reset) data_push <= 3'd0;
   else      data_push <= {data_push[1:0], bin_vld};

always@(posedge clk)
   if(reset) last_push <= 3'd0;
   else      last_push <= {last_push[1:0], bin_last};

assign char_byte_0_vld = data_push[0];
assign char_byte_1_vld = data_push[1];
assign char_space_vld  = data_push[2] & last_push[2];

assign char_vld  = char_space_vld | char_byte_0_vld | char_byte_1_vld;

assign char_data =   ({8{char_byte_0_vld}} & char_byte_0) |
                     ({8{char_byte_1_vld}} & char_byte_1) |
                     ({8{ char_space_vld}} & char_space ) ;

function [7:0] to_char(input [3:0] hex);
   begin
      if(hex < 4'd10) to_char = hex + 8'h30;
      else            to_char = hex + 8'h61 - 8'd10;
   end
endfunction                       

endmodule
