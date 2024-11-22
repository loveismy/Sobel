clc;close all;clear 
infilename = 'testpic.bmp';
outfilename1 = 'Y.dat';
outfilename2 = 'U.dat';
outfilename3 = 'V.dat';
RGBimg =imread(infilename);
figure;imshow(RGBimg);
%%ʵ��RGB��YUV��ʽ��ת��
YUVimg = rgb2ycbcr(RGBimg);
figure;imshow((YUVimg));
[imgHeight,imgWidth,imgDim] = size(YUVimg);
len = imgHeight*imgWidth*imgDim;
yuvimout = zeros(1,len);
Y = YUVimg(:,:,1);     % Y ����
U = YUVimg(:,:,2);     % U ����
V = YUVimg(:,:,3);     % V ���� 
R = RGBimg(:,:,1);     % R ����
G = RGBimg(:,:,2);    % G ����
B = RGBimg(:,:,3);     % B ���� 

Yid= fopen(outfilename1,'wb');
fprintf(Yid,'%02x\n',Y);
fclose(Yid);
Uid= fopen(outfilename2,'wb');
fprintf(Uid,'%02x\n',U);
fclose(Uid);
Vid= fopen(outfilename3,'wb');
fprintf(Uid,'%02x\n',V);
fclose(Vid);
