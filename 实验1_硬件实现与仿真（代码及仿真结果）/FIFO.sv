`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 西安交通大学
// Engineer: 曹琪
// 
// Create Date: 2022/04/15 20:51:46
// Design Name: 
// Module Name: FIFO
// Project Name: sobel_y_enhance
// Target Devices: Stratix EP1S25
// Tool Versions: Quartus II 13.0
// Description: 
//              本代码主要用于生成一个数据位宽以及深度可配置的FIFO，并将其作为子模块用于后续的matrix_3x3代码
//              在工程中，将数据位宽设为8位，将数据深度设为480，完成对一列数据的读取，当读取过程将FIFO读满时，打开
//           写使能，开始边读边写。
// Dependencies: 无
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//              该模块的位宽、深度均可配置
//////////////////////////////////////////////////////////////////////////////////
module FIFO
#(  parameter DATA_WIDTH = 8,
  parameter DATA_DEPTH = 480 ,
  parameter PTR_WIDTH  = 9 
)
(input clk_i,
input rst_n_i,
  
//写端口
input wr_en_i  ,
input [DATA_WIDTH-1:0] wr_data_i,
  
//读端口
output logic rd_en_o  ,
output logic [DATA_WIDTH-1:0] rd_data_o,

//空、满信号输出
output logic full_o,
output logic empty_o  
);

logic [DATA_WIDTH-1:0] regs_array [0:DATA_DEPTH-1];
logic [PTR_WIDTH-1 :0] wr_ptr;
logic [PTR_WIDTH-1 :0] rd_ptr;
logic [PTR_WIDTH   :0] elem_cnt;
logic [PTR_WIDTH   :0] elem_cnt_nxt;

//空、满信号
wire full_comb ;
wire empty_comb ;

/*---------------------------------------------------\
  ---------------   读指针地址的计算   ----------------
\---------------------------------------------------*/
always_ff @ (posedge clk_i or negedge rst_n_i) begin
  if (!rst_n_i) begin
    wr_ptr <= 9'b0;
  end
    else if (wr_en_i && wr_ptr == 9'd479) begin
      wr_ptr <= 9'd0;
  end
  else if (wr_en_i) begin
    wr_ptr <= wr_ptr + 9'b1;
  end
end

/*---------------------------------------------------\
  --------------  写指针地址的计算  ------------------
\---------------------------------------------------*/
always_ff @ (posedge clk_i or negedge rst_n_i) begin
  if (!rst_n_i) begin
    rd_ptr <= 9'b0;
  end
  else if(rd_en_o && rd_ptr == 9'd479) begin
    rd_ptr <= 9'd0;
  end
  else if (rd_en_o) begin
    rd_ptr <= rd_ptr + 9'b1;
  end
end

/*---------------------------------------------------\
  -------------- FIFO内数据个数的计数 ----------------
\---------------------------------------------------*/
always_ff @ (posedge clk_i or negedge rst_n_i) begin
  if (!rst_n_i) begin
    elem_cnt <= 10'b0;
  end
  else if (wr_en_i && rd_en_o) begin
    elem_cnt <= elem_cnt;
  end
  else if(wr_en_i && !full_o) begin
    elem_cnt <= elem_cnt + 1'b1;
  end
  else if(rd_en_o && !empty_o) begin
    elem_cnt <= elem_cnt - 1'b1;
  end
end

/*---------------------------------------------------\
  -------------  用于判断空、满信号  -----------------
\---------------------------------------------------*/
always_comb begin
  if(!rst_n_i) begin
    elem_cnt_nxt = 1'b0;
  end
  else if(elem_cnt != 3'd4 && wr_en_i && !full_o && !rd_en_o) begin
    elem_cnt_nxt = elem_cnt + 1'b1; 
  end
  else begin
    elem_cnt_nxt = elem_cnt;
  end
end
assign full_comb  = (elem_cnt_nxt == 9'd479);
assign empty_comb = (elem_cnt_nxt == 10'd0);

/*---------------------------------------------------\
  -------- 用于输出空、满信号与读使能信号 -------------
\---------------------------------------------------*/
always_ff @ (posedge clk_i or negedge rst_n_i) begin
  if (!rst_n_i) begin
    full_o <= 1'b0;
  end
  else begin
    full_o <= full_comb;
    rd_en_o <= full_comb;
  end
end

always_ff @ (posedge clk_i or negedge rst_n_i) begin
  if (!rst_n_i) begin
    empty_o <= 1'b1;
  end
  else begin
    empty_o <= empty_comb;
  end
end
/*---------------------------------------------------\
  -------------------- 读数据模块 -------------------
\---------------------------------------------------*/
always_ff @ (posedge clk_i or negedge rst_n_i) begin
  if (!rst_n_i) begin
    rd_data_o <= 8'b0;
  end
  else if(rd_en_o) begin
        rd_data_o <= regs_array[rd_ptr];
  end
end

/*---------------------------------------------------\
  -------------------  写数据模块  -------------------
\---------------------------------------------------*/
reg [PTR_WIDTH:0] i;
always_ff @ (posedge clk_i or negedge rst_n_i) begin
  if (!rst_n_i) begin
    for(i=0;i<DATA_DEPTH;i=i+1) begin
      regs_array[i] <= 32'b0;
    end
  end
  else if(wr_en_i) begin
    regs_array[wr_ptr] <= wr_data_i;
  end
end
endmodule
