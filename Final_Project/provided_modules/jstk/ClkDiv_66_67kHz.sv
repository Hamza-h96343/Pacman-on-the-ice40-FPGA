module ClkDiv_66_67kHz
  (input [0:0] clk_i
  ,input [0:0] reset_i
  ,output [0:0] clk_o
  );

   assign clk_o = clk_r;
   
   // Output register
   reg    clk_r = 1'b1;

   // Value to toggle output clock at
   parameter max_val_p = 7'b1011010;
   // Current count
   logic [6:0] count_r = 7'b0000000;

   always_ff @(posedge clk_i) begin
      if(reset_i) begin
         clk_r <= 1'b0;
         count_r <= '0;
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

