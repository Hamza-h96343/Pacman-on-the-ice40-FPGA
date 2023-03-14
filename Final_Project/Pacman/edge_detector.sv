module pos_edge_det(input col_i,
                    input clk_i,
                    output col_o);
    reg sig_dly_r;

    always_ff @(posedge clk_i) begin
        sig_dly_r <= col_i;
    end

    assign col_o = col_i & ~sig_dly_r;
endmodule
