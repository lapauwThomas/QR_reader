function result=medianfilter(image)
sz=size(image); % Get size of image
width=sz(1,2);
height=sz(1,1);
block=zeros(1,9); % variable to save the neighbouring pixels in
blockcounter=1;
%add border
bordered=zeros(height+2,width+2); % generate a matrix to be able to filter until the edge of the image
bordered(2:height+1,2:width+1)=image(1:height,1:width); % copy the image into the bordered image
target=zeros(height,width); 
for i=2:width+1 %for the entire width of the image (goes from the second pixel, to the width + 1)
   for j=2:height+1 %same for the height
      %copy relevant pixels to block
      blockcounter=1; 
       for x=i-1:i+1    %get all the pixels around the current pixels in the x direction
         for y=j-1:j+1 %same in the Y direction
            block(1,blockcounter)=bordered(y,x); %save theb in block
            blockcounter=blockcounter+1; % increase the index in whick to save the value of the next neighbouring pixel
         end
      end
      %calculate median
      target(j-1,i-1)=median(block); %calculate the median value of the pixels around it and save it to the target matrix
   end
end
result=target;