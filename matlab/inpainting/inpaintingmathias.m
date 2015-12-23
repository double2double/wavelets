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
A_dist = A;
A_dist = A.*(1-mask);
%% Plotting image + distorsion
close all
colormap(cmap)
image(A_dist);
%%

[C,S] = wavedec2(A_dist,2,'haar');
coef = reshape(C,512,512);
image(coef);

%% Settings for the  wavelets.
dwtmode('per'); % sym,per
wname = 'db5'; % bior4.4,haar,db1,db2

t = wtree(A_dist,2,wname);
%plot(t)
%% Creating the treshold function
SoftThresh = @(x,T) x .* max( 0, 1-T./max(abs(x),1e-10) );
HardThresh = @(x,T) x .* (abs(x) >= T);
clf;
T = linspace(-1,1,1000);
%plot( T, SoftThresh(T,.5) );
%plot( T, HardThresh(T,.5) );
axis('equal');
%% Setting up the transformation
PsiS = @(f)wavedec2(f,20,wname);
Psi = @(C,S)waverec2(C,S,wname);

%% Denoising test
%imageplot( clamp(SoftThreshPsi(f0,.1)) );
A_noise = randn(512)*20 +A;
[C,S] = PsiS(A_noise);
C = SoftThresh(C,20);
colormap(cmap);
A_denoise = Psi(C,S);
subplot(1,2,1);
image(A_noise)
subplot(1,2,2);
image(A_denoise)
%% Implementatie van inpainting 
% Minimaliseer: @(y) norm(psi(f)-y) + lambda *
close all;

threshold = 'soft'; % 'soft' or 'hard'
delta = 10; % threshold parameter
maxit = 100;


B_n=A_dist;

for n=1:maxit
    disp(n);
    [C,S] = PsiS(B_n);
    switch threshold
        case 'soft'
            C = SoftThresh(C,delta);
        case 'hard'
            C = HardThresh(C,delta);
        otherwise
            error('thresholding kind unknown')
    end
    B_np1 = (1-mask).*A_dist+mask.*Psi(C,S);
    B_n=B_np1;
    colormap(cmap)
    image(B_np1);
    pause(0.00001)
end
%%
imwrite(A_dist,cmap,'lena_broke.gif')
imwrite(B_np1,cmap,'lena_fixed.gif')













