`timescale 1ns / 1ps
module sim_cpu();
reg clk=0;
reg rst=0;
reg go=0;
wire [31:0] leddata;
CPU CPU_0(
.clk(clk),
.rst(rst),
.LedData(leddata)
);
wire prediction_valid=CPU_0.BPB_0.prediction_valid;
wire PredictJump=CPU_0.PredictJump;
wire PredictErr=CPU_0.PredictErr;
wire actual_branchtaken=CPU_0.actual_branchtaken;
wire Branch=CPU_0.Branch;
wire BEQ_EX=CPU_0.BEQ_EX;
wire EQ=CPU_0.EQ;
wire PredictJump_EX=CPU_0.PredictJump_EX;
wire [31:0] ALU_SRCA=CPU_0.ALU_SRCA;
wire [31:0] ALU_SRCB=CPU_0.ALU_SRCB;
wire MFHI_MEM=CPU_0.MFHI_MEM;
wire MFLO_MEM=CPU_0.MFLO_MEM;
wire [31:0] HI_MEM=CPU_0.Hi_MEM;
wire [31:0] Lo_MEM=CPU_0.Lo_MEM;
wire [3:0] ALU_OP=CPU_0.ALU_OP;
wire MULT=CPU_0.MULT;
wire [3:0] ALU_OP_EX=CPU_0.ALU_OP_EX;
wire [31:0] WD=CPU_0.WD;
wire [1:0] R1_Forward_EX=CPU_0.R1_Forward_EX;
wire [1:0] R2_Forward_EX=CPU_0.R2_Forward_EX;
wire [31:0] IR_ID=CPU_0.CS_RD_ID;
wire [31:0]IR_EX=CPU_0.IR_EX;
wire [31:0]IR_MEM=CPU_0.IR_MEM;
wire [31:0]IR_WB=CPU_0.IR_WB;
wire [31:0] pc_out=CPU_0.pc_out;
wire [31:0]PC_EX=CPU_0.PC_EX;
wire [4:0] R1=CPU_0.BubleDel_0.R1;
wire [4:0] R2=CPU_0.BubleDel_0.R2;
wire REGW=CPU_0.REGW;
wire RGEW_EX=CPU_0.REGW_EX;
wire [4:0] WA_EX=CPU_0.WA_EX;
wire stall=CPU_0.stall;
wire R1USED=CPU_0.BubleDel_0.R1_USED;
wire R2USED=CPU_0.BubleDel_0.R2_USED;
wire [31:0] CS_RD=CPU_0.CS_RD;
wire [31:0] pc_in =CPU_0.pc_in;
wire halt=CPU_0.halt;
always #5 clk=~clk;
endmodule
