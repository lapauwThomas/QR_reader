Image = imread('cameraman.tif','tif');
subplot(2,2,1)
imshow(Image);
title('Original Image');
imDouble = im2double(Image);
J = imnoise(imDouble,'salt & pepper', 0.1);

subplot(2,2,2)
imshow(J);
title('Noisy Image');

K = medianfilter(J);
subplot(2,2,3)
imshow(K);
title('Median filtered Image');