/*!SECTION
fp32 - 1, 8 (bias = 127), 23
fp16 - 1, 5 (bias = 15 ), 10
127 - 15 = 112

+-inf
+-0
qnan
subnormal
normal

fp32 -> fp16
normal -> subnormal
normal -> max

fp16 -> fp32
subnormal -> normal


(exp + mant)

fp32
inf {8'hF, 23'b0}
qnan {8'hF, 1'b1, 22'b0}

fp16
inf {5'b11111, 10'b0}
qnan {5'b11111, 1'b1, 9'b0}
*/


module fp_32_16_converter (
    input               clk_i       ,
    input               rst_i       ,
    input               is_fp32_i   ,
    input   [32-1:0]    a_i         ,
    output  [32-1:0]    result_o
);
    reg [32-1:0] res_internal;

    wire            from_32_sign;
    wire [8-1:0]    from_32_exp;
    wire [23-1:0]   from_32_mant;

    wire            from_16_sign;
    wire [5-1:0]    from_16_exp;
    wire [10-1:0]   from_16_mant;

    wire            to_32_sign;
    reg  [8-1:0]    to_32_exp;
    reg  [23-1:0]   to_32_mant;

    wire            to_16_sign;
    reg  [5-1:0]    to_16_exp;
    reg  [10-1:0]   to_16_mant;

    assign from_32_sign = a_i[31];
    assign from_32_exp  = a_i[30:23];
    assign from_32_mant = a_i[22:0];

    assign from_16_sign = a_i[15];
    assign from_16_exp  = a_i[14:10];
    assign from_16_mant = a_i[9:0];

    //sign
    assign to_32_sign = from_16_sign;
    assign to_16_sign = from_32_sign;

    //fp16->fp32

    reg [3:0] shift_for_denormal_16;

    always @(*) begin
        to_32_exp = 8'bx;
        to_32_mant = 23'bx;
        shift_for_denormal_16 = 4'bx;

        if (from_16_exp == 5'b11111 && from_16_mant == 10'b0) begin //inf
            to_32_exp = 8'hFF;
            to_32_mant = 23'b0;
        end
        else if (from_16_exp == 5'b11111 && from_16_mant[9] == 1'b1) begin //qnan
            to_32_exp = 8'hFF;
            to_32_mant = {1'b1, 22'b0};
        end
        else if (from_16_exp == 5'b0 && from_16_mant == 10'b0) begin //zero
            to_32_exp = 8'h00;
            to_32_mant = 23'b0;
        end
        else if (from_16_exp == 5'b0) begin //denormal
            casez (from_16_mant)
                10'b1????????? : shift_for_denormal_16 = 4'd1;
                10'b01???????? : shift_for_denormal_16 = 4'd2;
                10'b001??????? : shift_for_denormal_16 = 4'd3;
                10'b0001?????? : shift_for_denormal_16 = 4'd4;
                10'b00001????? : shift_for_denormal_16 = 4'd5;
                10'b000001???? : shift_for_denormal_16 = 4'd6;
                10'b0000001??? : shift_for_denormal_16 = 4'd7;
                10'b00000001?? : shift_for_denormal_16 = 4'd8;
                10'b000000001? : shift_for_denormal_16 = 4'd9;
                10'b0000000001 : shift_for_denormal_16 = 4'd10;
            endcase

            to_32_exp  = 8'd113 - {4'b0, shift_for_denormal_16}; // 113 = 1 - 15 + 127
            to_32_mant = {from_16_mant, 13'b0} << shift_for_denormal_16;
        end
        else begin //normal
            to_32_exp = from_16_exp + 112;
            to_32_mant = {from_16_mant, 13'b0};
        end
    end

    //fp32->fp16
    wire signed [8:0] signed_exp_32;
    wire signed [8:0] shift_val_32;

    assign signed_exp_32 = $signed({1'b0, from_32_exp}) - 9'sd112;
    assign shift_val_32  = 9'sd1 - signed_exp_32;

    reg [23:0] shifted_mant_32;

    always @(*) begin
        to_16_exp = 5'bx;
        to_16_mant = 10'bx;

        if (from_32_exp == 8'hFF && from_32_mant == 23'b0) begin //inf
            to_16_exp = 5'b11111;
            to_16_mant = 10'b0;
        end
        else if (from_32_exp == 8'hFF && from_32_mant[22] == 1'b1) begin //qnan
            to_16_exp = 5'b11111;
            to_16_mant = {1'b1, 9'b0};
        end
        else if (from_32_exp == 8'h00) begin ///denormal or zero
            to_16_exp = 5'b0;
            to_16_mant = 10'b0;
        end
        else begin //normal
            if (signed_exp_32 >= 9'sb0_00011111) begin // 31
                to_16_exp  = 5'b11110; // 30
                to_16_mant = 10'b11_1111_1111;
            end
            else if (signed_exp_32 > 9'sb0) begin 
                to_16_exp  = signed_exp_32[4:0];
                to_16_mant = from_32_mant[22:13];
            end
            else begin
                to_16_exp = 5'b0;
                shifted_mant_32 = {1'b1, from_32_mant} >> shift_val_32;
                to_16_mant = shifted_mant_32[22:13];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            res_internal <= 32'b0;
        end 
        else begin
            res_internal <= is_fp32_i 
                         ? {16'hFFFF, to_16_sign, to_16_exp, to_16_mant} 
                         : {          to_32_sign, to_32_exp, to_32_mant} ;
        end
    end

    assign result_o = res_internal;
endmodule