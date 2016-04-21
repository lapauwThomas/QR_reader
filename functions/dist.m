function [ distance ] = dist( CorA , CorB )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    distance = sqrt((CorA(1)-CorB(1))^2 + (CorA(2)-CorB(2))^2);

end

