module counter
  #(parameter width_p = 4,
    parameter overroll_right_val = 0,
    parameter overroll_left_val = 0)
   (input [0:0] clk_i
   ,input [0:0] overroll_right
   ,input [0:0] overroll_left
   ,input [width_p-1:0] start_i
   ,input [0:0] reset_i
   ,input [0:0] up_i
   ,input [0:0] down_i
   ,output [width_p-1:0] counter_o);

   // Implement a parameterized up/down counter. You must use behavioral verilog
   //
   // counter_o must reset to '0 at the positive edge of clk_i when reset_i is 1
   //
   // counter_o must have the following behavior at the positive edge of clk_i when reset_i is 0:
   // 
   // * Maintain the same value when up_i and down_i are both 1 or both 0.
   // 
   // * Increment by 1 when up_i is 1 and down_i is 0
   //
   // * Decrement by 1 when down_i is 1 and up_i is 0 
   //
   // * Use two's complement: -1 == '1 (Remember: decrementing by 1 is the same as adding negative 1)
   //
   // If the counter value overflows, return to 0. If the counter value underflows, return to the maximum value.
   //
   // (In other words you don't need to handle over/underflow conditions).
   // 
   // Your code here:
   reg [width_p-1:0] count;
  

   always_ff @(posedge clk_i) begin
       if(reset_i) begin
        count <= start_i;
       end else if(overroll_right == 1'b1) begin
        count <= overroll_right_val;
       end else if(overroll_left == 1'b1) begin
        count <= overroll_left_val;
       end else if(up_i) begin
        count <= count + 1;
       end else if(down_i) begin
       	count <= count - 1;
       end
   end

   assign counter_o = count;

endmodule
