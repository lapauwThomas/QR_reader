close all
clear
addpath ( genpath ( pwd ) );

%*********************************$
%******   Parameters **********$*
imWidth = 500; %image width to scale
threshold = 0.5; %threshold for binarization

angle = 0; %angle in degrees to rotate image for test

angleMargin = 0.1;


% Original = imread('test.jpg','jpg'); %read image
Image = imread('perspective2.png','png'); %read image
%imshow(Original); % show original image
%title('Original image');

%Image = imrotate(Image,angle);
%Image = imresize(Image,[imWidth,NaN]); % resize image
Image = rgb2gray(Image); %convert to grayscale


% figure;
% imshow(grey); %show image in grayscale
%title('Greyscale & scaled image');

mono = binarize(im2double(Image),threshold); % convert to double and binarize with a threshold of 0.5

 figure;
 imshow(mono); %show image in grayscale

% IM = PT_function([1;350;350;1 ],[1;78;332;254],mono);
% IM = Ftrans(mono,[1,1],[350 78],[350,332],[1,254]);
IM = transformPerspective([48 64],[285 64],[94 325], [240 325],mono);

figure
imshow(IM)
title('final transformed');
hold on
M = size(IM,1);
N = size(IM,2);

for k = 1:25:M
    x = [1 N];
    y = [k k];
    plot(x,y,'Color','w','LineStyle','-');
    plot(x,y,'Color','k','LineStyle',':');
end

for k = 1:25:N
    x = [k k];
    y = [1 M];
    plot(x,y,'Color','w','LineStyle','-');
    plot(x,y,'Color','k','LineStyle',':');
end

hold off