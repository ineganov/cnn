module seg7 (  input        clk,
               input        reset,

               input [31:0] data,

               output [7:0] an,
               output [7:0] ca );

logic  [2:0] cur_an;

logic [16:0] adv_cnt = '0;
logic        adv_an;

assign adv_an = (adv_cnt == '1);

always_ff@(posedge clk)
   adv_cnt <= adv_cnt + 1'b1;

always_ff@(posedge clk)
   if(reset)       cur_an <= '0;
   else if(adv_an) cur_an <= cur_an + 1'b1;

assign an = to_an(cur_an);
assign ca = to_ca(data[cur_an*4+:4]);


function [7:0] to_an(input [2:0] an_idx);
   case(an_idx)
         3'd0: to_an = 8'b11111110;
         3'd1: to_an = 8'b11111101;
         3'd2: to_an = 8'b11111011;
         3'd3: to_an = 8'b11110111;
         3'd4: to_an = 8'b11101111;
         3'd5: to_an = 8'b11011111;
         3'd6: to_an = 8'b10111111;
      default: to_an = 8'b01111111;
   endcase
endfunction 

function [7:0] to_ca(input [3:0] hex);
   case (hex)
         //                ABCDEFG_DP
         4'h0:  to_ca = 8'b0000001_1;
         4'h1:  to_ca = 8'b1001111_1;
         4'h2:  to_ca = 8'b0010010_1;
         4'h3:  to_ca = 8'b0000110_1;
         4'h4:  to_ca = 8'b1001100_1;
         4'h5:  to_ca = 8'b0100100_1;
         4'h6:  to_ca = 8'b0100000_1;
         4'h7:  to_ca = 8'b0001111_1;
         4'h8:  to_ca = 8'b0000000_1;
         4'h9:  to_ca = 8'b0000100_1;
         4'ha:  to_ca = 8'b0001000_1;
         4'hb:  to_ca = 8'b1100000_1;
         4'hc:  to_ca = 8'b0110001_1;
         4'hd:  to_ca = 8'b1000010_1;
         4'he:  to_ca = 8'b0110000_1;
      default:  to_ca = 8'b0111000_1;
   endcase
endfunction          

endmodule
