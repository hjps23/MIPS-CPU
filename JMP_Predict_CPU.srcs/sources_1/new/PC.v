`timescale 1ns / 1ps
module PC(
    input clk,
    input en,
    input rst,
    input [31:0] pc_in,
    output reg [31:0] pc_out
    );
    initial begin pc_out<=32'd0; end
    always@(posedge clk,posedge rst) begin
       if(rst) pc_out<=32'd0;
       else begin if(en) pc_out<=pc_in; end
        end 
endmodule
