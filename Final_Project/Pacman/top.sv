module top (
	input [0:0] clk_12mhz_i,
	input [0:0] reset_n_async_unsafe_i,
	input [0:0] button_async_unsafe_i,
	output      logic dvi_clk,      // DVI pixel clock
	output      logic dvi_hsync,    // DVI horizontal sync
	output      logic dvi_vsync,    // DVI vertical sync
	output      logic dvi_de,       // DVI data enable
	output      logic [3:0] dvi_r,  // 4-bit DVI red
	output      logic [3:0] dvi_g,  // 4-bit DVI green
	output      logic [3:0] dvi_b,  // 4-bit DVI blue
	output [0:0] spi_cs_o,
	output [0:0] spi_sd_o,
	input  [0:0] spi_sd_i,
	output [0:0] spi_sck_o,   
	output [4:2] led_o
);

	wire [0:0] reset_n_sync_r;
	wire [0:0] reset_sync_r;
	wire [0:0] reset_r; // Use this as your reset_signal

	wire [2:1] button_sync_r;
	wire [0:0] button_sync;

	dff
	 #()
	sync_a
	 (.clk_i(clk_pix)
	 ,.reset_i(1'b0)
	 ,.d_i(reset_n_async_unsafe_i)
	 ,.q_o(reset_n_sync_r));

	inv
	 #()
	inv
	 (.a_i(reset_n_sync_r)
	 ,.b_o(reset_sync_r));

	dff
	 #()
	sync_b
	 (.clk_i(clk_pix)
	 ,.reset_i(1'b0)
	 ,.d_i(reset_sync_r)
	 ,.q_o(reset_r));

	//button/jstk sync


	logic [0:0] right, left, up, down;
	

	input_de_sync start_b(.clk_i(clk_pix), .btn_i(button_async_unsafe_i), .btn_o(button_sync));
	input_de_sync jstk_r(.clk_i(clk_pix), .btn_i(position_x > 640), .btn_o(right));
	input_de_sync jstk_l(.clk_i(clk_pix), .btn_i(position_x < 384), .btn_o(left));
	input_de_sync jstk_u(.clk_i(clk_pix), .btn_i(position_y > 640), .btn_o(up));
	input_de_sync jstk_d(.clk_i(clk_pix), .btn_i(position_y < 384), .btn_o(down));

	//setup modules for the dvi interface
	logic clk_pix;
	logic clk_pix_locked;
	clock_480p clock_pix_inst (
	  .clk_i(clk_12mhz_i),
	  .reset_i(reset_r),
	  .clk_o(clk_pix),
	  .clk_o_locked(clk_pix_locked)
	);

	logic rst_pix;
	always_comb rst_pix = !clk_pix_locked;  // wait for clock lock

	logic frame;
	localparam CORDW = 16;  // signed coordinate width (bits)
	logic signed [CORDW-1:0] sx, sy;
	logic hsync, vsync;
	logic de, line;
	display_480p #(.CORDW(CORDW)) display_inst (
	.clk_pix,
	.rst_pix,
	.sx,
	.sy,
	.hsync,
	.vsync,
	.de,
	.frame,
	.line
	);
	
	// jstk variables and module setup
	wire [39:0] data_o;
	wire [39:0] data_i;
	wire [9:0]  position_x;
	wire [9:0]  position_y;

	wire [23:0] color_rgb;

	PmodJSTK 
		#()
	jstk_i (
		.clk_12mhz_i(clk_pix)
		,.reset_i(reset_r)
		,.data_i(data_i)
		,.spi_sd_i(spi_sd_i)
		,.spi_cs_o(spi_cs_o)
		,.spi_sck_o(spi_sck_o)
		,.spi_sd_o(spi_sd_o)
		,.data_o(data_o)
	);

	// data_o is Data Recieved from the PmodJSTK
	// Byte 1: Low byte X Coordinate
	// Byte 2: High byte X Coordinate
	// Byte 3: Low byte Y Coordinate
	// Byte 4: High byte Y Coordinate
	// Byte 5: High six bytes are ignored, then trigger, joystick
	assign position_y = {data_o[25:24], data_o[39:32]};
	assign position_x = {data_o[9:8], data_o[23:16]};

	// data_i to be sent to PmodJSTK.
	// Byte 1: Control Command for RGB on PmodJSTK
	// Byte 2: Red
	// Byte 3: Green
	// Byte 4: Blue
	// Byte 5: Ignored
	assign data_i = {8'b10000100, color_rgb, 8'b00000000};

	// Example Code: The example assignment statments below will light
	// the directional LEDs 2-5 when the joystick is pushed in a
	// direction.
	//
	// The Trigger button will light the red LED.

	// Red
	assign color_rgb[23:16] = 8'h00;
	// Green
	assign color_rgb[15:8] = 8'h00;
	// Blue
	assign color_rgb[7:0] = 8'h00;

	// Trigger Button
	assign led_o[4] = data_o[1];
	// bitmap: MSB first, so we can write pixels left to right
	/* verilator lint_off LITENDIAN */
	logic [0:160] bmap_maze [120]; 
	logic [0:160] bmap_start [120];
	logic [0:160] bmap_over [120];
	/* verilator lint_on LITENDIAN */

	initial begin
		
		$readmemb("pacman_maze.mem", bmap_maze);
		$readmemb("pacman_menu.mem", bmap_start);
		$readmemb("pacman_game_over.mem", bmap_over);
		$readmemb("foodXcoords.mem", food_x_coord);
		$readmemb("foodYcoords.mem", food_y_coord);
	end
	
	//sprite bitmaps used throughout
	localparam SPR_FILE_RIGHT = "pacman_sprite_right.mem";  // bitmap file
	localparam SPR_FILE_LEFT = "pacman_sprite_left.mem";  // bitmap file
	localparam SPR_FILE_UP = "pacman_sprite_top.mem";  // bitmap file
	localparam SPR_FILE_DOWN = "pacman_sprite_bottom.mem";  // bitmap file
	localparam SPR_FILE_CIRCLE = "pacman_sprite_circle.mem";  // bitmap file
	localparam SPR_FILE_SCORE = "pacman_sprite_score.mem";  // bitmap file
	localparam SPR_FILE_LIVES = "pacman_sprite_lives.mem";  // bitmap file
	localparam SPR_FILE_FOOD = "food_sprite.mem";  // bitmap file
	localparam SPR_FILE_READY = "ready_maze.mem";  // bitmap file
	localparam SPR_FILE_GHOST = "ghost_sprite.mem";  // bitmap file
	
	//pacamn menus state machine
	
	logic [1:0] screen_o;

	screens screen_inst (
		.clk_i(clk_pix),
		.reset_i(reset_r),
		.up_i(button_sync),
		.end_i(lives == 0 | (total_score == 30)),
		.screen_o(screen_o)
	);
	
	//pacman movement counters and variables
	
	
	logic [15:0] x_val;
	logic [15:0] y_val;

	counter #(
		.width_p(10)
		,.overroll_right_val(1)
		,.overroll_left_val(470))
	pac_x (
		.clk_i(frame && clk_pix)
		,.overroll_right(x_val > 480)
		,.overroll_left(x_val <= 0)
		,.start_i(SPRX)
		,.reset_i(reset_r | (screen_o != 2'b01) | spawn_reset)
		,.up_i(right_p && ready_view && !spawn_reset)
		,.down_i(left_p && ready_view)
		,.counter_o(x_val)
	);

	counter #(
		.width_p(10))
	pac_y (
		.clk_i(frame)
		,.overroll_right(1'b0)
		,.overroll_left(1'b0)
		,.start_i(SPRY)
		,.reset_i(reset_r | (screen_o != 2'b01) | spawn_reset)
		,.up_i(up_p && ready_view)
		,.down_i(down_p && ready_view && !spawn_reset)
		,.counter_o(y_val)
	);
	
	//pacman orientation animation state machine and the corresponding sprite modules for each orientation
	
	logic [1:0] orientation;
	
	pacman_orientation
	 #()
	orientation_pacman(
		.up_i(up),
		.down_i(down),
		.left_i(left),
		.right_i(right),
		.clk_i(clk_pix),
		.reset_i(reset_r | (screen_o != 2'b01)),
		.orientation_o(orientation)
	 );
	 
	// sprite parameters pacman
	localparam SPRX       = 235;  // horizontal position
	localparam SPRY       = 259;  // vertical position
	localparam SPR_WIDTH  =  8;  // bitmap width in pixels
	localparam SPR_HEIGHT =  8;  // bitmap height in pixels
	localparam SPR_SCALE  =  1;  // 2^3 = 8x scale
	localparam SPR_DATAW  =  1;  // bits per pixel
	localparam H_RES = 640;
	 
	//pacman sprite modules for each orientation and idle and setup variables.
	logic drawing_left, drawing_right, drawing_up, drawing_down, drawing_circle;
	
	logic [SPR_DATAW-1:0] pix_left, pix_right, pix_up, pix_down, pix_circle;
	sprite #(
		.CORDW(CORDW),
		.H_RES(H_RES),
		.SPR_FILE(SPR_FILE_RIGHT),
		.SPR_WIDTH(SPR_WIDTH),
		.SPR_HEIGHT(SPR_HEIGHT),
		.SPR_SCALE(SPR_SCALE),
		.SPR_DATAW(SPR_DATAW)
	) sprite_r (
		.clk(clk_pix),
		.rst(rst_pix),
		.line,
		.sx,
		.sy,
		.sprx(x_val),
		.spry(y_val),
		.pix(pix_right),
		.drawing(drawing_right)
	);
	
	sprite #(
		.CORDW(CORDW),
		.H_RES(H_RES),
		.SPR_FILE(SPR_FILE_LEFT),
		.SPR_WIDTH(SPR_WIDTH),
		.SPR_HEIGHT(SPR_HEIGHT),
		.SPR_SCALE(SPR_SCALE),
		.SPR_DATAW(SPR_DATAW)
	) sprite_l (
		.clk(clk_pix),
		.rst(rst_pix),
		.line,
		.sx,
		.sy,
		.sprx(x_val),
		.spry(y_val),
		.pix(pix_left),
		.drawing(drawing_left)
	);
	
	sprite #(
		.CORDW(CORDW),
		.H_RES(H_RES),
		.SPR_FILE(SPR_FILE_DOWN),
		.SPR_WIDTH(SPR_WIDTH),
		.SPR_HEIGHT(SPR_HEIGHT),
		.SPR_SCALE(SPR_SCALE),
		.SPR_DATAW(SPR_DATAW)
	) sprite_u (
		.clk(clk_pix),
		.rst(rst_pix),
		.line,
		.sx,
		.sy,
		.sprx(x_val),
		.spry(y_val),
		.pix(pix_up),
		.drawing(drawing_up)
	);
	
	sprite #(
		.CORDW(CORDW),
		.H_RES(H_RES),
		.SPR_FILE(SPR_FILE_UP),
		.SPR_WIDTH(SPR_WIDTH),
		.SPR_HEIGHT(SPR_HEIGHT),
		.SPR_SCALE(SPR_SCALE),
		.SPR_DATAW(SPR_DATAW)
	) sprite_d (
		.clk(clk_pix),
		.rst(rst_pix),
		.line,
		.sx,
		.sy,
		.sprx(x_val),
		.spry(y_val),
		.pix(pix_down),
		.drawing(drawing_down)
	);
	
	sprite #(
		.CORDW(CORDW),
		.H_RES(H_RES),
		.SPR_FILE(SPR_FILE_CIRCLE),
		.SPR_WIDTH(SPR_WIDTH),
		.SPR_HEIGHT(SPR_HEIGHT),
		.SPR_SCALE(SPR_SCALE),
		.SPR_DATAW(SPR_DATAW)
	) sprite_circle (
		.clk(clk_pix),
		.rst(rst_pix),
		.line,
		.sx,
		.sy,
		.sprx(x_val),
		.spry(y_val),
		.pix(pix_circle),
		.drawing(drawing_circle)
	);

	
	
	// ghost sprite, movement, collision logic, and state machines
	logic drawing_score, drawing_lives, drawing_ghost;  // drawing at (sx,sy)
	
	logic [SPR_DATAW-1:0] pix_score, pix_lives, pix_ghost;  // pixel colour index
	
	logic [7:0] rand_bit;
	logic [1:0] rand_val = 1;
	logic [15:0] x_gval;
	logic [15:0] y_gval;

	logic [15:0] x_gval_start = 210;
	logic [15:0] y_gval_start = 170;
	
	lsfr ran_v(.clk_i(clk_pix),.reset_i(reset_r | (screen_o != 2'b01)),.data_o(rand_bit));
	
	
	counter #(
		.width_p(10)
		,.overroll_right_val(1)
		,.overroll_left_val(470))
	ghost_x (
		.clk_i(frame && clk_pix)
		,.overroll_right(x_gval > 470)
		,.overroll_left(x_gval <= 0)
		,.start_i(x_gval_start)
		,.reset_i(reset_r | (screen_o != 2'b01) | ghost_reset)
		,.up_i(right_g && ready_view && !ghost_reset)
		,.down_i(left_g && ready_view)
		,.counter_o(x_gval)
	);

	counter #(
		.width_p(10))
	ghost_y (
		.clk_i(frame)
		,.overroll_right(1'b0)
		,.overroll_left(1'b0)
		,.start_i(y_gval_start)
		,.reset_i(reset_r | (screen_o != 2'b01) | ghost_reset)
		,.up_i(up_g && ready_view)
		,.down_i(down_g && ready_view && !ghost_reset)
		,.counter_o(y_gval)
	);
	
	//ghost collisions state machine
	
	logic [0:0] right_g, left_g, up_g, down_g;
	
	logic collision_ghost_r;
	logic collision_ghost_l;
	logic collision_ghost_u;
	logic collision_ghost_d;
	
	logic ghost_collision_pacman;
	
	logic pacman_collision_ghost;
	
	logic ghost_reset;
	
	logic [8:0] ghosts_killed = 0;
	
	logic [3:0] power_ups = 0;
	
	logic scared = 1'b0;
	
	always_ff @(posedge clk_pix) begin
		
		
		
		if(poll_done) begin
			if(x_val >= x_gval && y_val >= y_gval) begin
				if((x_val - x_gval) > (y_val-y_gval) && !collision_ghost_r) begin
					rand_val <= 0;
				end else if(!collision_ghost_u) begin
					rand_val <= 2;
				end else if(!collision_ghost_l) begin
					rand_val <= 1;
				end else begin
					rand_val <= 3;
				end
			end else if(x_val >= x_gval && y_val <= y_gval) begin
				if((x_val - x_gval) > (y_gval-y_val) && !collision_ghost_r) begin
					rand_val <= 0;
				end else if(!collision_ghost_d) begin
					rand_val <= 3;
				end else if(!collision_ghost_l) begin
					rand_val <= 1;
				end else begin
					rand_val <= 2;
				end
			end else if(x_val <= x_gval && y_val >= y_gval) begin
				if((x_gval - x_val) > (y_val-y_gval) && !collision_ghost_l) begin
					rand_val <= 1;
				end else if(!collision_ghost_u) begin
					rand_val <= 2;
				end else if (!collision_ghost_r) begin
					rand_val <= 0;
				end else begin
					rand_val <= 3;
				end
			end else begin
				if((x_gval - x_val) > (y_gval-y_val) && !collision_ghost_l) begin
					rand_val <= 1;
				end else if(!collision_ghost_d) begin
					rand_val <= 3;
				end else if (!collision_ghost_r) begin
					rand_val <= 0;
				end else begin
					rand_val <= 2;
				end
			end
		
		end
		
		
		case(spawn_reset)
		
			1'b0: begin
				if(ghost_collision_pacman) begin
					lives <= lives - 1;
					spawn_reset <= 1'b1;
				end
				if(reset_r | (screen_o != 2'b01)) begin
					lives <= 3;	
				end
			end
			
			1'b1: begin
				if(x_val == 235 && y_val == 259) begin
					spawn_reset <= 1'b0;
				end
			end
			
			default:;
		
		endcase
		
		case(ghost_reset)
		
			1'b0: begin
				if(reset_r | (screen_o != 2'b01))begin
					ghosts_killed <= 0;
				
				end else if(pacman_collision_ghost) begin
					ghost_reset <= 1'b1;
					ghosts_killed <= ghosts_killed + 2;
				end
			end
			
			1'b1: begin
				if(x_gval == 210 && y_gval == 170) begin
					ghost_reset <= 1'b0;
				end
			end
			
			default:;
		
		endcase
		
		case(scared)
			1'b0: begin
				ghost_collision_pacman <= ((drawing_right && pix_right && (orientation == 2'b00)) | 
					     (drawing_left && pix_left && (orientation == 2'b01)) | 
					     (drawing_up && pix_up && (orientation == 2'b10)) |
					     (drawing_down && pix_down && (orientation == 2'b11))) && (pix_ghost && drawing_ghost);
				pacman_collision_ghost <= 0;
				if (reset_r | (screen_o != 2'b01)) begin
					power_ups <= 0;
				end else begin
					if(food_collision[0] && !power_ups[0]) begin
						scared <= 1'b1;
					end
					if(food_collision[3] && !power_ups[1]) begin
						scared <= 1'b1;
					end
					if(food_collision[26] && !power_ups[2]) begin
						scared <= 1'b1;
					end
					if(food_collision[29] && !power_ups[3]) begin
						scared <= 1'b1;
					end
				end
			end
			
			1'b1: begin
				ghost_collision_pacman <= 0;
				pacman_collision_ghost <= ((drawing_right && pix_right && (orientation == 2'b00)) | 
					     (drawing_left && pix_left && (orientation == 2'b01)) | 
					     (drawing_up && pix_up && (orientation == 2'b10)) |
					     (drawing_down && pix_down && (orientation == 2'b11))) && (pix_ghost && drawing_ghost);
				if(reset_r | (screen_o != 2'b01))begin
					scared <= 0;
				end
				if(done_t4 | (x_gval == 210 && y_gval == 170)) begin
					if(food_collision[0]) begin
						power_ups[0] = 1;
						scared <= 0;
					end
					if(food_collision[3] ) begin
						power_ups[1] = 1;
						scared <= 0;
					end
					if(food_collision[26] ) begin
						power_ups[2] = 1;
						scared <= 0;
					end
					if(food_collision[29]) begin
						power_ups[3] = 1;
						scared <= 0;
					end
					
				end
			end
			default:;
		
		endcase
		
		
		collision_ghost_r = (rand_val == 0) && (x_gval && bmap_maze[y_gval[8:2]][x_gval[9:2]+5]) && (y_gval && bmap_maze[y_gval[8:2]+3][x_gval[9:2]+5]);
		collision_ghost_l = (rand_val == 1)&& (x_gval && bmap_maze[y_gval[8:2]][x_gval[9:2]-2]) && (y_gval && bmap_maze[y_gval[8:2]+3][x_gval[9:2]-2]);
		collision_ghost_u = (rand_val == 2) && (y_gval && bmap_maze[y_gval[8:2]+5][x_gval[9:2]]) && (x_gval && bmap_maze[y_gval[8:2]+5][x_gval[9:2]+3]);
		collision_ghost_d = (rand_val == 3) && (y_gval && bmap_maze[y_gval[8:2]-1][x_gval[9:2]]) && (x_gval && bmap_maze[y_gval[8:2]-1][x_gval[9:2]+3]);
		
		right_g <= (rand_val == 0) && !(x_gval && bmap_maze[y_gval[8:2]][x_gval[9:2]+5]) && !(y_gval && bmap_maze[y_gval[8:2]+3][x_gval[9:2]+5]);
		left_g <= (rand_val == 1)&& !(x_gval && bmap_maze[y_gval[8:2]][x_gval[9:2]-2]) && !(y_gval && bmap_maze[y_gval[8:2]+3][x_gval[9:2]-2]);
		up_g <= (rand_val == 2) && !(y_gval && bmap_maze[y_gval[8:2]+5][x_gval[9:2]]) && !(x_gval && bmap_maze[y_gval[8:2]+5][x_gval[9:2]+3]);
		down_g <= (rand_val == 3) && !(y_gval && bmap_maze[y_gval[8:2]-1][x_gval[9:2]]) && !(x_gval && bmap_maze[y_gval[8:2]-1][x_gval[9:2]+3]);
		
	end
	
	logic done_t4;
	
	timer #(
	    .TIME_WIDTH(32),
	    .CLOCK_FREQ(CLOCK_FREQ)
	) scared_timer (
	    .clk(clk_pix),
	    .reset(reset_r | (screen_o != 2'b01) | !scared),
	    .start(scared),
	    .duration(100000000),
	    .done(done_t4)
	);
	
	logic poll_done;
	logic spawn_reset;
	
	timer #(
	    .TIME_WIDTH(32),
	    .CLOCK_FREQ(CLOCK_FREQ)
	) poll_timer (
	    .clk(clk_pix),
	    .reset(reset_r | (screen_o != 2'b01) ),
	    .start(ready_view),
	    .duration(10000000),
	    .done(poll_done)
	);
	
	//ghost sprites
	sprite #(
		.CORDW(CORDW),
		.H_RES(H_RES),
		.SPR_FILE(SPR_FILE_GHOST),
		.SPR_WIDTH(SPR_WIDTH),
		.SPR_HEIGHT(SPR_HEIGHT),
		.SPR_SCALE(SPR_SCALE),
		.SPR_DATAW(SPR_DATAW)
	) sprite_ghost1 (
		.clk(clk_pix),
		.rst(rst_pix),
		.line,
		.sx,
		.sy,
		.sprx(x_gval),
		.spry(y_gval),
		.pix(pix_ghost),
		.drawing(drawing_ghost)
	);
	
	logic pix_mock_ghost, drawing_mock_ghost;	
	sprite #(
		.CORDW(CORDW),
		.H_RES(H_RES),
		.SPR_FILE(SPR_FILE_GHOST),
		.SPR_WIDTH(SPR_WIDTH),
		.SPR_HEIGHT(SPR_HEIGHT),
		.SPR_SCALE(SPR_SCALE),
		.SPR_DATAW(SPR_DATAW)
	) sprite_ghost1_mock (
		.clk(clk_pix),
		.rst(rst_pix),
		.line,
		.sx,
		.sy,
		.sprx(220),
		.spry(225),
		.pix(pix_mock_ghost),
		.drawing(drawing_mock_ghost)
	);
	
	//lives left variables and sprite modules
	
	
	logic [SPR_DATAW-1:0] pix_live1, pix_live2;
	logic drawing_live1, drawing_live2;
	logic [1:0] lives = 3;
	
	sprite #(
		.CORDW(CORDW),
		.H_RES(H_RES),
		.SPR_FILE(SPR_FILE_LEFT),
		.SPR_WIDTH(SPR_WIDTH),
		.SPR_HEIGHT(SPR_HEIGHT),
		.SPR_SCALE(SPR_SCALE),
		.SPR_DATAW(SPR_DATAW)
	) sprite_live1 (
		.clk(clk_pix),
		.rst(rst_pix),
		.line,
		.sx,
		.sy,
		.sprx(570),
		.spry(347),
		.pix(pix_live1),
		.drawing(drawing_live1)
	);
	sprite #(
		.CORDW(CORDW),
		.H_RES(H_RES),
		.SPR_FILE(SPR_FILE_LEFT),
		.SPR_WIDTH(SPR_WIDTH),
		.SPR_HEIGHT(SPR_HEIGHT),
		.SPR_SCALE(SPR_SCALE),
		.SPR_DATAW(SPR_DATAW)
	) sprite_live2 (
		.clk(clk_pix),
		.rst(rst_pix),
		.line,
		.sx,
		.sy,
		.sprx(590),
		.spry(347),
		.pix(pix_live2),
		.drawing(drawing_live2)
	);
	
	//scoring logic for the food and ghost kills
	
	 // score text sprite
	sprite #(
		.CORDW(CORDW),
		.H_RES(H_RES),
		.SPR_FILE(SPR_FILE_SCORE),
		.SPR_WIDTH(25),
		.SPR_HEIGHT(5),
		.SPR_SCALE(SPR_SCALE),
		.SPR_DATAW(SPR_DATAW)
	) sprite_score (
		.clk(clk_pix),
		.rst(rst_pix),
		.line,
		.sx,
		.sy,
		.sprx(520),
		.spry(30),
		.pix(pix_score),
		.drawing(drawing_score)
	);
	 //score display modules and calculation
	 
	logic [7:0] total_score = $countones(food_collision) + ghosts_killed;
	reg [3:0] score_digit1, score_digit2;
	
	always @(posedge clk_pix) begin
		score_digit1 <= total_score % 10;
		score_digit2 <= total_score / 10;
    end
	
	logic pix_digit1, pix_digit2;
	
	simple_score 
	 #()
	digit1_inst
	 (.clk_pix
	 ,.sx
	 ,.sy
	 ,.score(score_digit1)
	 ,.pix(pix_digit1));
	simple_score2 
	 #()
	digit2_inst
	 (.clk_pix
	 ,.sx
	 ,.sy
	 ,.score(score_digit2)
	 ,.pix(pix_digit2));
	
	
	//ready text for start of the game
	
	logic pix_ready, drawing_ready;
	
	sprite #(
		.CORDW(CORDW),
		.H_RES(H_RES),
		.SPR_FILE(SPR_FILE_READY),
		.SPR_WIDTH(27),
		.SPR_HEIGHT(5),
		.SPR_SCALE(SPR_SCALE),
		.SPR_DATAW(SPR_DATAW)
	) ready_maze (
		.clk(clk_pix),
		.rst(rst_pix),
		.line,
		.sx,
		.sy,
		.sprx(220),
		.spry(170),
		.pix(pix_ready),
		.drawing(drawing_ready)
	);
	
	//lives text
	
	sprite #(
		.CORDW(CORDW),
		.H_RES(H_RES),
		.SPR_FILE(SPR_FILE_LIVES),
		.SPR_WIDTH(25),
		.SPR_HEIGHT(5),
		.SPR_SCALE(SPR_SCALE),
		.SPR_DATAW(SPR_DATAW)
	) sprite_lives (
		.clk(clk_pix),
		.rst(rst_pix),
		.line,
		.sx,
		.sy,
		.sprx(520),
		.spry(350),
		.pix(pix_lives),
		.drawing(drawing_lives)
	);
	
	// food sprite modules and variables
	
	logic [CORDW-1:0] food_x_coord [30];
	logic [CORDW-1:0] food_y_coord [30];
	logic [29:0] drawing_food;
	logic [29:0] pix_food;
	logic [29:0] food_collision = 0;
	
	
	for(genvar j = 0; j <= 29; j++) begin
		if(j == 0 | j == 3 | j == 26 | j == 29) begin
			sprite #(
				.CORDW(CORDW),
				.H_RES(H_RES),
				.SPR_FILE(SPR_FILE_FOOD),
				.SPR_WIDTH(2),
				.SPR_HEIGHT(2),
				.SPR_SCALE(2),
				.SPR_DATAW(SPR_DATAW)
			) sprite_food (
				.clk(clk_pix),
				.rst(rst_pix),
				.line,
				.sx,
				.sy,
				.sprx(food_x_coord[j]),
				.spry(food_y_coord[j]),
				.pix(pix_food[j]),
				.drawing(drawing_food[j])
			);
		end else begin
			sprite #(
				.CORDW(CORDW),
				.H_RES(H_RES),
				.SPR_FILE(SPR_FILE_FOOD),
				.SPR_WIDTH(2),
				.SPR_HEIGHT(2),
				.SPR_SCALE(1),
				.SPR_DATAW(SPR_DATAW)
			) sprite_food (
				.clk(clk_pix),
				.rst(rst_pix),
				.line,
				.sx,
				.sy,
				.sprx(food_x_coord[j]),
				.spry(food_y_coord[j]),
				.pix(pix_food[j]),
				.drawing(drawing_food[j])
			);
		
		end
		
	
	
	end
	
	
	// paint at 32x scale in active screen area
	logic start;
	logic maze;
	logic over;
	logic logo_plate;
	logic logo_plate_back;
	logic hole_p;
	logic hole_a1;
	logic hole_a2;
	logic [7:0] x;  // 20 columns need five bits
	logic [6:0] y;  // 15 rows need four bits
	logic [9:0] p_x;  // 20 columns need five bits
	logic [8:0] p_y;  // 15 rows need four bits
	logic [0:0] right_p, left_p, up_p, down_p;
	
	reg right2, right3, left2, left3, up2, up3, down2, down3;
	reg [7:0] x_val2, x_val3, x_val4;
	reg [6:0] y_val2, y_val3, y_val4;

	always @(posedge clk_pix) begin

	    // Second stage
	    x_val2 <= x_val[9:2] + 5;
	    y_val2 <= y_val[8:2] + 3;
	    
	    x_val3 <= x_val[9:2] + 3;
	    y_val3 <= y_val[8:2] + 5;
	    
	    x_val4 <= x_val[9:2] - 2;
	    y_val4 <= y_val[8:2] - 1;

	    // Third stage
	    right2 <= right && !(up | down | left);
	    right3 <= right2 && !(x_val && bmap_maze[y_val[8:2]][x_val2]) && !(y_val && bmap_maze[y_val2][x_val2]);
	    
	    left2 <= left && !(up | down | right);
	    left3 <= left2 && !(x_val && bmap_maze[y_val[8:2]][x_val4]) && !(y_val && bmap_maze[y_val2][x_val4]);
	    
	    up2 <= up && !(right | down | left);
	    up3 <= up2 && !(y_val && bmap_maze[y_val3][x_val[9:2]]) && !(x_val && bmap_maze[y_val3][x_val3]);
	    
	    down2 <= down && !(right | up | left);
	    down3 <= down2 && !(y_val && bmap_maze[y_val4][x_val[9:2]]) && !(x_val && bmap_maze[y_val4][x_val3]);
	end

	assign right_p = right3;
	assign left_p = left3;
	assign up_p = up3;
	assign down_p = down3;
	
	
	
		
	always_ff @(posedge clk_pix) begin
		x <= sx[9:2];  // every 32 horizontal pixels
		y <= sy[8:2];  // every 32 vertical pixels
		p_x <= sx[9:0];
		p_y <= sy[8:0];
		start <= de ? bmap_start[y][x] : 0;  // look up pixel (unless we're in blanking)
		maze <= de ? bmap_maze[y][x] : 0;
		over <= de ? bmap_over[y][x] : 0;
		
		for (int i = 0; i <= 29; i++) begin
			case(food_collision[i])
				1'b0: begin
					food_collision[i] <= ((drawing_right && pix_right && (orientation == 2'b00)) | 
							     (drawing_left && pix_left && (orientation == 2'b01)) | 
							     (drawing_up && pix_up && (orientation == 2'b10)) |
							     (drawing_down && pix_down && (orientation == 2'b11))) && (pix_food[i] && drawing_food[i]);
				end
				1'b1: begin
					food_collision[i] <= 1'b1;
					if(reset_r | (screen_o != 2'b01)) begin
						food_collision[i] <= 1'b0;
					end 
				end
				
				default: food_collision[i] <= 1'b0 ;
			endcase
		end
	end
	
	//timer initialization variables
	parameter CLOCK_FREQ = 25000000; // 25 MHz
	parameter DURATION = 12500000; // 0.5 seconds (25 MHz * 0.5 = 12.5 million)
	reg done_t , done_t2, done_t3;
	reg start_t, start_t2 = 0;
	
	
	// Instantiate the timer modules for ready and pacman eating animation
	timer #(
	    .TIME_WIDTH(32),
	    .CLOCK_FREQ(CLOCK_FREQ)
	) eat_mouth_open (
	    .clk(clk_pix),
	    .reset(reset_r | (screen_o != 2'b01)),
	    .start(start_t),
	    .duration(DURATION),
	    .done(done_t)
	);
	
	timer #(
	    .TIME_WIDTH(32),
	    .CLOCK_FREQ(CLOCK_FREQ)
	) eat_mouth_close (
	    .clk(clk_pix),
	    .reset(reset_r | (screen_o != 2'b01)),
	    .start(start_t2),
	    .duration(DURATION),
	    .done(done_t2)
	);
	
	timer #(
	    .TIME_WIDTH(32),
	    .CLOCK_FREQ(CLOCK_FREQ)
	) ready_timer (
	    .clk(clk_pix),
	    .reset(reset_r | (screen_o != 2'b01)),
	    .start(screen_o == 2'b01),
	    .duration(35000000),
	    .done(done_t3)
	);
	
	
	
	logic ready_time;
	logic eat_animation;
	logic ready_view;
	
	always_ff @(posedge clk_pix) begin
		
		case(eat_animation)
			1'b0: begin
				if(right | left | up | down) begin
					start_t2 <=1;
					if(done_t2) begin
						eat_animation <= 1;
					end
					
				end
			end
			
			1'b1: begin
				if(right | left | up | down) begin
					start_t <=1;
					if(done_t) begin
						eat_animation <= 0;
					end
				end else begin
					eat_animation <= 0;
				end
			end
			
		
			default: eat_animation <= 0;
		endcase
		
		if(reset_r | (screen_o != 2'b01)) begin
			ready_view <= 0;
		end else if(done_t3 == 1) begin
			ready_view <= 1;
		end
	
	end

	// paint colour: yellow lines, blue background
	logic [3:0] paint_r, paint_g, paint_b;
	
	logic fd;

	always_comb begin
		hole_p = ((sx[9:1] > 63 && sx[9:1] < 66) && (sy[8:1] > 65 && sy[8:1] < 69));
		hole_a1 = ((sx[9:1] > 86 && sx[9:1] < 89) && (sy[8:1] > 75 && sy[8:1] < 79));
		hole_a2 = ((sx[9:1] > 227 && sx[9:1] < 230) && (sy[8:1] > 75 && sy[8:1] < 79));
		logo_plate = ((sx[9:1] > 45 && sx[9:1] < 280) && (sy[8:1] > 46 && sy[8:1] < 96));
		logo_plate_back = ((sx[9:1] > 40 && sx[9:1] < 285) && (sy[8:1] > 41 && sy[8:1] < 46)) |
						  ((sx[9:1] > 40 && sx[9:1] < 285) && (sy[8:1] >96 && sy[8:1] < 101)) |
						  ((sx[9:1] > 40 && sx[9:1] < 45) && (sy[8:1] >= 46 && sy[8:1] < 101)) |
						  ((sx[9:1] > 280 && sx[9:1] < 285) && (sy[8:1] >= 46 && sy[8:1] < 101));
		fd = ((pix_food[0] && drawing_food[0] && !food_collision[0]) |
			(pix_food[1] && drawing_food[1] && !food_collision[1]) |
			(pix_food[2] && drawing_food[2] && !food_collision[2]) |
			(pix_food[3] && drawing_food[3] && !food_collision[3]) |
			(pix_food[4] && drawing_food[4] && !food_collision[4]) |
			(pix_food[5] && drawing_food[5] && !food_collision[5]) |
			(pix_food[6] && drawing_food[6] && !food_collision[6]) |
			(pix_food[7] && drawing_food[7] && !food_collision[7]) |
			(pix_food[8] && drawing_food[8] && !food_collision[8]) |
			(pix_food[9] && drawing_food[9] && !food_collision[9]) |
			(pix_food[10] && drawing_food[10] && !food_collision[10]) |
			(pix_food[11] && drawing_food[11] && !food_collision[11]) |
			(pix_food[12] && drawing_food[12] && !food_collision[12]) |
			(pix_food[13] && drawing_food[13] && !food_collision[13]) |
			(pix_food[14] && drawing_food[14] && !food_collision[14]) |
			(pix_food[15] && drawing_food[15] && !food_collision[15]) |
			(pix_food[16] && drawing_food[16] && !food_collision[16]) |
			(pix_food[17] && drawing_food[17] && !food_collision[17]) |
			(pix_food[18] && drawing_food[18] && !food_collision[18]) |
			(pix_food[19] && drawing_food[19] && !food_collision[19]) |
			(pix_food[20] && drawing_food[20] && !food_collision[20]) |
			(pix_food[21] && drawing_food[21] && !food_collision[21]) |
			(pix_food[22] && drawing_food[22] && !food_collision[22]) |
			(pix_food[23] && drawing_food[23] && !food_collision[23]) |
			(pix_food[24] && drawing_food[24] && !food_collision[24]) |
			(pix_food[25] && drawing_food[25] && !food_collision[25]) |
			(pix_food[26] && drawing_food[26] && !food_collision[26]) |
			(pix_food[27] && drawing_food[27] && !food_collision[27]) |
			(pix_food[28] && drawing_food[28] && !food_collision[28]) |
			(pix_food[29] && drawing_food[29] && !food_collision[29]) );
	end
	always_comb begin
		if(screen_o == 2'b01) begin
			paint_r =  (((drawing_right && pix_right && (orientation == 2'b00)) | 
					   (drawing_left && pix_left && (orientation == 2'b01)) | 
					   (drawing_up && pix_up && (orientation == 2'b10)) |
					   (drawing_down && pix_down && (orientation == 2'b11)) && !eat_animation) | 
					   (drawing_circle && pix_circle && eat_animation) | 
					   (pix_live1 && drawing_live1 && (lives == 2 | lives == 3)) | 
					   (pix_live2 && drawing_live2 && lives == 3) |
					   (pix_ready && drawing_ready && !ready_view)) ? 4'hF : ((pix_ghost && drawing_ghost && ready_view && !scared) |
					   (drawing_mock_ghost && pix_mock_ghost && !ready_view) ) ? 4'hF :
					   (pix_ghost && drawing_ghost && ready_view && scared) ? 4'h2 : (maze) ? 4'h0 : 
					   ((pix_score && drawing_score) | 
					   (pix_lives && drawing_lives) |
					   (fd) | (pix_digit1) | (pix_digit2)) ? 4'hF : 4'h0;
			paint_g = (((drawing_right && pix_right && (orientation == 2'b00)) | 
					   (drawing_left && pix_left && (orientation == 2'b01)) | 
					   (drawing_up && pix_up && (orientation == 2'b10)) |
					   (drawing_down && pix_down && (orientation == 2'b11)) && !eat_animation) | 
					   (drawing_circle && pix_circle && eat_animation) | 
					   (pix_live1 && drawing_live1 && (lives == 2 | lives == 3)) | 
					   (pix_live2 && drawing_live2 && lives == 3)|
					   (pix_ready && drawing_ready && !ready_view)) ? 4'hF : ((pix_ghost && drawing_ghost && ready_view && !scared) |
					   (drawing_mock_ghost && pix_mock_ghost && !ready_view)) ? 4'h0 :
					   (pix_ghost && drawing_ghost && ready_view && scared) ? 4'h0 : (maze) ? 4'h0 : 
					   ((pix_score && drawing_score) | 
					   (pix_lives && drawing_lives) |
					   (fd) | (pix_digit1) | (pix_digit2)) ? 4'hF : 4'h0;
			paint_b = (((drawing_right && pix_right && (orientation == 2'b00)) | 
					   (drawing_left && pix_left && (orientation == 2'b01)) | 
					   (drawing_up && pix_up && (orientation == 2'b10)) |
					   (drawing_down && pix_down && (orientation == 2'b11)) && !eat_animation) | 
					   (drawing_circle && pix_circle && eat_animation) | 
					   (pix_live1 && drawing_live1 && (lives == 2 | lives == 3)) | 
					   (pix_live2 && drawing_live2 && lives == 3)|
					   (pix_ready && drawing_ready && !ready_view)) ? 4'h0 : ((pix_ghost && drawing_ghost && ready_view && !scared) |
					   (drawing_mock_ghost && pix_mock_ghost && !ready_view)) ? 4'h0 :
					   (pix_ghost && drawing_ghost && ready_view && scared) ? 4'hF : (maze) ? 4'hF : 
					   ((pix_score && drawing_score) | 
					   (pix_lives && drawing_lives) |
					   (fd) | (pix_digit1) | (pix_digit2)) ? 4'hF : 4'h0;
			
		end else if (screen_o == 2'b10) begin
			paint_r = (over) ? 4'hF : 4'h0;
			paint_g = (over) ? 4'hF : 4'h0;
			paint_b = (over) ? 4'h0 : 4'h0;

		end else begin
			paint_r = (logo_plate_back) ? 4'hF : (hole_p | hole_a1 | hole_a2) ? 4'h0 : (start) ? 4'hF : (logo_plate) ? 4'hF : 4'h0;
			paint_g = (logo_plate_back) ? 4'h0 : (hole_p | hole_a1 | hole_a2) ? 4'h0 : (start) ? 4'hF : (logo_plate) ? 4'h7 : 4'h0;
			paint_b = (logo_plate_back) ? 4'h0 : (hole_p | hole_a1 | hole_a2) ? 4'h0 : (start) ? 4'h0 : (logo_plate) ? 4'h0 : 4'h0;
		end
	end

	// display colour: paint colour but black in blanking interval
	logic [3:0] display_r, display_g, display_b;
	always_comb begin
		display_r = (de) ? paint_r : 4'h0;
		display_g = (de) ? paint_g : 4'h0;
		display_b = (de) ? paint_b : 4'h0;
	end

	// DVI Pmod output
	SB_IO #(
	 .PIN_TYPE(6'b010100)  // PIN_OUTPUT_REGISTERED
	) dvi_signal_io [14:0] (
	 .PACKAGE_PIN({dvi_hsync, dvi_vsync, dvi_de, dvi_r, dvi_g, dvi_b}),
	 .OUTPUT_CLK(clk_pix),
	 .D_OUT_0({hsync, vsync, de, display_r, display_g, display_b}),
	/* verilator lint_off PINCONNECTEMPTY */
	 .D_OUT_1()
	/* verilator lint_on PINCONNECTEMPTY */
	);

	// DVI Pmod clock output: 180° out of phase with other DVI signals
	SB_IO #(
	 .PIN_TYPE(6'b010000)  // PIN_OUTPUT_DDR
	) dvi_clk_io (
	 .PACKAGE_PIN(dvi_clk),
	 .OUTPUT_CLK(clk_pix),
	 .D_OUT_0(1'b0),
	 .D_OUT_1(1'b1)
	);
endmodule
