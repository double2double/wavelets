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
subplot(2,2,2)
image(An.*sqrt(A_var)+A_mean);
%subplot(3,2,3:6)
%image(An-A);
title(['snr = ',num2str(snr)]);
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
title(['snr = ',num2str(snr_hard)]);
subplot(2,2,4)
snr_soft = 10*log10(norm(A(:))^2/norm(An(:)-A_den_soft(:))^2);
image(A_den_soft.*sqrt(A_var)+A_mean);
title(['snr = ',num2str(snr_soft)]);





