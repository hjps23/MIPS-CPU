`timescale 1ns / 1ps
module ALU(
    input [31:0] X,Y,
    input [3:0] ALU_OP,
    input [4:0] shamt,
    output EQ,GT,
    output reg [31:0] R,
    output reg [31:0] ALU_Hi,ALU_Lo
);
    assign EQ = (X == Y);
    assign GT = ($signed(X) > 0);
    
    wire [63:0] mult_result;
    wire  sign_X, sign_Y;
    wire  [31:0] temp_X, temp_Y;
    wire [63:0] mult_result_u = X * Y;
    // 处理符号
    assign sign_X = X[31];
    assign sign_Y = Y[31];
                
    // 取绝对值
    assign temp_X = sign_X ? (~X + 1) : X;
    assign temp_Y = sign_Y ? (~Y + 1) : Y;
                
     // 计算无符号乘法
     assign mult_result =(sign_X ^ sign_Y) ?  ~(temp_X * temp_Y)+1 : temp_X * temp_Y;

    always @(*) begin
        // 设置默认值
        R = 32'd0;
        ALU_Hi = 32'd0;
        ALU_Lo = 32'd0;
        case(ALU_OP) 
            4'd0 : R = X + Y;
            4'd1 : R = X - Y;
            4'd2 : R = X & Y;
            4'd3 : R = X | Y;
            4'd4 : R = ~(X | Y);
            4'd5 : R = (X < Y) ? 32'd1 : 32'd0;
            4'd6 : R = ($signed(X) < $signed(Y)) ? 32'd1 : 32'd0;
            4'd7 : R = Y << shamt;
            4'd8 : R = $signed(Y) >>> shamt;
            4'd9 : R = Y >> shamt;
            4'd10: R = Y << X;
            4'd11: begin // multu (无符号乘法)
                ALU_Hi = mult_result_u[63:32];
                ALU_Lo = mult_result_u[31:0];
            end
            4'd12: begin // divu (无符号除法)
                if (Y != 0) begin
                    ALU_Hi = X % Y;
                    ALU_Lo = X / Y;
                end
            end
            4'd13: begin // mult (有符号乘法)
                ALU_Hi = mult_result[63:32];
                ALU_Lo = mult_result[31:0];
            end
            default : begin
                R = 32'd0;
                ALU_Hi = 32'd0;
                ALU_Lo = 32'd0;
            end
        endcase
    end 
endmodule