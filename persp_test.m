%% 

close all
clear all

Image = imread('QR.jpg','jpg'); %read image

figure
imshow(Image);
Image = imrotate(Image,90);

% Image = rgb2gray(Image); %convert to grayscale
mono = binarize(im2double(Image),0.5); % convert to double and binarize with a threshold of 0.5


figure
imshow(mono); % show mono image
title('Binarized figure');


UL = [47 284];
UR = [48 48];
LL = [284 284];
LR = [253 78];


 IM = transformPerspective(UL,UR,LL, LR,mono);


