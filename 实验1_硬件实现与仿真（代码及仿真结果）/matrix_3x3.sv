`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 西安交通大学
// Engineer: 曹琪
// 
// Create Date: 2022/04/15 22:20:36
// Design Name: matrix_3x3
// Module Name: matrix_3x3
// Project Name: sobel_y_enhance
// Target Devices: Stratix EP1S25
// Tool Versions: Quartus II 13.0
// Description: 
//              该代码用于读取整张图片640x480的Y分量数据，并且利用三个FIFO实现3x3矩阵的输出。由于与sobel算子运算时，我们需要3X3的窗口，那么我们就需要设计3行行缓存。
//          因为正常情况下，大多图像数据都是一行一行的，先从左到右，然后从上到下将每一个像素数据输出。如果不加处理，我们是不能得到3X3的图像窗口的，我们的最终目的是让
//          一帧图像的三行数据对齐之后同时输出，这样我们才能得到3X3的图像窗口！！！
//              为了实现3行行缓存，我们就需要3个fifo。整体的思路就是，第一行数据依次输入进来写入fifo1，当写到第一行最后一个数据时，开始从fifo1依次读出数据然后写入fifo2，
//          依次类推。就这样，当第四行数据到来的时候，此时三个fifo会同时输出数据，而输出的数据正是前三行数据且是对齐的。
//          
// Dependencies: 
//          需要实例化三个位宽为8位、深度为480的FIFO模块，即FIFO.sv
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//               当输入图像行列发生变化时，只需要修改COL_NUM和ROW_NUM即可，且数据位宽也可调。
//////////////////////////////////////////////////////////////////////////////////
module matrix_3x3 (
    clk,
    rst_n,
    valid_in,               //输入数据有效信号
    din,                    //输入的图像数据，将一帧的数据从左到右，然后从上到下依次输入  
    dout_r0,                //第一行的输出数据
    dout_r1,                //第二行的输出数据
    dout_r2,                //第三行的输出数据
    dout,                   //最后一行的输出数据
    mat_flag                //当第四行数据到来，前三行数据才开始同时输出，此时该信号拉高
);
parameter WIDTH = 8;               //数据位宽
parameter COL_NUM     =   480;     //数据有480行
parameter ROW_NUM     =   640;     //数据有640列
parameter LINE_NUM = 3;            //行缓存的行数

input clk;
input rst_n;
input valid_in;
input [WIDTH-1:0] din;

output[WIDTH-1:0] dout;
output[WIDTH-1:0] dout_r0;
output[WIDTH-1:0] dout_r1;
output[WIDTH-1:0] dout_r2;
output mat_flag;

logic [WIDTH-1:0] line[2:0];        //保存每个line_fifo的输入数据
logic valid_in_r  [2:0];
logic valid_out_r [2:0];
logic [WIDTH-1:0] dout_r[2:0];      //保存每个line_fifo的输出数据

assign dout_r0 = dout_r[0];
assign dout_r1 = dout_r[1];
assign dout_r2 = dout_r[2];
assign dout = dout_r[2];

//实例化三个FIFO模块，实现三行数据的同时输出
genvar m;
generate
    begin:HDL1
    for (m = 0;m < LINE_NUM;m = m +1)
        begin : buffer_inst
            // line 1
            if(m == 0) begin: MAPO
                always @(*)begin
                    line[m]<=din;
                    valid_in_r[m]<= valid_in;  //第一个line_fifo的din和valid_in由顶层直接提供
                end
            end
            // line 2 3 ...
            if(~(m == 0)) begin: MAP1
                always @(*) begin
                	//将上一个line_fifo的输出连接到下一个line_fifo的输入
                    line[m] <= dout_r[m-1];
                    //当上一个line_fifo写入480个数据之后拉高rd_en，表示开始读出数据；
                    //valid_out和rd_en同步，valid_out赋值给下一个line_fifo的
                    //valid_in,表示可以开始写入了
                    valid_in_r[m] <= valid_out_r[m-1];
                end
            end
        FIFO line_buffer_inst(
                .rst_n_i (rst_n),
                .clk_i (clk),
                .wr_data_i (line[m]),
                .rd_data_o (dout_r[m]),
                .wr_en_i (valid_in_r[m]),
                .rd_en_o (valid_out_r[m])
                );
        end
    end
endgenerate
reg [10:0] col_cnt;
reg [10:0] row_cnt;

assign mat_flag = row_cnt >= 11'd3 ? valid_in : 1'b0;

/*---------------------------------------------------\
  ---------------   所读行数的计算   ----------------
\---------------------------------------------------*/
always_ff @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        col_cnt <= 11'd0;
    else if(col_cnt == COL_NUM-1 && valid_in == 1'b1)
        col_cnt <= 11'd0;
    else if(valid_in == 1'b1)
        col_cnt <= col_cnt + 1'b1;
    else
        col_cnt <= col_cnt;

/*---------------------------------------------------\
  ---------------   所读列数的计算   ----------------
\---------------------------------------------------*/
always_ff @(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        row_cnt <= 11'd0;
    else if(row_cnt == ROW_NUM-1 && col_cnt == COL_NUM-1 && valid_in == 1'b1)
        row_cnt <= 11'd0;
    else if(col_cnt == COL_NUM-1 && valid_in == 1'b1) 
        row_cnt <= row_cnt + 1'b1;
endmodule