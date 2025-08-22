`timescale 1ns / 1ps
module CU(
    input clk,
    input [5:0] OP,
    input [5:0] FUNC,
    output JMP,JR,JAL,SIGNED,BEQ,BNE,BGTZ,MEM2REG,MEMW,ALUSRCB,REGW,REGDST,SYSCALL,LH,
    output [3:0] ALU_OP,
    output MULTU,MULT,DIVU,MFLO,MFHI
    );
    wire SLL,SRA,SRL,ADD,ADDU,SUB,AND,OR,NOR,SLT,SLTU,SLLV;
    wire R_TYPE=(OP==6'd0);
    wire J;
    wire ADDI,ANDI,ADDIU,SLTI,ORI,LW,SW,SLTIU;
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
    
    assign ALU_OP=SLL? 4'd7:
                  SRA? 4'd8:
                  SRL? 4'd9:
                  ADD? 4'd0:
                  ADDU?4'd0:
                  SUB? 4'd1:
                  AND? 4'd2:
                  OR?  4'd3:
                  NOR? 4'd4:
                  SLT? 4'd6:
                  SLTU?4'd5:
                  JR  ?4'd0:
                  SYSCALL? 4'd0:
                  J ?  4'd0:
                  JAL ?4'd0:
                  BEQ ?4'd0:
                  BNE ?4'd0:
                  ADDI?4'd0:
                  ANDI?4'd2:
                  ADDIU?4'd0:
                  SLTI?4'd6:
                  ORI ?4'd3:
                  LW ? 4'd0:
                  SW ? 4'd0:
                  SLLV?4'd10:
                  SLTIU? 4'd5:
                  LH   ? 4'd0:
                  BGTZ ? 4'd0:
                  MULTU? 4'd11:
                  DIVU ? 4'd12:
                  MULT ? 4'd13:
                  MFLO ? 4'd0 : 
                  MFHI ? 4'd0:4'd0;
                  
      assign MEM2REG=LW;
      assign MEMW=SW;
      assign ALUSRCB=(ADDI||ANDI||SLTI||ORI||LW||SW||ADDIU||SLTIU||LH);
      assign REGW=(SLL||SRA||SRL||ADD||ADDU||SUB||AND||OR||NOR||SLT||SLTU||JAL||ADDI||ANDI||SLTI||ORI||LW||ADDIU||SLLV||SLTIU||LH||MFLO||MFHI);
      assign SIGNED=(BEQ||BNE||ADDI||ADDIU||SLTI||LW||SW||SLTIU||LH||BGTZ);
      assign REGDST=(SLL||SRA||SRL||ADD||ADDU||SUB||AND||OR||NOR||SLT||SLTU||SLLV||MFLO||MFHI);
      assign JMP=(J||JAL);
      
      
endmodule
