%% Clear data + add subfolders to path

close all
clear
addpath ( genpath ( pwd ) );

%% Parameters

%*********************************$
%******   Parameters **********$*
imWidth = 500; %image width to scale
threshold = 0.5; %threshold for binarization

imAngle = 0; %angle in degrees to rotate image for test

angleMargin = 10; %in degrees
%% Open Image
% Image = imread('QR_persp.jpg','jpg'); %read image
Original = imread('2.jpg','jpg'); %read image
figure('name','Original image')
 imshow(Original)
title('starting image')
%Image = imread('test.jpg','jpg'); %read image
%Image = imread('perspective2.png','png'); %read image
%imshow(Image); % show original image
%title('Original image');
notDecoded = true;

while notDecoded && (threshold > 0)
    close all
    try
%% Transform image
Image = imrotate(Original,imAngle);
Image = imresize(Image,[imWidth,NaN]); % resize image

%% Binarize the image
grey = rgb2gray(Image); %convert to grayscale

mono = binarize(im2double(grey),threshold); % convert to double and binarize with a threshold of 0.5


figure
imshow(mono); % show mono image
title('Binarized figure');

%% Calculate centers of Patternboxex
centers = calculatePatternboxCor(mono);
hold on


%% Sort centers
%classify location of the alignment patterns by finding the three
%coordinates that have an angle of +- 90° between them.
upperLeftIndex = 0;
possibleCombinations = perms(1:length(centers(1,:))); %all possible permutations of the indices of the centers, based on this all possible combinations of 3 vectors can be tested
indexA = 0;
corA = 0;
indexB = 0;
corB = 0;


if length(centers(1,:))< 3
    error('No 3 points detected');
end


for i = 1:length(possibleCombinations(:,1)) %here we are assumed that only 3 possible indices are left
    upperLeftIndexTest = possibleCombinations(i,1)
    presumedUpperLeft = centers(:,upperLeftIndexTest);
    
    indexA = possibleCombinations(i,2);
    corA = centers(:,indexA)-presumedUpperLeft;
    indexB = possibleCombinations(i,3);
    corB = centers(:,indexB)-presumedUpperLeft;
    
    angle = rad2deg(acos(dot(corA, corB) / (norm(corA) * norm(corB))))
    if angle < (90 + angleMargin) & angle > (90 - angleMargin) %check if angle is within resonable margin from 90 degrees
        upperLeftIndex = upperLeftIndexTest;
        break;
    end
end

if upperLeftIndex == 0
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
indexMod = 1 + mod(upperLeftIndex+1,length(centers(1,:)));
B = centers(:,indexMod);



% detection is now done with a sqare detection pattern, maybe better with
% round patters to compensate for rotation?
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

LR = [ round(ji-size(detectionBox,2)/2),round(ij - size(detectionBox,1)/2 )].'


x = ij;
X = ij-size(detectionBox,1)+1;

y = ji;
Y = ji-size(detectionBox,2)+1;
hold on
plot([UL(1);LR(1)],[UL(2);LR(2)]);


% %% Compensate rotation
% 
% v1 = LR-UL;
% v2 = [1 1]
% 
% angle = rad2deg(acos(dot(v1, v2) / (norm(v1) * norm(v2))))
% compensated = imrotate(mono,-angle);
% figure;
% imshow(compensated)

%% find out which point is which for transformation.
    diagonal = LR-UL;
    angle = rad2deg(acos(dot(diagonal, corB) / (norm(diagonal) * norm(corB))))*sign(sum(cross([diagonal ; 0],[corB;0])))
    LL = [0;0];
    UR = [0;0];
    
    if angle < (45 + angleMargin/2) & angle > (45 - angleMargin/2) %check if angle is within resonable margin from 90 degrees
        LL = centers(:,indexB);
    elseif angle < (-45 + angleMargin/2) & angle > (-45 - angleMargin/2)
      UR = centers(:,indexB);  
    end
    
        diagonal = LR-UL;
    angle = rad2deg(acos(dot(diagonal, corA) / (norm(diagonal) * norm(corA))))*sign(sum(cross([diagonal ; 0],[corA;0])))
    if angle < (45 + angleMargin/2) & angle > (45 - angleMargin/2) %check if angle is within resonable margin from 90 degrees
        LL = centers(:,indexA);
    elseif angle < (-45 + angleMargin/2) & angle > (-45 - angleMargin/2)
      UR= centers(:,indexA);  
    end
    
 
 

%% Correct the perspective of the QR code
hold on
plot(UR(1),UR(2),'y*');
plot(LL(1),LL(2),'g*');
plot(UL(1),UL(2),'w*');
plot(LR(1),LR(2),'r*');
legend('Diagonal vector','Upper Right pattern','Lower left pattern','Upper Left pattern','Lower Right pattern');


% UL
% UR
% LL
% LR
if ((UR(1)|UR(2)) & (LL(1)|LL(2)) & (UL(1)|UL(2)) & (LR(1)|LR(2)))==0
    error('one of the coordinates is [0;0]')
end


IM = transformPerspective(UL,UR,LL, LR,mono);
% figure
% imshow(IM)
% title('Corrected perspective');


%% Decode the QR code

content = decoder(IM)
notDecoded = false

    catch errorMsg
        disp(errorMsg);
        notDecoded = true;
        imAngle = imAngle + 90
        if imAngle >= 360
            imAngle = 0
            threshold = threshold - 0.1
        end
    end
end




