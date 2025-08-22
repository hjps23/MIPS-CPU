`timescale 1ns / 1ps
module RegFile(
    input clk,
    input WE,
    input [4:0] R1,R2,WA,
    input [31:0] WD,
    output [31:0] RD1,RD2
    );
    integer i;
    reg [31:0] MEM[0:31];
    assign RD1=MEM[R1];
    assign RD2=MEM[R2];
    initial begin for(i=0;i<32;i=i+1) MEM[i]<=32'd0; end
    always@(negedge clk)begin
        if(WE) begin
            if(WA==5'd0) MEM[WA]<=32'd0;
            else MEM[WA]<=WD;
        end
     end 
endmodule
