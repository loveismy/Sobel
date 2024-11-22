`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 西安交通大学
// Engineer: 曹琪
// 
// Create Date: 2022/04/16 15:33:22
// Design Name: y_enhance.sv
// Module Name: sobel
// Project Name: sobel_y_enhance
// Target Devices: Stratix EP1S25
// Tool Versions: Quartus II 13.0
// Description: 
// 				该代码用于实现sobel算子对Y数据的增强，具体实现步骤为：
//                1.sobel_gx:原始图像Y分量与Sobel算子X方向卷积;
//                2.sobel_gy:原始图像Y分量与sobel算子Y方向卷积;
//                3.sobel_g:abs(sobel_gx)+abs(sobel_gy);
//                4.Y_verilog = Y + sobel_g;
//                4.阈值判断，防止溢出;
// Dependencies:  
// 				依赖于子模块matrix_3x3.sv文件以及FIFO.sv。需要实例化matrix_3x3模块，输入对齐的三行数据
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module  sobel(
	 input clk, 
	 input rst_n,
	 
	 input [7:0] THRESHOLD,
	 input [7:0]data_in,              //8 bit 灰度 pixel 
	 input data_in_en,
	 
	 output logic [7:0] data_out,     //输出sobel算子增强及叠加后的数据
	 output logic data_out_en         //输出数据有效信号
);
       


//------------------------------------
// 三行像素缓存
//----------------------------------- 
wire [7:0] line0;
wire [7:0] line1;
wire [7:0] line2;

//-----------------------------------------
//3x3 像素矩阵中的像素点
//-----------------------------------------
logic [7:0] line0_data0;
logic [7:0] line0_data1;
logic [7:0] line0_data2;
logic [7:0] line1_data0;
logic [7:0] line1_data1;
logic [7:0] line1_data2;
logic [7:0] line2_data0;
logic [7:0] line2_data1;
logic [7:0] line2_data2;

//-----------------------------------------
//定义gx和gy的正负项中间变量
//-----------------------------------------
logic [9:0] sum0_gx;
logic [9:0] sum1_gx;
logic [9:0] sum0_gy;
logic [9:0] sum1_gy;

wire [9:0] sobel_g;
wire [9:0] sobel_gx; 
wire [9:0] sobel_gy;


//前三行数据开始同时输出，此时该信号拉高
logic   mat_flag; 
logic    mat_flag_1; 
logic    mat_flag_2; 
logic    mat_flag_3; 
logic    mat_flag_4; 
logic    mat_flag_5; 
logic    mat_flag_6;

/*---------------------------------------------------\
  ---------------  计算过程信号的传递  ---------------
\---------------------------------------------------*/
always_ff @(posedge clk)begin
        mat_flag_1          <=          mat_flag;      
        mat_flag_2          <=          mat_flag_1;      
        mat_flag_3          <=          mat_flag_2;      
        mat_flag_4          <=          mat_flag_3; 
        mat_flag_5          <=          mat_flag_4;      
        mat_flag_6          <=          mat_flag_5;         
end





//---------------------------------------------
// 获取3*3的图像矩阵
//---------------------------------------------
matrix_3x3 matrix_3x3_inst(
    .clk (clk),
    .rst_n(rst_n),
    .din (data_in),
    .valid_in(data_in_en),
    .dout(),
    .dout_r0(line0),
    .dout_r1(line1),
    .dout_r2(line2),
    .mat_flag(mat_flag)
);

/*---------------------------------------------------\
  --------------  得到3x3的Y分量数据  ---------------
\---------------------------------------------------*/
always_ff @(posedge clk or negedge rst_n) begin
 if(!rst_n) begin
	 line0_data0 <= 8'b0;
	 line0_data1 <= 8'b0;
	 line0_data2 <= 8'b0;
	 
	 line1_data0 <= 8'b0;
	 line1_data1 <= 8'b0;
	 line1_data2 <= 8'b0;
	 
	 line2_data0 <= 8'b0;
	 line2_data1 <= 8'b0;
	 line2_data2 <= 8'b0;

 end
 else if(data_in_en) begin            //像素有效信号
	 line0_data0 <= line0;
	 line0_data1 <= line0_data0;
	 line0_data2 <= line0_data1;
	 
	 line1_data0 <= line1;
	 line1_data1 <= line1_data0;
	 line1_data2 <= line1_data1;
	 
	 line2_data0 <= line2;
	 line2_data1 <= line2_data0;
	 line2_data2 <= line2_data1; 
 end
end

/*---------------------------------------------------\
  ----- 利用sobel算子计算X方向卷积gx,Y方向卷积gy ------
\---------------------------------------------------*/
always_ff @(posedge clk or negedge rst_n) begin
 if(!rst_n) begin
 	sum0_gx <= 18'b0;
 	sum1_gx <= 18'b0;
 	sum0_gy <= 18'b0;
 	sum1_gy <= 18'b0;
 end
 else if(data_in_en) begin
 //这里需要注意数据从左到右流进来，所以在3*3的像素矩阵中左右两侧像素是反的
 //sum0计算的是正权重部分，sum1计算的是负权重部分
 	sum0_gx  <= line0_data0 + line1_data0*2 + line2_data0;
 	sum1_gx  <= line0_data2 + line1_data2*2 + line2_data2;
 	
 	sum0_gy  <= line0_data0 + line0_data1*2 + line0_data2;
 	sum1_gy  <= line2_data2 + line2_data1*2 + line2_data0;
 end
 else ;
end

//这里可能得到真实值的相反数，但不影响计算，只要绝对值相同即可
assign sobel_gx = (sum0_gx>=sum1_gx)?(sum0_gx-sum1_gx):(sum1_gx-sum0_gx);
assign sobel_gy = (sum0_gy>=sum1_gy)?(sum0_gy-sum1_gy):(sum1_gy-sum0_gy);
assign sobel_g = sobel_gx + sobel_gy + line1_data1;

/*---------------------------------------------------\
  ------------- 利用阈值判断，防止溢出 ---------------
\---------------------------------------------------*/
always_ff @(posedge clk or negedge rst_n) begin
 if(!rst_n)
 	data_out <= 8'b0;
 else if(data_in_en)
 	data_out <= (sobel_g >= THRESHOLD) ? 8'hff : sobel_g[7:0];
 else ;
end

/*---------------------------------------------------\
  ------------- 判断输出数据是否有效 ---------------
\---------------------------------------------------*/
always_ff @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)
        data_out_en  <= 1'b0;
    else if(mat_flag_3 == 1'b1 && mat_flag_6 == 1'b1) 
        data_out_en  <= 1'b1;
    else
        data_out_en  <= 1'b0;
end
endmodule

