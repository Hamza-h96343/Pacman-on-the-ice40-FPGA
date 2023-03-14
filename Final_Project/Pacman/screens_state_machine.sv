`default_nettype none
`timescale 1ns / 1ps

module screens (
	input wire logic clk_i,
	input reset_i,
	input up_i,
	input end_i,
	output [1:0] screen_o
);


reg [1:0] present_state = 2'b00;
reg [1:0] next_state = 2'b00;
reg [1:0] screen_r;

always_comb begin
	next_state = 2'b00;
	screen_r = 0;
	case(present_state)
		2'b00: begin
			if(up_i == 1) begin
				next_state = 2'b01;
				screen_r = 1;
			end else begin
				next_state = 2'b00;
				screen_r = 0;
			end
		end
		
		2'b01: begin
			if(end_i == 1) begin
				next_state = 2'b10;
				screen_r = 2;
			end else begin
				next_state = 2'b01;
				screen_r = 1;
			end
		
		end
		
		2'b10: begin
			if(up_i == 1) begin
				next_state = 2'b00;
				screen_r = 0;
			end else begin
				next_state = 2'b10;
				screen_r = 2;
			end
		end
		
		default: ;
	
	
	
	
	endcase

end



always_ff @(posedge clk_i) begin
	if(reset_i | next_state == 2'b00) begin
		present_state <= 2'b00;
	end else begin
		present_state <= next_state;
	end

end

assign screen_o = screen_r;

endmodule
