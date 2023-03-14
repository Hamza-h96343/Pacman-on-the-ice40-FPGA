`default_nettype none
`timescale 1ns / 1ps

// Generates 25.125 MHz (640x480 59.8 Hz) with 12 MHz input clock
// iCE40 PLLs are documented in Lattice TN1251 and ICE Technology Library

module clock_480p (
    input  wire logic clk_i,        // input clock (12 MHz)
    input  wire logic reset_i,            // reset
    output      logic clk_o,        // pixel clock
    output      logic clk_o_locked  // pixel clock locked?
    );

    localparam FEEDBACK_PATH="SIMPLE";
    localparam DIVR=4'b0000;
    localparam DIVF=7'b1000010;
    localparam DIVQ=3'b101;
    localparam FILTER_RANGE=3'b001;

    logic locked;
    SB_PLL40_PAD #(
        .FEEDBACK_PATH(FEEDBACK_PATH),
        .PLLOUT_SELECT("GENCLK"),
        .DIVR(DIVR),
        .DIVF(DIVF),
        .DIVQ(DIVQ),
        .FILTER_RANGE(FILTER_RANGE)
    ) SB_PLL40_PAD_inst (
        .PACKAGEPIN(clk_i),
        .PLLOUTCORE(clk_o),  // use global clock network
        .RESETB(1'b1),
        .BYPASS(1'b0),
        .LOCK(locked)
    );

    // ensure clock lock is synced with pixel clock
    logic locked_sync_0;
    always_ff @(posedge clk_o) begin
        locked_sync_0 <= locked;
        clk_o_locked <= locked_sync_0;
    end
endmodule
