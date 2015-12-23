% testing the error plots for denoising

clear all
close all
% Image names : 
%       ./src/lena.gif
%       ./src/baboon.gif

[A_orig,cmap] = imread('../src/lena.gif');
A = double(A_orig);

% Normilize signal:
A_mean = mean(A(:));
A = A-A_mean;
A_var = var(A(:));
A = (A./sqrt(A_var));

wname = {'db6'}; % 'db4', 'haar'
Nb_levels = 10;
mode = 'per';
thres = {'soft','hard','smooth'}; % 'soft', 'hard' or 'smooth'

% Denoising settings:
    delta = 10.^linspace(-2,1,40);
    
% Noise settings:
    sigma = 0.2;
    A_noise = A + sigma.*randn(size(A)); % Adding the noise
    
A_origineel = A; % normalised picture as original picture

     
[rel_err] = err_plot_denoising(mode, thres, delta, wname, Nb_levels, A_origineel, A_noise);






