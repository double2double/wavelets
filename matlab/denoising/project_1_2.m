%% Wavelte image denoising
clear all
close all
% Image names : 
%       ./src/lena.gif
%       ./src/baboon.gif

[A_orig,cmap] = imread('../src/lena.gif');
A = double(A_orig);

% Wavelet settings:
    wname = 'db4';
    n = 5;
% Denoising settings:
    delta = 0.5;
% Noise settings:
    sigma = 0.2;
    
% Normilize signal:
A_mean = mean(A(:));
A = A-A_mean;
A_var = var(A(:));
A = (A./sqrt(A_var));


% Adding the noise    

An = A + sigma.*randn(size(A));
    
    
% Ploting original and noisy images:
fig1 = figure();
snr = 10*log10(norm(A(:))^2/norm(An(:)-A(:))^2);
subplot(2,2,1)
colormap(cmap)
image(A_orig);
title('original picture')
subplot(2,2,2)
image(An.*sqrt(A_var)+A_mean);
%subplot(3,2,3:6)
%image(An-A);
title(['picture + noise, snr = ',num2str(snr)]);
% Denoising
[C,L] = wavedec2(An,n,wname);
% Hard denoisisg
C_hard = C.*(abs(C)>delta);
C_soft = (abs(C)>delta).*(sign(C).*(abs(C_hard)-delta));
[A_den_hard] = waverec2(C_hard,L,wname);
[A_den_soft] = waverec2(C_soft,L,wname);
% Plotting results;
figure(fig1);
subplot(2,2,3)
colormap(cmap)
snr_hard = 10*log10(norm(A(:))^2/norm(An(:)-A_den_hard(:))^2);
image(A_den_hard.*sqrt(A_var)+A_mean);
title(['hard thresholding, snr = ',num2str(snr_hard)]);
subplot(2,2,4)
snr_soft = 10*log10(norm(A(:))^2/norm(An(:)-A_den_soft(:))^2);
image(A_den_soft.*sqrt(A_var)+A_mean);
title(['soft thresholding, snr = ',num2str(snr_soft)]);
%%
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
dwtmode('sym'); % sym,per
wname = 'db5'; % bior4.4,haar,db1,db2
Nb_levels = 20;

t = wtree(A_dist,2,wname);
%plot(t)
%% Creating the treshold function
SoftThresh = @(x,T)x.*max( 0, 1-T./max(abs(x),1e-10) );
HardThresh = @(x,T) x .* (abs(x) >= T);
clf;
T = linspace(-1,1,1000);
%plot( T, SoftThresh(T,.5) );
%plot( T, HardThresh(T,.5) );
axis('equal');
%% Setting up the transformation
PsiS = @(f)wavedec2(f,Nb_levels,wname);
Psi = @(C,S)waverec2(C,S,wname);

%% Denoising test
%A_noise = randn(512)*20 +A;
%[C,S] = PsiS(A_noise);
%C = SoftThresh(C,20);
%colormap(cmap);
%A_denoise = Psi(C,S);
%subplot(1,2,1);
%image(A_noise)
%subplot(1,2,2);
%image(A_denoise)





