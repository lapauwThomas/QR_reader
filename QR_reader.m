close all
clear

%*********************************$
%******   Parameters **********$*





Original = imread('QR_persp.jpg','jpg'); %read image
imshow(Original); % show original image
title('Original image');

Image = imresize(Original,[500,NaN]); % resize image
grey = rgb2gray(Image); %convert to grayscale
figure;
imshow(grey); %show image in grayscale
mono = binarize(im2double(grey),0.5); % convert to double and binarize with a threshold of 0.5
figure
imshow(mono); % show mono image

centers = calculatePatternboxCor(mono);
hold on
plot(centers(1,:),centers(2,:),'w*');






