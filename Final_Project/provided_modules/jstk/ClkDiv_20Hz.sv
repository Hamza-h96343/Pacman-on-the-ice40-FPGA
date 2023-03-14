module ClkDiv_20Hz
  (input [0:0] clk_i
  ,input [0:0] reset_i
  ,output [0:0] clk_o
  );

   logic [0:0]    clk_r = 1'b1;

   parameter max_val_p = 19'h493E0;
   logic [18:0] count_r = 19'h00000;
   
   assign clk_o = clk_r;

   always_ff @(posedge clk_i) begin

      // Reset clock
      if(reset_i == 1'b1) begin
	 clk_r <= 1'b0;
	 count_r <= 0;
      end else begin
	 if(count_r == max_val_p) begin
	    clk_r <= ~clk_r;
	    count_r <= 0;
	 end
	 else begin
	    count_r <= count_r + 1'b1;
	 end
      end
   end
endmodule

