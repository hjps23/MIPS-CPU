`timescale 1ns / 1ps
module Hi_reg(
    input clk,
    input rst,
    input en,
    input [31:0] din,
    output [31:0] dout
    );
    reg [31:0] mem[0:1];
    initial begin mem[0]<=32'd0;mem[1]<=32'd0;end
    always@(posedge clk,posedge rst) begin
        if(rst) begin mem[0]<=32'd0;mem[1]<=32'd0;end
        else if(en) mem[0]<=din;
    end
    assign dout=mem[0];
endmodule
