function [ content ] = decoder( image )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here







%% Preprocessing

version = 3;
block_size = 20;
number_of_blocks = 17 + 4*version;
length_transformed_image = number_of_blocks*block_size;
color_non_data = 0.5;

image_gray = image;
 
image_gray = imresize(image,[length_transformed_image length_transformed_image]);

figure('name','thresholded')
imshow(image_gray);

%% Find format marker
row = 9;
column = [1 9];

format_info_row = image_gray(8*block_size+1:9*block_size,1:9*block_size);
format_info_column = image_gray(1:8*block_size,8*block_size+1:9*block_size);

for k = 1:8
    format_info_column_reordered(:,(k-1)*block_size+1:k*block_size) = format_info_column((k-1)*block_size+1:k*block_size,:);
end

format_info = [format_info_row fliplr(format_info_column_reordered)];

%average over columns
for i = 1:size(format_info,2)
    format_info_column_averaged(i) = mean(format_info(:,i));
end

%average per block
for i = 1:17
    format_info_averaged(1,i) = mean(format_info_column_averaged(1,(i-1)*block_size+1:i*block_size));
end

format_info_averaged(7) = [];
format_info_averaged(11) = [];

format_info_averaged = 1-round(format_info_averaged);
mask_pattern = [1 0 1 0 1 0 0 0 0 0 1 0 0 1 0];


unmasked_format_info = xor(format_info_averaged,mask_pattern);
error_correction_level = bi2de(unmasked_format_info(1,1:2),'left-msb');
format_marker = bi2de(unmasked_format_info(1,3:5),'left-msb');


%% Indicate everything that is non data
% give parts that have to be removed another value, then concatenate
% everything to a horizontal vector

image_gray([1:9*block_size],[1:9*block_size]) = color_non_data;
image_gray([1:9*block_size],[number_of_blocks*block_size-8*block_size+1:number_of_blocks*block_size]) = color_non_data;
image_gray([number_of_blocks*block_size-8*block_size+1:number_of_blocks*block_size],[1:9*block_size]) = color_non_data;
image_gray([number_of_blocks*block_size-9*block_size+1:number_of_blocks*block_size-4*block_size],[number_of_blocks*block_size-9*block_size+1:number_of_blocks*block_size-4*block_size]) = color_non_data;

%timing sequences
image_gray(6*block_size+1:7*block_size,:) = color_non_data;
image_gray(:,6*block_size+1:7*block_size) = color_non_data;

figure('name','non-data indicated')
imshow(image_gray);


%% Apply format marker (=masking)

%%000
 for i = 1:number_of_blocks
     for j = 1:number_of_blocks
        switch format_marker
            case 0
                if mod((i-1)+(j-1),2) == 0 %insert switch case here for other format markers
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end
            case 1
                if mod(i-1,2) == 0 %insert switch case here for other format markers
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end            
            case 2
                if mod(j-1,3) == 0 %insert switch case here for other format markers
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end
            case 3
                if mod((i-1)+(j-1),3) == 0 %insert switch case here for other format markers
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end               
            case 4
                if mod( (floor((i-1)/2) + floor((j-1)/3)) , 2 ) == 0 %insert switch case here for other format markers
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end               
            case 5
                if mod((i-1)*(j-1),2)+mod((i-1)*(j-1),3) == 0 %insert switch case here for other format markers
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end               
            case 6
                if mod(mod((i-1)*(j-1),2)+mod((i-1)*(j-1),3),2) == 0 %insert switch case here for other format markers
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end
            otherwise    
                if mod(mod((i-1)*(j-1),3)+mod((i-1)+(j-1),2),2) == 0 %insert switch case here for other format markers
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 0.5;%1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end
         end
     end
 end

%         if mod((i-1)+(j-1),2) == 0 %insert switch case here for other format markers
%            image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
%         end
%     end
% end

%001
% for i = 1:number_of_blocks
%     for j = 1:number_of_blocks
%         if mod(i-1,2) == 0 %insert switch case here for other format markers
%            image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
%         end
%     end
% end

%010
% for i = 1:number_of_blocks
%     for j = 1:number_of_blocks
%         if mod(j-1,3) == 0 %insert switch case here for other format markers
%            image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
%         end
%     end
% end

%011
% for i = 1:number_of_blocks
%     for j = 1:number_of_blocks
%         if mod((i-1)+(j-1),3) == 0 %insert switch case here for other format markers
%            image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
%         end
%     end
% end

%%100
% for i = 1:number_of_blocks
%     for j = 1:number_of_blocks
%         if mod( (floor((i-1)/2) + floor((j-1)/3)) , 2 ) == 0 %insert switch case here for other format markers
%            image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
%         end
%     end
% end

%101
% for i = 1:number_of_blocks
%     for j = 1:number_of_blocks
%         if mod((i-1)*(j-1),2)+mod((i-1)*(j-1),3) == 0 %insert switch case here for other format markers
%            image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
%         end
%     end
% end


%110
% for i = 1:number_of_blocks
%     for j = 1:number_of_blocks
%         if mod(mod((i-1)*(j-1),2)+mod((i-1)*(j-1),3),2) == 0 %insert switch case here for other format markers
%            image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
%         end
%     end
% end

%111
% for i = 1:number_of_blocks
%     for j = 1:number_of_blocks
%         if mod(mod((i-1)*(j-1),3)+mod((i-1)+(j-1),2),2) == 0 %insert switch case here for other format markers
%            image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 0.5;%1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
%         end
%     end
% end

figure('name','masked')
imshow(image_gray);



%% Make decoding easier
%Rotate -90 degrees and mirror
image_gray = fliplr(imrotate(image_gray,90));
%figure('name','rotated and flipped')
%imshow(image_gray);

%reverse row 3 and 4, 7 and 8, ...
for l = 3:4:number_of_blocks
    image_gray((l-1)*block_size+1:(l+1)*block_size,:) = fliplr(image_gray((l-1)*block_size+1:(l+1)*block_size,:));
end
    
figure('name','every two rows flipped')
imshow(image_gray);


%% Eerst averagen

image_gray_column_averaged = zeros(length_transformed_image,number_of_blocks);
image_gray_averaged = zeros(number_of_blocks,number_of_blocks);

%average over columns
for j = 1:length_transformed_image
    for i = 1:number_of_blocks
        image_gray_column_averaged(j,i) = mean(image_gray(j,(i-1)*block_size+1:i*block_size));
    end 
end

%average over rows
for l = 1:number_of_blocks
     for k = 1:number_of_blocks
         image_gray_averaged(k,l) = mean(image_gray_column_averaged((k-1)*block_size+1:k*block_size,l));
     end
end

% update size
block_size = 1; %update size
length_transformed_image = number_of_blocks*block_size;

%thresholding to round 0.99 or 0.1 while still keeping 0.5
for l = 1:length_transformed_image
     for k = 1:length_transformed_image
         if image_gray_averaged(k,l) > 0.5
            image_gray_averaged(k,l) = 1;
         elseif image_gray_averaged(k,l) < 0.5
            image_gray_averaged(k,l) = 0;
         end
     end
end

figure('name','averaged')
imshow(image_gray_averaged,'InitialMagnification','fit');



%%
%for the following operations, the matrix need to be square and row/columns
%should be multiple of 2

if mod(length_transformed_image,2) ~= 0
    image_gray_averaged(length_transformed_image+1,1:length_transformed_image+1) = color_non_data;
    image_gray_averaged(1:length_transformed_image+1,length_transformed_image+1) = color_non_data;
    length_transformed_image = length_transformed_image+1;
end 

%figure('name','extended')
%imshow(image_gray_averaged,'InitialMagnification','fit');

%from n x n -> 2 x (n^2)/2
predata = color_non_data*ones(2,length_transformed_image*length_transformed_image./2); %initialise with color_non_data for safety
for m = 1:length_transformed_image/2
     predata(1:2,(m-1)*length_transformed_image+1:m*length_transformed_image) = image_gray_averaged(2*m-1:2*m,1:length_transformed_image);
end

%figure('name','predata')
%imshow(predata(1:2,1:end),'InitialMagnification','fit');

%from 2 x (n^2)/2 -> 1 x (n^2)
for i = 1:length(predata)
   data(1,2*i-1) = predata(1,i);
   data(1,2*i) = predata(2,i);
end
 
figure('name','data with non-data in it')
imshow(data(1:120),'InitialMagnification','fit');


% remove non-data parts
s = 1; % DO THIS!
while( s <= length(data))
    if data(1,s) == color_non_data
        data(s) = [];
        s = s-1;
    end
    s = s+1;
end

figure('name','data')
imshow(data(41:100),'InitialMagnification','fit');

data = 1 - data;

%% Decode data

mode_indicator = bi2de(data(1:4),'left-msb')

if mode_indicator == 4
    bits_per_character = 8;
    pointer = 8;
    character_count_indicator = bi2de(data(4+1:4+pointer),'left-msb')  
else
    disp('NOT YET IMPLEMENTED: other mode detected!')
end


binary_message = data(4+pointer+1:end);

for z = 1:character_count_indicator
    decimal(z) = bi2de(binary_message(1,(z-1)*bits_per_character+1:z*bits_per_character),'left-msb');
end

message = char(decimal)


%%
% test = 4;
% for i = 1:length(data)/4 
%     data_hex(i) = dec2hex(bi2de(data(1,(i-1)*test+1:i*test),'left-msb'));
% end


% for i = 1:4:length(data_hex)-1
%     data_hex_reduced(i) = data_hex(1,i); 
%     data_hex_reduced(i+1) = data_hex(1,i+1); 
% end



















end

