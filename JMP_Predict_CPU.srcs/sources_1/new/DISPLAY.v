`timescale 1ns / 1ps
module DISPLAY(
    input  wire    clk_1ms , 
    input  wire  [31:0] din     ,
    output wire [3 : 0] sel_l   ,   // 左组, 通过 l 区分
    output wire [3 : 0] sel_r   ,   // 右组, 通过 r 区分
    output wire [7 : 0] seg_l   ,   // 左组, 通过 l 区分
    output wire [7 : 0] seg_r       // 右组, 通过 r 区分
    );
    reg [3:0] shift = 4'b0001;    // 用于转换工作的数码管
    always @(posedge clk_1ms)begin
         shift <= {shift[2:0], shift[3]}; 
    end
    wire [6:0] x1, x2, x3, x4;  //表示{1-4}数码管所要显示数字对应的输出信号
    wire [6:0] x5, x6, x7, x8;  //表示{5-8}数码管所要显示数字对应的输出信号

    // right group
    seg7 U1(.din(din[3 : 0]), .dout(x1));       // 右起第一个, 最低4位
    seg7 U2(.din(din[7 : 4]), .dout(x2));       
    seg7 U3(.din(din[11: 8]), .dout(x3));
    seg7 U4(.din(din[15:12]), .dout(x4));
    //将din的各四位送入显示译码模块，输出为Xn  
    // left group        
    seg7 U5(.din(din[19:16]), .dout(x5)); 
    seg7 U6(.din(din[23:20]), .dout(x6));
    seg7 U7(.din(din[27:24]), .dout(x7));
    seg7 U8(.din(din[31:28]), .dout(x8));     // 左起第一个, 最高4位

    assign sel_r = shift & 4'b1111;     // 通过按位与操作点亮指定数码管
    assign sel_l = shift & 4'b1111;     // 通过按位与操作点亮指定数码管
    assign seg_r =  (shift == 4'b0001)? x1 :   
                    (shift == 4'b0010)? x2 :
                    (shift == 4'b0100)? x3 :
                    (shift == 4'b1000)? x4 : 0; 
//对于右组数码管，shift为0001表示第一个数码管工作，对应输出信号为X1；shift为0010表示第二个数码管工作，对应输出信号为X2……对于左组同理。
    assign seg_l =  (shift == 4'b0001)? x5 :
                    (shift == 4'b0010)? x6 :
                    (shift == 4'b0100)? x7 :
                    (shift == 4'b1000)? x8 : 0;
endmodule

module seg7(
    input  wire [3 : 0] din ,
    output reg  [6 : 0] dout 
); 
    always @(*) begin
        case(din)
            4'b0000: dout = 7'h3f;
            4'b0001: dout = 7'h06;
            4'b0010: dout = 7'h5b;
            4'b0011: dout = 7'h4f;
            4'b0100: dout = 7'h66;
            4'b0101: dout = 7'h6d;
            4'b0110: dout = 7'h7d;
            4'b0111: dout = 7'h07;
            4'b1000: dout = 7'h7f;
            4'b1001: dout = 7'h6f;
            4'b1010: dout = 7'h77;
            4'b1011: dout = 7'h7c;
            4'b1100: dout = 7'h39;
            4'b1101: dout = 7'h5e;
            4'b1110: dout = 7'h79;
            4'b1111: dout = 7'h71;
        endcase
    end
endmodule