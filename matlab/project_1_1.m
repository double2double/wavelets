% The project
close all
clear all
dwtmode('per')



% Question 1.1
f = @(x) exp(x);
N = 100;
n = 5;
sigma= 0.01;        % Noise level;
delta = 0.4;           % Treshold level;
% No noise

xj = linspace(0,1,N);
fj = f(xj);

% Computing the wavelet transform.
[a,b]=wavedec(fj,n,'db4');
subplot(1,2,1)
plot(a)

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



