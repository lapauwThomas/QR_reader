clear
close all


Original = imread('test.jpg','jpg'); %read image
imshow(Original); % show original image
title('Original image');

Image = imresize(Original,[500,500]); % resize image
grey = rgb2gray(Image); %convert to grayscale
figure;
imshow(grey); %show image in grayscale
mono = binarize(im2double(grey),0.5); % convert to double and binarize with a threshold of 0.5
figure
imshow(mono); % show mono image

linetest = mono(:,101).';
linescanPatternbox(linetest)
