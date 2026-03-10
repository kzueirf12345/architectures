// File mux4.v
module mux4 #(
    parameter WIDTH = 8
) (
    input   [WIDTH-1:0] d0_i,
    input   [WIDTH-1:0] d1_i,
    input   [WIDTH-1:0] d2_i,
    input   [WIDTH-1:0] d3_i,
    input   [1:0]       sel_i,
    output  [WIDTH-1:0] res_o
);
    reg [WIDTH-1:0] res_internal;
    
    always @(*) begin
        res_internal = {WIDTH{1'b0}};
        case (sel_i)
            2'b00: res_internal = d0_i;
            2'b01: res_internal = d1_i;
            2'b10: res_internal = d2_i;
            2'b11: res_internal = d3_i;
        endcase
    end

    assign res_o = res_internal;
endmodule