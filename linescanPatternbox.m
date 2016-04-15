function [ indexOfCenterbox boxSize] = linescanPatternbox(line,startingIndex)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    patternboxRatios = [1 1 3 1 1];
    detectedPixels = zeros(1,5);
    
    errorMargin = 0.5; %allowed deviation from ratio; 0.5 is standard
    
    centerboxIndex = 0;
    x = startingIndex; 
    
    lineLength = length(line);
    currentState = 'reset';
    

    while x < lineLength
        switch currentState
            
            case 'reset' %reset case
                
                if ~line(x) %if the current pixel is black, possibly the black bar is detected
                    detectedPixels = zeros(1,5); %reset the pixel counting vector
                    state = 'firstBlack'; %advance state to first black bar
                    detectedPixels(1) = 1; %count 1 pixel for the black bar
                else
                    state = 'reset';                 
                end
            case 'firstBlack'
                 if ~line(x) %if the current pixel is black, possibly the black bar is detected
                    state = 'firstBlack'; %advance state to first black bar
                    detectedPixels(1) = detectedPixels(1) + 1; %count 1 pixel for the black bar
                 else
                     state = 'firstWhite';
                     detectedPixels(2) = 1;
                 end
            case 'firstWhite'
                 if line(x) %if the current pixel is black, possibly the black bar is detected
                    state = 'firstWhite'; %advance state to first black bar
                    detectedPixels(2) = detectedPixels(2) + 1; %count 1 pixel for the black bar
                 else
                     state = 'centerBox';
                     detectedPixels(3) = 1;
                     centerboxIndex = x;
                     
                     
                     %check the ratio of the first black and white region
                     ratioFound = detectedPixels(1)/detectedPixels(2);
                     ratioRef =  patternboxRatios(1)/patternboxRatios(2);
                     if ratioFound > (ratioRef + errorMargin) || ratioFound < (ratioRef - errorMargin) %check if the ratio between boxes is OK
                         state = 'reset';
                         x = x-1; % decrease x with one to compensate for the + 1 ath the end of the algorithm
                     end
                 end
                 
            case 'centerBox'
                 if ~line(x)  %if the current pixel is black, possibly the black bar is detected
                    state = 'centerBox'; %advance state to first black bar
                    detectedPixels(3) = detectedPixels(3) + 1; %count 1 pixel for the black bar
                 else
                     state = 'secondWhite';
                     detectedPixels(4) = 1;
                     
                     %check the ratio of the centerbox black and first white region
                     ratioFound = detectedPixels(3)/detectedPixels(2);
                     ratioRef =  patternboxRatios(3)/patternboxRatios(2);
                     if ratioFound > (ratioRef + errorMargin) || ratioFound < (ratioRef - errorMargin) %check if the ratio between boxes is OK
                         state = 'reset';
                         x = centerboxIndex-1; % go back to the presumed centerbox to restart with pattern recongnition,-1 to compensate for the + 1 ath the end of the algorithm
                     end
                 end
                 
             case 'secondWhite'
                 if line(x) %if the current pixel is black, possibly the black bar is detected
                    state = 'secondWhite'; %advance state to first black bar
                    detectedPixels(4) = detectedPixels(4) + 1; %count 1 pixel for the black bar
                 else
                     state = 'lastBlack';
                     detectedPixels(5) = 1;
                     
                     %check the ratio of the first black and white region
                     ratioFound = detectedPixels(3)/detectedPixels(4);
                     ratioRef =  patternboxRatios(3)/patternboxRatios(4);
                     if ratioFound > (ratioRef + errorMargin) || ratioFound < (ratioRef - errorMargin) %check if the ratio between boxes is OK
                         state = 'reset';
                         x = centerboxIndex-1; % go back to the presumed centerbox to restart with pattern recongnition,-1 to compensate for the + 1 ath the end of the algorithm
                     end
                     
                 end   
                 
            case 'lastBlack'
                if ~line(x) %if the current pixel is black, possibly the black bar is detected
                    state = 'lastBlack'; %advance state to first black bar
                    detectedPixels(5) = detectedPixels(1) + 1; %count 1 pixel for the black bar
                 else
                    state = 'patternEnd';
                     detectedPixels(2) = 1;
                                          %check the ratio of the first black and white region
                     ratioFound = detectedPixels(4)/detectedPixels(5);
                     ratioRef =  patternboxRatios(4)/patternboxRatios(5);
                     if ratioFound > (ratioRef + errorMargin) || ratioFound < (ratioRef - errorMargin) %check if the ratio between boxes is OK
                         state = 'reset';
                         x = centerboxIndex -1; % go back to the presumed centerbox to restart with pattern recongnition,-1 to compensate for the + 1 ath the end of the algorithm
                     end
                end
            case 'patternEnd'
                indexOfCenterbox = centerboxIndex;
                boxSize = detectedPixels(3);
                return
        end
        x = x+1;
        currentState = state;
        
    end
    indexOfCenterbox = 0;
    boxSize = 0;
end



