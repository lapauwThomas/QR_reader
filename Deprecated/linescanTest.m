clear
close all


Original = imread('test.jpg','jpg'); %read image
Original = imrotate(Original,180);
Image = imresize(Original,[500 NaN]); % resize image
grey = rgb2gray(Image); %convert to grayscale

%grey = imread('QR.jpg','jpg'); %read image


mono = binarize(im2double(grey),0.5); % convert to double and binarize with a threshold of 0.5
figure
imshow(mono); % show mono image

hold on
% Cor = calculatePatternboxCor(mono)
% plot(Cor(1,:),Cor(2,:),'r*');
centers = []
clusterMargin = 20;%in pixels

moveUpVal = 100;

for i = 1:length(mono(1,:))
    hCor = 0;
    vCor = 0;
    horizontalCor = linescanPatternbox(mono(i,:),1); %calculates all positions of the pattern box on row i
    
    for k = 1:length(horizontalCor) %for each found position
        if horizontalCor(k) ~=0 %check if not zero
            hCor = (horizontalCor(k));   %
            if i < moveUpVal+1
                verticalCor = linescanPatternbox(mono(:,hCor).', i); %start scanning at the top of the image
            else
                verticalCor = linescanPatternbox(mono(:,hCor).', i-moveUpVal); % return 50 bixels higher to scan block
            end
            if length(verticalCor)>1 & verticalCor(2) ~=0
                vCor = verticalCor(2);
                
                Cor = [hCor vCor];
                [numberOfCor y] = size(centers);
                if numberOfCor==0
                    B = Cor.'
                    centers = [centers B]
                else
                    found = false;
                    for l = 1:y %for each found position
                        if dist(centers(:,l).',Cor) < clusterMargin
                            found =  true;
                            break;
                        end
                    end
                    
                    if found
                        centers(:,l) = round((centers(:,l)+ Cor.')/2);
                    else
                        centers = [centers Cor.'];
                    end
                end
                
            end
            
        end
    end
    
    %    if horizontalCor > 0
    %        verticalCor = linescanPatternbox(mono(:,horizontalCor+1).',1);
    %        if verticalCor > 0
    %         plot(horizontalCor,verticalCor,'w*');
    %        end
    %    end
end


plot(centers(1,:),centers(2,:),'w*');

