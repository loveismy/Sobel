clc;close all;clear 
infilename = 'testpic.bmp';
outfilename1 = 'Y.dat';
outfilename2 = 'U.dat';
outfilename3 = 'V.dat';
outfilename4 = 'Y_new.dat';
RGBimg =imread(infilename);
figure;imshow(RGBimg);
%%ʵ��RGB��YUV��ʽ��ת��
YUVimg = rgb2ycbcr(RGBimg);    
figure;imshow((YUVimg));
[imgHeight,imgWidth,imgDim] = size(YUVimg);  
Y = YUVimg(:,:,1);     % Y ����
U = YUVimg(:,:,2);     % U ����
V = YUVimg(:,:,3);     % V ���� 
R = RGBimg(:,:,1);     % R ����
G = RGBimg(:,:,2);    % G ����
B = RGBimg(:,:,3);     % B ���� 
hy=[1 2 1;0 0 0 ;-1 -2 -1];    %sobel��ֱ�ݶ�ģ��
hx=hy';                    %sobelˮƽ�ݶ�ģ��
Y_double = double(Y);
Sobel_Img = zeros(imgHeight,imgWidth);
Y_new_data = zeros(imgHeight,imgWidth);
%%forѭ����sobel�������Ӧλ�õ�Y������ˣ�ʵ��ˮƽ�ݶȺʹ�ֱ�ݶȵ�����
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
%%�����ս������ת��Ϊuint8���͵�����
Y_new_uint8 = uint8(Y_new_data);
%%Y_new.dat��U.dat��V.datתΪRGB��ʾ
new_YUVimage_matlab = zeros(imgHeight,imgWidth,imgDim);
new_YUVimage_matlab(:,:,1) = Y_new_uint8;
new_YUVimage_matlab(:,:,2) = U;
new_YUVimage_matlab(:,:,3) = V;
new_RGBimg_matlab = ycbcr2rgb(uint8(new_YUVimage_matlab));
figure;imshow(new_RGBimg_matlab);