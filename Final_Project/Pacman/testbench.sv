`timescale 1ns/1ps
module testbench();
   
   logic up_i;
   logic reset_i;
   wire clk_i;
   wire [1:0] screen_o;
   
   
   nonsynth_clock_gen
     #(.cycle_time_p(10))
   cg
     (.clk_o(clk_i));

   nonsynth_reset_gen
     #(.num_clocks_p(1)
      ,.reset_cycles_lo_p(1)
      ,.reset_cycles_hi_p(10))
   rg
     (.clk_i(clk_i)
     ,.async_reset_o(reset_i));
   
   screens dut (
   	.clk_i(clk_i),
   	.reset_i(reset_i),
   	.up_i(up_i),
   	.end_i(1'b0),
   	.screen_o(screen_o)
	   
   );

   initial begin
   
	   
      // Leave this code alone, it generates the waveforms
`ifdef VERILATOR
      $dumpfile("verilator.fst");
`else
      $dumpfile("iverilog.vcd");
`endif
      $dumpvars;

      // Put your testbench code here. Print all of the test cases and
	
	#200
        up_i = 1;
        #150
        up_i = 0;
        #300

      // their correctness.

      $finish();
   end

   final begin
     $display("Simulation time is %t", $time);
     
	 $display("\033[0;32m    ____  ___    __________ \033[0m");
	 $display("\033[0;32m   / __ \\/   | / ___/ ___/ \033[0m");
	 $display("\033[0;32m  / /_/ / /| | \\__\_\\\__   \033[0m");
	 $display("\033[0;32m / ____/ __  |____/ /__/ /   \033[0m");
	 $display("\033[0;32m/_/   /_/  |_/_____/ ___/   \033[0m");
	 $display();
	 $display("Simulation Succeeded!");
      
   end

endmodule
