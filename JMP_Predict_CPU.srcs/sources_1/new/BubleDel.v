`timescale 1ns / 1ps
module BubleDel(
    input [5:0] OP,
    input [5:0] FUNC,
    input REGW_EX,REGW_MEM,MEM2REG_EX,LH_EX,
    input [4:0] WA_EX,WA_MEM,R1,R2,
    output stall,
    output [1:0] R1_Forward,R2_Forward
    );
    wire R1_USED,R2_USED;
    wire JR,JAL,BEQ,BNE,BGTZ,SYSCALL,LH;
    wire SLL,SRA,SRL,ADD,ADDU,SUB,AND,OR,NOR,SLT,SLTU,SLLV;
    wire R_TYPE=(OP==6'd0);
    wire J;
    wire ADDI,ANDI,ADDIU,SLTI,ORI,LW,SW,SLTIU;
    wire MULTU,DIVU,MFLO,MFHI,MULT;
    assign SLL=(R_TYPE&&FUNC==6'd0);
    assign SRA=(R_TYPE&&FUNC==6'd3);
    assign SRL=(R_TYPE&&FUNC==6'd2);
    assign ADD=(R_TYPE&&FUNC==6'd32);
    assign ADDU=(R_TYPE&&FUNC==6'd33);
    assign SUB=(R_TYPE&&FUNC==6'd34);
    assign AND=(R_TYPE&&FUNC==6'd36);
    assign OR=(R_TYPE&&FUNC==6'd37);
    assign NOR=(R_TYPE&&FUNC==6'd39);
    assign SLT=(R_TYPE&&FUNC==6'd42);
    assign SLTU=(R_TYPE&&FUNC==6'd43);
    assign SLLV=(R_TYPE&&FUNC==6'd4);
    assign JR=(R_TYPE&&FUNC==6'd8);
    assign SYSCALL=(R_TYPE&&FUNC==6'd12);
    
    assign J=(OP==6'd2);
    assign JAL=(OP==6'd3);
    
    assign BEQ=(OP==6'd4);
    assign BNE=(OP==6'd5);
    assign BGTZ=(OP==6'd7);
    assign ADDI=(OP==6'd8);
    assign ANDI=(OP==6'd12);
    assign ADDIU=(OP==6'd9);
    assign SLTI=(OP==6'd10);
    assign ORI=(OP==6'd13);
    assign LW=(OP==6'd35);
    assign SW=(OP==6'd43);
    assign LH=(OP==6'd33);
    assign SLTIU=(OP==6'd11);
    
    assign MULTU=(R_TYPE&&FUNC==6'd25);
    assign DIVU=(R_TYPE&&FUNC==6'd27);
    assign MFLO=(R_TYPE&&FUNC==6'd18);
    assign MFHI=(R_TYPE&&FUNC==6'd16);
    assign MULT=(R_TYPE&&FUNC==6'd24);
    
    assign R1_USED=ADD||ADDU||SUB||AND||OR||NOR||SLT||SLTU||JR||SYSCALL||BEQ||BNE||ADDI||ANDI||ADDIU||SLTI||ORI||LW||SW||BGTZ||SLTIU||LH||SLLV||MULTU||DIVU||MULT;
    assign R2_USED=SLL||SRA||SRL||ADD||ADDU||SUB||AND||OR||NOR||SLT||SLTU||SYSCALL||BEQ||BNE||SW||SLLV||MULTU||DIVU||MULT;
    assign stall=(R1_USED&&(R1!=5'd0)&&MEM2REG_EX&&(R1==WA_EX))|| 
                 (R2_USED&&(R2!=5'd0)&&MEM2REG_EX&&(R2==WA_EX))||
                 (R1_USED&&(R1!=5'd0)&&LH_EX&&(R1==WA_EX))|| 
                 (R2_USED&&(R2!=5'd0)&&LH_EX&&(R2==WA_EX));
                 
    assign R1_Forward=(R1_USED&&(R1!=5'd0)&&REGW_EX&&(R1==WA_EX))? 2'd2 :
                      (R1_USED&&(R1!=5'd0)&&REGW_MEM&&(R1==WA_MEM)) ? 2'd1 : 2'd0;
    assign R2_Forward=(R2_USED&&(R2!=5'd0)&&REGW_EX&&(R2==WA_EX))? 2'd2 :
                      (R2_USED&&(R2!=5'd0)&&REGW_MEM&&(R2==WA_MEM)) ? 2'd1 : 2'd0;

endmodule
