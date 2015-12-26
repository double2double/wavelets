% Loading and destroing a nice picture.

clear all
close all
addpath('../src/AddTextToImage');
addpath('../src/ipsum');
% Image names : 
%       ./src/lena.gif
%       ./src/baboon.gif
% Loading the image.
[A_orig,cmap] = imread('../src/lena.gif');
A = double(A_orig);
colormap(cmap)
image(A_orig);

%% Create some distorsion.

distorsion='text';
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
            text = AddTextToImage(text,ipsum(1+40*(i-1):40*i),[30*(i-1),10]);
            text(text~=1)=0;
            mask = mask.*text;
            i=i+1;
        end
        text(text~=1)=0;
        mask = 1-text;
end 

A_dist = A.*(1-mask);

image(A_dist)

%% Plotting image + distorsion
close all
colormap(cmap)
image(A_dist);

%% Settings for the  wavelets.

dwtmode('per');     % Boundary conditions: sym,per
wname = 'coif4';      % Type of wavelet: bior4.4,haar,db1,db2
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


if redundant
    % SWC = swt2(X,N,'wname')
    % X = iswt2(SWC,'wname')
%     PsiS = @(f) swt2(f,Nb_levels,wname);
%     Psi = @(SWC) iswt2(SWC,wname);
    
    for n=1:maxit
        disp(n);
%         SWC = swt2(B_n,Nb_levels,wname);
%         SWC = threshold(SWC);
%         B_np1 = (1-mask).*A_dist+mask.*iswt2(SWC,wname);
        [A1,H1,V1,D1] = swt2(B_n,Nb_levels,wname);
        A1 = threshold(A1); H1 = threshold(H1); V1 = threshold(V1); D1 = threshold(D1);
        B_np1 = (1-mask).*A_dist+mask.*iswt2(A1,H1,V1,D1,wname);
        B_n=B_np1;
        colormap(cmap)
        image(B_np1);
        pause(0.000001)
    end

else
    
    PsiS = @(f) wavedec2(f,Nb_levels,wname);
    Psi = @(C,S) waverec2(C,S,wname);
    
    for n=1:maxit
        disp(n);
        [C,S] = PsiS(B_n);
        C = threshold(C);
        B_np1 = (1-mask).*A_dist+mask.*Psi(C,S);
        B_n=B_np1;
        colormap(cmap)
        image(B_np1);
        %if n == maxit
            snr = 10*log10( norm(A,'fro')^2 / norm(A - B_n,'fro')^2 );
            title(strcat('SNR = ', num2str(snr)), 'Fontsize', 18);
        %end
        pause(0.000001)
    end
end 
    



%% Outputting the results
imwrite(A_dist,cmap,'lena_broke.gif')
imwrite(B_np1,cmap,'lena_fixed.gif')









