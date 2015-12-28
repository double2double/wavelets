% testing the error plots for denoising

clear 
close all
addpath('../src/')
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
%A_noise = A + sigma.*randn(size(A)); % Adding the noise
A_noise = A+randn(size(A))*0.2;



A_origineel = A; % normalised picture as original picture

wname = {'db6'}; % 'db4', 'haar'
Nb_levels = 5;
mode = 'per';
thres = {'smooth'}; % 'soft', 'hard' or 'smooth'

costFun = @(delta) -err_plot_denoising(mode, thres, delta, wname, Nb_levels, A_origineel, A_noise,0);
costFun_sure = @(delta) 100*(sure_error(mode, thres, delta, wname, Nb_levels, sigma, A_noise,0));
[a,b] = fminunc(costFun,1);
[a_sure,b_sure] = fminunc(costFun_sure,0.5);

b_snr_sure =costFun(a_sure);


%plot_denoise(mode, thres, a, wname, Nb_levels, A_mean,A_var, A_noise,cmap)

% Vraag 1.6 Optimalisatie(zonder vals spelen) SURE
close all
thres = {'soft','hard','smooth'}; % 'soft', 'hard' or 'smooth'
costFun = @(delta) -err_plot_denoising(mode, thres, delta, wname, Nb_levels, A_origineel, A_noise,0);
costFun_sure = @(delta) 100*(sure_error(mode, thres, delta, wname, Nb_levels, sigma, A_noise,0));

aoeu=200;
T=linspace(0,2,aoeu);
cstT_snr = zeros(aoeu,numel(thres));
cstT_sure = zeros(aoeu,numel(thres));
for i=1:aoeu
    disp(i)
    cstT_sure(i,:) =costFun_sure(T(i));
    cstT_snr(i,:)  = costFun(T(i));
end
%%

close
fig1 = figure('position',[1000 1000 300 200]);
plot(T,cstT_sure);
xlabel('Coefficient','interpreter','Latex');
ylabel('Amplitude','interpreter','Latex');
title(['Waarde voor SURE cost functie, \textit{',wname,'} wavelet'],'interpreter','Latex');
legend('soft','hard','smooth')
exportfig(fig1,'plot/SURE_cost.eps',... 
    'FontSize',1.2,...
    'Bounds','loose',...
    'color','rgb');
fig2 = figure('position',[1000 1000 300 200]);
plot(T,cstT_snr);
xlabel('Coefficient','interpreter','Latex');
ylabel('Amplitude','interpreter','Latex');
title(['Waarde voor SNR cost functie, \textit{',wname,'} wavelet'],'interpreter','Latex');
legend('soft','hard','smooth')
exportfig(fig2,'plot/SURE_cost_snr.eps',... 
    'FontSize',1.2,...
    'Bounds','loose',...
    'color','rgb');



%%
close
fig3= figure('position',[1000 1000 300 200]);
plot_denoise(mode, thres, a, wname, Nb_levels, A_mean,A_var, A_noise,cmap)
title(['SNR=',num2str(b)])
%%
fig4 = figure('position',[1320 1000 300 200]);
plot_denoise(mode, thres, a_sure, wname, Nb_levels, A_mean,A_var, A_noise,cmap)
title(['SNR=',num2str(b_snr_sure)])
%[a,b] = fminunc(costFun,1);
%[a_sure,b_sure] = fminunc(costFun_sure,0.5);

%b_snr_sure =costFun(a_sure);




