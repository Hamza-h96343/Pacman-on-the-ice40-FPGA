module input_de_sync (input clk_i, btn_i, output btn_o);
    reg [19:0] ctr_d, ctr_q;
    reg [1:0] sync_d, sync_q;

    assign btn_o = ctr_q == {20{1'b1}};

    always_comb begin
        sync_d[0] = btn_i;
        sync_d[1] = sync_q[0];
        ctr_d = ctr_q + 1'b1;

        if (ctr_q == {20{1'b1}}) begin
            ctr_d = ctr_q;
        end

        if (!sync_q[1]) begin
            ctr_d = 20'd0;
        end

    end

    always_ff @(posedge clk_i) begin
        ctr_q <= ctr_d;
        sync_q <= sync_d;
    end

endmodule
