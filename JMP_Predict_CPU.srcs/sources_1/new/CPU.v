`timescale 1ns / 1ps
module CPU(
    input clk,
    input rst,
    input go,
    output reg [31:0] LedData     
    );
    
    //数据通路信号
    wire [31:0] pc_in,pc_out,CS_RD,RD1,RD2,WD,ALU_res,DS_RD,sign_imm,usign_imm,imm;
    wire JMP,JR,JAL,SIGNED,BEQ,BNE,BGTZ,MEM2REG,MEMW,ALUSRCB,REGW,REGDST,SYSCALL,LH,MULTU,MULT,DIVU,MFLO,MFHI;
    wire [3:0] ALU_OP;
    wire EQ,GT;
    wire LedEN,halt;
    
    wire stall;
    wire [1:0] R1_Forward,R2_Forward;
    wire [31:0] PC_ID,CS_RD_ID;
    
    assign sign_imm={{16{CS_RD_ID[15]}},CS_RD_ID[15:0]};
    assign usign_imm={16'd0,CS_RD_ID[15:0]};
    assign imm=SIGNED ? sign_imm:usign_imm;
    
    //ID/EX缓冲池信号
    wire JMP_EX,JR_EX,JAL_EX,BEQ_EX,BNE_EX,BGTZ_EX,MEM2REG_EX,MEMW_EX,ALUSRCB_EX,REGW_EX,LH_EX,SYSCALL_EX,MULTU_EX,MULT_EX,DIVU_EX,MFLO_EX,MFHI_EX;
    wire [3:0] ALU_OP_EX;
    wire [1:0] R1_Forward_EX,R2_Forward_EX;
    wire [31:0] RD1_EX,RD2_EX,PC_EX,PC_JMP_EX,IR_EX,sign_imm_EX,imm_EX;
    wire [4:0] shamt_EX,WA_EX;
    
    //EX/MEM缓冲池信号
    wire MEM2REG_MEM,RGW_MEM,MEMW_MEM,JAL_MEM,LH_MEM,MFLO_MEM,MFHI_MEM;
    wire [31:0] ALU_res_MEM,RD2_MEM,PC_MEM,IR_MEM,Lo_MEM,Hi_MEM;
    wire [4:0] WA_MEM;
    
    //MEM/WB缓冲池信号
    wire MEM2REG_WB,REGW_WB,JAL_WB,LH_WB,MFLO_WB,MFHI_WB;
    wire [31:0] ALU_res_WB,DS_RD_WB,PC_WB,IR_WB,Lo_WB,Hi_WB;
    wire [4:0] WA_WB;



    //PC数据选择
    wire PredictErr;
    wire [31:0] revera,predicta;
    assign revera=actual_branchtaken ? actual_target : (PC_EX+32'd4);
    assign predicta=PredictJump ? target_addr : (pc_out+32'd4);
    assign PredictErr=(PredictJump_EX!=actual_branchtaken);
    assign pc_in= PredictErr ? revera : predicta;
    PC PC_0(
    .clk(clk),
    .en((~halt&&~stall)||go),
    .rst(rst),
    .pc_in(pc_in),
    .pc_out(pc_out)
    );
    
    
    //分支预测数据通路
    wire PredictJump,PredictJump_ID,PredictJump_EX;
    wire [31:0] target_addr;
    wire Branch=(EQ&BEQ_EX)|(~EQ&BNE_EX)|(GT&BGTZ_EX);
    wire Branch_EX=BEQ_EX|BNE_EX|BGTZ_EX|JR_EX|JMP_EX;
    wire actual_branchtaken=(EQ&BEQ_EX)|(~EQ&BNE_EX)|(GT&BGTZ_EX)|JR_EX|JMP_EX;
    wire [31:0] actual_target=JMP_EX? PC_JMP_EX:
           JR_EX ? ALU_SRCA:
           Branch ? (PC_EX+32'd4+(sign_imm_EX<<2)): PC_EX+32'd4;       
    BPB BPB_0(
    .clk(clk),
    .rst(rst),
    .pc_if(pc_out),
    .prediction(PredictJump),
    .target_addr(target_addr),
    .update_en(Branch_EX),
    .pc_ex(PC_EX),
    .actual_taken(actual_branchtaken),
    .actual_target(actual_target)
    );
    
    //指令寄存器(IP核)
    wire [9:0] cs_addr=pc_out[11:2];
    CS_DRAM CS_0(
    .a(cs_addr),
    .spo(CS_RD)
    );
    
    
    IFID IFID_0(
    .clk(clk),
    .rst(rst),
    .en((~halt&&~stall)||go),
    .clr(PredictErr),
    .CS_RD(CS_RD),
    .pc(pc_out),
    .PredictJump(PredictJump),
    .instr(CS_RD_ID),
    .pc_ID(PC_ID),
    .PredictJump_ID(PredictJump_ID)
    );
    
    //数据冲突处理逻辑（重定向）
    BubleDel BubleDel_0(
    .OP(CS_RD_ID[31:26]),
    .FUNC(CS_RD_ID[5:0]),
    .REGW_EX(REGW_EX),
    .REGW_MEM(REGW_MEM),
    .MEM2REG_EX(MEM2REG_EX),
    .LH_EX(LH_EX),
    .WA_EX(WA_EX),
    .WA_MEM(WA_MEM),
    .R1(SYSCALL? 5'd2:CS_RD_ID[25:21]),
    .R2(SYSCALL? 5'd4:CS_RD_ID[20:16]),
    .stall(stall),
    .R1_Forward(R1_Forward),
    .R2_Forward(R2_Forward)
    );
    
    //控制信号生成
    CU CU_0(
    .clk(clk),
    .OP(CS_RD_ID[31:26]),
    .FUNC(CS_RD_ID[5:0]),
    .JMP(JMP),
    .JR(JR),
    .JAL(JAL),
    .SIGNED(SIGNED),
    .BEQ(BEQ),
    .BNE(BNE),
    .BGTZ(BGTZ),
    .MEM2REG(MEM2REG),
    .MEMW(MEMW),
    .ALUSRCB(ALUSRCB),
    .REGW(REGW),
    .REGDST(REGDST),
    .SYSCALL(SYSCALL),
    .LH(LH),
    .ALU_OP(ALU_OP),
    .MULTU(MULTU),
    .MULT(MULT),
    .DIVU(DIVU),
    .MFLO(MFLO),
    .MFHI(MFHI)
    );
    
    
    //写回寄存器数据选择
    wire [4:0] waddr;
    assign waddr=JAL? 5'd31:
                 REGDST ? CS_RD_ID[15:11] : CS_RD_ID[20:16];
    assign WD= JAL_WB? (PC_WB+32'd4):
               MEM2REG_WB ? DS_RD_WB : 
               LH_WB      ? {{16{DS_RD_WB[15]}},DS_RD_WB[15:0]} : 
               MFLO_WB    ? Lo_WB :
               MFHI_WB    ? Hi_WB : ALU_res_WB;
    RegFile REGFILE_0(
    .clk(clk),
    .WE(REGW_WB),
    .R1(SYSCALL? 5'd2:CS_RD_ID[25:21]),
    .R2(SYSCALL? 5'd4:CS_RD_ID[20:16]),
    .WA(WA_WB),
    .WD(WD),
    .RD1(RD1),
    .RD2(RD2)
    );
    
    IDEX IDEX_0(
    .clk(clk),
    .rst(rst),
    .clr(stall || PredictErr),
    .en(~halt||go),
    .JMP(JMP),
    .JR(JR),
    .JAL(JAL),
    .BEQ(BEQ),
    .BNE(BNE),
    .BGTZ(BGTZ),
    .MEM2REG(MEM2REG),
    .MEMW(MEMW),
    .ALUSRCB(ALUSRCB),
    .REGW(REGW),
    .LH(LH),
    .ALU_OP(ALU_OP),
    .MULTU(MULTU),
    .MULT(MULT),
    .DIVU(DIVU),
    .MFLO(MFLO),
    .MFHI(MFHI),
    .R1(RD1),
    .R2(RD2),
    .wa(waddr),
    .shamt(CS_RD_ID[10:6]),
    .imm(imm),
    .sign_imm(sign_imm),
    .pc(PC_ID),
    .pc_jmp({PC_ID[31:28],CS_RD_ID[25:0],2'd0}),
    .IR(CS_RD_ID),
    .R1_Forward(R1_Forward),
    .R2_Forward(R2_Forward),
    .SYSCALL(SYSCALL),
    .PredictJump_ID(PredictJump_ID),
    .JMP_EX(JMP_EX),
    .JR_EX(JR_EX),
    .JAL_EX(JAL_EX),
    .BEQ_EX(BEQ_EX),
    .BNE_EX(BNE_EX),
    .BGTZ_EX(BGTZ_EX),
    .MEM2REG_EX(MEM2REG_EX),
    .MEMW_EX(MEMW_EX),
    .ALUSRCB_EX(ALUSRCB_EX),
    .REGW_EX(REGW_EX),
    .LH_EX(LH_EX),
    .ALU_OP_EX(ALU_OP_EX),
    .MULTU_EX(MULTU_EX),
    .MULT_EX(MULT_EX),
    .DIVU_EX(DIVU_EX),
    .MFLO_EX(MFLO_EX),
    .MFHI_EX(MFHI_EX),
    .R1_EX(RD1_EX),
    .R2_EX(RD2_EX),
    .wa_EX(WA_EX),
    .shamt_EX(shamt_EX),
    .imm_EX(imm_EX),
    .sign_imm_EX(sign_imm_EX),
    .pc_EX(PC_EX),
    .pc_jmp_EX(PC_JMP_EX),
    .IR_EX(IR_EX),
    .R1_Forward_EX(R1_Forward_EX),
    .R2_Forward_EX(R2_Forward_EX),
    .SYSCALL_EX(SYSCALL_EX),
    .PredictJump_EX(PredictJump_EX)
    );
    
    
    //ALU源重定向选择
    wire [31:0] ALU_SRCA,ALU_SRCB;
    wire [31:0] ALU_Return;  
    assign ALU_Return=MFLO_MEM ? Lo_MEM :
                      MFHI_MEM ? Hi_MEM : ALU_res_MEM;
    assign ALU_SRCA=(R1_Forward_EX==2'd2) ? ALU_Return :
                    (R1_Forward_EX==2'd1) ? WD : RD1_EX;
    assign ALU_SRCB=(R2_Forward_EX==2'd2) ? ALU_Return :
                    (R2_Forward_EX==2'd1) ? WD : RD2_EX;          
    ALU ALU_0(
    .X(ALU_SRCA),
    .Y(ALUSRCB_EX ? imm_EX : ALU_SRCB),
    .ALU_OP(ALU_OP_EX),
    .shamt(shamt_EX),
    .EQ(EQ),
    .GT(GT),
    .R(ALU_res),
    .ALU_Hi(ALU_Hi),
    .ALU_Lo(ALU_Lo)
    );
    
    
    //Hi/Lo寄存器
    wire [31:0] Hi,Lo;
    wire [31:0] ALU_Hi,ALU_Lo;
    Hi_reg Hi_reg_0(
    .clk(clk),
    .rst(rst),
    .en(MULTU_EX||DIVU_EX||MULT_EX),
    .din(ALU_Hi),
    .dout(Hi)
    );
    
    Lo_reg Lo_reg_0(
    .clk(clk),
    .rst(rst),
    .en(MULTU_EX||DIVU_EX||MULT_EX),
    .din(ALU_Lo),
    .dout(Lo)
    );
    
    
    EXMEM EXMEM_0(
    .clk(clk),
    .rst(rst),
    .en(~halt||go),
    .MEM2REG_EX(MEM2REG_EX),
    .REGW_EX(REGW_EX),
    .MEMW_EX(MEMW_EX),
    .JAL_EX(JAL_EX),
    .LH_EX(LH_EX),
    .ALU_res(ALU_res),
    .R2_EX(ALU_SRCB),
    .wa_EX(WA_EX),
    .pc_EX(PC_EX),
    .IR_EX(IR_EX),
    .Lo(Lo),
    .Hi(Hi),
    .MFLO_EX(MFLO_EX),
    .MFHI_EX(MFHI_EX),
    .MEM2REG_MEM(MEM2REG_MEM),
    .REGW_MEM(REGW_MEM),
    .MEMW_MEM(MEMW_MEM),
    .JAL_MEM(JAL_MEM),
    .LH_MEM(LH_MEM),
    .ALU_res_MEM(ALU_res_MEM),
    .R2_MEM(RD2_MEM),
    .wa_MEM(WA_MEM),
    .pc_MEM(PC_MEM),
    .IR_MEM(IR_MEM),
    .Lo_MEM(Lo_MEM),
    .Hi_MEM(Hi_MEM),
    .MFLO_MEM(MFLO_MEM),
    .MFHI_MEM(MFHI_MEM)
    );
    
    //数据寄存器（IP核)
    DS_DRAM DS_0(
    .a(ALU_res_MEM[11:2]),
    .d(RD2_MEM),
    .clk(clk),
    .we(MEMW_MEM),
    .spo(DS_RD)
    );
    
    MEMWB MEMWB_0(
    .clk(clk),
    .rst(rst),
    .en(~halt||go),
    .MEM2REG_MEM(MEM2REG_MEM),
    .REGW_MEM(REGW_MEM),
    .JAL_MEM(JAL_MEM),
    .LH_MEM(LH_MEM),
    .ALU_res_MEM(ALU_res_MEM),
    .DS_RD(DS_RD),
    .wa_MEM(WA_MEM),
    .pc_MEM(PC_MEM),
    .IR_MEM(IR_MEM),
    .Lo_MEM(Lo_MEM),
    .Hi_MEM(Hi_MEM),
    .MFLO_MEM(MFLO_MEM),
    .MFHI_MEM(MFHI_MEM),
    .MEM2REG_WB(MEM2REG_WB),
    .REGW_WB(REGW_WB),
    .JAL_WB(JAL_WB),
    .LH_WB(LH_WB),
    .ALU_res_WB(ALU_res_WB),
    .DS_RD_WB(DS_RD_WB),
    .wa_WB(WA_WB),
    .pc_WB(PC_WB),
    .IR_WB(IR_WB),
    .Lo_WB(Lo_WB),
    .Hi_WB(Hi_WB),
    .MFLO_WB(MFLO_WB),
    .MFHI_WB(MFHI_WB)
    );
    
    //结果显示逻辑和停机逻辑
    assign LedEN=((ALU_SRCA==32'd34)&&SYSCALL_EX);
    assign halt=(SYSCALL_EX&&(ALU_SRCA!=32'd34));
    
    always@(posedge clk)begin
        if(LedEN) LedData<=ALU_SRCB;
    end 
    
endmodule
