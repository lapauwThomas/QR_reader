close all
clear

%*********************************$
%******   Parameters **********$*
imWidth = 500; %image width to scale
threshold = 0.5; %threshold for binarization

angle = 30; %angle in degrees to rotate image for test

angleMargin = 0.1;


Original = imread('test.jpg','jpg'); %read image

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

distsFromO = sqrt(centers(1,:).^2+centers(2,:).^2); % get distances from the origin
[M,index] = min(distsFromO);

upperLeftIndex = 0;
for i = 1:3 %here we are assumed that only 3 possible indices are left
    presumedUpperLeft = centers(:,i)
    
    indexMod = 1 + mod(i,3);
    A = centers(:,indexMod)-presumedUpperLeft
    indexMod = 1 + mod(i+1,3)
    B = centers(:,indexMod)-presumedUpperLeft
    
    angle = dot(A,B)
    if angle < angleMargin
        upperLeftIndex = i
        break;
    end
end

if upperLeftIndex ==0
    msgID = 'MYFUN:BadIndex';
    msg = 'Unable to find upper left';
    baseException = MException(msgID,msg);
    
    throw(baseException)
end

plot(centers(1,upperLeftIndex),centers(2,upperLeftIndex),'ro')
indexMod = 1 + mod(upperLeftIndex,3);
A = centers(:,indexMod) -centers(:,upperLeftIndex)
plot(A(1),A(2),'bo')
indexMod = 1 + mod(upperLeftIndex+1,3)
B = centers(:,indexMod) - centers(:,upperLeftIndex)
plot(B(1),B(2),'bo')

fourth = centers(:,upperLeftIndex)+ (A+B)
plot(fourth(1),fourth(2),'r*')


%         diagonal = [-1  1];
%
%
%         theta = acosd(dot(diagonal,(A-B).'))
%         fixed = imrotate(mono,theta);
%         figure
%         imshow(fixed)







