% Loading and destroing a nice picture.

clear all
close all
% Image names : 
%       ./src/lena.gif
%       ./src/baboon.gif
%% Loading the image.
[A_orig,cmap] = imread('../src/lena.gif');
A = double(A_orig);
colormap(cmap)
image(A_orig);
mask = zeros(size(A));

%% Create some distorsion.
n = 16;
for i=1:7
    for j=1:7
        mask(64*i-n:64*i,64*j-n:64*j) =1;
    end
end
A_dist = A.*(1-mask);
%% Plotting image + distorsion
close all
colormap(cmap)
image(A_dist);

%% Settings for the  wavelets.

dwtmode('sym');     % Boundary conditions: sym,per
wname = 'db5';      % Type of wavelet: bior4.4,haar,db1,db2
Nb_levels = 20;     % Nb of resolution levels.

%% Creating different treshold functions
SoftThresh  = @(x,T) x.*max( 0, 1-T./max(abs(x),1e-10) );
HardThresh  = @(x,T) x .* (abs(x) >= T);
SmootThresh = @(x,T) -x.*exp(-(x/T).^4)+x;
%% Setting up the transformation
PsiS = @(f)wavedec2(f,Nb_levels,wname);
Psi = @(C,S)waverec2(C,S,wname);
%% Implementatie van inpainting 

close all
threshold = 'hard'; % 'soft' or 'hard' or 'smooth'

delta = 10;         % threshold parameter
maxit = 200;        % Max itterations of algorithm

close all;
B_n=A_dist;
switch threshold
    case 'soft'
        threshold = @(C)SoftThresh(C,delta);
    case 'hard'
        threshold = @(C)HardThresh(C,delta);
    case 'smooth'
        threshold = @(C)SmootThresh(C,delta);
    otherwise
        error('thresholding kind unknown')
end


for n=1:maxit
    disp(n);
    [C,S] = PsiS(B_n);
    C = threshold(C);
    B_np1 = (1-mask).*A_dist+mask.*Psi(C,S);
    B_n=B_np1;
    colormap(cmap)
    image(B_np1);
    pause(0.00001)
end
%% Outputting the results
imwrite(A_dist,cmap,'lena_broke.gif')
imwrite(B_np1,cmap,'lena_fixed.gif')









