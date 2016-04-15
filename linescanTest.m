clear
close all


Original = imread('test.jpg','jpg'); %read image

Image = imresize(Original,[500,500]); % resize image
grey = rgb2gray(Image); %convert to grayscale
%grey = imread('QR.jpg','jpg'); %read image


mono = binarize(im2double(grey),0.5); % convert to double and binarize with a threshold of 0.5
figure
imshow(mono); % show mono image

hold on
Cor = calculatePatternboxCor(mono)
plot(Cor(1,:),Cor(2,:),'r*');

% for i = 1:330
%     horizontalCor = linescanPatternbox(mono(i,:),1);
%    %plot(horizontalCor,i,'ro');
%    if horizontalCor > 0
%        verticalCor = linescanPatternbox(mono(:,horizontalCor+1).',1);
%        if verticalCor > 0
%         plot(horizontalCor,verticalCor,'w*');
%        end
%    end
% end


