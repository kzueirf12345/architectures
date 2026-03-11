
module alu #(
    parameter WIDTH = 64
) (
    input               clk_i   ,
    input               rst_i   ,
    input   [WIDTH-1:0] first_i ,
    input   [WIDTH-1:0] second_i,
    input   [2:0]       opcode_i,
    output  [WIDTH-1:0] result_o
);
    reg [WIDTH-1:0] res_internal;

    wire signed [WIDTH-1:0] first_signed;
    wire signed [WIDTH-1:0] second_signed;

    wire unsigned [WIDTH-1:0] first_unsigned;
    wire unsigned [WIDTH-1:0] second_unsigned;

    assign first_signed = first_i;
    assign second_signed = second_i;
    assign first_unsigned = first_i;
    assign second_unsigned = second_i;

    always @(posedge clk_i) begin
        if (rst_i) begin
            res_internal <= {WIDTH{1'b0}};
        end else begin
            case (opcode_i)
                3'b000: res_internal <= ~(first_i & second_i);
                3'b001: res_internal <= first_i ^ second_i;
                3'b010: res_internal <= first_unsigned + second_unsigned;
                3'b011: res_internal <= first_signed >>> second_unsigned;
                3'b100: res_internal <= first_i | second_i;
                3'b101: res_internal <= first_i << second_i;
                3'b110: res_internal <= ~first_i;
                3'b111: res_internal <= first_i < second_i;
            endcase
        end
    end

    assign result_o = res_internal;
endmodule