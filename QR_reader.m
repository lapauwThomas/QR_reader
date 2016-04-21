close all
clear

%*********************************$
%******   Parameters **********$*
imWidth = 500; %image width to scale
threshold = 0.5; %threshold for binarization

angle = 0; %angle in degrees to rotate image for test


Original = imread('QR_persp.jpg','jpg'); %read image

%imshow(Original); % show original image
%title('Original image');

OriginalRot = imrotate(Original,angle);
Image = imresize(OriginalRot,[imWidth,NaN]); % resize image
grey = rgb2gray(Image); %convert to grayscale


% figure;
% imshow(grey); %show image in grayscale
%title('Greyscale & scaled image');

mono = binarize(im2double(grey),threshold); % convert to double and binarize with a threshold of 0.5
figure
imshow(mono); % show mono image
title('Binarized figure');


centers = calculatePatternboxCor(mono);
hold on
plot(centers(1,:),centers(2,:),'w*');






