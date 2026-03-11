`timescale 1ns/1ps

module alu_tb();

    integer seed = 228667;
    localparam CLK_TIME = 8;

    localparam WIDTH = 64;
    localparam OPCODE_WIDTH = 3;

    reg                 clk_i       ;
    reg                 rst_i       ;
    reg     [WIDTH-1:0] first_i     ;
    reg     [WIDTH-1:0] second_i    ;
    reg     [2:0]       opcode_i    ;
    wire    [WIDTH-1:0] result_o    ;

    alu #(
        .WIDTH(WIDTH)
    ) alu_inst (
        .clk_i      (clk_i)    ,
        .rst_i      (rst_i)    ,
        .first_i    (first_i)  ,
        .second_i   (second_i) ,
        .opcode_i   (opcode_i) ,
        .result_o   (result_o)
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

        for (integer opcode = 0; opcode < (1 << OPCODE_WIDTH); ++opcode) begin
            @(posedge clk_i); #(CLK_TIME / 4);
            first_i  = $urandom(seed);
            second_i = $urandom(seed);
            opcode_i = opcode;
        end
        #(CLK_TIME * 2);
        $finish;
    end
    
endmodule