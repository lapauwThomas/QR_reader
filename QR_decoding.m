%% Date: 21-05-2016
%INPUT REQUIREMENTS: input image has to be a monochrome double image (so
%only 0's and 1's, no 0.01 or 245). Hence, in the 'loading image' and
%'thresholding' section are commando's which can be removed in the final
%code

%From ISO standard:
% => QR code begint bij 0!!!
% => A dark module is a binary one and a light module is a binary zero.
% => The most significant bit of each codeword shall be placed in the first available module position.
% => error correction levels are: L (1), M (0), Q (3), H (2)  (p59 ISO)

clear all; close all;

%% Constants

version = 3;
block_size = 20; %one block: block_size x block_size pixels
number_of_blocks = 17 + 4*version;
length_transformed_image = number_of_blocks*block_size;
color_non_data = 0.5; %grey


%% Loading image

% Examples found in the real world
%image = imread('test_set/wikipedia.jpg','jpg'); 
image = imread('test_set/tumblr.jpg','jpg');
%image = imread('test_set/insomnia.jpg','jpg'); %very bad quality picture


% Some self created examples
%image = imread('test_set/alphabet_EC0.jpg','jpg');
%image = imread('test_set/alphabet_EC1.jpg','jpg');
%image = imread('test_set/alphabet_EC3.jpg','jpg');
%image = imread('test_set/alphabetSHORT_EC2.jpg','jpg'); %alphabet tot en met s
%image = imread('test_set/aaaaaaaaaaaaaaayyyyyyyyyyyyyyABC_EC3.jpg','jpg');
%imshow(image);

%image_gray = rgb2gray(image);
image_gray = image;
 
%Resize image to a known size
image_gray = imresize(image_gray,[length_transformed_image length_transformed_image]);

%figure('name','rescaled')
%imshow(image_gray);

size_image = size(image_gray);


%% Thresholding to 0's and 1's => can be removed if done somewhere before in the process
for i = 1:size_image(1)
    for j = 1:size_image(2)
        if image_gray(i,j) >= 128;
            image_gray(i,j) = 255;
        else
            image_gray(i,j) = 0; 
        end
    end
end
image_gray = im2double(image_gray);

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
% give parts that have to be removed another value
% this includes finder patterns, allignment patterns and timing sequences

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

 for i = 1:number_of_blocks
     for j = 1:number_of_blocks
        switch format_marker
            case 0
                if mod((i-1)+(j-1),2) == 0 
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end
            case 1
                if mod(i-1,2) == 0 
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end            
            case 2
                if mod(j-1,3) == 0 
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end
            case 3
                if mod((i-1)+(j-1),3) == 0 
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end               
            case 4
                if mod( (floor((i-1)/2) + floor((j-1)/3)) , 2 ) == 0 
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end               
            case 5
                if mod((i-1)*(j-1),2)+mod((i-1)*(j-1),3) == 0 
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end               
            case 6
                if mod(mod((i-1)*(j-1),2)+mod((i-1)*(j-1),3),2) == 0 
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end
            otherwise    
                if mod(mod((i-1)*(j-1),3)+mod((i-1)+(j-1),2),2) == 0
                    image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size) = 1-image_gray((i-1)*block_size+1:i*block_size,(j-1)*block_size+1:j*block_size);% invert it
                end
         end
     end
 end

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
block_size = 1; %update size => 1 pixel per block now
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

%note: QR code is always square, but rows are not always a multiple of 2
%(e.g. version 3: 29 rows). In that case the QR code is extended with one
%row and one column with color = color_non_data so that it can be removed
%later.

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


%% Undo interleaving if EC equals 2 or 3
if (error_correction_level == 2) | (error_correction_level == 3)
    data_even = [];
    data_odd = [];
    
    for z = 1:2:floor(length(data)/8)-3
        data_even = [data_even data((z-1)*8+1:z*8)];
        data_odd = [data_odd data(z*8+1:(z+1)*8)];
    end
    
    data_reordend = [data_even data_odd data((z+1)*8+1:length(data))];
    
    if (error_correction_level == 3)
        %data_reordend = [data_reordend(1:17*8) data_reordend(36*8+1:end) data_reordend(17*8+1:36*8)];
        data_reordend = [data_reordend(1:17*8) data_reordend(34*8+1:end) data_reordend(17*8+1:34*8)];
    else
        data_reordend = [data_reordend(1:13*8) data_reordend(34*8+1:end) data_reordend(13*8+1:34*8)];
    end 
    
    data = data_reordend;
    clear data_reordend
end


%% Debug section
for z = 1:floor(length(data)./4)
        debug_hex(z) = bi2de(data(1,(z-1)*4+1:z*4),'left-msb');
end

%close all


%% Decode data

mode_indicator = bi2de(data(1:4),'left-msb');

if mode_indicator == 4
    bits_per_character = 8;
    pointer = 8;
    character_count_indicator = bi2de(data(4+1:4+pointer),'left-msb')  
else
    disp('NOT YET IMPLEMENTED: other mode detected!')
    % The mode that is implemented right now is the 8-bit byte mode (p16 of
    % ISO standard). In this mode 1 character is defined by 8 bits in
    % accordance with JIS X 0201. The first 96 codes in JIS are equal to the
    % ASCII charachters (without control charachters), with the exception
    % of \ and ~ replaced by ¥ and overline ? The last 96 codes in JIS
    % consists of Japanese signs.
    % For now the ASCII representation is used. To decode the Japanese signs,
    % a simple lookup table can be used. To decode other modes such as
    % numeric, alphanumeric and Kanji modes, a lookup table can be used as
    % well. 
end

binary_message = data(4+pointer+1:end);

for z = 1:character_count_indicator
    decimal(z) = bi2de(binary_message(1,(z-1)*bits_per_character+1:z*bits_per_character),'left-msb');
end
    
message = char(decimal)
