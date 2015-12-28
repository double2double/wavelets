% Loading and destroing a nice picture.

clear 
close all
addpath('../src/AddTextToImage');
addpath('../src/ipsum');
% Image names : 
%       ./src/lena.gif
%       ./src/baboon.gif
%       ./src/peppers.gif
% Loading the image.
[A_orig,cmap] = imread('../src/lena.gif');
A = double(A_orig);
colormap(cmap)
image(A_orig);

%% Create some distorsion.
distorsion='random';
mask = zeros(size(A));
switch distorsion
    case 'random'
        p = 0.7;
        mask = rand(size(A));
        mask(mask<p)=1;
        mask(mask~=1)=0;
    case 'block'
        n = 16;
        for i=1:7
            for j=1:7
                mask(64*i-n:64*i,64*j-n:64*j) =1;
            end
        end
    case 'text'
        text = ones(size(A));
        ipsum = matlab_ipsum;
        mask = ones(size(A));
        [h,w] =size(A);
        i=1;
        while (30*i<h)
            disp(i)
            text = AddTextToImage(text,ipsum(1+40*(i-1):40*i),[30*(i-1),10]);
            text(text~=1)=0;
            mask = mask.*text;
            i=i+1;
        end
        text(text~=1)=0;
        mask = 1-text;
    case 'grid'
        mask = zeros(size(A));
        mask(1:10:end,:)=1; mask(:,1:10:end)=1;
end 
A_dist = A.*(1-mask);
image(A_dist)
%% Plotting image + distorsion
close all
colormap(cmap)
image(A_dist);
imwrite(uint8(A_dist),'plot/dist.png');

%% Settings for the  wavelets.

dwtmode('per');     % Boundary conditions: sym,per
wname = 'db2';      % Type of wavelet: bior4.4,haar,db1,db2
Nb_levels = 10;     % Nb of resolution levels.

% Creating different treshold functions
SoftThresh  = @(x,T) x.*max( 0, 1-T./max(abs(x),1e-10) );
HardThresh  = @(x,T) x .* (abs(x) >= T);
SmootThresh = @(x,T) -x.*exp(-(x/T).^4)+x;

% Implementatie van inpainting 

close all
threshold = 'soft'; % 'soft' or 'hard' or 'smooth'

delta = 10;         % threshold parameter
maxit = 200;        % Max itterations of algorithm

redundant = 0; % 1 = 'yes', 0 = 'no'   redundant or nonredundant WT

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

snr_image = @(A,A_n) 10*log10( norm(A,'fro')^2 / norm(A - A_n,'fro')^2 );
cost = @(A_n) snr_image(A,A_n);

[result,snr_result] =inpainting_fun(A_dist,mask,Nb_levels,threshold,cost,wname,'per', maxit,0);




%%

% Outputting the results
imwrite(uint8(A_dist),cmap,'plot/lena_broke.png')
imwrite(uint8(B_np1),cmap,'plot/lena_fixed.png')









