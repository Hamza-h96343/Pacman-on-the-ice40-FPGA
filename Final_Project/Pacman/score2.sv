module simple_score2 #(
    parameter CORDW=16,                // coordinate width
    parameter H_RES=640                // horizontal screen resolution
    ) (
    input  wire logic clk_pix,         // pixel clock
    input  wire logic [CORDW-1:0] sx,  // horizontal screen position
    input  wire logic [CORDW-1:0] sy,  // vertical screen position
    input  wire logic [3:0] score,   // score for right-side player (0-9)
    output      logic pix              // draw pixel at this position?
    );

    logic [0:14] chars [10];  // ten characters of 15 pixels each
    initial begin
        chars[0] = 15'b111_101_101_101_111;
        chars[1] = 15'b110_010_010_010_111;
        chars[2] = 15'b111_001_111_100_111;
        chars[3] = 15'b111_001_011_001_111;
        chars[4] = 15'b101_101_111_001_001;
        chars[5] = 15'b111_100_111_001_111;
        chars[6] = 15'b100_100_111_101_111;
        chars[7] = 15'b111_001_001_001_001;
        chars[8] = 15'b111_101_111_101_111;
        chars[9] = 15'b111_101_111_001_001;
    end

    // ensure score in range of characters (0-9)
    logic [3:0] char;
    always_comb begin
        char = (score < 10) ? score : 0;
    end

    // set screen region for each score: 12x20 pixels (8,8) from corner
    // subtract one from 'sx' to account for latency for registering 'pix'
    logic score_region;
    always_comb begin
        score_region = (sx >= H_RES-62 && sx < H_RES-50 && sy >= 30 && sy < 50);
    end
    // determine character pixel address from screen position (scale 4x)
    always_comb begin
        /* verilator lint_off WIDTH */
        if (score_region) pix_addr = (sx-(H_RES-62))/4 + 3*((sy-30)/4);
        else pix_addr = 0;
        /* verilator lint_on WIDTH */
    end

    // score pixel for current screen position
    logic [3:0] pix_addr;
    always_ff @(posedge clk_pix) begin
        if (score_region) pix <= chars[char][pix_addr];
        else pix <= 0;
    end
endmodule
