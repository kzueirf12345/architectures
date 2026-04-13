
module fp_32_16_converter #(
    parameter WIDTH = 64
) (
    input               clk_i       ,
    input               rst_i       ,
    input               is_fp32_i   ,
    input   [32-1:0]    a_i         ,
    output  [32-1:0]    result_o
);
    reg [32-1:0] res_internal;

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            res_internal <= 32'b0;
        end else begin
            res_internal <= a_i;
        end
    end

    assign result_o = res_internal;
endmodule