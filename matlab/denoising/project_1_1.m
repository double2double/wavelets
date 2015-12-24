% The project
close all
clear all
dwtmode('per')
addpath('../src/')

% Question 1.1



rng(1)

N = 2^8;
sigma = 0.1;

nj = randn(1,N);

for N_l=2:6;
f = @(x) exp(x);

xj = linspace(0,1,N);
fj = f(xj)+sigma.*nj;
    
% Computing the wavelet transform.
wname = 'db45';
[a,b]=wavedec(fj,N_l,wname);
fig1 = figure('position',[1000 1000 300 200]);
set(0,'DefaultFigureColor','remove')
plot(xj,a)
hold on
M = max(a);
m = min(a);
Mm = max(abs([M,m]))*2;
for i=1:numel(b)
    x=(1/2)^i;
    %%plot([x,x],[Mm,-Mm],'k--');
    plot([xj(b(i)),xj(b(i))],[Mm,-Mm],'k--');
end
axis([0,1,m,M])
xlabel('Coefficient','interpreter','Latex');
ylabel('Amplitude','interpreter','Latex');
title(['Amplitude van Coefficient voor \textit{',wname,'} wavelet'],'interpreter','Latex');

if (sigma==0)
    name=['plot/coef_exp_',wname,'_',num2str(N_l),'.eps'];
else
    name=['plot/coef_exp_',wname,'_',num2str(N_l),'_noise_',num2str(sigma*100),'.eps'];
end

exportfig(fig1,name,... 
    'FontSize',1.2,...
    'Bounds','loose',...
    'color','rgb');
fig2 = figure('position',[1000 1000 300 200]);
box on
f=0;
x_b=1;
f=0;

for i=1:numel(b)-1
    bi=b(i);
    x_e=x_b+b(i)-1;
    atemp=zeros(1,b(end));
    atemp(x_b:x_e)=a(x_b:x_e);
    fi=waverec(atemp,b,wname);
    hold on
    plot(xj,fi/2+i)
    f=fi+f;
    x_b=x_e+1;
end
    
xlabel('$$x$$','interpreter','Latex');
ylabel('$$f_i(x)$$','interpreter','Latex');
title(['MRA voorstelling van $$e^x$$ voor \textit{',wname,'} wavelet'],'interpreter','Latex');

if (sigma==0)
    name=['plot/MRA_exp_',wname,'_',num2str(N_l),'.eps'];
else
    name=['plot/MRA_exp_',wname,'_',num2str(N_l),'_noise_',num2str(sigma*100),'.eps'];
end

exportfig(fig2,name,... 
    'FontSize',1.2,...
    'Bounds','loose',...
    'color','rgb');
close all
end
%%

% With noise
fjn = fj + randn(1,N).*sigma;

SNR = 10 * log10(norm(fj)^2/norm(fj-fjn)^2);
disp(['SNR = ' ,num2str(SNR)]);

[an,bn]=wavedec(fjn,n,'db4');
subplot(1,2,2)
plot(an)
% Hard treshold
an_tres_hard = an.*(abs(an)>delta);
% Soft treshold
an_tres_soft = sign(an_tres_hard).*(abs(an_tres_hard)-delta);
% Plotting both signals
subplot(2,1,1);
plot(an_tres_hard)
subplot(2,1,2);
plot(an_tres_soft)
% Plotting the denoised signals
fj_tres_hard=waverec(an_tres_hard,bn,'db4');
fj_tres_soft=waverec(an_tres_soft,bn,'db4');
subplot(1,2,1);
hold off
plot(fjn)
hold on
plot(fj)
plot(fj_tres_hard,'k-');
subplot(1,2,2);
hold off
plot(fjn)
hold on
plot(fj)
plot(fj_tres_soft,'k-');




