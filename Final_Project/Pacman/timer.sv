module timer #(
    parameter TIME_WIDTH = 32, // width of the time value
    parameter CLOCK_FREQ = 100000000 // frequency of the clock input in Hz
)(
    input clk, // clock input
    input reset, // asynchronous reset input
    input start, // start signal input
    input [TIME_WIDTH-1:0] duration, // duration in clock cycles
    output done // done signal output
);

// Internal registers
reg [TIME_WIDTH-1:0] count; // count of clock cycles
reg running; // indicates whether the timer is running or not
reg done_r;

// Reset the internal registers on asynchronous reset

// Increment the count on each clock cycle when the timer is running
always @(posedge clk) begin
    if (reset) begin
        count <= 0;
        running <= 0;
        done_r <= 0;
    end else if(running) begin
    	count <= count + 1;
        if (count == duration) begin
            done_r <= 1;
            running <= 0;
        end
    	
    end else if (start) begin
        count <= 0;
        running <= 1;
        done_r <= 0;
    end
end
assign done = done_r;
endmodule
