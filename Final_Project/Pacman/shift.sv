module shift
  #(parameter depth_p = 5
   ,parameter [depth_p-1:0] reset_val_p = 0)
   (input [0:0] clk_i
   ,input [0:0] reset_i
   ,input [0:0] data_i
   ,output [depth_p-1:0] data_o);

   logic [depth_p-1:0] q_l;

   always_ff @(posedge clk_i) begin
    if(reset_i) begin
        q_l <= reset_val_p;
       end else begin
        q_l <= q_l << 1;
        q_l[0] <= data_i;
       end
   end

   assign data_o = q_l;


endmodule
