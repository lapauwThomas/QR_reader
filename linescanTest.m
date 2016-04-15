clear
close all


Original = imread('test.jpg','jpg'); %read image

Image = imresize(Original,[500,500]); % resize image
grey = rgb2gray(Image); %convert to grayscale
mono = binarize(im2double(grey),0.5); % convert to double and binarize with a threshold of 0.5
figure
imshow(mono); % show mono image

hold on
for i = 1:500
   plot(linescanPatternbox(mono(i,:)),i,'ro')
   plot(i,linescanPatternbox(mono(:,i).'),'bo')
end
