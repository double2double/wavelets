% Example script for denoising algorithm. In this sctript the optimal
% denoising parameter will be found by fmincon.
clear
close
% Loading and normalising the image
[A_orig,cmap] = imread('../../matlab/src/lena.gif');
A = double(A_orig);
A_mean = mean(A(:));
A = A-A_mean;
A_var = var(A(:));
A = (A./sqrt(A_var));

% Settings for the denoising
wname =         'db2';  % wavelet name
Nb_levels =     6;      % Number of levels
w_mode =        'per';  % Boundary type
maxit=          10;     % Maximum itterations
redundant=      0;      % 1 for redundant transformation
thres =         1;     % Threshold value
sigma=0.2;

% Generate noisy image
A_n= A +randn(size(A)).*sigma;
% Cost function for images.
snr_image   = @(An) -20*log10( norm(A - An,'fro') / norm(A)); 
% Define the threshold function

SmootThresh = @(x,T) -x.*exp(-(x/T).^4)+x;
% Cost function for threshold parameter
costFun = @(T) -snr_image(den_image(A_n,Nb_levels,wname,@(x) SmootThresh(x,T),w_mode,0));
[a,b] =fminunc(costFun,0.2);

