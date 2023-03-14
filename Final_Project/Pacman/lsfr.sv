module lsfr
 (input [0:0] clk_i
 ,input [0:0] reset_i
 ,output [7:0] data_o);
 
 wire[0:0] xor_o_w;
 
 assign xor_o_w = data_o[0] ^ data_o[5] ^ data_o[6] ^ data_o[7];
 
 shift
  #(.depth_p(8),.reset_val_p(8'b00000001))
 shift_inst_lsfr
  (.clk_i
  ,.reset_i
  ,.data_i(xor_o_w)
  ,.data_o(data_o)
  );
 
 
 
 endmodule
