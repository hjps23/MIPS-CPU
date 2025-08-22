`timescale 1ns / 1ps
module IFID(
    input clk,
    input rst,
    input en,
    input clr,
    input [31:0] CS_RD,
    input [31:0] pc,
    input PredictJump,
    output reg [31:0] instr,
    output reg [31:0] pc_ID,
    output reg PredictJump_ID
    );
    initial begin instr<=32'd0; pc_ID<=32'd0;PredictJump_ID<=1'd0;end
    always@(posedge clk,posedge rst) begin
        if(rst) begin instr<=32'd0; pc_ID<=32'd0; PredictJump_ID<=1'd0;end
        else begin
        if(clr) begin instr<=32'd0; pc_ID<=32'd0; PredictJump_ID<=1'd0;end
        else begin
            if(en) begin instr<=CS_RD; pc_ID<=pc; PredictJump_ID<=PredictJump;end
        end
        end
    end
endmodule
