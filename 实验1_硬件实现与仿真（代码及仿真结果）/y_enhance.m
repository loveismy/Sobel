clc;close all;clear 
infilename = 'testpic.bmp';
outfilename1 = 'Y.dat';
outfilename2 = 'U.dat';
outfilename3 = 'V.dat';
outfilename4 = 'Y_new.dat';
RGBimg =imread(infilename);
figure;imshow(RGBimg);
%%实现RGB向YUV格式的转变
YUVimg = rgb2ycbcr(RGBimg);    
figure;imshow((YUVimg));
[imgHeight,imgWidth,imgDim] = size(YUVimg);  
Y = YUVimg(:,:,1);     % Y 矩阵
U = YUVimg(:,:,2);     % U 矩阵
V = YUVimg(:,:,3);     % V 矩阵 
R = RGBimg(:,:,1);     % R 矩阵
G = RGBimg(:,:,2);    % G 矩阵
B = RGBimg(:,:,3);     % B 矩阵 
hy=[1 2 1;0 0 0 ;-1 -2 -1];    %sobel垂直梯度模板
hx=hy';                    %sobel水平梯度模板
Y_double = double(Y);
Sobel_Img = zeros(imgHeight,imgWidth);
Y_new_data = zeros(imgHeight,imgWidth);
%%for循环将sobel算子与对应位置的Y数据相乘，实现水平梯度和垂直梯度的运算
for r = 2:imgHeight-1
     for c = 2:imgWidth-1
         Sobel_x = Y_double(r-1,c+1) + 2*Y_double(r,c+1) + Y_double(r+1,c+1) - Y_double(r-1,c-1) - 2*Y_double(r,c-1) - Y_double(r+1,c-1);
         Sobel_y = Y_double(r-1,c-1) + 2*Y_double(r-1,c) + Y_double(r-1,c+1) - Y_double(r+1,c-1) - 2*Y_double(r+1,c) - Y_double(r+1,c+1);
         Sobel_Num = abs(Sobel_x) + abs(Sobel_y);
         %%Sobel_Num = sqrt(Sobel_x^2 + Sobel_y^2);
         Sobel_Img(r,c) = Sobel_Num;
%           if(Sobel_Num > Sobel_Threshold)
%               Sobel_Img(r,c)=255;
%           else
%               Sobel_Img(r,c)=Sobel_Num;
%           end
     end
end
for r = 1:imgHeight
    for c = 1:imgWidth
         Y_new_data(r,c) = Sobel_Img(r,c)+Y_double(r,c); 
    end
end
%%将最终结果重新转化为uint8类型的数据
Y_new_uint8 = uint8(Y_new_data);
%%Y_new.dat和U.dat和V.dat转为RGB显示
new_YUVimage_matlab = zeros(imgHeight,imgWidth,imgDim);
new_YUVimage_matlab(:,:,1) = Y_new_uint8;
new_YUVimage_matlab(:,:,2) = U;
new_YUVimage_matlab(:,:,3) = V;
new_RGBimg_matlab = ycbcr2rgb(uint8(new_YUVimage_matlab));
figure;imshow(new_RGBimg_matlab);