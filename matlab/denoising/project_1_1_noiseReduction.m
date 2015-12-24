close all
clear all
dwtmode('per')
addpath('../src/')

% Question 1.1
SoftThresh  = @(x,T) x.*max( 0, 1-T./max(abs(x),1e-10) );
HardThresh  = @(x,T) x .* (abs(x) >= T);
SmootThresh = @(x,T) -x.*exp(-(x/T).^4)+x;
distance    = @(f,g) norm(f-g)/(sqrt(norm(f))*sqrt(norm(g)));


rng(1)
N = 2^8;
sigma = 0.1;
wname = 'db2';
T=0.2;
N_l=4;


nj = randn(1,N);
f = @(x) exp(x);

xj = linspace(0,1,N);

fj = f(xj)+sigma.*nj;


[a,b]=wavedec(fj,N_l,wname);


Trs = logspace(log10(0.01),log10(0.8),50);

er = zeros(3,numel(Trs));

i=1;



j=1;
for thresH=1:3
i=1;
for T=Trs


% Computing the wavelet transform.


switch thresH
    case 1
        threshold = @(C)SoftThresh(C,T);
    case 2
        threshold = @(C)HardThresh(C,T);
    case 3
        threshold = @(C)SmootThresh(C,T);
    otherwise
        error('thresholding kind unknown')
end

a_T = threshold(a);

f_rec = waverec(a_T,b,wname);


er(j,i)= norm(f_rec - f(xj))^2/(norm(f_rec)*norm(f(xj)));

hold off

plot(f_rec);
hold on
plot(f(xj));
pause(0.01);
title(num2str(er(j,i)));

i=i+1;
end



j=j+1;
end
%%
fig2 = figure('position',[1000 1000 300 200]);
box on
for j=1:3
    hold on
    semilogy(Trs,log10(er(j,:)))
end

xlabel('Threshold','interpreter','Latex');
ylabel('log Error','interpreter','Latex');
h=title(['Fout in functie van treshold \textit{',wname,'} wavelet'],'interpreter','Latex');
legend('soft','hard','smooth','Location','northwest');

%%
name=['plot/error_exp_',wname,'_',num2str(sigma*100),'.eps'];


exportfig(fig2,name,... 
    'FontSize',1.2,...
    'Bounds','loose',...
    'color','rgb');

%% Optimal result:

fig3 = figure('position',[1000 1000 300 200]);
a_T=SmootThresh(a,0.4);
f_rec = waverec(a_T,b,wname);
hold off
plot(xj,fj)
hold on
plot(xj,f_rec);
plot(xj,f(xj));
ylabel('$$f(x)$$','interpreter','Latex');
xlabel('$$x$$','interpreter','Latex');
h=title('Optimale ruisreductie','interpreter','Latex');
legend('ruisig','gefilterd','origineel','Location','northwest');


exportfig(fig3,'plot/Optimale_ruisReductie.eps',... 
    'FontSize',1.2,...
    'Bounds','loose',...
    'color','rgb');

%%
close all
fig4 = figure('position',[1000 1000 300 200]);
T = linspace(-20,20,100);
x = SoftThresh(T,5);
plot(T,x);
hold on
x=HardThresh(T,5);
plot(T,x);
x=SmootThresh(T,5);
plot(T,x);
legend('Soft','Hard','Smooth','Location','northwest');
title('Vorm van verschillende Threshold functies','interpreter','Latex');
exportfig(fig4,'plot/Threshold.eps',... 
    'FontSize',1.2,...
    'Bounds','loose',...
    'color','rgb');



