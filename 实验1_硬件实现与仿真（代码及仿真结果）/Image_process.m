clc;close all;clear 
infilename = 'testpic.bmp';
outfilename1 = 'Y.dat';
outfilename2 = 'U.dat';
outfilename3 = 'V.dat';
RGBimg =imread(infilename);
figure;imshow(RGBimg);
%%实现RGB向YUV格式的转变
YUVimg = rgb2ycbcr(RGBimg);
figure;imshow((YUVimg));
[imgHeight,imgWidth,imgDim] = size(YUVimg);
len = imgHeight*imgWidth*imgDim;
yuvimout = zeros(1,len);
Y = YUVimg(:,:,1);     % Y 矩阵
U = YUVimg(:,:,2);     % U 矩阵
V = YUVimg(:,:,3);     % V 矩阵 
R = RGBimg(:,:,1);     % R 矩阵
G = RGBimg(:,:,2);    % G 矩阵
B = RGBimg(:,:,3);     % B 矩阵 

Yid= fopen(outfilename1,'wb');
fprintf(Yid,'%02x\n',Y);
fclose(Yid);
Uid= fopen(outfilename2,'wb');
fprintf(Uid,'%02x\n',U);
fclose(Uid);
Vid= fopen(outfilename3,'wb');
fprintf(Uid,'%02x\n',V);
fclose(Vid);
