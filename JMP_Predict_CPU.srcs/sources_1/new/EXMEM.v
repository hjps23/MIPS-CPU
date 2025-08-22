`timescale 1ns / 1ps
module EXMEM(
    input clk,
    input rst,
    input en,
    input MEM2REG_EX,REGW_EX,MEMW_EX,JAL_EX,LH_EX,
    input [31:0] ALU_res,
    input [31:0] R2_EX,
    input [4:0] wa_EX,
    input [31:0] pc_EX,
    input [31:0] IR_EX,
    input [31:0] Lo,Hi,
    input MFLO_EX,MFHI_EX,
    output reg MEM2REG_MEM,REGW_MEM,MEMW_MEM,JAL_MEM,LH_MEM,
    output reg [31:0] ALU_res_MEM,
    output reg [31:0] R2_MEM,
    output reg [4:0] wa_MEM,
    output reg [31:0] pc_MEM,
    output reg [31:0] IR_MEM,
    output reg [31:0] Lo_MEM,Hi_MEM,
    output reg MFLO_MEM,MFHI_MEM
    );
    initial begin
        {MEM2REG_MEM,REGW_MEM,MEMW_MEM,JAL_MEM,LH_MEM,MFLO_MEM,MFHI_MEM}<=7'd0;
            ALU_res_MEM<=32'd0;
            R2_MEM<=32'd0;
            wa_MEM<=5'd0;
            pc_MEM<=32'd0;
            IR_MEM<=32'd0;
            Lo_MEM<=32'd0;
            Hi_MEM<=32'd0;
         end
    always@(posedge clk,posedge rst) begin
        if(rst) begin
            {MEM2REG_MEM,REGW_MEM,MEMW_MEM,JAL_MEM,LH_MEM,MFLO_MEM,MFHI_MEM}<=7'd0;
            ALU_res_MEM<=32'd0;
            R2_MEM<=32'd0;
            wa_MEM<=5'd0;
            pc_MEM<=32'd0;
            IR_MEM<=32'd0;
            Lo_MEM<=32'd0;
            Hi_MEM<=32'd0;
         end
         else begin
         if(en) begin
            {MEM2REG_MEM,REGW_MEM,MEMW_MEM,JAL_MEM,LH_MEM,MFLO_MEM,MFHI_MEM}<={MEM2REG_EX,REGW_EX,MEMW_EX,JAL_EX,LH_EX,MFLO_EX,MFHI_EX};
            ALU_res_MEM<=ALU_res;
            R2_MEM<=R2_EX;
            wa_MEM<=wa_EX;
            pc_MEM<=pc_EX;
            IR_MEM<=IR_EX;
            Lo_MEM<=Lo;
            Hi_MEM<=Hi;
            end
          end 
     end 
endmodule    
   
    
