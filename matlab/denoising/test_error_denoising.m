% testing the error plots for denoising

clear 
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
    delta = linspace(0,2,40);
    
% Noise settings:
    sigma = 0.2;
    A_noise = A + sigma.*randn(size(A)); % Adding the noise
    
A_origineel = A; % normalised picture as original picture

     
[rel_err] = err_plot_denoising(mode, thres, delta, wname, Nb_levels, A_origineel, A_noise,1);

%% Vraag 1.6 Optimalisatie(vals spelen)

clear 
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

% Noise settings:
    sigma = 0.2;
    A_noise = A + sigma.*randn(size(A)); % Adding the noise
    
A_origineel = A; % normalised picture as original picture

wname = {'bior6.8'}; % 'db4', 'haar'
Nb_levels = 5;
mode = 'per';
thres = {'smooth'}; % 'soft', 'hard' or 'smooth'

costFun = @(delta) -err_plot_denoising(mode, thres, delta, wname, Nb_levels, A_origineel, A_noise,0);

[a,b] = fminunc(costFun,1)
%% Vraag 1.6 Optimalisatie(zonder vals spelen) SURE




