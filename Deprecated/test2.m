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

%mono = binarize(im2double(image_gray),0.5); % convert to double and binarize with a threshold of 0.5


u0 = 47;  
v0 = 62;

u1 = 285;
v1 = 62;

u2 = 93;
v2 = 323;

u3 = 246;
v3 = 323;


IM = Ftrans(mono,[u0 v0],[u1 v1],[u2 v2],[u3 v3]);