`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 西安交通大学
// Engineer: 曹琪
// 
// Create Date: 2022/04/16 15:52:04
// Design Name: tb_y_enhance
// Module Name: tb_sobel
// Project Name: sobel_y_enhance
// Target Devices: Stratix EP1S25
// Tool Versions: Quartus II 13.0
// Description: 
// 				该代码用于对实现sobel算子对Y数据的增强的代码y_enhance.v进行测试，具体实现步骤为：
//                1.导入Y.dat文件数据到myimage;
//                2.打开存储输出数据的文件；
//                3.在时钟上升沿将数据Y逐个送入电路
//                4.在时钟上升沿将电路计算结果写入image_result寄存器；
//                5.将image_result寄存器写入指定的文件
// Dependencies: 
// 				需要原始数据Y.dat以及其绝对位置
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module tb_sobel();
logic clk;                   
logic rst_n;	 
logic[7:0] THRESHOLD;       //阈值，防止溢出
logic[7:0]data_in;          //位宽为8位的Y数据
logic data_in_en;
wire [7:0] data_out;
wire data_out_en;           

logic [9:0] i,j;
logic [9:0] out_i,out_j;
logic [19:0] write_j;
logic [7:0] myimage[0:639][0:479];       //存储Y.dat中的所有数据
logic [7:0] image_result[0:307199];      //输出的所有数据
logic data_en;
integer out_file;


//导入Y.dat文件数据到myimage
initial begin
    $display("step1: Load Data");
 	$readmemh("C:/Users/Administrator/Desktop/Y.dat",myimage);
    $display("%h",myimage[0][0]);
	$display("%h",myimage[639][479]);
end

//生成时钟
always #15 clk = ~clk;

//打开存储输出数据的文件
initial begin
    clk = 0;
    rst_n = 0;
    data_in_en = 0;
	data_en = 0;
    THRESHOLD = 8'd255;
    #5 rst_n = 1;
	#5 data_en = 1;
    #15 data_in_en = 1;
	out_file = $fopen("C:/Users/Administrator/Desktop/Y_verilog.dat","wb");//获取文件句柄
	//out_file = $fopen("C:/Users/Administrator/Desktop/Y_verilog_fpga.dat","wb");//获取文件句柄  
end

/*---------------------------------------------------\
  ---------- 在时钟上升沿将数据Y逐个送入电路 ----------
\---------------------------------------------------*/
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_in <= 8'd0;
        i <= 0;
        j <= 0;
    end
	else begin
		data_in <= myimage[i][j];
		if(data_en) begin		
			j <= j+1;
			if(j >= 10'd479 && i <= 10'd639) begin
				i <= i+1;
				j <= 8'd0;
			end
			else if(j >= 10'd479 && i > 10'd639) begin
				i <= 8'd0;
				j <= 8'd0;
			end
		end
	end
end

/*---------------------------------------------------\
  --在时钟上升沿将电路计算结果写入image_result寄存器 --
\---------------------------------------------------*/
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_i <= 10'd0;
        out_j <= 10'd0;
    end
    else if(data_out_en) begin
        image_result[out_i][out_j] <= data_out_en;
        if(out_j >= 10'd477 && out_i < 10'd637) begin
            out_i <= out_i+1;
            out_j <= 8'd0;
        end
        else if(out_i >= 10'd477 && out_i >= 10'd637) begin
            out_i <= 8'd0;
            out_j <= 8'd0;
        end        
    end
end

/*---------------------------------------------------\
  -----  将image_result寄存器写入指定的文件  ----------
\---------------------------------------------------*/
always_ff @(posedge clk) begin
		if(!data_out_en) begin
			if(write_j < 20'd305757)begin
				write_j <= 0;
				$display("fff"); 
			end
			else if(write_j == 20'd305757)begin
				$fclose(out_file);
        		$display("done");				
			end
			else begin
				write_j <= 0;
			end
		end
		else if(data_out_en && write_j <= 20'd305757)
			begin
				write_j <= write_j + 1;
				image_result[write_j] = data_out;
				$display("write_j= %d,:%h",write_j,image_result[write_j]); 
				$fwrite(out_file,"%h\n",image_result[write_j]);	
			end

end

//实例化模块
sobel m0(.clk(clk),.rst_n(rst_n),.THRESHOLD(THRESHOLD),.data_in(data_in),.data_in_en(data_in_en),.data_out(data_out),.data_out_en(data_out_en));
endmodule