%%Opmerkingen
% Momenteel wordt afbeelding manueel "bijgesneden"

%%
clear all; clc; close all;

%%
%*************************************************************************%
%**************************** Part 1 *************************************%
%*************************************************************************%
figure('name','original')
image = imread('perspective2.png','png');
imshow(image);

image_gray = rgb2gray(image);

size_image = size(image_gray);

for i = 1:size_image(1)
    for j = 1:size_image(2)
        if image_gray(i,j) >= 128;
            image_gray(i,j) = 1;
        else
            image_gray(i,j) = 0; 
        end
    end
end


%%
u0 = 1;  
v0 = 1;

u1 = size_image(1);
v1 = (1/4.25)*size_image(2);

u2 = 1;
v2 = size_image(2);

u3 = size_image(1);
v3 = (3.25/4.25)*size_image(2);

x0 = 1;
y0 = 1;

x1 = size_image(1);
y1 = 1;

x2 = 1;
y2 = size_image(2);

x3 = size_image(1);
y3 = size_image(2);

u = [u0 u1 u2 u3].';
v = [v0 v1 v2 v3].';
x = [x0 x1 x2 x3].';
y = [y0 y1 y2 y3].';
a = zeros(8,1);

u_x = [u(1)*x(1) u(2)*x(2) u(3)*x(3) u(4)*x(4)].';
v_x = [v(1)*x(1) v(2)*x(2) v(3)*x(3) v(4)*x(4)].';
u_y = [u(1)*y(1) u(2)*y(2) u(3)*y(3) u(4)*y(4)].';
v_y = [v(1)*y(1) v(2)*y(2) v(3)*y(3) v(4)*y(4)].';

correspondance_matrix = [u v ones(4,1) zeros(4,3) -u_x -v_x; zeros(4,3) u v ones(4,1) -u_y -v_y];

a = inv(correspondance_matrix)*[x;y];

transformation_matrix = [a(1) a(4) a(7); a(2) a(5) a(8); a(3) a(6) 1];

new_coordinates = ones(size_image(1),size_image(2)); %ones to get white missing pixels

primes = zeros(1,3);

for i = 1:size_image(1)
    for j = 1:size_image(2)
        primes = [i j 1]*transformation_matrix;
        x_new = primes(1)./primes(3);
        y_new = primes(2)./primes(3);
        
        x_new = round(x_new);
        y_new = round(y_new);

        if (x_new > 0) & (y_new > 0)      
            new_coordinates(x_new,y_new) = image_gray(i,j);             
        end
    end
end
      
figure('name','transformed perspective')
imshow(new_coordinates);


%% Dilate picture
se = strel('line',3,90);
vertical_dilation = imdilate(1-new_coordinates,se);

se = strel('line',2,0);
horizontal_dilation = imdilate(vertical_dilation,se);

horizontal_plus_vertical_dilation = 1-horizontal_dilation;

figure('name','horizontal & vertical dilation')
imshow(horizontal_plus_vertical_dilation);

%% Manueel bijsnijden
cropped = zeros(330,330);
cropped(:,:) = horizontal_plus_vertical_dilation(10:339,6:335);

% for i = 1:size_image(1)
%     for j = size_image(2):479
%        horizontal_plus_vertical_dilation(i,j) = 1;
%     end
% end
% 
figure('name','horizontal & vertical dilation cropped')
imshow(cropped);

size_cropped = size(cropped);
%% Construct masks
mask = ones(size_cropped(1),size_cropped(2));
mask_size = 60;
mask_offset_x = 1;
mask_offset_y = 1;
line

for i = mask_offset_y:mask_offset_y+mask_size
    for j = mask_offset_x:mask_offset_x+mask_size
        mask(i,j) = 0;
    end
end

figure('name','mask')
imshow(mask);

cropped_masked = ones(size_cropped(1),size_cropped(2));

%And image with mask
for i = 1:size_cropped(1)
    for j = 1:size_cropped(2)
        if (mask(i,j) == 0)
            cropped_masked(i,j) = cropped(i,j);
        else
            cropped_masked(i,j) = 1;
        end
    end
end

figure('name','masked')
imshow(cropped_masked);
