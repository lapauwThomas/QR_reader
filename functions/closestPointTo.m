function [ vertex , dist ] = closestPointTo( Cor, origin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
vertex = [];
dist = 50000; %large starting disctance
for i = 1:length(Cor(1,:))
   A = Cor(:,i); 
   temp = dist(A,origin); %calc distance of current point
   
   if temp < dist %if the distance is smaller
       vertex = A; %save the vertex as the closest
   end
end
    
end
    


end

