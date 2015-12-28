% Example code for the usage of the inpainting script.
clear
close
[A_orig,cmap] = imread('../src/lena.gif');
A = double(A_orig);
% Settings for the denoising
wname =         'db2';  % wavelet name
Nb_levels =     6;      % Number of levels
w_mode =        'per';  % Boundary type
maxit=          10;     % Maximum itterations
redundant=      0;      % 1 for redundant transformation
thres =         10;     % Threshold value
% create mask
mask = rand(size(A));
mask(mask<0.7)=1;
mask(mask~=1)=0;
% Setting up distorted A
A_dist = A.*(1-mask);
% Create cost function and threshold function
cost = @(A_n) 10*log10( norm(A,'fro')^2 / norm(A - A_n,'fro')^2 );
threshold = @(x) x.*max( 0, 1-thres./max(abs(x),1e-10) );
% running the algorithm
[result,snr_result] =inpainting_fun(A_dist,mask,Nb_levels,threshold,cost,wname,'per', maxit,redundant);
% Plotting the result
colormap(cmap);
imwrite(uint8(A_dist),cmap,'plot/lena_broke.png')
imwrite(uint8(result),cmap,'plot/lena_fixed.png')