%% Question 1.10
clear 
close all


SmootThresh = @(x,T) -x.*exp(-(x/T).^4)+x;
snr_image   = @(A,An) -20*log10( norm(A - An,'fro') / norm(A)); 

% Image names : 
%       ./src/lena.gif
%       ./src/baboon.gif

[A_orig,cmap] = imread('../src/lena.gif');
A = double(A_orig);

A_mean = mean(A(:));
A = A-A_mean;
A_var = var(A(:));
A = (A./sqrt(A_var));


wname = 'db2'; % 'db4', 'haar'
Nb_levels = 5;
mode = 'per';
thres = 'smooth';
sigma=0.1;

An =A;

An(1:10:end,:)=0; An(:,1:10:end)=0;

allT=linspace(0,2,100);

allErr=zeros(size(allT));


costFun = @(T) -snr_den(An,A,Nb_levels,wname,@(x) SmootThresh(x,T));

[a,b] =fminunc(costFun,0.2);

y = den_wst2(An,Nb_levels,wname,@(x) SmootThresh(x,a));

%%

colormap(cmap);
subplot(1,2,1)
image(An*sqrt(A_var)+A_mean)
title(num2str(snr_image(A,An)))
subplot(1,2,2)
image(y*sqrt(A_var)+A_mean)

title([num2str(-b)]);


