%% Clear data + add subfolders to path

close all
clear
addpath ( genpath ( pwd ) );

%% Parameters

%*********************************$
%******   Parameters **********$*
imWidth = 500; %image width to scale
threshold = 0.5; %threshold for binarization

angle = 0143; %angle in degrees to rotate image for test

angleMargin = 10; %in degrees
%% Open Image
 Image = imread('QR_persp.jpg','jpg'); %read image
%Image = imread('test.jpg','jpg'); %read image
%Image = imread('perspective2.png','png'); %read image
%imshow(Image); % show original image
%title('Original image');

%% Transform image
Image = imrotate(Image,angle);
Image = imresize(Image,[imWidth,NaN]); % resize image

%% Binarize the image
grey = rgb2gray(Image); %convert to grayscale
mono = binarize(im2double(grey),threshold); % convert to double and binarize with a threshold of 0.5

mono = im2double(mono);

figure
imshow(mono); % show mono image
title('Binarized figure');

%% Calculate centers of Patternboxex
centers = calculatePatternboxCor(mono);
hold on
plot(centers(1,:),centers(2,:),'w*');


%% Sort centers
distsFromO = sqrt(centers(1,:).^2+centers(2,:).^2); % get distances from the origin
[M,index] = min(distsFromO);

% if length(centers(1,:)) ~=3
%     msgID = 'MYFUN:BadIndex';
%     msg = 'Not exactly 3 points detected ';
%     baseException = MException(msgID,msg);
%     
%     throw(baseException)
% end



upperLeftIndex = 0;
for i = 1:length(centers(1,:)) %here we are assumed that only 3 possible indices are left
    presumedUpperLeft = centers(:,i)
    
    indexModA = 1 + mod(i,length(centers(1,:))) %calculate  the index of another 
    v1 = centers(:,indexModA)-presumedUpperLeft;
    indexModB = 1 + mod(i+1,length(centers(1,:)))
    v2 = centers(:,indexModB)-presumedUpperLeft;
    
    %angle = dot(A,B) %find upper left conren by calculating dot product
    angle = rad2deg(acos(dot(v1, v2) / (norm(v1) * norm(v2))))
    if angle < (90 + angleMargin) & angle > (90 - angleMargin) %check if angle is within resonable margin from 90 degrees
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

UL = centers(:,upperLeftIndex);

%% Detection of fourth box
indexMod = 1 + mod(upperLeftIndex,length(centers(1,:)));
A = centers(:,indexMod);
moduleWidth = ceil(dist(A,UL)/22); %distance between centers is 22 modules round up


% detection is now done with a sqare detection pattern, maybe better with
% round patters to compensate for rotation
detectionBox = zeros(5*moduleWidth);
whiteOverlay = ones(3*moduleWidth);
centerOverlay = zeros(moduleWidth);
detectionBox(moduleWidth+1:4*moduleWidth,moduleWidth+1:4*moduleWidth) = whiteOverlay;
detectionBox(2*moduleWidth+1:3*moduleWidth,2*moduleWidth+1:3*moduleWidth) = centerOverlay;
% figure
% imshow(detectionBox);

nimg = mono-mean(mean(mono));
nSec = detectionBox-mean(mean(detectionBox));

crr = xcorr2(nimg,nSec);
[ssr,snd] = max(crr(:));
[ij,ji] = ind2sub(size(crr),snd);
plot(ij,ji,'y*')
mono(ij:-1:ij-size(detectionBox,1)+1,ji:-1:ji-size(detectionBox,2)+1) = rot90(detectionBox,2);

LR = [round(ij - size(detectionBox,1)/2 ); round(ji-size(detectionBox,2)/2)]


figure
 imshow(mono);
 title('With overlay xcor')
x = ij;
X = ij-size(detectionBox,1)+1;

y = ji;
Y = ji-size(detectionBox,2)+1;
hold on
    plot([y y Y Y y],[x X X x x],'r')
    plot(LR(2),LR(1),'r*');
    
    
%% Compensate rotation

v1 = LR-UL
v2 = [1 0]

angle = rad2deg(acos(dot(v1, v2) / (norm(v1) * norm(v2))))
compensated = imrotate(mono,-angle);
figure;
imshow(compensated)

%% find out which point is which for transformation.
% 
% plot(centers(1,upperLeftIndex),centers(2,upperLeftIndex),'ro')
% indexMod = 1 + mod(upperLeftIndex,length(centers(1,:)));
% A = centers(:,indexMod) -centers(:,upperLeftIndex)
% plot(centers(1,indexMod),centers(2,indexMod),'bo');
% indexMod = 1 + mod(upperLeftIndex+1,length(centers(1,:)));
% B = centers(:,indexMod) - centers(:,upperLeftIndex)
% 
% plot(centers(1,indexMod),centers(2,indexMod),'bo')
% 
% fourth = centers(:,upperLeftIndex)+ (A+B)
% plot(fourth(1),fourth(2),'r*')

%% Correct the perspective of the QR code

% IM = transformPerspective(centers(:,upperLeftIndex),B,A, fourth,mono);
% figure
% imshow(IM)
% title('Corrected perspective');


%% Decode the QR code








