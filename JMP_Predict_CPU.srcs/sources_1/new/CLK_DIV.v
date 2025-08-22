`timescale 1ns / 1ps
module CLK_DIV(
    input clk,           // 100MHz (10nsÖÜÆÚ)
    output reg clk_1ms = 0,
    output reg clk_10ms=0
);
    // 1msÊ±ÖÓ (100MHz -> 1KHz)
    reg [15:0] cnt_1ms = 0;
    always @(posedge clk) begin
        if(cnt_1ms == 16'd49_999) begin
            cnt_1ms <= 0;
            clk_1ms <= ~clk_1ms;
        end else begin
            cnt_1ms <= cnt_1ms + 1;
        end
    end
    //10ms 
    reg [3:0] cnt_10ms_reg = 0;
    always @(posedge clk_1ms) begin
        if(cnt_10ms_reg ==4'd9) begin
            cnt_10ms_reg <= 0;
            clk_10ms <= ~clk_10ms;
        end else begin
            cnt_10ms_reg <= cnt_10ms_reg + 1;
        end
    end
endmodule
