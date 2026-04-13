`timescale 1ns/1ps

module fp_32_16_converter_tb();

    integer seed = 228667;
    localparam CLK_TIME = 8;

    localparam WIDTH      = 32;
    localparam HALF_WIDTH = 16;

    reg                 clk_i       ;   
    reg                 rst_i       ;
    reg                 is_fp32_i   ;
    reg     [32-1:0]    a_i         ;
    wire    [32-1:0]    result_o    ;


    fp_32_16_converter fp_32_16_converter_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .is_fp32_i(is_fp32_i),
        .a_i(a_i),
        .result_o(result_o)
    );

    always begin
        clk_i = 1'b0;
        #(CLK_TIME / 2);
        clk_i = 1'b1;
        #(CLK_TIME / 2);
    end
    
    initial begin
        $dumpvars;
        rst_i = 1'b0;
        @(posedge clk_i);#(CLK_TIME / 4);
        rst_i = 1'b1;
        @(posedge clk_i); #(CLK_TIME / 4);
        rst_i = 1'b0;

        // FP32 -> FP16 (MAX)
        is_fp32_i = 1'b1; a_i = 32'h52400000;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'hFFFF7BFF) $display("[PASS] Case 1: FP32(0x52400000) -> FP16(0x7BFF)");
        else $display("[FAIL] Case 1: Expected 0xFFFF7BFF, got 0x%h", result_o);

        // FP16 -> FP32 (NORMAL)
        is_fp32_i = 1'b0; a_i = 32'h00000200;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'h38000000) $display("[PASS] Case 2: FP16(0x0200) -> FP32(0x38000000)");
        else $display("[FAIL] Case 2: Expected 0x38000000, got 0x%h", result_o);

        // FP32 -> FP16 (-0)
        is_fp32_i = 1'b1; a_i = 32'h80000000;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'hFFFF8000) $display("[PASS] Case 3: FP32(-0.0) -> FP16(0x8000)");
        else $display("[FAIL] Case 3: Expected 0xFFFF8000, got 0x%h", result_o);

        // FP32 -> FP16 (NaN)
        is_fp32_i = 1'b1; a_i = 32'h7FC00000;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'hFFFF7E00) $display("[PASS] Case 4: FP32(NaN) -> FP16(0x7E00)");
        else $display("[FAIL] Case 4: Expected 0xFFFF7E00, got 0x%h", result_o);

        // FP16 -> FP32 (Inf)
        is_fp32_i = 1'b0; a_i = 32'h00007C00;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'h7F800000) $display("[PASS] Case 5: FP16(Inf) -> FP32(0x7F800000)");
        else $display("[FAIL] Case 5: Expected 0x7F800000, got 0x%h", result_o);

        // =====================================================
        // FP32 -> FP16
        // =====================================================

        // +INF
        is_fp32_i = 1'b1; a_i = 32'h7F800000;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'hFFFF7C00) $display("[PASS] FP32(+Inf) -> FP16(0x7C00)");
        else $display("[FAIL] FP32(+Inf): Exp 0xFFFF7C00, got 0x%h", result_o);

        // -INF
        is_fp32_i = 1'b1; a_i = 32'hFF800000;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'hFFFFFC00) $display("[PASS] FP32(-Inf) -> FP16(0xFC00)");
        else $display("[FAIL] FP32(-Inf): Exp 0xFFFFFC00, got 0x%h", result_o);

        // +0
        is_fp32_i = 1'b1; a_i = 32'h00000000;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'hFFFF0000) $display("[PASS] FP32(+0) -> FP16(0x0000)");
        else $display("[FAIL] FP32(+0): Exp 0xFFFF0000, got 0x%h", result_o);

        // -0
        is_fp32_i = 1'b1; a_i = 32'h80000000;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'hFFFF8000) $display("[PASS] FP32(-0) -> FP16(0x8000)");
        else $display("[FAIL] FP32(-0): Exp 0xFFFF8000, got 0x%h", result_o);

        // qNaN
        is_fp32_i = 1'b1; a_i = 32'h7FC00000;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'hFFFF7E00) $display("[PASS] FP32(qNaN) -> FP16(0x7E00)");
        else $display("[FAIL] FP32(qNaN): Exp 0xFFFF7E00, got 0x%h", result_o);

        // Normal -> Max
        is_fp32_i = 1'b1; a_i = 32'h52400000;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'hFFFF7BFF) $display("[PASS] FP32(Normal 0x52400000) -> FP16(Max 0x7BFF)");
        else $display("[FAIL] FP32(NormToMax): Exp 0xFFFF7BFF, got 0x%h", result_o);

        // Normal -> Subnormal
        is_fp32_i = 1'b1; a_i = 32'h38000000;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'hFFFF0200) $display("[PASS] FP32(Normal 0x38000000) -> FP16(Subnorm 0x0200)");
        else $display("[FAIL] FP32(NormToSub): Exp 0xFFFF0200, got 0x%h", result_o);

        // Normal -> Zero
        is_fp32_i = 1'b1; a_i = 32'h30800000;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'hFFFF0000) $display("[PASS] FP32(Normal 0x30800000) -> FP16(+0)");
        else $display("[FAIL] FP32(NormToZero): Exp 0xFFFF0000, got 0x%h", result_o);


        // =====================================================
        // FP16 -> FP32
        // =====================================================

        // +INF
        is_fp32_i = 1'b0; a_i = 32'h00007C00;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'h7F800000) $display("[PASS] FP16(+Inf) -> FP32(0x7F800000)");
        else $display("[FAIL] FP16(+Inf): Exp 0x7F800000, got 0x%h", result_o);

        // -INF
        is_fp32_i = 1'b0; a_i = 32'h0000FC00;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'hFF800000) $display("[PASS] FP16(-Inf) -> FP32(0xFF800000)");
        else $display("[FAIL] FP16(-Inf): Exp 0xFF800000, got 0x%h", result_o);

        // +0
        is_fp32_i = 1'b0; a_i = 32'h00000000;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'h00000000) $display("[PASS] FP16(+0) -> FP32(0x00000000)");
        else $display("[FAIL] FP16(+0): Exp 0x00000000, got 0x%h", result_o);

        // qNaN
        is_fp32_i = 1'b0; a_i = 32'h00007E00;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'h7FC00000) $display("[PASS] FP16(qNaN) -> FP32(0x7FC00000)");
        else $display("[FAIL] FP16(qNaN): Exp 0x7FC00000, got 0x%h", result_o);

        // Subnormal -> Normal
        is_fp32_i = 1'b0; a_i = 32'h00000200;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'h38000000) $display("[PASS] FP16(Subnorm 0x0200) -> FP32(Normal 0x38000000)");
        else $display("[FAIL] FP16(SubToNorm): Exp 0x38000000, got 0x%h", result_o);

        // Normal -> Normal
        is_fp32_i = 1'b0; a_i = 32'h00003C00;
        @(posedge clk_i); #(CLK_TIME / 4);
        if (result_o === 32'h3F800000) $display("[PASS] FP16(0x3C00 1.0) -> FP32(0x3F800000)");
        else $display("[FAIL] FP16(1.0): Exp 0x3F800000, got 0x%h", result_o);

        #(CLK_TIME * 2);

        $finish;
    end
    
endmodule