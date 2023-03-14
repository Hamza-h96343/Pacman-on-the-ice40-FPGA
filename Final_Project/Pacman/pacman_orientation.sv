module pacman_orientation # () (
	input 	wire up_i,
	input	wire down_i,
	input	wire left_i,
	input	wire right_i,
	input 	wire clk_i,
	input 	wire reset_i,
	output [1:0] orientation_o
);

	localparam right = 2'b00;
	localparam left = 2'b01;
	localparam up = 2'b10;
	localparam down = 2'b11;
	
	reg [1:0] present_state = right;
	reg [1:0] next_state = right;
	reg [1:0] orientation_r;
	
	always_comb begin
		next_state = right;
		orientation_r = 0;
		case(present_state)
			right: begin
				if(up_i && !(down_i | right_i | left_i)) begin
					next_state = up;
					orientation_r = up;
				end else if(down_i && !(up_i | right_i | left_i)) begin
					next_state = down;
					orientation_r = down;
				end else if(left_i && !(up_i | right_i | down_i)) begin
					next_state = left;
					orientation_r = left;
				end else begin
					next_state = right;
					orientation_r = right;
				end
			end
			
			left: begin
				if(up_i && !(down_i | right_i | left_i)) begin
					next_state = up;
					orientation_r = up;
				end else if(down_i && !(up_i | right_i | left_i)) begin
					next_state = down;
					orientation_r = down;
				end else if(right_i && !(down_i | up_i | left_i)) begin
					next_state = right;
					orientation_r = right;
				end else begin
					next_state = left;
					orientation_r = left;
				end
			end
			
			up: begin
				if(left_i && !(down_i | right_i | up_i)) begin
					next_state = left;
					orientation_r = left;
				end else if(down_i && !(up_i | right_i | left_i)) begin
					next_state = down;
					orientation_r = down;
				end else if(right_i && !(down_i | up_i | left_i)) begin
					next_state = right;
					orientation_r = right;
				end else begin
					next_state = up;
					orientation_r = up;
				end
			end
			
			down: begin
				if(left_i && !(down_i | right_i | up_i)) begin
					next_state = left;
					orientation_r = left;
				end else if(up_i && !(down_i | right_i | left_i)) begin
					next_state = up;
					orientation_r = up;
				end else if(right_i && !(down_i | up_i | left_i)) begin
					next_state = right;
					orientation_r = right;
				end else begin
					next_state = down;
					orientation_r = down;
				end
			end
			
			default: ;
		
		
		
		endcase
	
	
	end
	
	
	always_ff @(posedge clk_i) begin
		if(reset_i)begin
			present_state <= right;
		end else begin
			present_state <= next_state;
		end
	
	
	
	end
	
	assign orientation_o = orientation_r;
	


endmodule
