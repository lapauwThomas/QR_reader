function [ centers ] = calculatePatternboxCor(monoImage)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
centers = []
clusterMargin = 20;%in pixels

moveUpVal = 100;

for i = 1:length(monoImage(1,:))
    hCor = 0;
    vCor = 0;
    horizontalCor = linescanPatternbox(monoImage(i,:),1); %calculates all positions of the pattern box on row i
    
    for k = 1:length(horizontalCor) %for each found position
        if horizontalCor(k) ~=0 %check if not zero
            hCor = (horizontalCor(k));   %
            if i < moveUpVal+1
                verticalCor = linescanPatternbox(monoImage(:,hCor).', i); %start scanning at the top of the image
            else
                verticalCor = linescanPatternbox(monoImage(:,hCor).', i-moveUpVal); % return 50 bixels higher to scan block
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
end


%plot(centers(1,:),centers(2,:),'w*');
end

