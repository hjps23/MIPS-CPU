`timescale 1ns / 1ps
module MEMWB(
    input clk,
    input rst,
    input en,
    input MEM2REG_MEM,REGW_MEM,JAL_MEM,LH_MEM,
    input [31:0] ALU_res_MEM,
    input [31:0] DS_RD,
    input [4:0] wa_MEM,
    input [31:0] pc_MEM,
    input [31:0] IR_MEM,
    input [31:0] Lo_MEM,Hi_MEM,
    input MFLO_MEM,MFHI_MEM,
    output reg MEM2REG_WB,REGW_WB,JAL_WB,LH_WB,
    output reg [31:0] ALU_res_WB,
    output reg [31:0] DS_RD_WB,
    output reg [4:0] wa_WB,
    output reg [31:0] pc_WB,
    output reg [31:0] IR_WB,
    output reg [31:0] Lo_WB,Hi_WB,
    output reg MFLO_WB,MFHI_WB
    );
    initial begin
        {MEM2REG_WB,REGW_WB,JAL_WB,LH_WB,MFLO_WB,MFHI_WB}<=6'd0;
            ALU_res_WB<=32'd0;
            DS_RD_WB<=32'd0;
            wa_WB<=5'd0;
            pc_WB<=32'd0;
            IR_WB<=32'd0;
            Lo_WB<=32'd0;
            Hi_WB<=32'd0;
         end
    always@(posedge clk,posedge rst)begin
        if(rst) begin
            {MEM2REG_WB,REGW_WB,JAL_WB,LH_WB,MFLO_WB,MFHI_WB}<=6'd0;
            ALU_res_WB<=32'd0;
            DS_RD_WB<=32'd0;
            wa_WB<=5'd0;
            pc_WB<=32'd0;
            IR_WB<=32'd0;
            Lo_WB<=32'd0;
            Hi_WB<=32'd0;
         end
         else begin
         if(en)begin
            {MEM2REG_WB,REGW_WB,JAL_WB,LH_WB,MFLO_WB,MFHI_WB}<={MEM2REG_MEM,REGW_MEM,JAL_MEM,LH_MEM,MFLO_MEM,MFHI_MEM};
            ALU_res_WB<=ALU_res_MEM;
            DS_RD_WB<=DS_RD;
            wa_WB<=wa_MEM;
            pc_WB<=pc_MEM;
            IR_WB<=IR_MEM;
            Lo_WB<=Lo_MEM;
            Hi_WB<=Hi_MEM;
            end
         end 
     end 
endmodule
