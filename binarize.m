function [ imageOut ] = binarize( imageIn, level)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
[x , y] = size(imageIn); %get size from image

imageOut = false(x,y); % generate mono image array

for i=1:1:x
    for j = 1:1:y
        if imageIn(i,j) <= level 
            imageOut(i,j) = 0;
        else
            imageOut(i,j) = 1;
        end
    end
end


end

