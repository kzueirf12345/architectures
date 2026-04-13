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


    fp_32_16_converter #(
        .WIDTH(WIDTH)
    ) fp_32_16_converter_inst (
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
        is_fp32_i = 1'b1; 
        a_i = 32'h52400000;
        @(posedge clk_i);
        #(CLK_TIME / 4);
        if (result_o === 32'hFFFF7BFF) 
            $display("[PASS] Case 1: FP32(0x52400000) -> FP16(0x7BFF)");
        else 
            $display("[FAIL] Case 1: Expected 0xFFFF7BFF, got 0x%h", result_o);

        // FP16 -> FP32 (NORMAL)
        is_fp32_i = 1'b0; 
        a_i = 32'h00000200;
        @(posedge clk_i);
        #(CLK_TIME / 4);
        if (result_o === 32'h38000000)
            $display("[PASS] Case 2: FP16(0x0200) -> FP32(0x38000000)");
        else 
            $display("[FAIL] Case 2: Expected 0x38000000, got 0x%h", result_o);

        // FP32 -> FP16 (-0)
        is_fp32_i = 1'b1; 
        a_i = 32'h80000000;
        @(posedge clk_i);
        #(CLK_TIME / 4);
        if (result_o === 32'hFFFF8000)
            $display("[PASS] Case 3: FP32(-0.0) -> FP16(0x8000)");
        else 
            $display("[FAIL] Case 3: Expected 0xFFFF8000, got 0x%h", result_o);

        // FP32 -> FP16 (NaN)
        is_fp32_i = 1'b1; 
        a_i = 32'h7FC00000;
        @(posedge clk_i);
        #(CLK_TIME / 4);
        if (result_o === 32'hFFFF7E00)
            $display("[PASS] Case 4: FP32(NaN) -> FP16(0x7E00)");
        else 
            $display("[FAIL] Case 4: Expected 0xFFFF7E00, got 0x%h", result_o);

        // FP16 -> FP32 (Inf)
        is_fp32_i = 1'b0; 
        a_i = 32'h00007C00;
        @(posedge clk_i);
        #(CLK_TIME / 4);
        if (result_o === 32'h7F800000)
            $display("[PASS] Case 5: FP16(Inf) -> FP32(0x7F800000)");
        else 
            $display("[FAIL] Case 5: Expected 0x7F800000, got 0x%h", result_o);

        #(CLK_TIME * 2);

        $finish;
    end
    
endmodule