`timescale 1ns / 1ps
module IDEX(
    input clk,
    input rst,
    input clr,
    input en,
    input JMP,JR,JAL,BEQ,BNE,BGTZ,MEM2REG,MEMW,ALUSRCB,REGW,LH,
    input [3:0] ALU_OP,
    input MULTU,MULT,DIVU,MFLO,MFHI,
    input [31:0] R1,
    input [31:0] R2,
    input [4:0] wa,
    input [4:0] shamt,
    input [31:0] imm,
    input [31:0] sign_imm,
    input [31:0] pc,
    input [31:0] pc_jmp,
    input [31:0] IR,
    input [1:0] R1_Forward,R2_Forward,
    input SYSCALL,
    input PredictJump_ID,
    output reg JMP_EX,JR_EX,JAL_EX,BEQ_EX,BNE_EX,BGTZ_EX,MEM2REG_EX,MEMW_EX,ALUSRCB_EX,REGW_EX,LH_EX,
    output reg [3:0] ALU_OP_EX,
    output reg  MULTU_EX,MULT_EX,DIVU_EX,MFLO_EX,MFHI_EX,
    output reg [31:0] R1_EX,
    output reg [31:0] R2_EX,
    output reg [4:0] wa_EX,
    output reg [4:0] shamt_EX,
    output reg [31:0] imm_EX,
    output reg [31:0] sign_imm_EX,
    output reg [31:0] pc_EX,
    output reg [31:0] pc_jmp_EX,
    output reg [31:0] IR_EX,
    output reg [1:0] R1_Forward_EX,R2_Forward_EX,
    output reg SYSCALL_EX,
    output reg PredictJump_EX
    );
    initial begin
        {JMP_EX,JR_EX,JAL_EX,BEQ_EX,BNE_EX,BGTZ_EX,MEM2REG_EX,MEMW_EX,ALUSRCB_EX,REGW_EX,LH_EX,ALU_OP_EX,SYSCALL_EX,PredictJump_EX,MULTU_EX,DIVU_EX,MFLO_EX,MFHI_EX,MULT_EX}<=22'd0;
            R1_EX<=32'd0;
            R2_EX<=32'd0;
            wa_EX<=5'd0;
            shamt_EX<=5'd0;
            imm_EX<=32'd0;
            sign_imm_EX<=32'd0;
            pc_EX<=32'd0;
            pc_jmp_EX<=32'd0;
            IR_EX<=32'd0;
            R1_Forward_EX<=2'd0;
            R2_Forward_EX<=2'd0;
        end
    always@(posedge clk, posedge rst)begin
        if(rst) begin
            {JMP_EX,JR_EX,JAL_EX,BEQ_EX,BNE_EX,BGTZ_EX,MEM2REG_EX,MEMW_EX,ALUSRCB_EX,REGW_EX,LH_EX,ALU_OP_EX,SYSCALL_EX,PredictJump_EX,MULTU_EX,DIVU_EX,MFLO_EX,MFHI_EX,MULT_EX}<=22'd0;
            R1_EX<=32'd0;
            R2_EX<=32'd0;
            wa_EX<=5'd0;
            shamt_EX<=5'd0;
            imm_EX<=32'd0;
            sign_imm_EX<=32'd0;
            pc_EX<=32'd0;
            pc_jmp_EX<=32'd0;
            IR_EX<=32'd0;
            R1_Forward_EX<=2'd0;
            R2_Forward_EX<=2'd0;
        end
        else begin
            if(clr) begin
                {JMP_EX,JR_EX,BEQ_EX,BNE_EX,BGTZ_EX,JAL_EX,MEM2REG_EX,MEMW_EX,ALUSRCB_EX,REGW_EX,LH_EX,ALU_OP_EX,SYSCALL_EX,PredictJump_EX,MULTU_EX,DIVU_EX,MFLO_EX,MFHI_EX,MULT_EX}<=22'd0;
                R1_EX<=32'd0;
                R2_EX<=32'd0;
                wa_EX<=5'd0;
                shamt_EX<=5'd0;
                imm_EX<=32'd0;
                sign_imm_EX<=32'd0;
                pc_EX<=32'd0;
                pc_jmp_EX<=32'd0;
                IR_EX<=32'd0;
                R1_Forward_EX<=2'd0;
                R2_Forward_EX<=2'd0;
            end
            else begin
            if(en) begin
                {JMP_EX,JR_EX,JAL_EX,BEQ_EX,BNE_EX,BGTZ_EX,MEM2REG_EX,MEMW_EX,ALUSRCB_EX,REGW_EX,LH_EX,ALU_OP_EX,SYSCALL_EX,PredictJump_EX,MULTU_EX,DIVU_EX,MFLO_EX,MFHI_EX,MULT_EX}<={JMP,JR,JAL,BEQ,BNE,BGTZ,MEM2REG,MEMW,ALUSRCB,REGW,LH,ALU_OP,SYSCALL,PredictJump_ID,MULTU,DIVU,MFLO,MFHI,MULT};
                R1_EX<=R1;
                R2_EX<=R2;
                wa_EX<=wa;
                shamt_EX<=shamt;
                imm_EX<=imm;
                sign_imm_EX<=sign_imm;
                pc_EX<=pc;
                pc_jmp_EX<=pc_jmp;
                IR_EX<=IR;
                R1_Forward_EX<=R1_Forward;
                R2_Forward_EX<=R2_Forward;
                end
            end
        end
     end
endmodule
