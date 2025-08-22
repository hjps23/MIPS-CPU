`timescale 1ns / 1ps
module TOP(
    input clk,
    input rst,
    input go,
    output [3:0] sel_l,sel_r,
    output [7:0] seg_l,seg_r
    );
    wire [31:0] LedData;
    wire clk_1ms,clk_10ms;
    
    //确保只按下一个时钟的go
    reg go_once,if_go;
    always@(posedge clk_10ms)begin
        if(!go) {go_once,if_go}<=2'b00;
        else if(!if_go && go) {go_once,if_go}<=2'b11;
        else {go_once,if_go}<=2'b01;
    end
    
    CLK_DIV CLK_0(
    .clk(clk),
    .clk_1ms(clk_1ms),
    .clk_10ms(clk_10ms)
    );
    
    CPU CPU_U(
    .clk(clk_10ms),
    .go(go_once),
    .rst(rst),
    .LedData(LedData)
    );
    
    DISPLAY DIS(
    .clk_1ms(clk_1ms),
    .din(LedData),
    .sel_l(sel_l),
    .sel_r(sel_r),
    .seg_l(seg_l),
    .seg_r(seg_r)
    );
endmodule
