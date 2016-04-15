function [ coordinates ] = calculatePatternboxCor(monoImage)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

[x , y] = size(monoImage)
coordinates = []
a=1;
b=0;

horizontalOffset = 1;
verticalOffset = 1;
edgeHor = 0;
widthHor = 0;
for i=1:y
   [edgeHor, widthHor] = linescanPatternbox(monoImage(i,:),1);
   if edgeHor ~=0 & widthHor ~=0
       horizontalCor = round(edgeHor+widthHor/2);
       [edgeVer, widthVer] = linescanPatternbox(monoImage(:,horizontalCor+1).',verticalOffset);
       if edgeVer ~=0 & widthVer ~=0
        verticalCor = round(edgeVer+widthVer/2);
        verticalOffset = edgeVer+widthVer
        y = verticalOffset;
        coordinates = [coordinates [horizontalCor;verticalCor]];
        horizontalOffset = edgeHor+widthHor
       end
   end
end

        verticalOffset = 1;
for i=1:y
      [edgeHor, widthHor] = linescanPatternbox(monoImage(i,:),horizontalOffset);
   if edgeHor ~=0 & widthHor ~=0
       horizontalCor = round(edgeHor+widthHor/2);
       [edgeVer, widthVer] = linescanPatternbox(monoImage(:,horizontalCor+1).',verticalOffset);
       if edgeVer ~=0 & widthVer ~=0
        verticalCor = round(edgeVer+widthVer/2);
        verticalOffset = edgeVer+widthVer;
        y = verticalOffset;
        coordinates = [coordinates [horizontalCor;verticalCor]];
       end
   end
end
   



%first row
% for i = 1:x
%     [g h] = linescanPatternbox(monoImage(i,:),c+d);
%     if g+h ~=0
%         a = g;
%         b = h;
%     end
%     horizontalCor = round(a+b/2);
%    %plot(horizontalCor,i,'ro');
%    if horizontalCor > 0
%        [g h] = linescanPatternbox(monoImage(:,horizontalCor+1).',1);
%        if g+h ~=0
%         c = g;
%         d = h;
%     end
%        verticalCor = round(c + d/2);
%        if verticalCor > 0
%            coordinates = [coordinates [horizontalCor;verticalCor]]
%         plot(horizontalCor,verticalCor,'w*');
%        end
%    end
% end
% 
% %second row
% xOffset = max(coordinates(2,:));
% for i = 1:x
%     horizontalCor = linescanPatternbox(monoImage(i,:),1);
%    %plot(horizontalCor,i,'ro');
%    if horizontalCor > 0
%        verticalCor = linescanPatternbox(monoImage(:,horizontalCor+1).',xOffset);
%        if verticalCor > 0
%            coordinates = [coordinates [horizontalCor;verticalCor]]
%         plot(horizontalCor,verticalCor,'w*');
%        end
%    end
% end


end

